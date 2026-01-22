"""
Deployment Advisor Chat Agent

An interactive agent that guides users through AVD deployment parameter selection,
providing recommendations and default values based on the AVD Accelerator Baseline.

Reference: workload/bicep/deploy-baseline.bicep
"""

from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum
import json
import sys

# Optional yaml import - will use json fallback if not available
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

# Try to import from core, but make it optional for standalone use
try:
    sys.path.append(str(Path(__file__).parent.parent))
    from core.orchestrator import AgentResult, AgentType
except ImportError:
    # Define minimal types for standalone use
    class AgentType(Enum):
        CHAT_ADVISOR = "chat_advisor"
    
    @dataclass
    class AgentResult:
        agent_type: AgentType
        success: bool
        artifacts: List[Path]
        messages: List[str]
        errors: List[str]


class ConversationStage(Enum):
    """Stages of the deployment advisor conversation"""
    WELCOME = "welcome"
    BASICS = "basics"
    IDENTITY = "identity"
    HOST_POOL = "host_pool"
    SESSION_HOSTS = "session_hosts"
    NETWORKING = "networking"
    STORAGE = "storage"
    SECURITY = "security"
    MONITORING = "monitoring"
    REVIEW = "review"
    COMPLETE = "complete"


@dataclass
class ParameterInfo:
    """Information about a deployment parameter"""
    name: str
    description: str
    default: Any
    allowed_values: Optional[List[Any]] = None
    min_value: Optional[int] = None
    max_value: Optional[int] = None
    required: bool = False
    recommendation: str = ""
    category: str = ""


@dataclass 
class UserSelection:
    """User's selected parameters"""
    parameters: Dict[str, Any] = field(default_factory=dict)
    stage: ConversationStage = ConversationStage.WELCOME
    

# =============================================================================
# AVD Accelerator Baseline Parameters
# Extracted from: workload/bicep/deploy-baseline.bicep
# =============================================================================

