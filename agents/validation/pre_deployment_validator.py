"""
Pre-Deployment Validator Agent

A validation agent that runs before AVD deployment to provide:
1. List of Azure resources that will be created
2. Estimated monthly cost of the deployment
3. Prerequisites required on the Azure environment
4. Detection of existing resources that may be updated

Reference: workload/bicep/deploy-baseline.bicep
"""

from pathlib import Path
from typing import Dict, Any, List, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum
import json
import sys

# Try to import from core, but make it optional for standalone use
try:
    sys.path.append(str(Path(__file__).parent.parent))
    from core.orchestrator import AgentResult, AgentType
except ImportError:
    # Define minimal types for standalone use
    class AgentType(Enum):
        VALIDATOR = "validator"
    
    @dataclass
    class AgentResult:
        agent_type: AgentType
        success: bool
        artifacts: List[Path]
        messages: List[str]
        errors: List[str]


# =============================================================================
# Azure Pricing Estimates (USD/month)
# Note: These are estimates for East US region. Actual costs vary by region.
# =============================================================================

AZURE_PRICING = {
    # Compute - VMs (pay-as-you-go per hour, converted to monthly assuming 730 hours)
    "vm_sizes": {
        "Standard_D2ads_v5": {"vcpu": 2, "memory_gb": 8, "price_per_hour": 0.096},
        "Standard_D4ads_v5": {"vcpu": 4, "memory_gb": 16, "price_per_hour": 0.192},
        "Standard_D8ads_v5": {"vcpu": 8, "memory_gb": 32, "price_per_hour": 0.384},
        "Standard_D16ads_v5": {"vcpu": 16, "memory_gb": 64, "price_per_hour": 0.768},
        "Standard_D2s_v5": {"vcpu": 2, "memory_gb": 8, "price_per_hour": 0.096},
        "Standard_D4s_v5": {"vcpu": 4, "memory_gb": 16, "price_per_hour": 0.192},
        "Standard_D8s_v5": {"vcpu": 8, "memory_gb": 32, "price_per_hour": 0.384},
        "Standard_NV6ads_A10_v5": {"vcpu": 6, "memory_gb": 55, "price_per_hour": 0.45, "gpu": True},
        "Standard_NV12ads_A10_v5": {"vcpu": 12, "memory_gb": 110, "price_per_hour": 0.90, "gpu": True},
    },
    # Managed Disks (per GB/month)
    "disk_types": {
        "Standard_LRS": 0.04,
        "StandardSSD_LRS": 0.075,
        "Premium_LRS": 0.12,
        "Premium_ZRS": 0.144,
    },
    # Storage - Azure Files (per GB/month)
    "storage": {
        "Standard_LRS": 0.06,
        "Standard_ZRS": 0.0725,
        "Premium_LRS": 0.16,
        "Premium_ZRS": 0.192,
    },
    # Key Vault
    "keyvault": {
        "operations_per_10k": 0.03,
        "keys_per_month": 1.00,  # Premium keys
        "secrets_per_month": 0.03,
    },
    # Log Analytics (per GB ingested)
    "log_analytics_per_gb": 2.30,
    # Private Endpoints (per hour)
    "private_endpoint_per_hour": 0.01,
    # Virtual Network (Peering per GB)
    "vnet_peering_per_gb": 0.01,
    # NSG - Free
    "nsg": 0,
    # Route Table - Free
    "route_table": 0,
    # Application Security Group - Free
    "asg": 0,
    # AVD Management Plane - Free
    "host_pool": 0,
    "workspace": 0,
    "application_group": 0,
    "scaling_plan": 0,
    # Resource Groups - Free
    "resource_group": 0,
    # Managed Identity - Free
    "managed_identity": 0,
    # DDoS Protection Plan (per month)
    "ddos_protection_plan": 2944,
}


@dataclass
class ResourceInfo:
    """Information about an Azure resource to be deployed"""
    resource_type: str
    name: str
    description: str
    estimated_monthly_cost: float
    pricing_notes: str = ""
    depends_on: List[str] = field(default_factory=list)
    conditional: bool = False
    condition_description: str = ""


@dataclass
class PrerequisiteInfo:
    """Information about a deployment prerequisite"""
    name: str
    description: str
    required: bool
    how_to_check: str
    how_to_fulfill: str
    category: str  # "permissions", "networking", "identity", "quota", "configuration"


@dataclass
class ExistingResourceCheck:
    """Check for existing resources that may be updated"""
    resource_type: str
    identifier: str  # How to identify (e.g., subscription ID, resource ID)
    description: str
    impact_if_exists: str
    

@dataclass
class ValidationResult:
    """Result of the pre-deployment validation"""
    resources_to_create: List[ResourceInfo]
    estimated_monthly_cost: float
    cost_breakdown: Dict[str, float]
    prerequisites: List[PrerequisiteInfo]
    existing_resource_checks: List[ExistingResourceCheck]
    warnings: List[str]
    errors: List[str]
    is_valid: bool


