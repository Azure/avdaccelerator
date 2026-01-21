"""
Specification Parser and Validator

Parses AVD specifications and validates against the JSON schema.
"""

import json
import yaml
from pathlib import Path
from typing import Dict, Any, List, Tuple
from jsonschema import validate, ValidationError, Draft7Validator


class SpecificationParser:
    """Parses and validates AVD deployment specifications"""
    
    def __init__(self, schema_path: Path = None):
        """
        Initialize the parser.
        
        Args:
            schema_path: Path to JSON schema file. If None, uses default.
        """
        if schema_path is None:
            # Default schema path
            schema_path = Path(__file__).parent.parent.parent / 'specs' / 'schema' / 'avd-spec-v1.schema.json'
        
        with open(schema_path, 'r') as f:
            self.schema = json.load(f)
        
        self.validator = Draft7Validator(self.schema)
    
    def parse(self, spec_path: Path) -> Tuple[bool, Dict[str, Any], List[str]]:
        """
        Parse and validate a specification file.
        
        Args:
            spec_path: Path to specification YAML file
        
        Returns:
            Tuple of (is_valid, spec_dict, error_messages)
        """
        try:
            # Load YAML
            with open(spec_path, 'r') as f:
                spec = yaml.safe_load(f)
            
            # Validate against schema
            errors = list(self.validator.iter_errors(spec))
            
            if errors:
                error_messages = [f"{e.json_path}: {e.message}" for e in errors]
                return False, spec, error_messages
            
            return True, spec, []
            
        except Exception as e:
            return False, {}, [str(e)]
    
    def get_deployment_summary(self, spec: Dict[str, Any]) -> Dict[str, Any]:
        """
        Extract key deployment information from spec.
        
        Args:
            spec: Parsed specification dictionary
        
        Returns:
            Dictionary with deployment summary
        """
        metadata = spec.get('metadata', {})
        spec_data = spec.get('spec', {})
        
        # Count host pools and session hosts
        host_pools = spec_data.get('hostPools', [])
        total_session_hosts = sum(
            hp.get('sessionHosts', {}).get('count', 0)
            for hp in host_pools
        )
        
        # Get networking info
        networking = spec_data.get('networking', {})
        create_new_vnet = networking.get('createNew', True)
        
        # Get storage info
        storage = spec_data.get('storage', {})
        fslogix_enabled = storage.get('fslogix', {}).get('enabled', True)
        appattach_enabled = storage.get('appAttach', {}).get('enabled', False)
        
        # Get security info
        security = spec_data.get('security', {})
        private_link = security.get('privateLink', {}).get('enabled', False)
        encryption_at_host = security.get('encryption', {}).get('encryptionAtHost', False)
        
        return {
            'name': metadata.get('name'),
            'environment': metadata.get('environment'),
            'region': metadata.get('region'),
            'identity_provider': spec_data.get('identity', {}).get('provider'),
            'host_pool_count': len(host_pools),
            'total_session_hosts': total_session_hosts,
            'create_new_vnet': create_new_vnet,
            'fslogix_enabled': fslogix_enabled,
            'appattach_enabled': appattach_enabled,
            'private_link_enabled': private_link,
            'encryption_at_host': encryption_at_host,
        }
    
    def get_resource_list(self, spec: Dict[str, Any]) -> List[Dict[str, str]]:
        """
        Generate a list of Azure resources that will be created.
        
        Args:
            spec: Parsed specification dictionary
        
        Returns:
            List of resource dictionaries with type and name
        """
        resources = []
        spec_data = spec.get('spec', {})
        deployment_prefix = spec_data.get('deploymentPrefix', 'AVD')
        
        # Host pools
        for hp in spec_data.get('hostPools', []):
            resources.append({
                'type': 'Microsoft.DesktopVirtualization/hostPools',
                'name': hp.get('name'),
                'description': f"{hp.get('type')} host pool"
            })
            
            # Session hosts
            count = hp.get('sessionHosts', {}).get('count', 0)
            for i in range(1, count + 1):
                resources.append({
                    'type': 'Microsoft.Compute/virtualMachines',
                    'name': f"{hp.get('name')}-{i:02d}",
                    'description': 'AVD session host VM'
                })
        
        # Virtual Network
        if spec_data.get('networking', {}).get('createNew', True):
            resources.append({
                'type': 'Microsoft.Network/virtualNetworks',
                'name': spec_data.get('networking', {}).get('vnet', {}).get('name', f'vnet-{deployment_prefix}'),
                'description': 'Virtual network for AVD'
            })
        
        # Storage accounts
        if spec_data.get('storage', {}).get('fslogix', {}).get('enabled', True):
            resources.append({
                'type': 'Microsoft.Storage/storageAccounts',
                'name': f"st{deployment_prefix.lower()}fslogix",
                'description': 'FSLogix profile storage'
            })
        
        if spec_data.get('storage', {}).get('appAttach', {}).get('enabled', False):
            resources.append({
                'type': 'Microsoft.Storage/storageAccounts',
                'name': f"st{deployment_prefix.lower()}appattach",
                'description': 'App Attach storage'
            })
        
        # Key Vault
        resources.append({
            'type': 'Microsoft.KeyVault/vaults',
            'name': f"kv-{deployment_prefix.lower()}",
            'description': 'Secrets and encryption keys'
        })
        
        # Log Analytics
        if spec_data.get('monitoring', {}).get('logAnalytics', {}).get('enabled', True):
            resources.append({
                'type': 'Microsoft.OperationalInsights/workspaces',
                'name': f"law-{deployment_prefix.lower()}",
                'description': 'Log Analytics workspace'
            })
        
        return resources


def main():
    """Test the parser"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python spec_parser.py <spec-file.yaml>")
        sys.exit(1)
    
    parser = SpecificationParser()
    spec_path = Path(sys.argv[1])
    
    is_valid, spec, errors = parser.parse(spec_path)
    
    if is_valid:
        print("✓ Specification is valid!\n")
        summary = parser.get_deployment_summary(spec)
        
        print("Deployment Summary:")
        print(f"  Name: {summary['name']}")
        print(f"  Environment: {summary['environment']}")
        print(f"  Region: {summary['region']}")
        print(f"  Identity: {summary['identity_provider']}")
        print(f"  Host Pools: {summary['host_pool_count']}")
        print(f"  Session Hosts: {summary['total_session_hosts']}")
        
        print("\nResources to be created:")
        resources = parser.get_resource_list(spec)
        for resource in resources:
            print(f"  - {resource['type']}: {resource['name']}")
    else:
        print("✗ Specification validation failed!\n")
        print("Errors:")
        for error in errors:
            print(f"  - {error}")
        sys.exit(1)


if __name__ == '__main__':
    main()