BASELINE_PARAMETERS: Dict[str, ParameterInfo] = {
    # ===== BASICS =====
    "deploymentPrefix": ParameterInfo(
        name="deploymentPrefix",
        description="A prefix (2-4 characters) appended to resource names for identification",
        default="AVD1",
        min_value=2,
        max_value=4,
        required=True,
        recommendation="Use a short, meaningful prefix like 'AVD1' for dev or 'PAVD' for production",
        category="basics"
    ),
    "avdWorkloadSubsId": ParameterInfo(
        name="avdWorkloadSubsId",
        description="Azure Subscription ID for AVD workload resources",
        default="",
        required=True,
        recommendation="Enter your Azure subscription ID (GUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)",
        category="basics"
    ),
    "deploymentEnvironment": ParameterInfo(
        name="deploymentEnvironment",
        description="The deployment environment type",
        default="Dev",
        allowed_values=["Dev", "Test", "Prod"],
        required=True,
        recommendation="Start with 'Dev' for testing, use 'Prod' for production workloads with higher SLAs",
        category="basics"
    ),
    "avdSessionHostLocation": ParameterInfo(
        name="avdSessionHostLocation",
        description="Azure region where session hosts (VMs) will be deployed",
        default="eastus2",
        required=True,
        recommendation="Choose a region close to your users for best performance. Consider paired regions for DR.",
        category="basics"
    ),
    "avdManagementPlaneLocation": ParameterInfo(
        name="avdManagementPlaneLocation",
        description="Azure region for AVD management plane (host pool, workspace, app groups)",
        default="eastus2",
        required=True,
        recommendation="Can differ from session host location. Management plane is globally replicated.",
        category="basics"
    ),
    
    # ===== IDENTITY =====
    "avdIdentityServiceProvider": ParameterInfo(
        name="avdIdentityServiceProvider",
        description="Identity service provider for domain services",
        default="ADDS",
        allowed_values=["ADDS", "EntraDS", "EntraID", "EntraIDKerberos"],
        required=True,
        recommendation="""
• ADDS: Best for existing on-premises AD environments with hybrid identity
• EntraDS: Good for cloud-managed domain services without on-premises AD
• EntraID: Simplest setup for cloud-only scenarios, no domain join required
• EntraIDKerberos: Hybrid users with cloud devices, supports FSLogix with Entra""",
        category="identity"
    ),
    "createIntuneEnrollment": ParameterInfo(
        name="createIntuneEnrollment",
        description="Enroll session hosts in Microsoft Intune for device management",
        default=False,
        required=False,
        recommendation="Enable for EntraID scenarios or if you want cloud-based device management",
        category="identity"
    ),
    "identityDomainName": ParameterInfo(
        name="identityDomainName",
        description="FQDN of the AD domain (required for ADDS/EntraDS/EntraIDKerberos)",
        default="none",
        required=False,
        recommendation="Example: contoso.com - Required for FSLogix with ADDS or EntraIDKerberos",
        category="identity"
    ),
    "avdOuPath": ParameterInfo(
        name="avdOuPath",
        description="Organizational Unit path for session hosts",
        default="",
        required=False,
        recommendation="Example: OU=AVDSessionHosts,OU=AVD,DC=contoso,DC=com. Leave empty for default Computers OU.",
        category="identity"
    ),
    
    # ===== HOST POOL =====
    "avdHostPoolType": ParameterInfo(
        name="avdHostPoolType",
        description="Type of host pool to create",
        default="Pooled",
        allowed_values=["Pooled", "Personal"],
        required=True,
        recommendation="""
• Pooled: Multiple users share session hosts. Best for task workers, cost-effective.
• Personal: Each user gets their own dedicated VM. Best for power users, developers.""",
        category="host_pool"
    ),
    "hostPoolPreferredAppGroupType": ParameterInfo(
        name="hostPoolPreferredAppGroupType",
        description="Default application group type",
        default="Desktop",
        allowed_values=["Desktop", "RemoteApp"],
        required=False,
        recommendation="""
• Desktop: Full desktop experience, best for general use
• RemoteApp: Individual apps only, best for specific LOB applications""",
        category="host_pool"
    ),
    "avdHostPoolLoadBalancerType": ParameterInfo(
        name="avdHostPoolLoadBalancerType",
        description="Load balancing algorithm for pooled host pools",
        default="BreadthFirst",
        allowed_values=["BreadthFirst", "DepthFirst"],
        required=False,
        recommendation="""
• BreadthFirst: Spreads users across all hosts evenly. Better user experience.
• DepthFirst: Fills hosts to max before using next. Better for cost optimization.""",
        category="host_pool"
    ),
    "hostPoolMaxSessions": ParameterInfo(
        name="hostPoolMaxSessions",
        description="Maximum concurrent sessions per session host",
        default=8,
        min_value=1,
        max_value=999999,
        required=False,
        recommendation="Typical values: 8-12 for Standard_D4s_v5, 16-20 for D8s_v5. Depends on workload.",
        category="host_pool"
    ),
    "avdStartVmOnConnect": ParameterInfo(
        name="avdStartVmOnConnect",
        description="Automatically start VMs when users connect",
        default=True,
        required=False,
        recommendation="Enable for cost savings - VMs start on demand. Adds ~30-60 seconds to connection time.",
        category="host_pool"
    ),
    "avdDeployScalingPlan": ParameterInfo(
        name="avdDeployScalingPlan",
        description="Deploy an autoscaling plan for the host pool",
        default=True,
        required=False,
        recommendation="Highly recommended for Pooled host pools to optimize costs automatically.",
        category="host_pool"
    ),
    "hostPoolPublicNetworkAccess": ParameterInfo(
        name="hostPoolPublicNetworkAccess",
        description="Public network access setting for the host pool",
        default="Enabled",
        allowed_values=["Disabled", "Enabled", "EnabledForClientsOnly", "EnabledForSessionHostsOnly"],
        required=False,
        recommendation="""
• Enabled: Default, works for most scenarios
• EnabledForClientsOnly: Enhanced security, session hosts use private endpoints
• Disabled: Requires private endpoints for all connections (zero trust)""",
        category="host_pool"
    ),
    
    # ===== SESSION HOSTS =====
    "avdDeploySessionHosts": ParameterInfo(
        name="avdDeploySessionHosts",
        description="Deploy session host VMs",
        default=True,
        required=False,
        recommendation="Set to false to deploy only AVD service objects without VMs",
        category="session_hosts"
    ),
    "avdDeploySessionHostsCount": ParameterInfo(
        name="avdDeploySessionHostsCount",
        description="Number of session hosts to deploy",
        default=1,
        min_value=1,
        max_value=1999,
        required=True,
        recommendation="Start with 1-2 for testing. For production: (expected users / max sessions per host) + 20% buffer",
        category="session_hosts"
    ),
    "avdSessionHostsSize": ParameterInfo(
        name="avdSessionHostsSize",
        description="Azure VM size for session hosts",
        default="Standard_D4ads_v5",
        required=True,
        recommendation="""
Common sizes for AVD:
• Standard_D4ads_v5 (4 vCPU, 16GB): General purpose, 8-12 users
• Standard_D8ads_v5 (8 vCPU, 32GB): Power users, 16-20 users
• Standard_D4s_v5 (4 vCPU, 16GB): Without AMD, Intel-based
• Standard_NV12s_v3: GPU workloads, graphics-intensive apps""",
        category="session_hosts"
    ),
    "avdSessionHostDiskType": ParameterInfo(
        name="avdSessionHostDiskType",
        description="OS disk type for session hosts",
        default="Premium_LRS",
        allowed_values=["Premium_LRS", "StandardSSD_LRS", "Standard_LRS"],
        required=False,
        recommendation="""
• Premium_LRS: Recommended for production. Better IOPS, higher SLA.
• StandardSSD_LRS: Good balance of cost and performance for dev/test
• Standard_LRS: Not recommended for AVD due to performance""",
        category="session_hosts"
    ),
    "enableAcceleratedNetworking": ParameterInfo(
        name="enableAcceleratedNetworking",
        description="Enable accelerated networking on NICs",
        default=True,
        required=False,
        recommendation="Always enable if VM size supports it. Improves network performance significantly.",
        category="session_hosts"
    ),
    "availability": ParameterInfo(
        name="availability",
        description="VM availability configuration",
        default="None",
        allowed_values=["None", "AvailabilityZones"],
        required=False,
        recommendation="""
• None: Regional deployment, no zone redundancy
• AvailabilityZones: Distribute VMs across zones for higher availability (99.99% SLA)""",
        category="session_hosts"
    ),
    "securityType": ParameterInfo(
        name="securityType",
        description="Security type for session host VMs",
        default="TrustedLaunch",
        allowed_values=["Standard", "TrustedLaunch"],
        required=False,
        recommendation="TrustedLaunch recommended for enhanced security (Secure Boot + vTPM)",
        category="session_hosts"
    ),
    "mpImageOffer": ParameterInfo(
        name="mpImageOffer",
        description="Marketplace image offer",
        default="Office-365",
        required=False,
        recommendation="Office-365 includes M365 Apps. Use 'windows-11' for OS-only images.",
        category="session_hosts"
    ),
    "mpImageSku": ParameterInfo(
        name="mpImageSku",
        description="Marketplace image SKU",
        default="win11-24h2-avd-m365",
        required=False,
        recommendation="""
• win11-24h2-avd-m365: Windows 11 Enterprise multi-session with M365 Apps
• win11-24h2-avd: Windows 11 Enterprise multi-session (no Office)
• win10-22h2-avd-m365: Windows 10 if Win11 compatibility issues""",
        category="session_hosts"
    ),
    
    # ===== NETWORKING =====
    "createAvdVnet": ParameterInfo(
        name="createAvdVnet",
        description="Create a new virtual network for AVD",
        default=True,
        required=False,
        recommendation="Set to true for new deployments. Use false to deploy into existing VNet.",
        category="networking"
    ),
    "avdVnetworkAddressPrefixes": ParameterInfo(
        name="avdVnetworkAddressPrefixes",
        description="Address space for the AVD virtual network",
        default="10.10.0.0/16",
        required=False,
        recommendation="Ensure no overlap with existing networks. /16 provides room for growth.",
        category="networking"
    ),
    "vNetworkAvdSubnetAddressPrefix": ParameterInfo(
        name="vNetworkAvdSubnetAddressPrefix",
        description="Subnet for AVD session hosts",
        default="10.10.1.0/24",
        required=False,
        recommendation="/24 supports ~250 hosts. Size based on expected session host count.",
        category="networking"
    ),
    "vNetworkPrivateEndpointSubnetAddressPrefix": ParameterInfo(
        name="vNetworkPrivateEndpointSubnetAddressPrefix",
        description="Subnet for private endpoints",
        default="10.10.2.0/27",
        required=False,
        recommendation="/27 provides 32 addresses, sufficient for storage + Key Vault endpoints",
        category="networking"
    ),
    "deployPrivateEndpointKeyvaultStorage": ParameterInfo(
        name="deployPrivateEndpointKeyvaultStorage",
        description="Deploy private endpoints for Key Vault and Storage",
        default=True,
        required=False,
        recommendation="Recommended for enhanced security. Keeps traffic on Microsoft backbone.",
        category="networking"
    ),
    "createPrivateDnsZones": ParameterInfo(
        name="createPrivateDnsZones",
        description="Create Azure Private DNS zones for private endpoints",
        default=True,
        required=False,
        recommendation="Required for private endpoints. Set to false if using existing DNS zones.",
        category="networking"
    ),
    
    # ===== STORAGE =====
    "createAvdFslogixDeployment": ParameterInfo(
        name="createAvdFslogixDeployment",
        description="Deploy Azure Files for FSLogix profile containers",
        default=True,
        required=False,
        recommendation="Required for Pooled host pools. Stores user profiles centrally.",
        category="storage"
    ),
    "fslogixStoragePerformance": ParameterInfo(
        name="fslogixStoragePerformance",
        description="Storage performance tier for FSLogix",
        default="Premium",
        allowed_values=["Standard", "Premium"],
        required=False,
        recommendation="""
• Premium: Recommended for production. Better IOPS, lower latency.
• Standard: Cost-effective for dev/test with lower user counts""",
        category="storage"
    ),
    "fslogixFileShareQuotaSize": ParameterInfo(
        name="fslogixFileShareQuotaSize",
        description="FSLogix file share quota in GB (increments of 100GB)",
        default=1,
        min_value=1,
        required=False,
        recommendation="Plan 30GB per user for profiles. 100GB minimum for Premium tier.",
        category="storage"
    ),
    "createAppAttachDeployment": ParameterInfo(
        name="createAppAttachDeployment",
        description="Deploy storage for App Attach",
        default=False,
        required=False,
        recommendation="Enable if using MSIX App Attach for application delivery",
        category="storage"
    ),
    "zoneRedundantStorage": ParameterInfo(
        name="zoneRedundantStorage",
        description="Use Zone Redundant Storage (ZRS) instead of LRS",
        default=False,
        required=False,
        recommendation="Enable for higher availability. Replicates data across availability zones.",
        category="storage"
    ),
    
    # ===== SECURITY =====
    "diskZeroTrust": ParameterInfo(
        name="diskZeroTrust",
        description="Enable zero trust disk configuration",
        default=False,
        required=False,
        recommendation="""
Enables double encryption with customer-managed key and disables public network access to disks.
Recommended for high-security environments.""",
        category="security"
    ),
    "diskEncryptionKeyExpirationInDays": ParameterInfo(
        name="diskEncryptionKeyExpirationInDays",
        description="Disk encryption key expiration in days",
        default=60,
        min_value=30,
        max_value=730,
        required=False,
        recommendation="60 days is a good balance. Shorter for higher security requirements.",
        category="security"
    ),
    "secureBootEnabled": ParameterInfo(
        name="secureBootEnabled",
        description="Enable Secure Boot on VMs",
        default=True,
        required=False,
        recommendation="Always enable with TrustedLaunch for protection against boot-level malware",
        category="security"
    ),
    "vTpmEnabled": ParameterInfo(
        name="vTpmEnabled",
        description="Enable Virtual TPM on VMs",
        default=True,
        required=False,
        recommendation="Always enable with TrustedLaunch for enhanced security capabilities",
        category="security"
    ),
    "enableKvPurgeProtection": ParameterInfo(
        name="enableKvPurgeProtection",
        description="Enable purge protection on Key Vaults",
        default=True,
        required=False,
        recommendation="Enable for production to prevent accidental key deletion",
        category="security"
    ),
    "deployAntiMalwareExt": ParameterInfo(
        name="deployAntiMalwareExt",
        description="Deploy antimalware extension on session hosts",
        default=True,
        required=False,
        recommendation="Always enable unless using a third-party antimalware solution",
        category="security"
    ),
    
    # ===== MONITORING =====
    "avdDeployMonitoring": ParameterInfo(
        name="avdDeployMonitoring",
        description="Deploy full AVD monitoring and diagnostics",
        default=False,
        required=False,
        recommendation="Enable for production. Provides AVD Insights, performance counters, and events.",
        category="monitoring"
    ),
    "deployAlaWorkspace": ParameterInfo(
        name="deployAlaWorkspace",
        description="Deploy a Log Analytics workspace",
        default=True,
        required=False,
        recommendation="Required for any monitoring. Set to false only if using existing workspace.",
        category="monitoring"
    ),
    "avdAlaWorkspaceDataRetention": ParameterInfo(
        name="avdAlaWorkspaceDataRetention",
        description="Log Analytics data retention in days",
        default=90,
        min_value=30,
        max_value=730,
        required=False,
        recommendation="90 days is standard. Longer retention increases costs but aids troubleshooting.",
        category="monitoring"
    ),
    "deployCustomPolicyMonitoring": ParameterInfo(
        name="deployCustomPolicyMonitoring",
        description="Deploy custom Azure Policy for diagnostic settings",
        default=False,
        required=False,
        recommendation="Enable for enterprise deployments to enforce monitoring on future resources",
        category="monitoring"
    ),
}


