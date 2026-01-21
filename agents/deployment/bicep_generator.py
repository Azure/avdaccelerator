"""
Deployment Agent - Generates Infrastructure as Code

This agent converts AVD specifications into deployable IaC:
- Bicep templates
- Parameter files
- Deployment scripts
- Naming conventions (CAF compliant)
"""

from pathlib import Path
from typing import Dict, Any, List
import sys
import json
sys.path.append(str(Path(__file__).parent.parent))
from core.orchestrator import AgentResult, AgentType


class NamingService:
    """Generates CAF-compliant resource names"""
    
    # Resource type abbreviations per CAF
    ABBREVIATIONS = {
        'virtualNetwork': 'vnet',
        'subnet': 'snet',
        'networkSecurityGroup': 'nsg',
        'storageAccount': 'st',
        'keyVault': 'kv',
        'logAnalyticsWorkspace': 'law',
        'hostPool': 'vdpool',
        'workspace': 'vdws',
        'applicationGroup': 'vdag',
        'virtualMachine': 'vm',
        'networkInterface': 'nic',
        'disk': 'disk',
        'privateEndpoint': 'pe',
        'privateDnsZone': 'pdns'
    }
    
    def __init__(self, deployment_prefix: str, environment: str):
        self.prefix = deployment_prefix.lower()
        self.env = self._env_abbr(environment)
    
    def _env_abbr(self, env: str) -> str:
        """Get environment abbreviation"""
        mapping = {
            'dev': 'dev',
            'development': 'dev',
            'test': 'tst',
            'staging': 'stg',
            'production': 'prd',
            'prod': 'prd'
        }
        return mapping.get(env.lower(), env[:3].lower())
    
    def generate(self, resource_type: str, purpose: str = '', region: str = '', unique_suffix: str = '') -> str:
        """
        Generate CAF-compliant resource name.
        
        Format: {abbr}-{prefix}-{purpose}-{env}-{region}-{suffix}
        """
        abbr = self.ABBREVIATIONS.get(resource_type, resource_type[:4].lower())
        
        parts = [abbr]
        
        if self.prefix:
            parts.append(self.prefix)
        
        if purpose:
            parts.append(purpose.lower())
        
        if self.env:
            parts.append(self.env)
        
        if region:
            # Abbreviate region
            region_abbr = region.replace('east', 'e').replace('west', 'w').replace('central', 'c')
            parts.append(region_abbr)
        
        if unique_suffix:
            parts.append(unique_suffix)
        
        name = '-'.join(parts)
        
        # Handle storage account special naming (no dashes, lowercase, max 24 chars)
        if resource_type == 'storageAccount':
            name = ''.join(parts)[:24]
        
        return name