class PreDeploymentValidator:
    """
    Pre-Deployment Validation Agent
    
    Analyzes deployment parameters and provides:
    - Complete resource inventory
    - Cost estimation
    - Prerequisites checklist
    - Existing resource detection
    """
    
    def __init__(self):
        """Initialize the validator"""
        self.parameters: Dict[str, Any] = {}
        self._load_default_parameters()
    
    def _load_default_parameters(self) -> None:
        """Load default deployment parameters from baseline"""
        self.parameters = {
            # Basic settings
            "deploymentPrefix": "AVD1",
            "deploymentEnvironment": "Dev",
            "avdManagementPlaneLocation": "eastus",
            "avdSessionHostLocation": "eastus",
            "avdWorkloadSubsId": "",
            
            # Identity
            "avdIdentityServiceProvider": "ADDS",
            "identityDomainName": "",
            
            # Host Pool
            "avdHostPoolType": "Pooled",
            "hostPoolMaxSessions": 8,
            "avdDeployScalingPlan": True,
            
            # Session Hosts
            "avdDeploySessionHosts": True,
            "avdDeploySessionHostsCount": 1,
            "avdSessionHostsSize": "Standard_D4ads_v5",
            "avdSessionHostDiskType": "Premium_LRS",
            "securityType": "TrustedLaunch",
            "availability": "availabilityZones",
            
            # Networking
            "createAvdVnet": True,
            "avdVnetworkAddressPrefixes": "10.10.0.0/23",
            "vNetworkAvdSubnetAddressPrefix": "10.10.0.0/24",
            "vNetworkPrivateEndpointSubnetAddressPrefix": "10.10.1.0/27",
            "deployDDoSNetworkProtection": False,
            
            # Storage
            "createAvdFslogixDeployment": True,
            "fslogixStoragePerformance": "Premium",
            "fslogixFileShareQuotaSize": 100,
            "createAppAttachDeployment": False,
            "appAttachStoragePerformance": "Premium",
            "appAttachFileShareQuotaSize": 100,
            
            # Security
            "diskZeroTrust": True,
            "deployPrivateEndpointKeyvaultStorage": True,
            "createPrivateDnsZones": True,
            "deployAvdPrivateLinkService": True,
            
            # Monitoring
            "avdDeployMonitoring": True,
            "deployAlaWorkspace": True,
            "deployCustomPolicyMonitoring": True,
            "avdAlaWorkspaceDataRetention": 90,
            
            # Microsoft Defender
            "deployDefender": False,
        }
    
    def set_parameters(self, parameters: Dict[str, Any]) -> None:
        """
        Set deployment parameters for validation
        
        Args:
            parameters: Dictionary of parameter name -> value
        """
        self.parameters.update(parameters)
    
    def validate(self) -> ValidationResult:
        """
        Perform complete pre-deployment validation
        
        Returns:
            ValidationResult with all validation information
        """
        resources = self._analyze_resources()
        cost_breakdown = self._calculate_costs(resources)
        total_cost = sum(cost_breakdown.values())
        prerequisites = self._analyze_prerequisites()
        existing_checks = self._analyze_existing_resources()
        warnings, errors = self._generate_warnings_and_errors()
        
        return ValidationResult(
            resources_to_create=resources,
            estimated_monthly_cost=total_cost,
            cost_breakdown=cost_breakdown,
            prerequisites=prerequisites,
            existing_resource_checks=existing_checks,
            warnings=warnings,
            errors=errors,
            is_valid=len(errors) == 0
        )
    
    def _analyze_resources(self) -> List[ResourceInfo]:
        """Analyze and list all resources that will be created"""
        resources = []
        
        prefix = self.parameters.get("deploymentPrefix", "AVD1")
        env = self.parameters.get("deploymentEnvironment", "Dev")
        location = self.parameters.get("avdSessionHostLocation", "eastus")
        
        # =====================================================================
        # Resource Groups
        # =====================================================================
        resources.append(ResourceInfo(
            resource_type="Microsoft.Resources/resourceGroups",
            name=f"rg-avd-{prefix.lower()}-{env.lower()}-service-objects",
            description="Service objects resource group for AVD management plane resources",
            estimated_monthly_cost=0,
            pricing_notes="Resource groups are free"
        ))
        
        resources.append(ResourceInfo(
            resource_type="Microsoft.Resources/resourceGroups",
            name=f"rg-avd-{prefix.lower()}-{env.lower()}-pool-compute",
            description="Compute resource group for session hosts and VMs",
            estimated_monthly_cost=0,
            pricing_notes="Resource groups are free"
        ))
        
        if self.parameters.get("createAvdVnet") or self.parameters.get("createPrivateDnsZones"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.Resources/resourceGroups",
                name=f"rg-avd-{prefix.lower()}-{env.lower()}-network",
                description="Network resource group for VNet, NSG, and DNS zones",
                estimated_monthly_cost=0,
                pricing_notes="Resource groups are free",
                conditional=True,
                condition_description="Created when createAvdVnet=true or createPrivateDnsZones=true"
            ))
        
        if self.parameters.get("createAvdFslogixDeployment") or self.parameters.get("createAppAttachDeployment"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.Resources/resourceGroups",
                name=f"rg-avd-{prefix.lower()}-{env.lower()}-storage",
                description="Storage resource group for Azure Files (FSLogix/App Attach)",
                estimated_monthly_cost=0,
                pricing_notes="Resource groups are free",
                conditional=True,
                condition_description="Created when FSLogix or App Attach storage is deployed"
            ))
        
        if self.parameters.get("avdDeployMonitoring"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.Resources/resourceGroups",
                name=f"rg-avd-{prefix.lower()}-{env.lower()}-monitoring",
                description="Monitoring resource group for Log Analytics and diagnostics",
                estimated_monthly_cost=0,
                pricing_notes="Resource groups are free",
                conditional=True,
                condition_description="Created when avdDeployMonitoring=true"
            ))
        
        # =====================================================================
        # AVD Management Plane (Free tier)
        # =====================================================================
        resources.append(ResourceInfo(
            resource_type="Microsoft.DesktopVirtualization/hostPools",
            name=f"vdpool-{prefix.lower()}-{env.lower()}-001",
            description="AVD Host Pool for session host management",
            estimated_monthly_cost=0,
            pricing_notes="AVD Host Pools are free - you only pay for underlying compute"
        ))
        
        resources.append(ResourceInfo(
            resource_type="Microsoft.DesktopVirtualization/workspaces",
            name=f"vdws-{prefix.lower()}-{env.lower()}-001",
            description="AVD Workspace for user-facing app groups",
            estimated_monthly_cost=0,
            pricing_notes="AVD Workspaces are free"
        ))
        
        resources.append(ResourceInfo(
            resource_type="Microsoft.DesktopVirtualization/applicationGroups",
            name=f"vdag-desktop-{prefix.lower()}-{env.lower()}-001",
            description="AVD Application Group for desktop/RemoteApp delivery",
            estimated_monthly_cost=0,
            pricing_notes="AVD Application Groups are free"
        ))
        
        if self.parameters.get("avdDeployScalingPlan"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.DesktopVirtualization/scalingPlans",
                name=f"vdscaling-{prefix.lower()}-{env.lower()}-001",
                description="AVD Scaling Plan for automatic session host scaling",
                estimated_monthly_cost=0,
                pricing_notes="AVD Scaling Plans are free",
                conditional=True,
                condition_description="Created when avdDeployScalingPlan=true"
            ))
        
        # =====================================================================
        # Networking
        # =====================================================================
        if self.parameters.get("createAvdVnet"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/virtualNetworks",
                name=f"vnet-{prefix.lower()}-{env.lower()}-001",
                description="Virtual Network for AVD session hosts",
                estimated_monthly_cost=0,
                pricing_notes="VNets are free - you pay for data transfer",
                conditional=True,
                condition_description="Created when createAvdVnet=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/networkSecurityGroups",
                name=f"nsg-avd-{prefix.lower()}-{env.lower()}-001",
                description="Network Security Group for AVD subnet",
                estimated_monthly_cost=0,
                pricing_notes="NSGs are free",
                conditional=True,
                condition_description="Created when createAvdVnet=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/networkSecurityGroups",
                name=f"nsg-pe-{prefix.lower()}-{env.lower()}-001",
                description="Network Security Group for Private Endpoints subnet",
                estimated_monthly_cost=0,
                pricing_notes="NSGs are free",
                conditional=True,
                condition_description="Created when createAvdVnet=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/routeTables",
                name=f"route-avd-{prefix.lower()}-{env.lower()}-001",
                description="Route Table for AVD subnet",
                estimated_monthly_cost=0,
                pricing_notes="Route Tables are free",
                conditional=True,
                condition_description="Created when createAvdVnet=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/routeTables",
                name=f"route-pe-{prefix.lower()}-{env.lower()}-001",
                description="Route Table for Private Endpoints subnet",
                estimated_monthly_cost=0,
                pricing_notes="Route Tables are free",
                conditional=True,
                condition_description="Created when createAvdVnet=true"
            ))
        
        if self.parameters.get("deployDDoSNetworkProtection"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/ddosProtectionPlans",
                name=f"ddos-vnet-{prefix.lower()}-{env.lower()}-001",
                description="DDoS Protection Plan for VNet",
                estimated_monthly_cost=AZURE_PRICING["ddos_protection_plan"],
                pricing_notes="Fixed monthly cost regardless of number of VNets",
                conditional=True,
                condition_description="Created when deployDDoSNetworkProtection=true"
            ))
        
        resources.append(ResourceInfo(
            resource_type="Microsoft.Network/applicationSecurityGroups",
            name=f"asg-{prefix.lower()}-{env.lower()}-001",
            description="Application Security Group for session host grouping",
            estimated_monthly_cost=0,
            pricing_notes="ASGs are free"
        ))
        
        # =====================================================================
        # Private DNS Zones
        # =====================================================================
        if self.parameters.get("createPrivateDnsZones"):
            dns_zones = [
                ("privatelink.file.core.windows.net", "Azure Files"),
                ("privatelink.vaultcore.azure.net", "Key Vault"),
            ]
            
            if self.parameters.get("deployAvdPrivateLinkService"):
                dns_zones.extend([
                    ("privatelink.wvd.microsoft.com", "AVD Feed Discovery"),
                    ("privatelink-global.wvd.microsoft.com", "AVD Global"),
                ])
            
            for zone_name, purpose in dns_zones:
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Network/privateDnsZones",
                    name=zone_name,
                    description=f"Private DNS Zone for {purpose}",
                    estimated_monthly_cost=0.50,  # ~$0.50/zone/month
                    pricing_notes="$0.50/zone/month + $0.40 per million queries",
                    conditional=True,
                    condition_description="Created when createPrivateDnsZones=true"
                ))
        
        # =====================================================================
        # Session Hosts (VMs)
        # =====================================================================
        if self.parameters.get("avdDeploySessionHosts"):
            vm_count = self.parameters.get("avdDeploySessionHostsCount", 1)
            vm_size = self.parameters.get("avdSessionHostsSize", "Standard_D4ads_v5")
            disk_type = self.parameters.get("avdSessionHostDiskType", "Premium_LRS")
            
            vm_pricing = AZURE_PRICING["vm_sizes"].get(vm_size, {"price_per_hour": 0.20})
            monthly_vm_cost = vm_pricing["price_per_hour"] * 730  # 730 hours/month
            
            disk_pricing = AZURE_PRICING["disk_types"].get(disk_type, 0.12)
            os_disk_size = self.parameters.get("customOsDiskSizeGB", 128)
            monthly_disk_cost = disk_pricing * os_disk_size
            
            for i in range(vm_count):
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Compute/virtualMachines",
                    name=f"vm{prefix.lower()}{env[0].lower()}-{i}",
                    description=f"AVD Session Host VM #{i+1} ({vm_size})",
                    estimated_monthly_cost=monthly_vm_cost,
                    pricing_notes=f"${vm_pricing['price_per_hour']}/hour @ 730 hrs/month (24/7)",
                    conditional=True,
                    condition_description="Created when avdDeploySessionHosts=true"
                ))
                
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Compute/disks",
                    name=f"vm{prefix.lower()}{env[0].lower()}-{i}-osdisk",
                    description=f"OS Disk for Session Host #{i+1} ({disk_type}, {os_disk_size}GB)",
                    estimated_monthly_cost=monthly_disk_cost,
                    pricing_notes=f"${disk_pricing}/GB/month",
                    conditional=True,
                    condition_description="Created with each session host"
                ))
                
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Network/networkInterfaces",
                    name=f"vm{prefix.lower()}{env[0].lower()}-{i}-nic",
                    description=f"Network Interface for Session Host #{i+1}",
                    estimated_monthly_cost=0,
                    pricing_notes="NICs are free",
                    conditional=True,
                    condition_description="Created with each session host"
                ))
        
        # =====================================================================
        # Key Vault
        # =====================================================================
        resources.append(ResourceInfo(
            resource_type="Microsoft.KeyVault/vaults",
            name=f"kv-sec-{prefix.lower()}-{env.lower()}",
            description="Key Vault for secrets (local admin, domain join credentials)",
            estimated_monthly_cost=1.00,
            pricing_notes="Premium tier: $1/key/month + $0.03/10K operations"
        ))
        
        if self.parameters.get("diskZeroTrust"):
            resources.append(ResourceInfo(
                resource_type="Microsoft.KeyVault/vaults",
                name=f"kv-key-{prefix.lower()}-{env.lower()}",
                description="Key Vault for disk encryption keys (Zero Trust)",
                estimated_monthly_cost=1.00,
                pricing_notes="Premium tier: $1/key/month + $0.03/10K operations",
                conditional=True,
                condition_description="Created when diskZeroTrust=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Compute/diskEncryptionSets",
                name=f"des-zt-{prefix.lower()}-{env.lower()}-001",
                description="Disk Encryption Set for VM disk encryption",
                estimated_monthly_cost=0,
                pricing_notes="Disk Encryption Sets are free",
                conditional=True,
                condition_description="Created when diskZeroTrust=true"
            ))
        
        # =====================================================================
        # Private Endpoints
        # =====================================================================
        if self.parameters.get("deployPrivateEndpointKeyvaultStorage"):
            pe_cost = AZURE_PRICING["private_endpoint_per_hour"] * 730
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/privateEndpoints",
                name=f"pe-kv-sec-{prefix.lower()}-{env.lower()}-vault",
                description="Private Endpoint for secrets Key Vault",
                estimated_monthly_cost=pe_cost,
                pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                conditional=True,
                condition_description="Created when deployPrivateEndpointKeyvaultStorage=true"
            ))
            
            if self.parameters.get("diskZeroTrust"):
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Network/privateEndpoints",
                    name=f"pe-kv-key-{prefix.lower()}-{env.lower()}-vault",
                    description="Private Endpoint for Zero Trust Key Vault",
                    estimated_monthly_cost=pe_cost,
                    pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                    conditional=True,
                    condition_description="Created when deployPrivateEndpointKeyvaultStorage=true and diskZeroTrust=true"
                ))
            
            if self.parameters.get("createAvdFslogixDeployment"):
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Network/privateEndpoints",
                    name=f"pe-stfsl{prefix.lower()}-file",
                    description="Private Endpoint for FSLogix Storage Account",
                    estimated_monthly_cost=pe_cost,
                    pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                    conditional=True,
                    condition_description="Created when FSLogix deployment is enabled"
                ))
            
            if self.parameters.get("createAppAttachDeployment"):
                resources.append(ResourceInfo(
                    resource_type="Microsoft.Network/privateEndpoints",
                    name=f"pe-stappa{prefix.lower()}-file",
                    description="Private Endpoint for App Attach Storage Account",
                    estimated_monthly_cost=pe_cost,
                    pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                    conditional=True,
                    condition_description="Created when App Attach deployment is enabled"
                ))
        
        if self.parameters.get("deployAvdPrivateLinkService"):
            pe_cost = AZURE_PRICING["private_endpoint_per_hour"] * 730
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/privateEndpoints",
                name=f"pe-vdpool-{prefix.lower()}-{env.lower()}-connection",
                description="Private Endpoint for Host Pool connection",
                estimated_monthly_cost=pe_cost,
                pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                conditional=True,
                condition_description="Created when deployAvdPrivateLinkService=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/privateEndpoints",
                name=f"pe-vdws-{prefix.lower()}-{env.lower()}-discovery",
                description="Private Endpoint for Workspace feed discovery",
                estimated_monthly_cost=pe_cost,
                pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                conditional=True,
                condition_description="Created when deployAvdPrivateLinkService=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Network/privateEndpoints",
                name=f"pe-vdws-{prefix.lower()}-{env.lower()}-global",
                description="Private Endpoint for Workspace global",
                estimated_monthly_cost=pe_cost,
                pricing_notes=f"${AZURE_PRICING['private_endpoint_per_hour']}/hour",
                conditional=True,
                condition_description="Created when deployAvdPrivateLinkService=true"
            ))
        
        # =====================================================================
        # Storage Accounts
        # =====================================================================
        if self.parameters.get("createAvdFslogixDeployment"):
            storage_perf = self.parameters.get("fslogixStoragePerformance", "Premium")
            storage_sku = f"{storage_perf}_LRS"
            quota_gb = self.parameters.get("fslogixFileShareQuotaSize", 100)
            storage_price = AZURE_PRICING["storage"].get(storage_sku, 0.16)
            monthly_storage_cost = storage_price * quota_gb
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Storage/storageAccounts",
                name=f"stfsl{prefix.lower()}{env[0].lower()}",
                description=f"Storage Account for FSLogix profiles ({storage_perf})",
                estimated_monthly_cost=monthly_storage_cost,
                pricing_notes=f"${storage_price}/GB/month for {quota_gb}GB",
                conditional=True,
                condition_description="Created when createAvdFslogixDeployment=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Storage/storageAccounts/fileServices/shares",
                name=f"fslogix-pc-{prefix.lower()}-{env.lower()}-001",
                description="Azure File Share for FSLogix profile containers",
                estimated_monthly_cost=0,  # Included in storage account cost
                pricing_notes="Included in storage account pricing",
                conditional=True,
                condition_description="Created when createAvdFslogixDeployment=true"
            ))
        
        if self.parameters.get("createAppAttachDeployment"):
            storage_perf = self.parameters.get("appAttachStoragePerformance", "Premium")
            storage_sku = f"{storage_perf}_LRS"
            quota_gb = self.parameters.get("appAttachFileShareQuotaSize", 100)
            storage_price = AZURE_PRICING["storage"].get(storage_sku, 0.16)
            monthly_storage_cost = storage_price * quota_gb
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Storage/storageAccounts",
                name=f"stappa{prefix.lower()}{env[0].lower()}",
                description=f"Storage Account for App Attach packages ({storage_perf})",
                estimated_monthly_cost=monthly_storage_cost,
                pricing_notes=f"${storage_price}/GB/month for {quota_gb}GB",
                conditional=True,
                condition_description="Created when createAppAttachDeployment=true"
            ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Storage/storageAccounts/fileServices/shares",
                name=f"appa-{prefix.lower()}-{env.lower()}-001",
                description="Azure File Share for App Attach MSIX packages",
                estimated_monthly_cost=0,
                pricing_notes="Included in storage account pricing",
                conditional=True,
                condition_description="Created when createAppAttachDeployment=true"
            ))
        
        # =====================================================================
        # Identity
        # =====================================================================
        resources.append(ResourceInfo(
            resource_type="Microsoft.ManagedIdentity/userAssignedIdentities",
            name=f"id-storage-{prefix.lower()}-{env.lower()}-001",
            description="Managed Identity for storage account management",
            estimated_monthly_cost=0,
            pricing_notes="Managed Identities are free"
        ))
        
        # =====================================================================
        # Monitoring
        # =====================================================================
        if self.parameters.get("avdDeployMonitoring"):
            if self.parameters.get("deployAlaWorkspace"):
                data_retention = self.parameters.get("avdAlaWorkspaceDataRetention", 90)
                # Estimate: ~500MB/VM/day for AVD monitoring
                vm_count = self.parameters.get("avdDeploySessionHostsCount", 1) if self.parameters.get("avdDeploySessionHosts") else 0
                estimated_gb_per_month = vm_count * 0.5 * 30  # 500MB/day * 30 days
                monthly_ala_cost = estimated_gb_per_month * AZURE_PRICING["log_analytics_per_gb"]
                
                resources.append(ResourceInfo(
                    resource_type="Microsoft.OperationalInsights/workspaces",
                    name=f"log-avd-{prefix.lower()}-{env.lower()}",
                    description=f"Log Analytics Workspace ({data_retention} days retention)",
                    estimated_monthly_cost=monthly_ala_cost,
                    pricing_notes=f"${AZURE_PRICING['log_analytics_per_gb']}/GB ingested. Estimate: {estimated_gb_per_month:.1f}GB/month",
                    conditional=True,
                    condition_description="Created when deployAlaWorkspace=true"
                ))
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Insights/dataCollectionRules",
                name=f"microsoft-avdi-{location}",
                description="Data Collection Rule for AVD Insights",
                estimated_monthly_cost=0,
                pricing_notes="DCRs are free",
                conditional=True,
                condition_description="Created when avdDeployMonitoring=true"
            ))
        
        # =====================================================================
        # Management VM (for domain-joined storage)
        # =====================================================================
        identity_provider = self.parameters.get("avdIdentityServiceProvider", "ADDS")
        create_storage = self.parameters.get("createAvdFslogixDeployment") or self.parameters.get("createAppAttachDeployment")
        
        if identity_provider != "EntraID" and create_storage:
            vm_size = self.parameters.get("avdSessionHostsSize", "Standard_D4ads_v5")
            vm_pricing = AZURE_PRICING["vm_sizes"].get(vm_size, {"price_per_hour": 0.20})
            monthly_vm_cost = vm_pricing["price_per_hour"] * 730
            
            resources.append(ResourceInfo(
                resource_type="Microsoft.Compute/virtualMachines",
                name=f"vmmgmt{prefix.lower()}{env[0].lower()}",
                description="Management VM for domain-joining storage accounts",
                estimated_monthly_cost=monthly_vm_cost,
                pricing_notes=f"Temporary VM - can be deleted after deployment",
                conditional=True,
                condition_description="Created when identity provider is ADDS/EntraDS and storage is deployed"
            ))
        
        return resources
    
    def _calculate_costs(self, resources: List[ResourceInfo]) -> Dict[str, float]:
        """Calculate cost breakdown by category"""
        cost_breakdown = {
            "Compute (VMs)": 0.0,
            "Storage (Disks)": 0.0,
            "Storage (Azure Files)": 0.0,
            "Networking": 0.0,
            "Security (Key Vault)": 0.0,
            "Monitoring": 0.0,
            "Private Endpoints": 0.0,
            "DDoS Protection": 0.0,
            "DNS": 0.0,
        }
        
        for resource in resources:
            if resource.resource_type == "Microsoft.Compute/virtualMachines":
                cost_breakdown["Compute (VMs)"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.Compute/disks":
                cost_breakdown["Storage (Disks)"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.Storage/storageAccounts":
                cost_breakdown["Storage (Azure Files)"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.KeyVault/vaults":
                cost_breakdown["Security (Key Vault)"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.OperationalInsights/workspaces":
                cost_breakdown["Monitoring"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.Network/privateEndpoints":
                cost_breakdown["Private Endpoints"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.Network/ddosProtectionPlans":
                cost_breakdown["DDoS Protection"] += resource.estimated_monthly_cost
            elif resource.resource_type == "Microsoft.Network/privateDnsZones":
                cost_breakdown["DNS"] += resource.estimated_monthly_cost
        
        # Remove zero-cost categories
        return {k: v for k, v in cost_breakdown.items() if v > 0}
    
    def _analyze_prerequisites(self) -> List[PrerequisiteInfo]:
        """Analyze deployment prerequisites"""
        prerequisites = []
        
        # =====================================================================
        # Azure Subscription Requirements
        # =====================================================================
        prerequisites.append(PrerequisiteInfo(
            name="Azure Subscription",
            description="Active Azure subscription with sufficient permissions",
            required=True,
            how_to_check="az account show --query 'state' -o tsv",
            how_to_fulfill="Create a new subscription or ensure existing subscription is active",
            category="permissions"
        ))
        
        prerequisites.append(PrerequisiteInfo(
            name="Subscription Owner/Contributor",
            description="Owner or Contributor role on the target subscription",
            required=True,
            how_to_check="az role assignment list --assignee <your-object-id> --scope /subscriptions/<sub-id> --query '[].roleDefinitionName'",
            how_to_fulfill="Request Owner or Contributor role assignment from subscription administrator",
            category="permissions"
        ))
        
        prerequisites.append(PrerequisiteInfo(
            name="User Access Administrator",
            description="User Access Administrator role for RBAC assignments (role assignments for identities)",
            required=True,
            how_to_check="az role assignment list --assignee <your-object-id> --query \"[?roleDefinitionName=='User Access Administrator']\"",
            how_to_fulfill="Request User Access Administrator role or use Owner role which includes this permission",
            category="permissions"
        ))
        
        # =====================================================================
        # Resource Provider Registration
        # =====================================================================
        resource_providers = [
            ("Microsoft.DesktopVirtualization", "AVD Host Pools, Workspaces, and Application Groups"),
            ("Microsoft.Compute", "Virtual Machines and Disks"),
            ("Microsoft.Network", "Virtual Networks, NSGs, and Private Endpoints"),
            ("Microsoft.Storage", "Storage Accounts for FSLogix"),
            ("Microsoft.KeyVault", "Key Vault for secrets and keys"),
            ("Microsoft.ManagedIdentity", "Managed Identities"),
            ("Microsoft.Insights", "Monitoring and Diagnostics"),
            ("Microsoft.OperationalInsights", "Log Analytics Workspace"),
        ]
        
        for provider, purpose in resource_providers:
            prerequisites.append(PrerequisiteInfo(
                name=f"Register {provider}",
                description=f"Resource provider for {purpose}",
                required=True,
                how_to_check=f"az provider show -n {provider} --query 'registrationState' -o tsv",
                how_to_fulfill=f"az provider register -n {provider}",
                category="configuration"
            ))
        
        # =====================================================================
        # Quota Requirements
        # =====================================================================
        if self.parameters.get("avdDeploySessionHosts"):
            vm_count = self.parameters.get("avdDeploySessionHostsCount", 1)
            vm_size = self.parameters.get("avdSessionHostsSize", "Standard_D4ads_v5")
            vm_info = AZURE_PRICING["vm_sizes"].get(vm_size, {"vcpu": 4})
            total_vcpus = vm_count * vm_info.get("vcpu", 4)
            
            prerequisites.append(PrerequisiteInfo(
                name=f"vCPU Quota ({vm_size})",
                description=f"At least {total_vcpus} vCPUs quota for {vm_size} VMs ({vm_count} VMs × {vm_info.get('vcpu', 4)} vCPUs)",
                required=True,
                how_to_check=f"az vm list-usage -l <location> --query \"[?localName=='{vm_size.split('_')[1]}']\"",
                how_to_fulfill="Request quota increase via Azure Portal > Subscriptions > Usage + quotas",
                category="quota"
            ))
        
        # =====================================================================
        # Identity Requirements
        # =====================================================================
        identity_provider = self.parameters.get("avdIdentityServiceProvider", "ADDS")
        
        if identity_provider == "ADDS":
            prerequisites.append(PrerequisiteInfo(
                name="Active Directory Domain Services",
                description="Existing AD DS domain with connectivity to Azure",
                required=True,
                how_to_check="Test domain connectivity from Azure VNet",
                how_to_fulfill="Deploy AD DS domain controllers or use Azure AD DS",
                category="identity"
            ))
            
            prerequisites.append(PrerequisiteInfo(
                name="Domain Join Account",
                description="Service account with permissions to join computers to the domain",
                required=True,
                how_to_check="Verify account has 'Add workstations to domain' permission",
                how_to_fulfill="Create service account with domain join permissions in the target OU",
                category="identity"
            ))
            
        elif identity_provider == "EntraDS":
            prerequisites.append(PrerequisiteInfo(
                name="Microsoft Entra Domain Services",
                description="Existing Entra DS managed domain",
                required=True,
                how_to_check="az ad ds show --name <domain-name> --resource-group <rg>",
                how_to_fulfill="Deploy Microsoft Entra Domain Services in the target region",
                category="identity"
            ))
            
        elif identity_provider == "EntraID":
            prerequisites.append(PrerequisiteInfo(
                name="Microsoft Entra ID Joined VMs",
                description="Entra ID join capability for session hosts",
                required=True,
                how_to_check="Verify Entra ID tenant supports device join",
                how_to_fulfill="Ensure Entra ID P1/P2 license for Entra join with Intune",
                category="identity"
            ))
        
        # =====================================================================
        # Networking Requirements
        # =====================================================================
        if not self.parameters.get("createAvdVnet"):
            prerequisites.append(PrerequisiteInfo(
                name="Existing Virtual Network",
                description="Pre-existing VNet with subnets for AVD and Private Endpoints",
                required=True,
                how_to_check="az network vnet show --ids <vnet-resource-id>",
                how_to_fulfill="Create VNet with at least /24 subnet for AVD and /27 for Private Endpoints",
                category="networking"
            ))
            
            prerequisites.append(PrerequisiteInfo(
                name="Existing AVD Subnet",
                description="Subnet with sufficient IP addresses for session hosts",
                required=True,
                how_to_check="Verify subnet has enough available IPs",
                how_to_fulfill="Ensure subnet can accommodate all planned session hosts",
                category="networking"
            ))
        
        if identity_provider in ["ADDS", "EntraDS"]:
            prerequisites.append(PrerequisiteInfo(
                name="DNS Configuration",
                description="DNS servers configured to resolve domain names",
                required=True,
                how_to_check="Verify VNet DNS settings point to domain controllers",
                how_to_fulfill="Configure VNet custom DNS to use AD DS/Entra DS DNS servers",
                category="networking"
            ))
        
        # =====================================================================
        # AVD-Specific Requirements
        # =====================================================================
        if self.parameters.get("avdDeployScalingPlan"):
            prerequisites.append(PrerequisiteInfo(
                name="AVD Service Principal",
                description="Azure Virtual Desktop service principal for scaling plan",
                required=True,
                how_to_check="az ad sp show --id 9cdead84-a844-4324-93f2-b2e6bb768d07",
                how_to_fulfill="The service principal should exist by default. If not, contact support.",
                category="permissions"
            ))
        
        if self.parameters.get("avdStartVmOnConnect", True):
            prerequisites.append(PrerequisiteInfo(
                name="Start VM on Connect Configuration",
                description="Desktop Virtualization Power On Contributor role for AVD service principal",
                required=True,
                how_to_check="az role assignment list --assignee 9cdead84-a844-4324-93f2-b2e6bb768d07 --scope /subscriptions/<sub-id>",
                how_to_fulfill="Deployment will create this role assignment automatically",
                category="permissions"
            ))
        
        # =====================================================================
        # Security Requirements
        # =====================================================================
        if self.parameters.get("diskZeroTrust"):
            prerequisites.append(PrerequisiteInfo(
                name="Key Vault Soft Delete",
                description="Soft delete enabled for Key Vault (required for disk encryption)",
                required=True,
                how_to_check="This is the default setting for new Key Vaults",
                how_to_fulfill="Deployment configures this automatically",
                category="configuration"
            ))
        
        return prerequisites
    
    def _analyze_existing_resources(self) -> List[ExistingResourceCheck]:
        """Analyze checks for existing resources"""
        checks = []
        
        prefix = self.parameters.get("deploymentPrefix", "AVD1")
        env = self.parameters.get("deploymentEnvironment", "Dev")
        subscription_id = self.parameters.get("avdWorkloadSubsId", "")
        
        # Resource Groups
        rg_names = [
            f"rg-avd-{prefix.lower()}-{env.lower()}-service-objects",
            f"rg-avd-{prefix.lower()}-{env.lower()}-pool-compute",
            f"rg-avd-{prefix.lower()}-{env.lower()}-network",
            f"rg-avd-{prefix.lower()}-{env.lower()}-storage",
            f"rg-avd-{prefix.lower()}-{env.lower()}-monitoring",
        ]
        
        for rg_name in rg_names:
            checks.append(ExistingResourceCheck(
                resource_type="Microsoft.Resources/resourceGroups",
                identifier=f"/subscriptions/{subscription_id}/resourceGroups/{rg_name}" if subscription_id else rg_name,
                description=f"Resource Group: {rg_name}",
                impact_if_exists="Existing resources in the RG will be preserved. New resources will be added. Tags may be updated."
            ))
        
        # Host Pool
        checks.append(ExistingResourceCheck(
            resource_type="Microsoft.DesktopVirtualization/hostPools",
            identifier=f"vdpool-{prefix.lower()}-{env.lower()}-001",
            description=f"Host Pool: vdpool-{prefix.lower()}-{env.lower()}-001",
            impact_if_exists="Host pool settings will be updated. Existing session hosts will NOT be affected. New session hosts will be added."
        ))
        
        # Workspace
        checks.append(ExistingResourceCheck(
            resource_type="Microsoft.DesktopVirtualization/workspaces",
            identifier=f"vdws-{prefix.lower()}-{env.lower()}-001",
            description=f"Workspace: vdws-{prefix.lower()}-{env.lower()}-001",
            impact_if_exists="Workspace settings and friendly name may be updated."
        ))
        
        # Virtual Network
        if self.parameters.get("createAvdVnet"):
            checks.append(ExistingResourceCheck(
                resource_type="Microsoft.Network/virtualNetworks",
                identifier=f"vnet-{prefix.lower()}-{env.lower()}-001",
                description=f"Virtual Network: vnet-{prefix.lower()}-{env.lower()}-001",
                impact_if_exists="VNet will be updated. Existing subnets preserved. New subnets may be added. DNS settings may change."
            ))
        
        # Storage Accounts
        if self.parameters.get("createAvdFslogixDeployment"):
            checks.append(ExistingResourceCheck(
                resource_type="Microsoft.Storage/storageAccounts",
                identifier=f"stfsl{prefix.lower()}{env[0].lower()}*",
                description=f"FSLogix Storage Account (name includes unique suffix)",
                impact_if_exists="Storage settings may be updated. EXISTING FILE SHARES AND DATA WILL BE PRESERVED."
            ))
        
        # Key Vault
        checks.append(ExistingResourceCheck(
            resource_type="Microsoft.KeyVault/vaults",
            identifier=f"kv-sec-{prefix.lower()}-{env.lower()}*",
            description=f"Secrets Key Vault (name includes unique suffix)",
            impact_if_exists="Key Vault settings may be updated. EXISTING SECRETS WILL BE PRESERVED unless explicitly overwritten."
        ))
        
        # Log Analytics
        if self.parameters.get("avdDeployMonitoring") and self.parameters.get("deployAlaWorkspace"):
            checks.append(ExistingResourceCheck(
                resource_type="Microsoft.OperationalInsights/workspaces",
                identifier=f"log-avd-{prefix.lower()}-{env.lower()}",
                description=f"Log Analytics Workspace: log-avd-{prefix.lower()}-{env.lower()}",
                impact_if_exists="Workspace retention settings may be updated. EXISTING DATA WILL BE PRESERVED."
            ))
        
        return checks
    
    def _generate_warnings_and_errors(self) -> Tuple[List[str], List[str]]:
        """Generate warnings and errors based on configuration"""
        warnings = []
        errors = []
        
        # Validate required parameters
        if not self.parameters.get("avdWorkloadSubsId"):
            errors.append("❌ Subscription ID (avdWorkloadSubsId) is required but not set")
        
        identity_provider = self.parameters.get("avdIdentityServiceProvider", "ADDS")
        if identity_provider in ["ADDS", "EntraDS"]:
            if not self.parameters.get("identityDomainName"):
                errors.append("❌ Domain name (identityDomainName) is required for ADDS/EntraDS identity provider")
        
        # Validate prefix length
        prefix = self.parameters.get("deploymentPrefix", "")
        if len(prefix) < 2 or len(prefix) > 4:
            errors.append(f"❌ Deployment prefix must be 2-4 characters (current: {len(prefix)})")
        
        # Cost warnings
        if self.parameters.get("deployDDoSNetworkProtection"):
            warnings.append(f"⚠️ DDoS Protection Plan costs ~${AZURE_PRICING['ddos_protection_plan']:,.0f}/month. Consider if this is needed for dev/test.")
        
        vm_count = self.parameters.get("avdDeploySessionHostsCount", 0)
        if vm_count > 10:
            warnings.append(f"⚠️ Deploying {vm_count} session hosts. Ensure you have sufficient vCPU quota.")
        
        # Security recommendations
        if not self.parameters.get("diskZeroTrust"):
            warnings.append("⚠️ Zero Trust disk encryption is disabled. Recommended for production workloads.")
        
        if not self.parameters.get("deployPrivateEndpointKeyvaultStorage"):
            warnings.append("⚠️ Private endpoints disabled. Resources will be accessible over public internet.")
        
        if not self.parameters.get("deployAvdPrivateLinkService"):
            warnings.append("⚠️ AVD Private Link disabled. Users will connect via public endpoints.")
        
        # Monitoring recommendations
        if not self.parameters.get("avdDeployMonitoring"):
            warnings.append("⚠️ Monitoring is disabled. Strongly recommended for troubleshooting and insights.")
        
        # Availability recommendations
        env = self.parameters.get("deploymentEnvironment", "Dev")
        if env == "Prod":
            if self.parameters.get("availability") != "availabilityZones":
                warnings.append("⚠️ Production environment without Availability Zones. Consider enabling for higher availability.")
            
            if not self.parameters.get("zoneRedundantStorage", False):
                warnings.append("⚠️ Production environment without Zone Redundant Storage. Consider enabling for data resilience.")
        
        return warnings, errors
    
    def generate_report(self, result: Optional[ValidationResult] = None) -> str:
        """
        Generate a human-readable validation report
        
        Args:
            result: Optional pre-computed ValidationResult. If not provided, validate() is called.
            
        Returns:
            Formatted report string
        """
        if result is None:
            result = self.validate()
        
        lines = []
        lines.append("=" * 80)
        lines.append("AVD PRE-DEPLOYMENT VALIDATION REPORT")
        lines.append("=" * 80)
        lines.append("")
        
        # Summary
        status = "✅ VALID" if result.is_valid else "❌ VALIDATION FAILED"
        lines.append(f"Status: {status}")
        lines.append(f"Total Resources: {len(result.resources_to_create)}")
        lines.append(f"Estimated Monthly Cost: ${result.estimated_monthly_cost:,.2f}")
        lines.append("")
        
        # Errors (if any)
        if result.errors:
            lines.append("-" * 80)
            lines.append("ERRORS (Must be fixed before deployment)")
            lines.append("-" * 80)
            for error in result.errors:
                lines.append(f"  {error}")
            lines.append("")
        
        # Warnings
        if result.warnings:
            lines.append("-" * 80)
            lines.append("WARNINGS (Review recommended)")
            lines.append("-" * 80)
            for warning in result.warnings:
                lines.append(f"  {warning}")
            lines.append("")
        
        # Cost Breakdown
        lines.append("-" * 80)
        lines.append("ESTIMATED MONTHLY COST BREAKDOWN")
        lines.append("-" * 80)
        for category, cost in sorted(result.cost_breakdown.items(), key=lambda x: -x[1]):
            if cost > 0:
                lines.append(f"  {category:30} ${cost:>10,.2f}")
        lines.append(f"  {'─' * 42}")
        lines.append(f"  {'TOTAL':30} ${result.estimated_monthly_cost:>10,.2f}")
        lines.append("")
        lines.append("  Note: Costs are estimates based on 24/7 operation. Actual costs may vary.")
        lines.append("        Use Azure Pricing Calculator for precise estimates.")
        lines.append("")
        
        # Resources to Create
        lines.append("-" * 80)
        lines.append("RESOURCES TO BE CREATED")
        lines.append("-" * 80)
        
        # Group by resource type
        by_type: Dict[str, List[ResourceInfo]] = {}
        for resource in result.resources_to_create:
            type_name = resource.resource_type.split("/")[-1]
            if type_name not in by_type:
                by_type[type_name] = []
            by_type[type_name].append(resource)
        
        for type_name, resources in sorted(by_type.items()):
            lines.append(f"\n  [{type_name}] ({len(resources)} resource(s))")
            for resource in resources:
                cost_str = f"${resource.estimated_monthly_cost:.2f}/mo" if resource.estimated_monthly_cost > 0 else "Free"
                conditional_str = " (conditional)" if resource.conditional else ""
                lines.append(f"    • {resource.name}{conditional_str}")
                lines.append(f"      {resource.description}")
                lines.append(f"      Cost: {cost_str} - {resource.pricing_notes}")
                if resource.conditional:
                    lines.append(f"      Condition: {resource.condition_description}")
        
        lines.append("")
        
        # Prerequisites
        lines.append("-" * 80)
        lines.append("PREREQUISITES CHECKLIST")
        lines.append("-" * 80)
        
        # Group by category
        by_category: Dict[str, List[PrerequisiteInfo]] = {}
        for prereq in result.prerequisites:
            if prereq.category not in by_category:
                by_category[prereq.category] = []
            by_category[prereq.category].append(prereq)
        
        category_order = ["permissions", "quota", "identity", "networking", "configuration"]
        for category in category_order:
            if category in by_category:
                lines.append(f"\n  [{category.upper()}]")
                for prereq in by_category[category]:
                    required_str = "REQUIRED" if prereq.required else "RECOMMENDED"
                    lines.append(f"    □ [{required_str}] {prereq.name}")
                    lines.append(f"      {prereq.description}")
                    lines.append(f"      Check: {prereq.how_to_check}")
                    lines.append(f"      Fulfill: {prereq.how_to_fulfill}")
        
        lines.append("")
        
        # Existing Resource Checks
        lines.append("-" * 80)
        lines.append("EXISTING RESOURCE IMPACT ANALYSIS")
        lines.append("-" * 80)
        lines.append("")
        lines.append("  The following resources will be checked/updated if they already exist:")
        lines.append("")
        
        for check in result.existing_resource_checks:
            lines.append(f"    • {check.description}")
            lines.append(f"      Impact: {check.impact_if_exists}")
        
        lines.append("")
        lines.append("=" * 80)
        lines.append("END OF VALIDATION REPORT")
        lines.append("=" * 80)
        
        return "\n".join(lines)
    
    def export_to_json(self, result: Optional[ValidationResult] = None) -> str:
        """Export validation result to JSON format"""
        if result is None:
            result = self.validate()
        
        data = {
            "validation_status": "valid" if result.is_valid else "invalid",
            "estimated_monthly_cost_usd": result.estimated_monthly_cost,
            "cost_breakdown": result.cost_breakdown,
            "errors": result.errors,
            "warnings": result.warnings,
            "resources": [
                {
                    "type": r.resource_type,
                    "name": r.name,
                    "description": r.description,
                    "estimated_cost": r.estimated_monthly_cost,
                    "pricing_notes": r.pricing_notes,
                    "conditional": r.conditional,
                    "condition": r.condition_description if r.conditional else None
                }
                for r in result.resources_to_create
            ],
            "prerequisites": [
                {
                    "name": p.name,
                    "description": p.description,
                    "required": p.required,
                    "category": p.category,
                    "how_to_check": p.how_to_check,
                    "how_to_fulfill": p.how_to_fulfill
                }
                for p in result.prerequisites
            ],
            "existing_resource_checks": [
                {
                    "type": c.resource_type,
                    "identifier": c.identifier,
                    "description": c.description,
                    "impact_if_exists": c.impact_if_exists
                }
                for c in result.existing_resource_checks
            ]
        }
        
        return json.dumps(data, indent=2)


# =============================================================================
# Interactive CLI Mode
# =============================================================================

def main():
    """Interactive CLI for pre-deployment validation"""
    print("\n" + "=" * 60)
    print("AVD Pre-Deployment Validator")
    print("=" * 60)
    
    validator = PreDeploymentValidator()
    
    # Collect basic parameters interactively
    print("\nEnter deployment parameters (press Enter for defaults):\n")
    
    prompts = [
        ("deploymentPrefix", "Deployment prefix (2-4 chars)", "AVD1"),
        ("deploymentEnvironment", "Environment (Dev/Test/Prod)", "Dev"),
        ("avdWorkloadSubsId", "Subscription ID", ""),
        ("avdIdentityServiceProvider", "Identity (ADDS/EntraDS/EntraID)", "ADDS"),
        ("avdDeploySessionHostsCount", "Number of session hosts", "1"),
        ("avdSessionHostsSize", "VM size", "Standard_D4ads_v5"),
    ]
    
    params = {}
    for param_name, prompt, default in prompts:
        user_input = input(f"  {prompt} [{default}]: ").strip()
        if user_input:
            # Convert to int if it looks like a number
            if user_input.isdigit():
                user_input = int(user_input)
            params[param_name] = user_input
        elif default:
            params[param_name] = int(default) if isinstance(default, str) and default.isdigit() else default
    
    validator.set_parameters(params)
    
    # Run validation
    print("\nValidating deployment configuration...\n")
    result = validator.validate()
    
    # Print report
    print(validator.generate_report(result))
    
    # Offer to save
    save = input("\nSave report to file? (y/n): ").strip().lower()
    if save == 'y':
        filename = input("  Filename [validation-report.txt]: ").strip() or "validation-report.txt"
        with open(filename, 'w') as f:
            f.write(validator.generate_report(result))
        print(f"  Report saved to {filename}")
        
        save_json = input("  Also save as JSON? (y/n): ").strip().lower()
        if save_json == 'y':
            json_filename = filename.rsplit('.', 1)[0] + ".json"
            with open(json_filename, 'w') as f:
                f.write(validator.export_to_json(result))
            print(f"  JSON saved to {json_filename}")


if __name__ == "__main__":
    main()