# =============================================================================
# Stage Definitions
# =============================================================================

STAGE_INFO = {
    ConversationStage.WELCOME: {
        "title": "Welcome to AVD Deployment Advisor",
        "description": "I'll help you configure your Azure Virtual Desktop deployment with best practices.",
        "parameters": []
    },
    ConversationStage.BASICS: {
        "title": "📋 Basic Configuration",
        "description": "Let's start with the fundamental deployment settings.",
        "parameters": ["deploymentPrefix", "deploymentEnvironment", "avdSessionHostLocation", "avdManagementPlaneLocation"]
    },
    ConversationStage.IDENTITY: {
        "title": "🔐 Identity Configuration", 
        "description": "Configure how users and devices will authenticate to AVD.",
        "parameters": ["avdIdentityServiceProvider", "createIntuneEnrollment", "identityDomainName", "avdOuPath"]
    },
    ConversationStage.HOST_POOL: {
        "title": "🖥️ Host Pool Configuration",
        "description": "Configure your AVD host pool settings.",
        "parameters": ["avdHostPoolType", "hostPoolPreferredAppGroupType", "avdHostPoolLoadBalancerType", 
                      "hostPoolMaxSessions", "avdStartVmOnConnect", "avdDeployScalingPlan", "hostPoolPublicNetworkAccess"]
    },
    ConversationStage.SESSION_HOSTS: {
        "title": "💻 Session Hosts Configuration",
        "description": "Configure the virtual machines that will host user sessions.",
        "parameters": ["avdDeploySessionHosts", "avdDeploySessionHostsCount", "avdSessionHostsSize",
                      "avdSessionHostDiskType", "enableAcceleratedNetworking", "availability",
                      "securityType", "mpImageOffer", "mpImageSku"]
    },
    ConversationStage.NETWORKING: {
        "title": "🌐 Networking Configuration",
        "description": "Configure virtual network and connectivity settings.",
        "parameters": ["createAvdVnet", "avdVnetworkAddressPrefixes", "vNetworkAvdSubnetAddressPrefix",
                      "vNetworkPrivateEndpointSubnetAddressPrefix", "deployPrivateEndpointKeyvaultStorage",
                      "createPrivateDnsZones"]
    },
    ConversationStage.STORAGE: {
        "title": "📁 Storage Configuration",
        "description": "Configure storage for user profiles and applications.",
        "parameters": ["createAvdFslogixDeployment", "fslogixStoragePerformance", "fslogixFileShareQuotaSize",
                      "createAppAttachDeployment", "zoneRedundantStorage"]
    },
    ConversationStage.SECURITY: {
        "title": "🛡️ Security Configuration",
        "description": "Configure security settings for your deployment.",
        "parameters": ["diskZeroTrust", "diskEncryptionKeyExpirationInDays", "secureBootEnabled",
                      "vTpmEnabled", "enableKvPurgeProtection", "deployAntiMalwareExt"]
    },
    ConversationStage.MONITORING: {
        "title": "📊 Monitoring Configuration",
        "description": "Configure monitoring and diagnostics.",
        "parameters": ["avdDeployMonitoring", "deployAlaWorkspace", "avdAlaWorkspaceDataRetention",
                      "deployCustomPolicyMonitoring"]
    },
    ConversationStage.REVIEW: {
        "title": "✅ Review Configuration",
        "description": "Review your configuration and generate deployment files.",
        "parameters": []
    },
    ConversationStage.COMPLETE: {
        "title": "🎉 Configuration Complete",
        "description": "Your AVD deployment configuration is ready!",
        "parameters": []
    }
}