class DeploymentAgent:
    """Generates IaC from AVD specifications"""
    
    def __init__(self, spec: Dict[str, Any], output_dir: Path):
        self.spec = spec
        self.output_dir = output_dir
        self.spec_data = spec.get('spec', {})
        self.metadata = spec.get('metadata', {})
        
        # Initialize naming service
        prefix = self.spec_data.get('deploymentPrefix', 'AVD')
        env = self.metadata.get('environment', 'dev')
        self.naming = NamingService(prefix, env)
    
    def execute(self) -> AgentResult:
        """Execute the deployment agent"""
        artifacts = []
        messages = []
        errors = []
        
        try:
            # Generate main Bicep file
            bicep_path = self._generate_main_bicep()
            artifacts.append(bicep_path)
            messages.append("Generated main Bicep template")
            
            # Generate parameters file
            params_path = self._generate_parameters()
            artifacts.append(params_path)
            messages.append("Generated parameters file")
            
            # Generate deployment script
            script_path = self._generate_deployment_script()
            artifacts.append(script_path)
            messages.append("Generated deployment script")
            
            # Generate README
            readme_path = self._generate_readme()
            artifacts.append(readme_path)
            messages.append("Generated deployment README")
            
            return AgentResult(
                agent_type=AgentType.DEPLOYMENT,
                success=True,
                artifacts=artifacts,
                messages=messages,
                errors=[]
            )
            
        except Exception as e:
            return AgentResult(
                agent_type=AgentType.DEPLOYMENT,
                success=False,
                artifacts=artifacts,
                messages=messages,
                errors=[str(e)]
            )
    
    def _generate_main_bicep(self) -> Path:
        """Generate main Bicep template"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        output_path = self.output_dir / 'iac' / 'bicep' / 'main.bicep'
        
        bicep_content = self._build_bicep_template()
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write(bicep_content)
        
        return output_path
    
    def _build_bicep_template(self) -> str:
        """Build the main Bicep template"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        
        lines = [
            f"// AVD Deployment: {deployment_name}",
            f"// Generated from specification",
            f"// Environment: {self.metadata.get('environment')}",
            "",
            "targetScope = 'subscription'",
            "",
            "// ========== Parameters ==========",
            "",
            "@description('Primary Azure region for deployment')",
            f"param location string = '{self.metadata.get('region', 'eastus2')}'",
            "",
            "@description('Deployment prefix for resource naming')",
            f"param deploymentPrefix string = '{self.spec_data.get('deploymentPrefix', 'AVD')}'",
            "",
            "@description('Environment name')",
            f"param environment string = '{self.metadata.get('environment', 'dev')}'",
            "",
            "@description('Tags to apply to all resources')",
            "param tags object = " + json.dumps(self.spec_data.get('tags', {}), indent=2),
            "",
            "// ========== Variables ==========",
            "",
            f"var resourceGroupName = 'rg-${{deploymentPrefix}}-${{environment}}-${{location}}'",
            "",
            "// ========== Resource Group ==========",
            "",
            "resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {",
            "  name: resourceGroupName",
            "  location: location",
            "  tags: tags",
            "}",
            "",
        ]
        
        # Add networking module if creating new VNet
        if self.spec_data.get('networking', {}).get('createNew', True):
            lines.extend([
                "// ========== Networking ==========",
                "",
                "module networking 'modules/networking.bicep' = {",
                "  scope: rg",
                "  name: 'networking-deployment'",
                "  params: {",
                "    location: location",
                f"    vnetName: '{self._get_vnet_name()}'",
                f"    addressSpace: '{self.spec_data.get('networking', {}).get('vnet', {}).get('addressSpace', '10.100.0.0/16')}'",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Add storage module
        if self.spec_data.get('storage', {}).get('fslogix', {}).get('enabled', True):
            lines.extend([
                "// ========== Storage ==========",
                "",
                "module storage 'modules/storage.bicep' = {",
                "  scope: rg",
                "  name: 'storage-deployment'",
                "  params: {",
                "    location: location",
                f"    storageAccountName: '{self.naming.generate('storageAccount', 'fslogix')}'",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Add Key Vault module
        lines.extend([
            "// ========== Key Vault ==========",
            "",
            "module keyVault 'modules/keyvault.bicep' = {",
            "  scope: rg",
            "  name: 'keyvault-deployment'",
            "  params: {",
            "    location: location",
            f"    keyVaultName: '{self.naming.generate('keyVault', 'avd')}'",
            "    tags: tags",
            "  }",
            "}",
            "",
        ])
        
        # Add host pool module
        for hp in self.spec_data.get('hostPools', []):
            hp_name = hp.get('name', 'hostpool')
            lines.extend([
                f"// ========== Host Pool: {hp_name} ==========",
                "",
                f"module hostPool_{hp_name.replace('-', '_')} 'modules/hostpool.bicep' = {{",
                "  scope: rg",
                f"  name: 'hostpool-{hp_name}-deployment'",
                "  params: {",
                f"    location: '{hp.get('location', self.metadata.get('region'))}'",
                f"    hostPoolName: '{hp_name}'",
                f"    hostPoolType: '{hp.get('type', 'Pooled')}'",
                f"    loadBalancerType: '{hp.get('loadBalancerType', 'BreadthFirst')}'",
                f"    maxSessionLimit: {hp.get('maxSessionLimit', 10)}",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Add monitoring module
        if self.spec_data.get('monitoring', {}).get('logAnalytics', {}).get('enabled', True):
            lines.extend([
                "// ========== Monitoring ==========",
                "",
                "module monitoring 'modules/monitoring.bicep' = {",
                "  scope: rg",
                "  name: 'monitoring-deployment'",
                "  params: {",
                "    location: location",
                f"    logAnalyticsName: '{self.naming.generate('logAnalyticsWorkspace', 'avd')}'",
                f"    retentionInDays: {self.spec_data.get('monitoring', {}).get('logAnalytics', {}).get('retentionDays', 90)}",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Outputs
        lines.extend([
            "// ========== Outputs ==========",
            "",
            "output resourceGroupName string = rg.name",
            "output location string = location",
        ])
        
        return "\n".join(lines)
    
    def _get_vnet_name(self) -> str:
        """Get VNet name"""
        vnet_config = self.spec_data.get('networking', {}).get('vnet', {})
        if 'name' in vnet_config:
            return vnet_config['name']
        
        region = self.metadata.get('region', 'eastus2')
        return self.naming.generate('virtualNetwork', 'avd', region)
    
    def _generate_parameters(self) -> Path:
        """Generate parameters file"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        output_path = self.output_dir / 'iac' / 'bicep' / 'parameters.json'
        
        params = {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "location": {
                    "value": self.metadata.get('region', 'eastus2')
                },
                "deploymentPrefix": {
                    "value": self.spec_data.get('deploymentPrefix', 'AVD')
                },
                "environment": {
                    "value": self.metadata.get('environment', 'dev')
                },
                "tags": {
                    "value": self.spec_data.get('tags', {
                        "Environment": self.metadata.get('environment'),
                        "ManagedBy": "AVD-SpecDriven"
                    })
                }
            }
        }
        
        with open(output_path, 'w') as f:
            json.dump(params, f, indent=2)
        
        return output_path
    
    def _generate_deployment_script(self) -> Path:
        """Generate PowerShell deployment script"""
        output_path = self.output_dir / 'iac' / 'bicep' / 'deploy.ps1'
        
        script = f"""# AVD Deployment Script
# Generated from specification: {self.metadata.get('name')}

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [string]$Location = '{self.metadata.get('region', 'eastus2')}'
)

# Set subscription context
Write-Host "Setting subscription context..." -ForegroundColor Cyan
Set-AzContext -SubscriptionId $SubscriptionId

# Deploy
Write-Host "Deploying AVD infrastructure..." -ForegroundColor Cyan
$deployment = New-AzSubscriptionDeployment `
    -Name "avd-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')" `
    -Location $Location `
    -TemplateFile "./main.bicep" `
    -TemplateParameterFile "./parameters.json" `
    -Verbose

if ($deployment.ProvisioningState -eq 'Succeeded') {{
    Write-Host "✓ Deployment completed successfully!" -ForegroundColor Green
    
    Write-Host "`nDeployment Outputs:" -ForegroundColor Cyan
    $deployment.Outputs | Format-Table
}} else {{
    Write-Host "✗ Deployment failed!" -ForegroundColor Red
    exit 1
}}
"""
        
        with open(output_path, 'w') as f:
            f.write(script)
        
        return output_path
    
    def _generate_readme(self) -> Path:
        """Generate deployment README"""
        output_path = self.output_dir / 'iac' / 'bicep' / 'README.md'
        
        readme = f"""# AVD Deployment - {self.metadata.get('name')}

**Environment:** {self.metadata.get('environment')}  
**Region:** {self.metadata.get('region')}  
**Generated:** Auto-generated from specification

## Prerequisites

- Azure subscription with Owner permissions
- Azure PowerShell or Azure CLI installed
- Appropriate licenses for Azure Virtual Desktop

## Deployment

### Using PowerShell

```powershell
./deploy.ps1 -SubscriptionId "<your-subscription-id>"
```

### Using Azure CLI

```bash
az deployment sub create \\
  --location {self.metadata.get('region', 'eastus2')} \\
  --template-file main.bicep \\
  --parameters @parameters.json
```

## What Gets Deployed

This deployment creates:

"""
        
        # List resources
        resources = []
        
        resources.append("- **Resource Group** for all AVD resources")
        
        if self.spec_data.get('networking', {}).get('createNew'):
            resources.append("- **Virtual Network** with subnets")
        
        for hp in self.spec_data.get('hostPools', []):
            count = hp.get('sessionHosts', {}).get('count', 0)
            resources.append(f"- **Host Pool** ({hp.get('name')}) with {count} session hosts")
        
        if self.spec_data.get('storage', {}).get('fslogix', {}).get('enabled'):
            resources.append("- **Storage Account** for FSLogix profiles")
        
        resources.append("- **Key Vault** for secrets and keys")
        
        if self.spec_data.get('monitoring', {}).get('logAnalytics', {}).get('enabled'):
            resources.append("- **Log Analytics Workspace** for monitoring")
        
        readme += "\n".join(resources)
        
        readme += f"""

## Post-Deployment

After deployment:

1. Assign users to application groups
2. Configure FSLogix profile settings
3. Test AVD connectivity
4. Set up monitoring alerts
5. Configure backup policies

## Customization

To customize this deployment:

1. Edit `parameters.json` with your values
2. Modify `main.bicep` for structural changes
3. Update individual modules in `modules/` directory

## Cleanup

To remove all resources:

```powershell
Remove-AzResourceGroup -Name "rg-{self.spec_data.get('deploymentPrefix', 'AVD').lower()}-{self.metadata.get('environment', 'dev')}-{self.metadata.get('region', 'eastus2')}" -Force
```
"""
        
        with open(output_path, 'w') as f:
            f.write(readme)
        
        return output_path


def main():
    """Test the deployment agent"""
    import yaml
    
    if len(sys.argv) < 2:
        print("Usage: python bicep_generator.py <spec-file.yaml>")
        sys.exit(1)
    
    spec_path = Path(sys.argv[1])
    with open(spec_path, 'r') as f:
        spec = yaml.safe_load(f)
    
    output_dir = Path('./test-output')
    agent = DeploymentAgent(spec, output_dir)
    result = agent.execute()
    
    if result.success:
        print("✓ Deployment code generation successful!\n")
        print("Generated artifacts:")
        for artifact in result.artifacts:
            print(f"  - {artifact}")
    else:
        print("✗ Generation failed!")
        for error in result.errors:
            print(f"  Error: {error}")


if __name__ == '__main__':
    main()
