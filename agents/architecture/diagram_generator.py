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


class ArchitectureAgent:
    """Generates architecture diagrams from AVD specifications"""
    
    def __init__(self, spec: Dict[str, Any], output_dir: Path):
        self.spec = spec
        self.output_dir = output_dir
        self.spec_data = spec.get('spec', {})
        self.metadata = spec.get('metadata', {})
        
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
    
    def _build_mermaid_diagram(self) -> str:
        """Build the Mermaid diagram content"""
        lines = ["graph TB"]
        lines.append("    %% Azure Virtual Desktop Architecture")
        lines.append("")
        
        # User/Client layer
        lines.append("    Users[👥 AVD Users]")
        lines.append("")
        
        # Management plane
        lines.append("    subgraph AVDManagement[AVD Management Plane]")
        for hp in self.spec_data.get('hostPools', []):
            hp_name = hp.get('name', 'hostpool')
            hp_type = hp.get('type', 'Pooled')
            lines.append(f"        HP_{hp_name}[🖥️ Host Pool: {hp_name}<br/>Type: {hp_type}]")
            lines.append(f"        WS_{hp_name}[📱 Workspace]")
        lines.append("    end")
        lines.append("")
        
        # Compute layer
        lines.append("    subgraph Compute[Session Host Compute]")
        for hp in self.spec_data.get('hostPools', []):
            hp_name = hp.get('name', 'hostpool')
            count = hp.get('sessionHosts', {}).get('count', 0)
            vm_size = hp.get('sessionHosts', {}).get('vmSize', 'Standard_D4s_v5')
            lines.append(f"        SH_{hp_name}[💻 Session Hosts<br/>Count: {count}<br/>Size: {vm_size}]")
        lines.append("    end")
        lines.append("")
        
        # Networking layer
        networking = self.spec_data.get('networking', {})
        vnet_name = networking.get('vnet', {}).get('name', 'vnet-avd')
        lines.append("    subgraph Network[Networking]")
        lines.append(f"        VNet[🌐 VNet: {vnet_name}]")
        
        for subnet in networking.get('vnet', {}).get('subnets', []):
            subnet_name = subnet.get('name', 'subnet')
            lines.append(f"        Subnet_{subnet_name}[Subnet: {subnet_name}]")
        
        if networking.get('hubVnet', {}).get('enabled', False):
            lines.append("        HubVNet[🔗 Hub VNet Peering]")
        lines.append("    end")
        lines.append("")
        
        # Storage layer
        storage = self.spec_data.get('storage', {})
        if storage.get('fslogix', {}).get('enabled', True) or storage.get('appAttach', {}).get('enabled', False):
            lines.append("    subgraph Storage[Storage Services]")
            
            if storage.get('fslogix', {}).get('enabled', True):
                sku = storage.get('fslogix', {}).get('azureFiles', {}).get('sku', 'Premium_LRS')
                lines.append(f"        FSLogix[📁 FSLogix Profiles<br/>SKU: {sku}]")
            
            if storage.get('appAttach', {}).get('enabled', False):
                lines.append("        AppAttach[📦 App Attach Storage]")
            
            lines.append("    end")
            lines.append("")
        
        # Security layer
        security = self.spec_data.get('security', {})
        lines.append("    subgraph Security[Security Services]")
        lines.append("        KV[🔐 Key Vault]")
        
        if security.get('privateLink', {}).get('enabled', False):
            lines.append("        PE[🔒 Private Endpoints]")
        lines.append("    end")
        lines.append("")
        
        # Monitoring layer
        monitoring = self.spec_data.get('monitoring', {})
        if monitoring.get('logAnalytics', {}).get('enabled', True):
            lines.append("    subgraph Monitoring[Monitoring & Diagnostics]")
            lines.append("        LAW[📊 Log Analytics]")
            
            if monitoring.get('insights', {}).get('enabled', False):
                lines.append("        Insights[💡 AVD Insights]")
            
            if monitoring.get('alerts', {}).get('enabled', False):
                lines.append("        Alerts[🔔 Alerts]")
            lines.append("    end")
            lines.append("")
        
        # Connections
        lines.append("    %% User connections")
        lines.append("    Users -->|Connect| WS_" + self.spec_data.get('hostPools', [{}])[0].get('name', 'hostpool'))
        
        for hp in self.spec_data.get('hostPools', []):
            hp_name = hp.get('name', 'hostpool')
            lines.append(f"    WS_{hp_name} --> HP_{hp_name}")
            lines.append(f"    HP_{hp_name} --> SH_{hp_name}")
            lines.append(f"    SH_{hp_name} --> VNet")
        
        # Storage connections
        if storage.get('fslogix', {}).get('enabled', True):
            for hp in self.spec_data.get('hostPools', []):
                hp_name = hp.get('name', 'hostpool')
                lines.append(f"    SH_{hp_name} -.->|Profiles| FSLogix")
        
        # Security connections
        for hp in self.spec_data.get('hostPools', []):
            hp_name = hp.get('name', 'hostpool')
            lines.append(f"    SH_{hp_name} -.->|Secrets| KV")
        
        # Monitoring connections
        if monitoring.get('logAnalytics', {}).get('enabled', True):
            for hp in self.spec_data.get('hostPools', []):
                hp_name = hp.get('name', 'hostpool')
                lines.append(f"    SH_{hp_name} -.->|Logs| LAW")
        
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