class DeploymentAdvisorAgent:
    """
    Interactive chat agent for AVD deployment parameter selection.
    
    Guides users through deployment configuration with recommendations
    based on AVD Accelerator Baseline best practices.
    """
    
    def __init__(self):
        """Initialize the deployment advisor agent"""
        self.selection = UserSelection()
        self.parameters = BASELINE_PARAMETERS
        self.stage_info = STAGE_INFO
        self._initialize_defaults()
    
    def _initialize_defaults(self):
        """Initialize parameters with baseline defaults"""
        for name, param in self.parameters.items():
            self.selection.parameters[name] = param.default
    
    def get_current_stage(self) -> ConversationStage:
        """Get the current conversation stage"""
        return self.selection.stage
    
    def get_stage_info(self, stage: ConversationStage = None) -> Dict[str, Any]:
        """Get information about a conversation stage"""
        if stage is None:
            stage = self.selection.stage
        return self.stage_info.get(stage, {})
    
    def get_stage_parameters(self, stage: ConversationStage = None) -> List[ParameterInfo]:
        """Get parameters for a specific stage"""
        if stage is None:
            stage = self.selection.stage
        
        stage_info = self.stage_info.get(stage, {})
        param_names = stage_info.get("parameters", [])
        return [self.parameters[name] for name in param_names if name in self.parameters]
    
    def format_welcome_message(self) -> str:
        """Generate the welcome message"""
        return """
╔══════════════════════════════════════════════════════════════════════════════╗
║         🖥️  Azure Virtual Desktop - Deployment Advisor  🖥️                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  Welcome! I'll guide you through configuring your AVD deployment.            ║
║                                                                              ║
║  📋 This wizard covers:                                                      ║
║     • Basic deployment settings (prefix, environment, region)                ║
║     • Identity configuration (ADDS, EntraID, etc.)                           ║
║     • Host pool settings (Pooled/Personal, scaling)                          ║
║     • Session host configuration (VM size, count, image)                     ║
║     • Networking (VNet, subnets, private endpoints)                          ║
║     • Storage (FSLogix profiles, App Attach)                                 ║
║     • Security (encryption, Trusted Launch)                                  ║
║     • Monitoring (Log Analytics, AVD Insights)                               ║
║                                                                              ║
║  💡 I'll provide recommendations based on AVD Accelerator best practices.    ║
║                                                                              ║
║  Commands:                                                                   ║
║     'next'     - Move to the next section                                   ║
║     'back'     - Go to the previous section                                 ║
║     'skip'     - Accept defaults for current section                        ║
║     'review'   - Jump to configuration review                               ║
║     'help'     - Get help on current parameter                              ║
║     'export'   - Export configuration to YAML/JSON                          ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Let's begin! Type 'next' to start with basic configuration.
"""
    
    def format_stage_header(self, stage: ConversationStage = None) -> str:
        """Format the header for a conversation stage"""
        if stage is None:
            stage = self.selection.stage
        
        info = self.stage_info.get(stage, {})
        title = info.get("title", "Configuration")
        description = info.get("description", "")
        
        stages = list(ConversationStage)
        current_idx = stages.index(stage) if stage in stages else 0
        progress = f"[{current_idx}/{len(stages)-2}]"  # Exclude WELCOME and COMPLETE
        
        return f"""
{'─' * 70}
{title} {progress}
{'─' * 70}
{description}
"""
    
    def format_parameter_prompt(self, param: ParameterInfo) -> str:
        """Format a parameter prompt with details and recommendation"""
        lines = [f"\n📌 {param.name}"]
        lines.append(f"   {param.description}")
        lines.append(f"   Default: {param.default}")
        
        if param.allowed_values:
            lines.append(f"   Options: {', '.join(str(v) for v in param.allowed_values)}")
        
        if param.min_value is not None or param.max_value is not None:
            range_str = ""
            if param.min_value is not None:
                range_str += f"min: {param.min_value}"
            if param.max_value is not None:
                range_str += f", max: {param.max_value}" if range_str else f"max: {param.max_value}"
            lines.append(f"   Range: {range_str}")
        
        if param.recommendation:
            lines.append(f"\n   💡 Recommendation:")
            for rec_line in param.recommendation.strip().split('\n'):
                lines.append(f"   {rec_line}")
        
        current_value = self.selection.parameters.get(param.name, param.default)
        lines.append(f"\n   Current value: {current_value}")
        lines.append(f"   Enter new value (or press Enter to keep current):")
        
        return '\n'.join(lines)
    
    def format_review(self) -> str:
        """Format the configuration review"""
        lines = [self.format_stage_header(ConversationStage.REVIEW)]
        lines.append("\nYour AVD Deployment Configuration:\n")
        
        # Group parameters by category
        categories = {}
        for name, param in self.parameters.items():
            category = param.category or "other"
            if category not in categories:
                categories[category] = []
            
            value = self.selection.parameters.get(name, param.default)
            is_default = value == param.default
            marker = "  " if is_default else "✏️"
            categories[category].append((name, value, is_default, marker))
        
        category_titles = {
            "basics": "📋 Basic Configuration",
            "identity": "🔐 Identity",
            "host_pool": "🖥️ Host Pool",
            "session_hosts": "💻 Session Hosts",
            "networking": "🌐 Networking",
            "storage": "📁 Storage",
            "security": "🛡️ Security",
            "monitoring": "📊 Monitoring"
        }
        
        for category, items in categories.items():
            title = category_titles.get(category, category.title())
            lines.append(f"\n{title}")
            lines.append("-" * 50)
            for name, value, is_default, marker in items:
                default_note = " (default)" if is_default else " (modified)"
                lines.append(f"{marker} {name}: {value}{default_note}")
        
        lines.append("\n" + "=" * 70)
        lines.append("\nCommands:")
        lines.append("  'export yaml' - Export to YAML specification file")
        lines.append("  'export json' - Export to JSON parameters file")
        lines.append("  'back'        - Go back to modify settings")
        lines.append("  'done'        - Finish and generate deployment files")
        
        return '\n'.join(lines)
    
    def advance_stage(self) -> ConversationStage:
        """Move to the next conversation stage"""
        stages = list(ConversationStage)
        current_idx = stages.index(self.selection.stage)
        
        if current_idx < len(stages) - 1:
            self.selection.stage = stages[current_idx + 1]
        
        return self.selection.stage
    
    def go_back_stage(self) -> ConversationStage:
        """Go back to the previous conversation stage"""
        stages = list(ConversationStage)
        current_idx = stages.index(self.selection.stage)
        
        if current_idx > 0:
            self.selection.stage = stages[current_idx - 1]
        
        return self.selection.stage
    
    def set_parameter(self, name: str, value: Any) -> Tuple[bool, str]:
        """
        Set a parameter value with validation.
        
        Returns:
            Tuple of (success, message)
        """
        if name not in self.parameters:
            return False, f"Unknown parameter: {name}"
        
        param = self.parameters[name]
        
        # Validate allowed values
        if param.allowed_values and value not in param.allowed_values:
            return False, f"Invalid value. Allowed: {param.allowed_values}"
        
        # Validate range for numeric values
        if isinstance(value, (int, float)):
            if param.min_value is not None and value < param.min_value:
                return False, f"Value must be >= {param.min_value}"
            if param.max_value is not None and value > param.max_value:
                return False, f"Value must be <= {param.max_value}"
        
        # Validate string length for prefix
        if name == "deploymentPrefix":
            if len(str(value)) < 2 or len(str(value)) > 4:
                return False, "Deployment prefix must be 2-4 characters"
        
        self.selection.parameters[name] = value
        return True, f"✓ Set {name} = {value}"
    
    def get_parameter_value(self, name: str) -> Any:
        """Get current value of a parameter"""
        if name in self.selection.parameters:
            return self.selection.parameters[name]
        if name in self.parameters:
            return self.parameters[name].default
        return None
    
    def export_to_yaml(self) -> str:
        """Export configuration to YAML specification format"""
        prefix = self.selection.parameters.get("deploymentPrefix", "AVD1")
        env = self.selection.parameters.get("deploymentEnvironment", "Dev").lower()
        region = self.selection.parameters.get("avdSessionHostLocation", "eastus2")
        
        spec = {
            "apiVersion": "avd.azure.com/v1",
            "kind": "AVDDeployment",
            "metadata": {
                "name": f"{prefix.lower()}-avd-{env}",
                "environment": env,
                "region": region,
                "description": f"AVD deployment generated by Deployment Advisor"
            },
            "spec": {
                "deploymentPrefix": prefix,
                "subscriptionId": "00000000-0000-0000-0000-000000000000",
                "identity": {
                    "provider": self.selection.parameters.get("avdIdentityServiceProvider", "ADDS"),
                    "intuneEnrollment": self.selection.parameters.get("createIntuneEnrollment", False),
                    "domainName": self.selection.parameters.get("identityDomainName", "none"),
                    "ouPath": self.selection.parameters.get("avdOuPath", "")
                },
                "hostPools": [{
                    "name": f"vdpool-{prefix.lower()}-{env}",
                    "type": self.selection.parameters.get("avdHostPoolType", "Pooled"),
                    "location": region,
                    "preferredAppGroupType": self.selection.parameters.get("hostPoolPreferredAppGroupType", "Desktop"),
                    "publicNetworkAccess": self.selection.parameters.get("hostPoolPublicNetworkAccess", "Enabled"),
                    "maxSessionLimit": self.selection.parameters.get("hostPoolMaxSessions", 8),
                    "loadBalancerType": self.selection.parameters.get("avdHostPoolLoadBalancerType", "BreadthFirst"),
                    "startVMOnConnect": self.selection.parameters.get("avdStartVmOnConnect", True),
                    "sessionHosts": {
                        "count": self.selection.parameters.get("avdDeploySessionHostsCount", 1),
                        "vmSize": self.selection.parameters.get("avdSessionHostsSize", "Standard_D4ads_v5"),
                        "diskType": self.selection.parameters.get("avdSessionHostDiskType", "Premium_LRS"),
                        "acceleratedNetworking": self.selection.parameters.get("enableAcceleratedNetworking", True),
                        "availability": self.selection.parameters.get("availability", "None"),
                        "securityType": self.selection.parameters.get("securityType", "TrustedLaunch"),
                        "imageOffer": self.selection.parameters.get("mpImageOffer", "Office-365"),
                        "imageSku": self.selection.parameters.get("mpImageSku", "win11-24h2-avd-m365")
                    },
                    "scaling": {
                        "enabled": self.selection.parameters.get("avdDeployScalingPlan", True)
                    }
                }],
                "networking": {
                    "createNew": self.selection.parameters.get("createAvdVnet", True),
                    "vnet": {
                        "addressSpace": self.selection.parameters.get("avdVnetworkAddressPrefixes", "10.10.0.0/16"),
                        "subnets": [
                            {
                                "name": "snet-avd",
                                "addressPrefix": self.selection.parameters.get("vNetworkAvdSubnetAddressPrefix", "10.10.1.0/24")
                            },
                            {
                                "name": "snet-pe",
                                "addressPrefix": self.selection.parameters.get("vNetworkPrivateEndpointSubnetAddressPrefix", "10.10.2.0/27")
                            }
                        ]
                    }
                },
                "storage": {
                    "fslogix": {
                        "enabled": self.selection.parameters.get("createAvdFslogixDeployment", True),
                        "performance": self.selection.parameters.get("fslogixStoragePerformance", "Premium"),
                        "quotaSizeGB": self.selection.parameters.get("fslogixFileShareQuotaSize", 1)
                    },
                    "appAttach": {
                        "enabled": self.selection.parameters.get("createAppAttachDeployment", False)
                    },
                    "zoneRedundant": self.selection.parameters.get("zoneRedundantStorage", False)
                },
                "security": {
                    "diskZeroTrust": self.selection.parameters.get("diskZeroTrust", False),
                    "encryptionKeyExpirationDays": self.selection.parameters.get("diskEncryptionKeyExpirationInDays", 60),
                    "secureBoot": self.selection.parameters.get("secureBootEnabled", True),
                    "vTpm": self.selection.parameters.get("vTpmEnabled", True),
                    "deployPrivateEndpoints": self.selection.parameters.get("deployPrivateEndpointKeyvaultStorage", True),
                    "createPrivateDnsZones": self.selection.parameters.get("createPrivateDnsZones", True),
                    "antiMalware": self.selection.parameters.get("deployAntiMalwareExt", True)
                },
                "monitoring": {
                    "enabled": self.selection.parameters.get("avdDeployMonitoring", False),
                    "deployLogAnalytics": self.selection.parameters.get("deployAlaWorkspace", True),
                    "retentionDays": self.selection.parameters.get("avdAlaWorkspaceDataRetention", 90),
                    "deployCustomPolicies": self.selection.parameters.get("deployCustomPolicyMonitoring", False)
                },
                "tags": {
                    "Environment": self.selection.parameters.get("deploymentEnvironment", "Dev"),
                    "ManagedBy": "AVD-Accelerator",
                    "GeneratedBy": "Deployment-Advisor"
                }
            }
        }
        
        # Convert to YAML or JSON fallback
        if HAS_YAML:
            import yaml
            return yaml.dump(spec, default_flow_style=False, sort_keys=False)
        else:
            # JSON fallback with formatting to look like YAML
            return json.dumps(spec, indent=2)
    
    def export_to_json_parameters(self) -> str:
        """Export configuration to Azure deployment parameters JSON format"""
        params = {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {}
        }
        
        for name, value in self.selection.parameters.items():
            params["parameters"][name] = {"value": value}
        
        return json.dumps(params, indent=2)
    
    def get_contextual_recommendations(self) -> List[str]:
        """Get recommendations based on current selections"""
        recommendations = []
        params = self.selection.parameters
        
        # Identity-based recommendations
        if params.get("avdIdentityServiceProvider") == "EntraID":
            recommendations.append("💡 With EntraID, consider enabling Intune enrollment for device management")
            if params.get("createAvdFslogixDeployment"):
                recommendations.append("⚠️ FSLogix with EntraID requires Cloud Cache or Azure Files with Entra Kerberos")
        
        # Host pool recommendations
        if params.get("avdHostPoolType") == "Pooled":
            if not params.get("avdDeployScalingPlan"):
                recommendations.append("💡 Consider enabling scaling plan for Pooled host pools to optimize costs")
            if not params.get("createAvdFslogixDeployment"):
                recommendations.append("⚠️ FSLogix is highly recommended for Pooled host pools to persist user profiles")
        
        # Security recommendations
        if params.get("deploymentEnvironment") == "Prod":
            if not params.get("diskZeroTrust"):
                recommendations.append("💡 Consider enabling Zero Trust disk configuration for production")
            if not params.get("avdDeployMonitoring"):
                recommendations.append("💡 Full monitoring is recommended for production environments")
            if params.get("availability") == "None":
                recommendations.append("💡 Consider using Availability Zones for production workloads")
        
        # Storage recommendations
        if params.get("fslogixStoragePerformance") == "Standard" and params.get("deploymentEnvironment") == "Prod":
            recommendations.append("⚠️ Premium storage is recommended for production FSLogix deployment")
        
        # Networking recommendations
        if not params.get("deployPrivateEndpointKeyvaultStorage"):
            recommendations.append("💡 Private endpoints enhance security by keeping traffic on Microsoft backbone")
        
        return recommendations
    
    def process_input(self, user_input: str) -> str:
        """
        Process user input and return response.
        
        Args:
            user_input: User's text input
            
        Returns:
            Response message
        """
        input_lower = user_input.strip().lower()
        
        # Handle commands
        if input_lower == "next":
            self.advance_stage()
            if self.selection.stage == ConversationStage.REVIEW:
                return self.format_review()
            return self.format_stage_header() + self._format_stage_parameters()
        
        elif input_lower == "back":
            self.go_back_stage()
            if self.selection.stage == ConversationStage.WELCOME:
                return self.format_welcome_message()
            return self.format_stage_header() + self._format_stage_parameters()
        
        elif input_lower == "skip":
            # Keep defaults and advance
            self.advance_stage()
            if self.selection.stage == ConversationStage.REVIEW:
                return self.format_review()
            return f"✓ Keeping defaults for previous section\n" + self.format_stage_header() + self._format_stage_parameters()
        
        elif input_lower == "review":
            self.selection.stage = ConversationStage.REVIEW
            return self.format_review()
        
        elif input_lower == "help":
            return self._format_help()
        
        elif input_lower.startswith("export yaml"):
            return f"```yaml\n{self.export_to_yaml()}\n```"
        
        elif input_lower.startswith("export json"):
            return f"```json\n{self.export_to_json_parameters()}\n```"
        
        elif input_lower.startswith("export validation"):
            if "json" in input_lower:
                return f"```json\n{self.export_validation_report('json')}\n```"
            return self.export_validation_report("text")
        
        elif input_lower == "done":
            self.selection.stage = ConversationStage.COMPLETE
            return self._format_completion()
        
        elif input_lower == "recommendations":
            recs = self.get_contextual_recommendations()
            if recs:
                return "📋 Recommendations based on your configuration:\n\n" + "\n".join(recs)
            return "✓ No additional recommendations for current configuration"
        
        elif input_lower == "validate" or input_lower == "validation":
            return self._run_validation()
        
        # Handle parameter setting (format: "param_name=value" or "param_name value")
        elif "=" in user_input or " " in user_input.strip():
            return self._process_parameter_setting(user_input)
        
        # Default: show current stage info
        if self.selection.stage == ConversationStage.WELCOME:
            return self.format_welcome_message()
        elif self.selection.stage == ConversationStage.REVIEW:
            return self.format_review()
        else:
            return self.format_stage_header() + self._format_stage_parameters()
    
    def _format_stage_parameters(self) -> str:
        """Format all parameters for the current stage"""
        params = self.get_stage_parameters()
        if not params:
            return "\nNo parameters to configure in this stage. Type 'next' to continue."
        
        lines = []
        for param in params:
            lines.append(self.format_parameter_prompt(param))
        
        lines.append("\n" + "-" * 70)
        lines.append("Set parameter: '<name>=<value>' or '<name> <value>'")
        lines.append("Commands: 'next', 'back', 'skip', 'review', 'help', 'recommendations'")
        
        return '\n'.join(lines)
    
    def _format_help(self) -> str:
        """Format help message for current context"""
        return """
📚 Deployment Advisor Help
══════════════════════════

Navigation Commands:
  next           - Move to the next configuration section
  back           - Return to the previous section  
  skip           - Accept defaults and move to next section
  review         - Jump to configuration review
  done           - Complete configuration and generate files

Setting Parameters:
  <name>=<value> - Set a parameter (e.g., deploymentPrefix=PROD)
  <name> <value> - Alternative syntax (e.g., deploymentPrefix PROD)

Validation Commands:
  validate       - Run pre-deployment validation (costs, resources, prerequisites)

Export Commands:
  export yaml    - Export to YAML specification file
  export json    - Export to JSON parameters file

Other Commands:
  help           - Show this help message
  recommendations - Get contextual recommendations

Tips:
  • Press Enter without a value to keep the current/default value
  • Boolean values: true, false, yes, no
  • Integer values: enter the number directly
  • Run 'validate' before deployment to see resource list and estimated costs
"""
    
    def _format_completion(self) -> str:
        """Format the completion message"""
        yaml_config = self.export_to_yaml()
        
        return f"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🎉 Configuration Complete! 🎉                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  Your AVD deployment configuration has been generated!                       ║
