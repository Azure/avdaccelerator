"""
Architecture Agent - Generates architecture diagrams and topology

This agent analyzes the AVD specification and generates:
- Mermaid diagrams (for markdown/web)
- Architecture topology documentation
- Resource dependency graphs
"""

from pathlib import Path
from typing import Dict, Any, List
import sys
sys.path.append(str(Path(__file__).parent.parent))
from core.orchestrator import AgentResult, AgentType


# AVD Accelerator Baseline Architecture Defaults
# Based on: workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
BASELINE_ARCHITECTURE_DEFAULTS = {
    'hostPool': {
        'type': 'Pooled',
        'loadBalancerType': 'BreadthFirst',
        'maxSessionLimit': 8,
        'preferredAppGroupType': 'Desktop',
        'publicNetworkAccess': 'Enabled',
        'startVMOnConnect': True,
        'rdpProperties': 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2'
    },
    'sessionHosts': {
        'count': 1,
        'vmSize': 'Standard_D4ads_v5',
        'diskType': 'Premium_LRS',
        'imageOffer': 'Office-365',
        'imageSku': 'win11-24h2-avd-m365',
        'acceleratedNetworking': True,
        'securityType': 'TrustedLaunch',
        'secureBoot': True,
        'vTpm': True
    },
    'networking': {
        'createNew': True,
        'addressSpace': '10.10.0.0/16',
        'avdSubnetPrefix': '10.10.1.0/24',
        'privateEndpointSubnetPrefix': '10.10.2.0/27',
        'deployDDoSProtection': False,
        'deployPrivateEndpoints': True
    },
    'storage': {
        'fslogix': {
            'enabled': True,
            'performance': 'Premium',
            'quotaSizeGB': 1,
            'zoneRedundant': False
        },
        'appAttach': {
            'enabled': False,
            'performance': 'Premium',
            'quotaSizeGB': 1
        }
    },
    'security': {
        'deployPrivateEndpoints': True,
        'createPrivateDnsZones': True,
        'diskZeroTrust': False,
        'encryptionKeyExpirationDays': 60
    },
    'monitoring': {
        'enabled': False,
        'deployLogAnalytics': True,
        'retentionDays': 90,
        'deployCustomPolicies': False
    },
    'identity': {
        'provider': 'ADDS',
        'intuneEnrollment': False
    },
    'scaling': {
        'enabled': True
    }
}


