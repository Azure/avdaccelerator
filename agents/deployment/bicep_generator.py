"""
Deployment Agent - Generates Infrastructure as Code

This agent converts AVD specifications into deployable IaC:
- Bicep templates
- Parameter files
- Deployment scripts
- Naming conventions (CAF compliant)

Reference Architecture: workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
"""

from pathlib import Path
from typing import Dict, Any, List
import sys
import json
sys.path.append(str(Path(__file__).parent.parent))
from core.orchestrator import AgentResult, AgentType


# AVD Accelerator Baseline Architecture Defaults
# Based on: workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
# Aligned with: workload/bicep/deploy-baseline.bicep defaults
BASELINE_DEFAULTS = {
    'deployment': {
        'prefix': 'AVD1',
        'environment': 'Dev',
        'diskEncryptionKeyExpirationDays': 60
    },
    'hostPool': {
        'type': 'Pooled',
        'loadBalancerType': 'BreadthFirst',
        'maxSessionLimit': 8,
        'preferredAppGroupType': 'Desktop',
        'publicNetworkAccess': 'Enabled',
        'workspacePublicNetworkAccess': 'Enabled',
        'startVMOnConnect': True,
        'rdpProperties': 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2',
        'deployScalingPlan': True
    },
    'sessionHosts': {
        'deploy': True,
        'count': 1,
        'countIndex': 1,
        'vmSize': 'Standard_D4ads_v5',
        'diskType': 'Premium_LRS',
        'customOsDiskSizeGB': 0,
        'acceleratedNetworking': True,
        'availability': 'None',
        'availabilityZones': ['1', '2', '3'],
        'securityType': 'TrustedLaunch',
        'secureBoot': True,
        'vTpm': True,
        'imageOffer': 'Office-365',
        'imageSku': 'win11-24h2-avd-m365',
        'useSharedImage': False,
        'managementVmImage': 'winServer_2022_Datacenter_smalldisk_g2'
    },
    'identity': {
        'provider': 'ADDS',
        'intuneEnrollment': False
    },
    'networking': {
        'createNew': True,
        'vnetAddressSpace': '10.10.0.0/16',
        'avdSubnetPrefix': '10.10.1.0/24',
        'privateEndpointSubnetPrefix': '10.10.2.0/27',
        'deployDDoSProtection': False,
        'vnetGatewayOnHub': False
    },
    'storage': {
        'fslogix': {
            'enabled': True,
            'performance': 'Premium',
            'quotaSizeGB': 1
        },
        'appAttach': {
            'enabled': False,
            'performance': 'Premium',
            'quotaSizeGB': 1
        },
        'zoneRedundant': False
    },
    'security': {
        'deployPrivateEndpoints': True,
        'deployAvdPrivateLink': False,
        'createPrivateDnsZones': True,
        'diskZeroTrust': False,
        'deployGpuPolicies': False
    },
    'monitoring': {
        'enabled': False,
        'deployLogAnalytics': True,
        'retentionDays': 90,
        'deployCustomPolicies': False
    }
}


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
    """Generates IaC from AVD specifications
    
    Uses AVD Accelerator Baseline Architecture as default reference:
    workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
    """
    
    def __init__(self, spec: Dict[str, Any], output_dir: Path):
        self.spec = spec
        self.output_dir = output_dir
        self.spec_data = spec.get('spec', {})
        self.metadata = spec.get('metadata', {})
        self.defaults = BASELINE_DEFAULTS
        
        # Initialize naming service with baseline defaults
        prefix = self.spec_data.get('deploymentPrefix', self.defaults['deployment']['prefix'])
        env = self.metadata.get('environment', self.defaults['deployment']['environment'])
        self.naming = NamingService(prefix, env)
    
    def _get_default(self, path: str) -> Any:
        """Get default value from baseline defaults"""
        parts = path.split('.')
        value = self.defaults
        for part in parts:
            if isinstance(value, dict):
                value = value.get(part)
            else:
                return None
        return value
    
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
        """Build the main Bicep template based on AVD Accelerator Baseline Architecture
        
        Reference: workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx
        Aligned with: workload/bicep/deploy-baseline.bicep
        """
        deployment_name = self.metadata.get('name', 'avd-deployment')
        region = self.metadata.get('region', 'eastus2')
        environment = self.metadata.get('environment', self.defaults['deployment']['environment'])
        deployment_prefix = self.spec_data.get('deploymentPrefix', self.defaults['deployment']['prefix'])
        
        lines = [
            f"// AVD Deployment: {deployment_name}",
            f"// Generated from specification - AVD Accelerator Baseline Architecture",
            f"// Reference: workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx",
            f"// Environment: {environment}",
            "",
            "targetScope = 'subscription'",
            "",
            "// ========== Parameters (Baseline Defaults) ==========",
            "",
            "@minLength(2)",
            "@maxLength(4)",
            "@description('Deployment prefix for resource naming')",
            f"param deploymentPrefix string = '{deployment_prefix}'",
            "",
            "@allowed(['Dev', 'Test', 'Prod'])",
            "@description('Environment type')",
            f"param deploymentEnvironment string = '{environment}'",
            "",
            "@description('Primary Azure region for deployment')",
            f"param location string = '{region}'",
            "",
            "@description('AVD session host region (can differ from management plane)')",
            f"param avdSessionHostLocation string = '{region}'",
            "",
            "@description('AVD management plane region')",
            f"param avdManagementPlaneLocation string = '{region}'",
            "",
            f"@maxValue(730)",
            f"@minValue(30)",
            f"@description('Disk encryption key expiration in days')",
            f"param diskEncryptionKeyExpirationInDays int = {self.defaults['deployment']['diskEncryptionKeyExpirationDays']}",
            "",
            "// ========== Identity Parameters ==========",
            "",
            "@allowed(['ADDS', 'EntraDS', 'EntraID', 'EntraIDKerberos'])",
            f"@description('Identity service provider')",
            f"param avdIdentityServiceProvider string = '{self.defaults['identity']['provider']}'",
            "",
            f"@description('Enroll session hosts on Intune')",
            f"param createIntuneEnrollment bool = {str(self.defaults['identity']['intuneEnrollment']).lower()}",
            "",
            "// ========== Host Pool Parameters ==========",
            "",
            "@allowed(['Personal', 'Pooled'])",
            f"@description('AVD host pool type')",
            f"param avdHostPoolType string = '{self.defaults['hostPool']['type']}'",
            "",
            "@allowed(['Desktop', 'RemoteApp'])",
            f"@description('Preferred application group type')",
            f"param hostPoolPreferredAppGroupType string = '{self.defaults['hostPool']['preferredAppGroupType']}'",
            "",
            "@allowed(['Disabled', 'Enabled', 'EnabledForClientsOnly', 'EnabledForSessionHostsOnly'])",
            f"@description('Host pool public network access')",
            f"param hostPoolPublicNetworkAccess string = '{self.defaults['hostPool']['publicNetworkAccess']}'",
            "",
            "@allowed(['BreadthFirst', 'DepthFirst'])",
            f"@description('Host pool load balancing type')",
            f"param avdHostPoolLoadBalancerType string = '{self.defaults['hostPool']['loadBalancerType']}'",
            "",
            f"@description('Maximum sessions per host')",
            f"param hostPoolMaxSessions int = {self.defaults['hostPool']['maxSessionLimit']}",
            "",
            f"@description('Start VM on connect')",
            f"param avdStartVmOnConnect bool = {str(self.defaults['hostPool']['startVMOnConnect']).lower()}",
            "",
            f"@description('Deploy scaling plan')",
            f"param avdDeployScalingPlan bool = {str(self.defaults['hostPool']['deployScalingPlan']).lower()}",
            "",
            "// ========== Session Host Parameters ==========",
            "",
            f"@description('Deploy session hosts')",
            f"param avdDeploySessionHosts bool = {str(self.defaults['sessionHosts']['deploy']).lower()}",
            "",
            f"@minValue(1)",
            f"@maxValue(1999)",
            f"@description('Number of session hosts to deploy')",
            f"param avdDeploySessionHostsCount int = {self.defaults['sessionHosts']['count']}",
            "",
            f"@description('Session host VM size')",
            f"param avdSessionHostsSize string = '{self.defaults['sessionHosts']['vmSize']}'",
            "",
            f"@description('OS disk type')",
            f"param avdSessionHostDiskType string = '{self.defaults['sessionHosts']['diskType']}'",
            "",
            f"@description('Enable accelerated networking')",
            f"param enableAcceleratedNetworking bool = {str(self.defaults['sessionHosts']['acceleratedNetworking']).lower()}",
            "",
            "@allowed(['None', 'AvailabilityZones'])",
            f"@description('VM availability option')",
            f"param availability string = '{self.defaults['sessionHosts']['availability']}'",
            "",
            "@allowed(['Standard', 'TrustedLaunch'])",
            f"@description('Security type for VMs')",
            f"param securityType string = '{self.defaults['sessionHosts']['securityType']}'",
            "",
            f"@description('Enable secure boot')",
            f"param secureBootEnabled bool = {str(self.defaults['sessionHosts']['secureBoot']).lower()}",
            "",
            f"@description('Enable vTPM')",
            f"param vTpmEnabled bool = {str(self.defaults['sessionHosts']['vTpm']).lower()}",
            "",
            f"@description('Marketplace image offer')",
            f"param mpImageOffer string = '{self.defaults['sessionHosts']['imageOffer']}'",
            "",
            f"@description('Marketplace image SKU')",
            f"param mpImageSku string = '{self.defaults['sessionHosts']['imageSku']}'",
            "",
            "// ========== Networking Parameters ==========",
            "",
            f"@description('Create new virtual network')",
            f"param createAvdVnet bool = {str(self.defaults['networking']['createNew']).lower()}",
            "",
            f"@description('VNet address space')",
            f"param avdVnetworkAddressPrefixes string = '{self.defaults['networking']['vnetAddressSpace']}'",
            "",
            f"@description('AVD subnet address prefix')",
            f"param vNetworkAvdSubnetAddressPrefix string = '{self.defaults['networking']['avdSubnetPrefix']}'",
            "",
            f"@description('Private endpoint subnet address prefix')",
            f"param vNetworkPrivateEndpointSubnetAddressPrefix string = '{self.defaults['networking']['privateEndpointSubnetPrefix']}'",
            "",
            f"@description('Deploy DDoS network protection')",
            f"param deployDDoSNetworkProtection bool = {str(self.defaults['networking']['deployDDoSProtection']).lower()}",
            "",
            "// ========== Storage Parameters ==========",
            "",
            f"@description('Deploy FSLogix setup')",
            f"param createAvdFslogixDeployment bool = {str(self.defaults['storage']['fslogix']['enabled']).lower()}",
            "",
            f"@description('Deploy App Attach setup')",
            f"param createAppAttachDeployment bool = {str(self.defaults['storage']['appAttach']['enabled']).lower()}",
            "",
            "@allowed(['Standard', 'Premium'])",
            f"@description('FSLogix storage performance tier')",
            f"param fslogixStoragePerformance string = '{self.defaults['storage']['fslogix']['performance']}'",
            "",
            f"@description('FSLogix file share quota (GB)')",
            f"param fslogixFileShareQuotaSize int = {self.defaults['storage']['fslogix']['quotaSizeGB']}",
            "",
            f"@description('Use zone redundant storage')",
            f"param zoneRedundantStorage bool = {str(self.defaults['storage']['zoneRedundant']).lower()}",
            "",
            "// ========== Security Parameters ==========",
            "",
            f"@description('Deploy private endpoints for Key Vault and Storage')",
            f"param deployPrivateEndpointKeyvaultStorage bool = {str(self.defaults['security']['deployPrivateEndpoints']).lower()}",
            "",
            f"@description('Deploy AVD private link service')",
            f"param deployAvdPrivateLinkService bool = {str(self.defaults['security']['deployAvdPrivateLink']).lower()}",
            "",
            f"@description('Create private DNS zones')",
            f"param createPrivateDnsZones bool = {str(self.defaults['security']['createPrivateDnsZones']).lower()}",
            "",
            f"@description('Enable zero trust disk configuration')",
            f"param diskZeroTrust bool = {str(self.defaults['security']['diskZeroTrust']).lower()}",
            "",
            "// ========== Monitoring Parameters ==========",
            "",
            f"@description('Deploy AVD monitoring')",
            f"param avdDeployMonitoring bool = {str(self.defaults['monitoring']['enabled']).lower()}",
            "",
            f"@description('Deploy Log Analytics workspace')",
            f"param deployAlaWorkspace bool = {str(self.defaults['monitoring']['deployLogAnalytics']).lower()}",
            "",
            f"@description('Log Analytics data retention days')",
            f"param avdAlaWorkspaceDataRetention int = {self.defaults['monitoring']['retentionDays']}",
            "",
            f"@description('Deploy custom monitoring policies')",
            f"param deployCustomPolicyMonitoring bool = {str(self.defaults['monitoring']['deployCustomPolicies']).lower()}",
            "",
            "@description('Tags to apply to all resources')",
            "param tags object = " + json.dumps(self.spec_data.get('tags', {'Environment': environment, 'ManagedBy': 'AVD-SpecDriven'}), indent=2),
            "",
            "// ========== Variables ==========",
            "",
            f"var resourceGroupName = 'rg-${{deploymentPrefix}}-${{deploymentEnvironment}}-${{location}}-service-objects'",
            "var networkResourceGroupName = 'rg-${deploymentPrefix}-${deploymentEnvironment}-${location}-network'",
            "var computeResourceGroupName = 'rg-${deploymentPrefix}-${deploymentEnvironment}-${location}-pool-compute'",
            "var storageResourceGroupName = 'rg-${deploymentPrefix}-${deploymentEnvironment}-${location}-storage'",
            "var monitoringResourceGroupName = 'rg-${deploymentPrefix}-${deploymentEnvironment}-${location}-monitoring'",
            "",
            "// ========== Resource Groups (Baseline Architecture) ==========",
            "",
            "resource rgServiceObjects 'Microsoft.Resources/resourceGroups@2021-04-01' = {",
            "  name: resourceGroupName",
            "  location: location",
            "  tags: tags",
            "}",
            "",
            "resource rgNetwork 'Microsoft.Resources/resourceGroups@2021-04-01' = if (createAvdVnet) {",
            "  name: networkResourceGroupName",
            "  location: location",
            "  tags: tags",
            "}",
            "",
            "resource rgCompute 'Microsoft.Resources/resourceGroups@2021-04-01' = if (avdDeploySessionHosts) {",
            "  name: computeResourceGroupName",
            "  location: avdSessionHostLocation",
            "  tags: tags",
            "}",
            "",
            "resource rgStorage 'Microsoft.Resources/resourceGroups@2021-04-01' = if (createAvdFslogixDeployment || createAppAttachDeployment) {",
            "  name: storageResourceGroupName",
            "  location: location",
            "  tags: tags",
            "}",
            "",
            "resource rgMonitoring 'Microsoft.Resources/resourceGroups@2021-04-01' = if (avdDeployMonitoring || deployAlaWorkspace) {",
            "  name: monitoringResourceGroupName",
            "  location: location",
            "  tags: tags",
            "}",
            "",
        ]
        
        # Add networking module if creating new VNet (Baseline Architecture)
        if self.spec_data.get('networking', {}).get('createNew', self.defaults['networking']['createNew']):
            vnet_address = self.spec_data.get('networking', {}).get('vnet', {}).get('addressSpace', 
                self.defaults['networking']['vnetAddressSpace'])
            lines.extend([
                "// ========== Networking (Baseline Architecture) ==========",
                "",
                "module networking 'modules/networking.bicep' = if (createAvdVnet) {",
                "  scope: rgNetwork",
                "  name: 'networking-deployment'",
                "  params: {",
                "    location: location",
                f"    vnetName: '{self._get_vnet_name()}'",
                f"    vnetAddressSpace: avdVnetworkAddressPrefixes",
                f"    avdSubnetPrefix: vNetworkAvdSubnetAddressPrefix",
                f"    privateEndpointSubnetPrefix: vNetworkPrivateEndpointSubnetAddressPrefix",
                "    deployDDoSProtection: deployDDoSNetworkProtection",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Add storage module (Baseline Architecture - FSLogix + App Attach)
        fslogix_enabled = self.spec_data.get('storage', {}).get('fslogix', {}).get('enabled', 
            self.defaults['storage']['fslogix']['enabled'])
        if fslogix_enabled:
            lines.extend([
                "// ========== Storage (Baseline Architecture) ==========",
                "",
                "module storage 'modules/storage.bicep' = if (createAvdFslogixDeployment || createAppAttachDeployment) {",
                "  scope: rgStorage",
                "  name: 'storage-deployment'",
                "  params: {",
                "    location: location",
                f"    storageAccountName: '{self.naming.generate('storageAccount', 'fslogix')}'",
                "    fslogixEnabled: createAvdFslogixDeployment",
                "    fslogixPerformance: fslogixStoragePerformance",
                "    fslogixQuotaSize: fslogixFileShareQuotaSize",
                "    appAttachEnabled: createAppAttachDeployment",
                "    zoneRedundant: zoneRedundantStorage",
                "    deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage",
                "    tags: tags",
                "  }",
                "  dependsOn: [",
                "    networking",
                "  ]",
                "}",
                "",
            ])
        
        # Add Key Vault module (Baseline Architecture)
        lines.extend([
            "// ========== Key Vault (Baseline Architecture) ==========",
            "",
            "module keyVault 'modules/keyvault.bicep' = {",
            "  scope: rgServiceObjects",
            "  name: 'keyvault-deployment'",
            "  params: {",
            "    location: location",
            f"    keyVaultName: '{self.naming.generate('keyVault', 'avd')}'",
            "    diskEncryptionKeyExpirationInDays: diskEncryptionKeyExpirationInDays",
            "    deployPrivateEndpoint: deployPrivateEndpointKeyvaultStorage",
            "    tags: tags",
            "  }",
            "  dependsOn: [",
            "    networking",
            "  ]",
            "}",
            "",
        ])
        
        # Add host pool module (Baseline Architecture)
        host_pools = self.spec_data.get('hostPools', [])
        if not host_pools:
            # Use default host pool configuration from baseline
            host_pools = [{
                'name': f"vdpool-{self.naming.prefix}-{self.naming.env}",
                'type': self.defaults['hostPool']['type'],
                'location': self.metadata.get('region', 'eastus2'),
                'loadBalancerType': self.defaults['hostPool']['loadBalancerType'],
                'maxSessionLimit': self.defaults['hostPool']['maxSessionLimit']
            }]
        
        for hp in host_pools:
            hp_name = hp.get('name', f"vdpool-{self.naming.prefix}-{self.naming.env}")
            hp_type = hp.get('type', self.defaults['hostPool']['type'])
            hp_location = hp.get('location', self.metadata.get('region', 'eastus2'))
            load_balancer = hp.get('loadBalancerType', self.defaults['hostPool']['loadBalancerType'])
            max_sessions = hp.get('maxSessionLimit', self.defaults['hostPool']['maxSessionLimit'])
            
            lines.extend([
                f"// ========== Host Pool: {hp_name} (Baseline Architecture) ==========",
                "",
                f"module hostPool_{hp_name.replace('-', '_')} 'modules/hostpool.bicep' = {{",
                "  scope: rgServiceObjects",
                f"  name: 'hostpool-{hp_name}-deployment'",
                "  params: {",
                f"    location: '{hp_location}'",
                f"    hostPoolName: '{hp_name}'",
                f"    hostPoolType: avdHostPoolType",
                f"    loadBalancerType: avdHostPoolLoadBalancerType",
                f"    maxSessionLimit: hostPoolMaxSessions",
                f"    preferredAppGroupType: hostPoolPreferredAppGroupType",
                f"    publicNetworkAccess: hostPoolPublicNetworkAccess",
                f"    startVmOnConnect: avdStartVmOnConnect",
                "    tags: tags",
                "  }",
                "}",
                "",
                f"// Scaling Plan for {hp_name}",
                f"module scalingPlan_{hp_name.replace('-', '_')} 'modules/scalingplan.bicep' = if (avdDeployScalingPlan) {{",
                "  scope: rgServiceObjects",
                f"  name: 'scalingplan-{hp_name}-deployment'",
                "  params: {",
                f"    location: '{hp_location}'",
                f"    hostPoolResourceId: hostPool_{hp_name.replace('-', '_')}.outputs.hostPoolResourceId",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Add monitoring module (Baseline Architecture)
        monitoring_enabled = self.spec_data.get('monitoring', {}).get('enabled', 
            self.defaults['monitoring']['enabled'])
        deploy_law = self.spec_data.get('monitoring', {}).get('deployLogAnalytics', 
            self.defaults['monitoring']['deployLogAnalytics'])
        retention_days = self.spec_data.get('monitoring', {}).get('retentionDays', 
            self.defaults['monitoring']['retentionDays'])
        
        if deploy_law or monitoring_enabled:
            lines.extend([
                "// ========== Monitoring (Baseline Architecture) ==========",
                "",
                "module monitoring 'modules/monitoring.bicep' = if (avdDeployMonitoring || deployAlaWorkspace) {",
                "  scope: rgMonitoring",
                "  name: 'monitoring-deployment'",
                "  params: {",
                "    location: location",
                f"    logAnalyticsName: '{self.naming.generate('logAnalyticsWorkspace', 'avd')}'",
                f"    retentionInDays: avdAlaWorkspaceDataRetention",
                "    deployCustomPolicies: deployCustomPolicyMonitoring",
                "    tags: tags",
                "  }",
                "}",
                "",
            ])
        
        # Add session hosts module (Baseline Architecture)
        lines.extend([
            "// ========== Session Hosts (Baseline Architecture) ==========",
            "",
            "module sessionHosts 'modules/sessionhosts.bicep' = if (avdDeploySessionHosts) {",
            "  scope: rgCompute",
            "  name: 'sessionhosts-deployment'",
            "  params: {",
            "    location: avdSessionHostLocation",
            "    vmSize: avdSessionHostsSize",
            "    vmCount: avdDeploySessionHostsCount",
            "    diskType: avdSessionHostDiskType",
            "    enableAcceleratedNetworking: enableAcceleratedNetworking",
            "    availability: availability",
            "    securityType: securityType",
            "    secureBootEnabled: secureBootEnabled",
            "    vTpmEnabled: vTpmEnabled",
            "    imageOffer: mpImageOffer",
            "    imageSku: mpImageSku",
            "    identityProvider: avdIdentityServiceProvider",
            "    tags: tags",
            "  }",
            "  dependsOn: [",
            "    networking",
            "    keyVault",
            "    storage",
            "  ]",
            "}",
            "",
        ])
        
        # Outputs (Baseline Architecture)
        lines.extend([
            "// ========== Outputs (Baseline Architecture) ==========",
            "",
            "output serviceObjectsResourceGroupName string = rgServiceObjects.name",
            "output networkResourceGroupName string = createAvdVnet ? rgNetwork.name : ''",
            "output computeResourceGroupName string = avdDeploySessionHosts ? rgCompute.name : ''",
            "output storageResourceGroupName string = (createAvdFslogixDeployment || createAppAttachDeployment) ? rgStorage.name : ''",
            "output monitoringResourceGroupName string = (avdDeployMonitoring || deployAlaWorkspace) ? rgMonitoring.name : ''",
            "output location string = location",
            "output deploymentEnvironment string = deploymentEnvironment",
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
        """Generate parameters file based on AVD Accelerator Baseline Architecture"""
        deployment_name = self.metadata.get('name', 'avd-deployment')
        output_path = self.output_dir / 'iac' / 'bicep' / 'parameters.json'
        
        region = self.metadata.get('region', 'eastus2')
        environment = self.metadata.get('environment', self.defaults['deployment']['environment'])
        
        params = {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                # Deployment
                "deploymentPrefix": {
                    "value": self.spec_data.get('deploymentPrefix', self.defaults['deployment']['prefix'])
                },
                "deploymentEnvironment": {
                    "value": environment
                },
                "location": {
                    "value": region
                },
                "avdSessionHostLocation": {
                    "value": region
                },
                "avdManagementPlaneLocation": {
                    "value": region
                },
                # Identity
                "avdIdentityServiceProvider": {
                    "value": self.spec_data.get('identity', {}).get('provider', self.defaults['identity']['provider'])
                },
                # Host Pool
                "avdHostPoolType": {
                    "value": self.defaults['hostPool']['type']
                },
                "avdHostPoolLoadBalancerType": {
                    "value": self.defaults['hostPool']['loadBalancerType']
                },
                "hostPoolMaxSessions": {
                    "value": self.defaults['hostPool']['maxSessionLimit']
                },
                "avdStartVmOnConnect": {
                    "value": self.defaults['hostPool']['startVMOnConnect']
                },
                "avdDeployScalingPlan": {
                    "value": self.defaults['hostPool']['deployScalingPlan']
                },
                # Session Hosts
                "avdDeploySessionHosts": {
                    "value": self.defaults['sessionHosts']['deploy']
                },
                "avdDeploySessionHostsCount": {
                    "value": self.defaults['sessionHosts']['count']
                },
                "avdSessionHostsSize": {
                    "value": self.defaults['sessionHosts']['vmSize']
                },
                "avdSessionHostDiskType": {
                    "value": self.defaults['sessionHosts']['diskType']
                },
                "enableAcceleratedNetworking": {
                    "value": self.defaults['sessionHosts']['acceleratedNetworking']
                },
                "securityType": {
                    "value": self.defaults['sessionHosts']['securityType']
                },
                "secureBootEnabled": {
                    "value": self.defaults['sessionHosts']['secureBoot']
                },
                "vTpmEnabled": {
                    "value": self.defaults['sessionHosts']['vTpm']
                },
                # Networking
                "createAvdVnet": {
                    "value": self.defaults['networking']['createNew']
                },
                "avdVnetworkAddressPrefixes": {
                    "value": self.defaults['networking']['vnetAddressSpace']
                },
                "vNetworkAvdSubnetAddressPrefix": {
                    "value": self.defaults['networking']['avdSubnetPrefix']
                },
                "vNetworkPrivateEndpointSubnetAddressPrefix": {
                    "value": self.defaults['networking']['privateEndpointSubnetPrefix']
                },
                # Storage
                "createAvdFslogixDeployment": {
                    "value": self.defaults['storage']['fslogix']['enabled']
                },
                "fslogixStoragePerformance": {
                    "value": self.defaults['storage']['fslogix']['performance']
                },
                # Security
                "deployPrivateEndpointKeyvaultStorage": {
                    "value": self.defaults['security']['deployPrivateEndpoints']
                },
                "createPrivateDnsZones": {
                    "value": self.defaults['security']['createPrivateDnsZones']
                },
                # Monitoring
                "avdDeployMonitoring": {
                    "value": self.defaults['monitoring']['enabled']
                },
                "deployAlaWorkspace": {
                    "value": self.defaults['monitoring']['deployLogAnalytics']
                },
                "avdAlaWorkspaceDataRetention": {
                    "value": self.defaults['monitoring']['retentionDays']
                },
                # Tags
                "tags": {
                    "value": self.spec_data.get('tags', {
                        "Environment": environment,
                        "ManagedBy": "AVD-SpecDriven",
                        "Architecture": "AVD-Accelerator-Baseline"
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