║                                                                              ║
║  Next Steps:                                                                 ║
║  1. Review the generated YAML specification below                            ║
║  2. Save it to a file (e.g., avd-deployment.yaml)                           ║
║  3. Run the AVD orchestrator to generate deployment artifacts               ║
║  4. Review and deploy the generated Bicep/Terraform templates               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

Generated YAML Specification:
─────────────────────────────

```yaml
{yaml_config}
```

To deploy, save this configuration and run:
  python agents/core/orchestrator.py <your-config.yaml>

Or use the generated parameters with the baseline Bicep template:
  az deployment sub create --location <region> --template-file workload/bicep/deploy-baseline.bicep --parameters @parameters.json
"""
    
    def _process_parameter_setting(self, user_input: str) -> str:
        """Process parameter setting input"""
        # Parse input
        if "=" in user_input:
            parts = user_input.split("=", 1)
        else:
            parts = user_input.split(None, 1)
        
        if len(parts) != 2:
            return "❌ Invalid format. Use: '<name>=<value>' or '<name> <value>'"
        
        name = parts[0].strip()
        value_str = parts[1].strip()
        
        # Find parameter
        if name not in self.parameters:
            # Try to find by partial match
            matches = [p for p in self.parameters.keys() if name.lower() in p.lower()]
            if matches:
                return f"❌ Unknown parameter '{name}'. Did you mean: {', '.join(matches[:3])}?"
            return f"❌ Unknown parameter: {name}"
        
        param = self.parameters[name]
        
        # Convert value
        try:
            if param.allowed_values:
                # Case-insensitive match for allowed values
                for av in param.allowed_values:
                    if str(av).lower() == value_str.lower():
                        value = av
                        break
                else:
                    value = value_str
            elif isinstance(param.default, bool):
                value = value_str.lower() in ('true', 'yes', '1', 'on')
            elif isinstance(param.default, int):
                value = int(value_str)
            else:
                value = value_str
        except ValueError as e:
            return f"❌ Invalid value format: {e}"
        
        # Set parameter
        success, message = self.set_parameter(name, value)
        
        if success:
            # Check for contextual recommendations
            recs = self.get_contextual_recommendations()
            if recs:
                message += "\n\n" + "\n".join(recs[:2])  # Show up to 2 recommendations
        
        return message
    
    def _run_validation(self) -> str:
        """Run pre-deployment validation and return report"""
        try:
            # Import validator
            from validation.pre_deployment_validator import PreDeploymentValidator
            
            # Create validator with current parameters
            validator = PreDeploymentValidator()
            validator.set_parameters(self.selection.parameters)
            
            # Run validation
            result = validator.validate()
            
            # Format summary
            lines = []
            lines.append("\n╔══════════════════════════════════════════════════════════════════════════════╗")
            lines.append("║                    🔍 PRE-DEPLOYMENT VALIDATION                               ║")
            lines.append("╚══════════════════════════════════════════════════════════════════════════════╝\n")
            
            # Status
            if result.is_valid:
                lines.append("✅ Status: VALID - Ready for deployment\n")
            else:
                lines.append("❌ Status: INVALID - Issues must be resolved\n")
            
            # Errors
            if result.errors:
                lines.append("🚫 ERRORS:")
                for e in result.errors:
                    lines.append(f"   {e}")
                lines.append("")
            
            # Warnings
            if result.warnings:
                lines.append("⚠️  WARNINGS:")
                for w in result.warnings:
                    lines.append(f"   {w}")
                lines.append("")
            
            # Cost summary
            lines.append(f"💰 ESTIMATED MONTHLY COST: ${result.estimated_monthly_cost:,.2f}")
            lines.append("")
            lines.append("   Cost Breakdown:")
            for category, cost in sorted(result.cost_breakdown.items(), key=lambda x: -x[1]):
                if cost > 0:
                    lines.append(f"   • {category}: ${cost:,.2f}")
            lines.append("")
            
            # Resource count
            lines.append(f"📦 RESOURCES TO CREATE: {len(result.resources_to_create)}")
            
            # Group by type
            by_type = {}
            for r in result.resources_to_create:
                type_name = r.resource_type.split("/")[-1]
                by_type[type_name] = by_type.get(type_name, 0) + 1
            
            for type_name, count in sorted(by_type.items()):
                lines.append(f"   • {type_name}: {count}")
            lines.append("")
            
            # Prerequisites count
            required_prereqs = [p for p in result.prerequisites if p.required]
            lines.append(f"📋 PREREQUISITES: {len(required_prereqs)} required")
            
            # Categories
            categories = set(p.category for p in required_prereqs)
            for cat in sorted(categories):
                count = len([p for p in required_prereqs if p.category == cat])
                lines.append(f"   • {cat}: {count}")
            lines.append("")
            
            lines.append("─" * 70)
            lines.append("Type 'export validation' for full validation report")
            lines.append("Type 'export validation json' for JSON format")
            
            return "\n".join(lines)
            
        except ImportError:
            return "❌ Validation agent not available. Ensure agents/validation module is installed."
        except Exception as e:
            return f"❌ Validation error: {e}"
    
    def export_validation_report(self, format_type: str = "text") -> str:
        """Export full validation report"""
        try:
            from validation.pre_deployment_validator import PreDeploymentValidator
            
            validator = PreDeploymentValidator()
            validator.set_parameters(self.selection.parameters)
            result = validator.validate()
            
            if format_type == "json":
                return validator.export_to_json(result)
            else:
                return validator.generate_report(result)
        except Exception as e:
            return f"Error generating validation report: {e}"


def main():
    """Interactive demo of the deployment advisor"""
    advisor = DeploymentAdvisorAgent()
    
    print(advisor.format_welcome_message())
    
    while True:
        try:
            user_input = input("\n> ").strip()
            if user_input.lower() in ('quit', 'exit', 'q'):
                print("Goodbye!")
                break
            
            response = advisor.process_input(user_input)
            print(response)
            
            if advisor.get_current_stage() == ConversationStage.COMPLETE:
                break
                
        except KeyboardInterrupt:
            print("\n\nGoodbye!")
            break
        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    main()