class ArchitectureAgent:
    """Generates architecture diagrams from AVD specifications
    
    Uses AVD Accelerator Baseline Architecture as default reference:
    workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
    """
    
    def __init__(self, spec: Dict[str, Any], output_dir: Path):
        self.spec = spec
        self.output_dir = output_dir
        self.spec_data = spec.get('spec', {})
        self.metadata = spec.get('metadata', {})
        self.defaults = BASELINE_ARCHITECTURE_DEFAULTS
        
    def execute(self) -> AgentResult:
        """Execute the architecture agent"""
        artifacts = []
        messages = []
        errors = []
        
        try:
            # Generate Mermaid diagram
            mermaid_path = self._generate_mermaid_diagram()
            artifacts.append(mermaid_path)
            messages.append("Generated Mermaid architecture diagram")
            
            # Generate topology documentation
            topology_path = self._generate_topology_doc()
            artifacts.append(topology_path)
            messages.append("Generated topology documentation")
            
            # Generate resource dependency graph
            deps_path = self._generate_dependency_graph()
            artifacts.append(deps_path)
            messages.append("Generated resource dependency graph")
            
            return AgentResult(
                agent_type=AgentType.ARCHITECTURE,
                success=True,
                artifacts=artifacts,
                messages=messages,
                errors=[]
            )
            
        except Exception as e:
            return AgentResult(
                agent_type=AgentType.ARCHITECTURE,
                success=False,
                artifacts=artifacts,
                messages=messages,
                errors=[str(e)]
            )
    
    def _generate_mermaid_diagram(self) -> Path:
        """Generate Mermaid architecture diagram"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        output_path = self.output_dir / 'architecture' / 'diagrams' / f'{deployment_name}-architecture.mmd'
        
        # Build Mermaid diagram
        diagram = self._build_mermaid_diagram()
        
        # Write to file
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write(diagram)
        
        # Also create a markdown version with the diagram
        md_path = output_path.with_suffix('.md')
        with open(md_path, 'w') as f:
            f.write(f"# {deployment_name} - Architecture Diagram\n\n")
            f.write(f"**Environment:** {self.metadata.get('environment', 'N/A')}\n\n")
            f.write(f"**Region:** {self.metadata.get('region', 'N/A')}\n\n")
            f.write("```mermaid\n")
            f.write(diagram)
            f.write("\n```\n")
        
        return output_path
    
    def _get_spec_value(self, path: str, default_path: str = None):
        """Get value from spec with fallback to baseline defaults"""
        parts = path.split('.')
        value = self.spec_data
        for part in parts:
            if isinstance(value, dict):
                value = value.get(part)
            else:
                value = None
                break
        
        if value is None and default_path:
            default_parts = default_path.split('.')
            value = self.defaults
            for part in default_parts:
                if isinstance(value, dict):
                    value = value.get(part)
                else:
                    value = None
                    break
        
        return value
    
    def _build_mermaid_diagram(self) -> str:
        """Build the Mermaid diagram content based on AVD Accelerator Baseline Architecture
        
        Reference: workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
        """
        lines = ["graph TB"]
        lines.append("    %% Azure Virtual Desktop - AVD Accelerator Baseline Architecture")
        lines.append("    %% Reference: avd-accelerator-baseline-architecture.vsdx")
        lines.append("")
        
        # User/Client layer
        lines.append("    Users[👥 AVD Users]")
        lines.append("")
        
        # Management plane - aligned with baseline architecture
        lines.append("    subgraph AVDManagement[AVD Management Plane]")
        host_pools = self.spec_data.get('hostPools', [{}])
        if not host_pools:
            host_pools = [{}]
        for hp in host_pools:
            hp_name = hp.get('name', 'vdpool-avd')
            hp_type = hp.get('type', self.defaults['hostPool']['type'])
            load_balancer = hp.get('loadBalancerType', self.defaults['hostPool']['loadBalancerType'])
            max_sessions = hp.get('maxSessionLimit', self.defaults['hostPool']['maxSessionLimit'])
            lines.append(f"        HP_{hp_name}[🖥️ Host Pool: {hp_name}<br/>Type: {hp_type}<br/>LB: {load_balancer}<br/>MaxSessions: {max_sessions}]")
            lines.append(f"        WS_{hp_name}[📱 Workspace]")
            lines.append(f"        AG_{hp_name}[📋 Application Group<br/>Desktop]")
            if self.defaults['scaling']['enabled']:
                lines.append(f"        SP_{hp_name}[⚖️ Scaling Plan]")
        lines.append("    end")
        lines.append("")
        
        # Compute layer - aligned with baseline architecture
        lines.append("    subgraph Compute[Session Host Compute]")
        for hp in host_pools:
            hp_name = hp.get('name', 'vdpool-avd')
            sh_config = hp.get('sessionHosts', {})
            count = sh_config.get('count', self.defaults['sessionHosts']['count'])
            vm_size = sh_config.get('vmSize', self.defaults['sessionHosts']['vmSize'])
            disk_type = sh_config.get('diskType', self.defaults['sessionHosts']['diskType'])
            security_type = self.defaults['sessionHosts']['securityType']
            accel_net = sh_config.get('acceleratedNetworking', self.defaults['sessionHosts']['acceleratedNetworking'])
            lines.append(f"        SH_{hp_name}[💻 Session Hosts<br/>Count: {count}<br/>Size: {vm_size}<br/>Disk: {disk_type}<br/>Security: {security_type}<br/>AccelNet: {accel_net}]")
            # Management VM for domain join operations
            lines.append(f"        MGMT_{hp_name}[🔧 Management VM<br/>Domain Join Operations]")
        lines.append("    end")
        lines.append("")
        
        # Networking layer - aligned with baseline architecture
        networking = self.spec_data.get('networking', {})
        vnet_config = networking.get('vnet', {})
        vnet_name = vnet_config.get('name', 'vnet-avd')
        address_space = vnet_config.get('addressSpace', self.defaults['networking']['addressSpace'])
        
        lines.append("    subgraph Network[Networking]")
        lines.append(f"        VNet[🌐 VNet: {vnet_name}<br/>Address: {address_space}]")
        
        # Default subnets per baseline architecture
        subnets = vnet_config.get('subnets', [])
        if not subnets:
            # Use baseline defaults
            lines.append(f"        Subnet_AVD[📍 AVD Subnet<br/>{self.defaults['networking']['avdSubnetPrefix']}]")
            lines.append(f"        Subnet_PE[📍 Private Endpoint Subnet<br/>{self.defaults['networking']['privateEndpointSubnetPrefix']}]")
        else:
            for subnet in subnets:
                subnet_name = subnet.get('name', 'subnet')
                subnet_prefix = subnet.get('addressPrefix', '')
                lines.append(f"        Subnet_{subnet_name}[📍 {subnet_name}<br/>{subnet_prefix}]")
        
        # NSGs per baseline architecture
        lines.append("        NSG_AVD[🛡️ NSG: AVD Subnet]")
        lines.append("        NSG_PE[🛡️ NSG: PE Subnet]")
        
        # Route tables
        lines.append("        RT_AVD[🔀 Route Table: AVD]")
        lines.append("        RT_PE[🔀 Route Table: PE]")
        
        if networking.get('hubVnet', {}).get('enabled', False):
            lines.append("        HubVNet[🔗 Hub VNet Peering<br/>Gateway Transit]")
        lines.append("    end")
        lines.append("")
        
        # Storage layer - aligned with baseline architecture
        storage = self.spec_data.get('storage', {})
        fslogix_config = storage.get('fslogix', {})
        fslogix_enabled = fslogix_config.get('enabled', self.defaults['storage']['fslogix']['enabled'])
        appattach_config = storage.get('appAttach', {})
        appattach_enabled = appattach_config.get('enabled', self.defaults['storage']['appAttach']['enabled'])
        
        if fslogix_enabled or appattach_enabled:
            lines.append("    subgraph Storage[Storage Services]")
            
            if fslogix_enabled:
                performance = fslogix_config.get('performance', self.defaults['storage']['fslogix']['performance'])
                quota = fslogix_config.get('quotaSizeGB', self.defaults['storage']['fslogix']['quotaSizeGB'])
                zone_redundant = self.defaults['storage']['fslogix']['zoneRedundant']
                storage_type = 'ZRS' if zone_redundant else 'LRS'
                lines.append(f"        FSLogix[📁 FSLogix Profiles<br/>Azure Files {performance}<br/>Quota: {quota}GB<br/>Redundancy: {storage_type}]")
            
            if appattach_enabled:
                app_performance = appattach_config.get('performance', self.defaults['storage']['appAttach']['performance'])
                lines.append(f"        AppAttach[📦 App Attach Storage<br/>Azure Files {app_performance}]")
            
            lines.append("    end")
            lines.append("")
        
        # Security layer - aligned with baseline architecture
        security = self.spec_data.get('security', {})
        deploy_pe = security.get('deployPrivateEndpoints', self.defaults['security']['deployPrivateEndpoints'])
        create_dns_zones = security.get('createPrivateDnsZones', self.defaults['security']['createPrivateDnsZones'])
        disk_zero_trust = security.get('diskZeroTrust', self.defaults['security']['diskZeroTrust'])
        key_expiration = self.defaults['security']['encryptionKeyExpirationDays']
        
        lines.append("    subgraph Security[Security Services]")
        lines.append(f"        KV[🔐 Key Vault<br/>Key Expiration: {key_expiration} days]")
        
        if deploy_pe:
            lines.append("        PE_KV[🔒 Private Endpoint<br/>Key Vault]")
            lines.append("        PE_Storage[🔒 Private Endpoint<br/>Azure Files]")
        
        if create_dns_zones:
            lines.append("        DNS_Files[🌐 Private DNS Zone<br/>privatelink.file.core.windows.net]")
            lines.append("        DNS_Vault[🌐 Private DNS Zone<br/>privatelink.vaultcore.azure.net]")
        
        if disk_zero_trust:
            lines.append("        ZT_Disk[🛡️ Zero Trust Disk<br/>Double Encryption + CMK]")
        
        # Trusted Launch security (baseline default)
        lines.append(f"        TL[🔐 Trusted Launch<br/>SecureBoot: {self.defaults['sessionHosts']['secureBoot']}<br/>vTPM: {self.defaults['sessionHosts']['vTpm']}]")
        
        lines.append("    end")
        lines.append("")
        
        # Monitoring layer - aligned with baseline architecture
        monitoring = self.spec_data.get('monitoring', {})
        monitoring_enabled = monitoring.get('enabled', self.defaults['monitoring']['enabled'])
        deploy_law = monitoring.get('deployLogAnalytics', self.defaults['monitoring']['deployLogAnalytics'])
        retention_days = monitoring.get('retentionDays', self.defaults['monitoring']['retentionDays'])
        deploy_custom_policies = monitoring.get('deployCustomPolicies', self.defaults['monitoring']['deployCustomPolicies'])
        
        if deploy_law or monitoring_enabled:
            lines.append("    subgraph Monitoring[Monitoring & Diagnostics]")
            lines.append(f"        LAW[📊 Log Analytics Workspace<br/>Retention: {retention_days} days]")
            
            if monitoring.get('insights', {}).get('enabled', False):
                lines.append("        Insights[💡 AVD Insights<br/>Performance Counters]")
            
            if monitoring.get('alerts', {}).get('enabled', False):
                lines.append("        Alerts[🔔 Alerts<br/>Action Groups]")
            
            if deploy_custom_policies:
                lines.append("        Policies[📜 Custom Monitoring Policies<br/>DeployIfNotExists]")
            
            # Diagnostic settings per baseline
            lines.append("        Diag[📋 Diagnostic Settings<br/>All AVD Resources]")
            
            lines.append("    end")
            lines.append("")
        
        # Connections - aligned with baseline architecture flow
        lines.append("    %% User connections (AVD Accelerator Baseline Architecture)")
        first_hp_name = host_pools[0].get('name', 'vdpool-avd')
        lines.append(f"    Users -->|RDP/HTTPS| WS_{first_hp_name}")
        
        for hp in host_pools:
            hp_name = hp.get('name', 'vdpool-avd')
            lines.append(f"    WS_{hp_name} --> AG_{hp_name}")
            lines.append(f"    AG_{hp_name} --> HP_{hp_name}")
            lines.append(f"    HP_{hp_name} --> SH_{hp_name}")
            lines.append(f"    SH_{hp_name} --> VNet")
            if self.defaults['scaling']['enabled']:
                lines.append(f"    SP_{hp_name} -.->|Scale| HP_{hp_name}")
        
        # Network connections
        if not subnets:
            lines.append("    VNet --> Subnet_AVD")
            lines.append("    VNet --> Subnet_PE")
            lines.append("    Subnet_AVD --> NSG_AVD")
            lines.append("    Subnet_PE --> NSG_PE")
            lines.append("    Subnet_AVD --> RT_AVD")
            lines.append("    Subnet_PE --> RT_PE")
        
        # Storage connections
        if fslogix_enabled:
            for hp in host_pools:
                hp_name = hp.get('name', 'vdpool-avd')
                lines.append(f"    SH_{hp_name} -.->|FSLogix Profiles| FSLogix")
        
        # Security connections
        for hp in host_pools:
            hp_name = hp.get('name', 'vdpool-avd')
            lines.append(f"    SH_{hp_name} -.->|Secrets/Certs| KV")
            lines.append(f"    MGMT_{hp_name} -.->|Domain Join| SH_{hp_name}")
        
        # Private endpoint connections
        if deploy_pe:
            lines.append("    PE_KV --> KV")
            lines.append("    PE_Storage --> FSLogix")
            if create_dns_zones:
                lines.append("    PE_KV --> DNS_Vault")
                lines.append("    PE_Storage --> DNS_Files")
        
        # Monitoring connections
        if deploy_law or monitoring_enabled:
            for hp in host_pools:
                hp_name = hp.get('name', 'vdpool-avd')
                lines.append(f"    SH_{hp_name} -.->|Diagnostics| LAW")
                lines.append(f"    HP_{hp_name} -.->|Diagnostics| LAW")
            lines.append("    KV -.->|Diagnostics| LAW")
            if fslogix_enabled:
                lines.append("    FSLogix -.->|Diagnostics| LAW")
        
        # Hub VNet peering
        if networking.get('hubVnet', {}).get('enabled', False):
            lines.append("    VNet <-.->|Peering| HubVNet")
        
        # Styling
        lines.append("")
        lines.append("    classDef mgmt fill:#0078D4,stroke:#004578,color:#fff")
        lines.append("    classDef compute fill:#50E6FF,stroke:#0078D4,color:#000")
        lines.append("    classDef storage fill:#FFA500,stroke:#CC8400,color:#000")
        lines.append("    classDef security fill:#FF6B6B,stroke:#CC5555,color:#fff")
        lines.append("    classDef monitoring fill:#4CAF50,stroke:#388E3C,color:#fff")
        
        return "\n".join(lines)
    
    def _generate_topology_doc(self) -> Path:
        """Generate topology documentation"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        output_path = self.output_dir / 'architecture' / 'topology' / f'{deployment_name}-topology.md'
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w') as f:
            f.write(f"# {deployment_name} - AVD Topology\n\n")
            
            # Overview
            f.write("## Overview\n\n")
            f.write(f"**Environment:** {self.metadata.get('environment')}\n\n")
            f.write(f"**Primary Region:** {self.metadata.get('region')}\n\n")
            f.write(f"**Identity Provider:** {self.spec_data.get('identity', {}).get('provider')}\n\n")
            
            # Host Pools
            f.write("## Host Pools\n\n")
            for hp in self.spec_data.get('hostPools', []):
                f.write(f"### {hp.get('name')}\n\n")
                f.write(f"- **Type:** {hp.get('type')}\n")
                f.write(f"- **Location:** {hp.get('location')}\n")
                f.write(f"- **Load Balancer:** {hp.get('loadBalancerType', 'BreadthFirst')}\n")
                
                if hp.get('type') == 'Pooled':
                    f.write(f"- **Max Sessions:** {hp.get('maxSessionLimit', 'N/A')}\n")
                
                # Session hosts
                sh = hp.get('sessionHosts', {})
                f.write(f"- **Session Hosts:**\n")
                f.write(f"  - Count: {sh.get('count')}\n")
                f.write(f"  - VM Size: {sh.get('vmSize')}\n")
                f.write(f"  - Disk Type: {sh.get('diskType', 'Premium_LRS')}\n")
                f.write(f"  - Image Source: {sh.get('imageSource', 'marketplace')}\n")
                f.write("\n")
            
            # Networking
            f.write("## Networking\n\n")
            networking = self.spec_data.get('networking', {})
            vnet = networking.get('vnet', {})
            
            f.write(f"- **VNet Name:** {vnet.get('name', 'N/A')}\n")
            f.write(f"- **Address Space:** {vnet.get('addressSpace', 'N/A')}\n")
            
            if vnet.get('subnets'):
                f.write("- **Subnets:**\n")
                for subnet in vnet.get('subnets', []):
                    f.write(f"  - {subnet.get('name')}: {subnet.get('addressPrefix')}\n")
            
            if networking.get('hubVnet', {}).get('enabled'):
                f.write(f"\n- **Hub VNet Peering:** Enabled\n")
            
            f.write("\n")
            
            # Storage
            f.write("## Storage\n\n")
            storage = self.spec_data.get('storage', {})
            
            if storage.get('fslogix', {}).get('enabled'):
                f.write("### FSLogix Profiles\n\n")
                fslogix = storage.get('fslogix', {})
                f.write(f"- **Storage Type:** {fslogix.get('storageType', 'AzureFiles')}\n")
                
                if fslogix.get('storageType') == 'AzureFiles':
                    af = fslogix.get('azureFiles', {})
                    f.write(f"- **SKU:** {af.get('sku', 'Premium_LRS')}\n")
                    f.write(f"- **Quota:** {af.get('quota', '1024')} GB\n")
                    f.write(f"- **Private Endpoint:** {af.get('privateEndpoint', True)}\n")
                f.write("\n")
            
            if storage.get('appAttach', {}).get('enabled'):
                f.write("### App Attach\n\n")
                f.write(f"- **Storage Type:** {storage.get('appAttach', {}).get('storageType')}\n\n")
            
            # Security
            f.write("## Security\n\n")
            security = self.spec_data.get('security', {})
            
            encryption = security.get('encryption', {})
            f.write(f"- **Encryption at Host:** {encryption.get('encryptionAtHost', False)}\n")
            f.write(f"- **Trusted Launch:** {security.get('trustedLaunch', False)}\n")
            f.write(f"- **Confidential VM:** {security.get('confidentialVm', False)}\n")
            
            pl = security.get('privateLink', {})
            f.write(f"- **Private Link:** {pl.get('enabled', False)}\n")
            f.write("\n")
            
            # Monitoring
            f.write("## Monitoring\n\n")
            monitoring = self.spec_data.get('monitoring', {})
            
            if monitoring.get('logAnalytics', {}).get('enabled'):
                law = monitoring.get('logAnalytics', {})
                f.write(f"- **Log Analytics:** Enabled\n")
                f.write(f"  - Retention: {law.get('retentionDays', 90)} days\n")
            
            f.write(f"- **AVD Insights:** {monitoring.get('insights', {}).get('enabled', False)}\n")
            f.write(f"- **Alerts:** {monitoring.get('alerts', {}).get('enabled', False)}\n")
        
        return output_path
    
    def _generate_dependency_graph(self) -> Path:
        """Generate resource dependency graph"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        output_path = self.output_dir / 'architecture' / 'diagrams' / f'{deployment_name}-dependencies.mmd'
        
        lines = ["graph LR"]
        lines.append("    %% Resource Dependencies")
        lines.append("")
        
        # Key Vault must be created first
        lines.append("    KV[Key Vault] --> ST[Storage Accounts]")
        lines.append("    KV --> VM[Session Hosts]")
        
        # VNet before VMs
        lines.append("    VNet[Virtual Network] --> VM")
        
        # Storage before VMs
        lines.append("    ST --> VM")
        
        # Host pool can be created in parallel
        lines.append("    HP[Host Pools] --> VM")
        
        # Monitoring can be created anytime
        lines.append("    LAW[Log Analytics] -.-> VM")
        lines.append("    LAW -.-> HP")
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, 'w') as f:
            f.write("\n".join(lines))
        
        return output_path


def main():
    """Test the architecture agent"""
    import yaml
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python diagram_generator.py <spec-file.yaml>")
        sys.exit(1)
    
    spec_path = Path(sys.argv[1])
    with open(spec_path, 'r') as f:
        spec = yaml.safe_load(f)
    
    output_dir = Path('./test-output')
    agent = ArchitectureAgent(spec, output_dir)
    result = agent.execute()
    
    if result.success:
        print("✓ Architecture generation successful!\n")
        print("Generated artifacts:")
        for artifact in result.artifacts:
            print(f"  - {artifact}")
    else:
        print("✗ Architecture generation failed!")
        for error in result.errors:
            print(f"  Error: {error}")


if __name__ == '__main__':
    main()
