# AVD Accelerator - AI Agents

This directory contains AI-powered agents that automate and enhance the Azure Virtual Desktop (AVD) deployment experience. The agents work together to provide a spec-driven approach to AVD deployments, offering interactive configuration, validation, architecture generation, and infrastructure-as-code generation.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Agents](#agents)
  - [Chat Advisor Agent](#1-chat-advisor-agent)
  - [Pre-Deployment Validator](#2-pre-deployment-validator)
  - [Architecture Diagram Generator](#3-architecture-diagram-generator)
  - [Bicep Generator](#4-bicep-generator)
  - [Orchestrator](#5-orchestrator)
- [Quick Start](#quick-start)
- [Step-by-Step Usage](#step-by-step-usage)
- [Integration Examples](#integration-examples)
- [Requirements](#requirements)

---

## Overview

The AVD Accelerator repository provides production-ready templates and tools for deploying Azure Virtual Desktop environments. This `agents/` directory extends the accelerator with intelligent automation:

| Capability | Description |
|------------|-------------|
| **Interactive Configuration** | Chat-based wizard to guide parameter selection |
| **Pre-Deployment Validation** | Analyze resources, costs, and prerequisites before deployment |
| **Architecture Diagrams** | Auto-generate Mermaid diagrams from specifications |
| **Infrastructure-as-Code** | Generate Bicep templates from YAML specifications |
| **Spec-Driven Deployments** | Define AVD environments in declarative YAML format |

### What This Repository Does

The AVD Accelerator automates the deployment of Azure Virtual Desktop environments following Microsoft best practices:

1. **Baseline Deployments** - Production-ready AVD with FSLogix, monitoring, and security
2. **Custom Image Builds** - Automated golden image creation with Azure Image Builder
3. **Brownfield Scenarios** - Integration with existing Azure infrastructure
4. **Zero Trust Security** - Disk encryption, private endpoints, and network isolation

The agents in this directory provide an intelligent layer on top of these capabilities.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User Interface                               │
│  (CLI / VS Code Copilot / Custom Application)                       │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Orchestrator (orchestrator.py)                   │
│  Coordinates agent execution and manages workflow                    │
└─────────────────────────────────────────────────────────────────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         ▼                      ▼                      ▼
┌─────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  Chat Advisor   │  │  Pre-Deployment     │  │  Architecture       │
│  Agent          │  │  Validator          │  │  Diagram Generator  │
│                 │  │                     │  │                     │
│ • Interactive   │  │ • Resource list     │  │ • Mermaid diagrams  │
│ • Parameters    │  │ • Cost estimation   │  │ • Baseline defaults │
│ • Validation    │  │ • Prerequisites     │  │ • Component mapping │
└─────────────────┘  └─────────────────────┘  └─────────────────────┘
         │                      │                      │
         └──────────────────────┼──────────────────────┘
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Bicep Generator (bicep_generator.py)             │
│  Generates Infrastructure-as-Code from specifications                │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     Output Artifacts                                 │
│  • YAML Specifications  • Bicep Templates  • Architecture Diagrams  │
│  • JSON Parameters      • Validation Reports                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Agents

### 1. Chat Advisor Agent

**Location:** `agents/chat/deployment_advisor.py`

An interactive conversational agent that guides users through AVD deployment configuration.

#### Features
- 45+ configurable parameters organized in 9 stages
- Contextual recommendations based on selections
- Parameter validation with helpful error messages
- Export to YAML specification or JSON parameters
- Integration with pre-deployment validation

#### Conversation Stages
1. **Welcome** - Introduction and overview
2. **Basics** - Prefix, environment, locations, subscription
3. **Identity** - Identity provider, domain settings
4. **Host Pool** - Pool type, load balancing, sessions
5. **Session Hosts** - VM size, count, disk type, security
6. **Networking** - VNet, subnets, private endpoints
7. **Storage** - FSLogix, App Attach settings
8. **Security** - Zero Trust, encryption, anti-malware
9. **Monitoring** - Log Analytics, diagnostics
10. **Review** - Summary and export

---

### 2. Pre-Deployment Validator

**Location:** `agents/validation/pre_deployment_validator.py`

Validates deployment configurations before execution and provides comprehensive analysis.

#### Features
- **Resource Inventory** - Lists all Azure resources to be created
- **Cost Estimation** - Monthly cost breakdown by category
- **Prerequisites Checklist** - Required permissions, quotas, configurations
- **Existing Resource Detection** - Identifies resources that may be updated
- **Warnings & Errors** - Security and best practice recommendations

#### Cost Categories Analyzed
- Compute (VMs)
- Storage (Disks, Azure Files)
- Networking (Private Endpoints, DDoS)
- Security (Key Vault)
- Monitoring (Log Analytics)

---

### 3. Architecture Diagram Generator

**Location:** `agents/architecture/diagram_generator.py`

Generates visual architecture diagrams from AVD specifications.

#### Features
- Mermaid diagram format (compatible with GitHub, VS Code, etc.)
- Baseline architecture defaults from AVD Accelerator
- Component relationship mapping
- Layer-based organization (Management, Compute, Network, Storage, Security)

---

### 4. Bicep Generator

**Location:** `agents/deployment/bicep_generator.py`

Generates Bicep Infrastructure-as-Code templates from specifications.

#### Features
- Baseline defaults aligned with `deploy-baseline.bicep`
- Parameter extraction from YAML specifications
- Module-based architecture
- Best practice configurations

---

### 5. Orchestrator

**Location:** `agents/core/orchestrator.py`

Central coordinator for all agent operations.

#### Agent Types
- `ANALYSIS` - Specification analysis
- `ARCHITECTURE` - Diagram generation
- `DEPLOYMENT` - Bicep/Terraform generation
- `DOCUMENTATION` - Documentation generation
- `VALIDATION` - Spec validation
- `CHAT_ADVISOR` - Interactive configuration
- `PRE_DEPLOYMENT_VALIDATOR` - Pre-deployment analysis

---

## Quick Start

### Prerequisites

```bash
# Python 3.8+
python3 --version

# Install dependencies
pip install pyyaml
```

### Run Interactive Chat Advisor

```bash
cd /path/to/avdaccelerator
python3 agents/chat/deployment_advisor.py
```

### Run Pre-Deployment Validation

```bash
cd /path/to/avdaccelerator
python3 agents/validation/pre_deployment_validator.py
```

---

## Step-by-Step Usage

### Workflow 1: Interactive Configuration with Chat Advisor

```
┌─────────────────────────────────────────────────────────────────┐
│  Step 1: Start Chat Advisor                                      │
│  $ python3 agents/chat/deployment_advisor.py                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 2: Configure Parameters                                    │
│  > deploymentPrefix=PROD                                         │
│  > deploymentEnvironment=Prod                                    │
│  > avdWorkloadSubsId=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx        │
│  > next                                                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 3: Validate Configuration                                  │
│  > validate                                                      │
│  (Shows resources, costs, prerequisites)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 4: Export Configuration                                    │
│  > export yaml   (YAML specification)                            │
│  > export json   (JSON parameters file)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Step 5: Deploy                                                  │
│  $ az deployment sub create \                                    │
│      --location eastus2 \                                        │
│      --template-file workload/bicep/deploy-baseline.bicep \      │
│      --parameters @parameters.json                               │
└─────────────────────────────────────────────────────────────────┘
```

#### Detailed Steps

**Step 1: Launch the Chat Advisor**

```bash
cd /path/to/avdaccelerator
python3 agents/chat/deployment_advisor.py
```

**Step 2: Navigate Through Configuration Stages**

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                    🖥️ AVD Deployment Advisor                                  ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Welcome! I'll help you configure your Azure Virtual Desktop deployment.     ║
╚══════════════════════════════════════════════════════════════════════════════╝

> next                                    # Move to basics configuration

📋 Section: BASICS
──────────────────────────────────────────────────────────────────────

> deploymentPrefix=PROD                   # Set deployment prefix
> avdWorkloadSubsId=12345678-1234-...     # Set subscription ID
> deploymentEnvironment=Prod              # Set environment
> next                                    # Move to identity section
```

**Step 3: Run Validation**

```
> validate

╔══════════════════════════════════════════════════════════════════════════════╗
║                    🔍 PRE-DEPLOYMENT VALIDATION                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

✅ Status: VALID - Ready for deployment

💰 ESTIMATED MONTHLY COST: $1,218.06

   Cost Breakdown:
   • Compute (VMs): $840.96
   • Monitoring: $172.50
   • Storage (Azure Files): $80.00
   ...

📦 RESOURCES TO CREATE: 49
   • virtualMachines: 5
   • disks: 5
   • privateEndpoints: 6
   ...

📋 PREREQUISITES: 18 required
```

**Step 4: Export Configuration**

```
> export yaml                             # Export YAML specification
> export json                             # Export JSON parameters
> export validation                       # Export full validation report
```

**Step 5: Complete and Deploy**

```
> done                                    # Finish configuration

# Use the exported parameters with Azure CLI
az deployment sub create \
  --location eastus2 \
  --template-file workload/bicep/deploy-baseline.bicep \
  --parameters @avd-parameters.json
```

---

### Workflow 2: Programmatic Validation

```python
#!/usr/bin/env python3
"""Example: Programmatic pre-deployment validation"""

import sys
sys.path.insert(0, 'agents')

from validation.pre_deployment_validator import PreDeploymentValidator

# Step 1: Initialize validator
validator = PreDeploymentValidator()

# Step 2: Set deployment parameters
validator.set_parameters({
    "deploymentPrefix": "PROD",
    "deploymentEnvironment": "Prod",
    "avdWorkloadSubsId": "12345678-1234-1234-1234-123456789012",
    "avdIdentityServiceProvider": "ADDS",
    "identityDomainName": "contoso.com",
    "avdDeploySessionHostsCount": 10,
    "avdSessionHostsSize": "Standard_D4ads_v5",
    "avdSessionHostDiskType": "Premium_LRS",
    "createAvdFslogixDeployment": True,
    "fslogixStoragePerformance": "Premium",
    "fslogixFileShareQuotaSize": 500,
    "diskZeroTrust": True,
    "deployPrivateEndpointKeyvaultStorage": True,
    "avdDeployMonitoring": True,
})

# Step 3: Run validation
result = validator.validate()

# Step 4: Check results
if result.is_valid:
    print("✅ Configuration is valid!")
    print(f"   Estimated monthly cost: ${result.estimated_monthly_cost:,.2f}")
    print(f"   Resources to create: {len(result.resources_to_create)}")
else:
    print("❌ Configuration has errors:")
    for error in result.errors:
        print(f"   {error}")

# Step 5: Generate full report
report = validator.generate_report(result)
print(report)

# Step 6: Export to JSON
json_report = validator.export_to_json(result)
with open("validation-report.json", "w") as f:
    f.write(json_report)
```

---

### Workflow 3: Using Chat Advisor Programmatically

```python
#!/usr/bin/env python3
"""Example: Using Chat Advisor in code"""

import sys
sys.path.insert(0, 'agents')

from chat.deployment_advisor import DeploymentAdvisorAgent

# Step 1: Initialize advisor
advisor = DeploymentAdvisorAgent()

# Step 2: Set parameters programmatically
parameters = {
    "deploymentPrefix": "DEV",
    "deploymentEnvironment": "Dev",
    "avdWorkloadSubsId": "your-subscription-id",
    "avdIdentityServiceProvider": "EntraID",
    "avdDeploySessionHostsCount": 2,
    "avdSessionHostsSize": "Standard_D4ads_v5",
}

for name, value in parameters.items():
    success, message = advisor.set_parameter(name, value)
    print(f"Set {name}: {'✓' if success else '✗'}")

# Step 3: Get recommendations
recommendations = advisor.get_contextual_recommendations()
for rec in recommendations:
    print(rec)

# Step 4: Validate
validation_result = advisor.process_input("validate")
print(validation_result)

# Step 5: Export YAML
yaml_spec = advisor.export_to_yaml()
print(yaml_spec)

# Step 6: Export JSON parameters
json_params = advisor.export_to_json_parameters()
print(json_params)
```

---

### Workflow 4: Generate Architecture Diagram

```python
#!/usr/bin/env python3
"""Example: Generate architecture diagram"""

import sys
sys.path.insert(0, 'agents')

from architecture.diagram_generator import ArchitectureDiagramGenerator

# Step 1: Load specification
spec = {
    "metadata": {"name": "production-avd"},
    "spec": {
        "environment": "production",
        "sessionHosts": {
            "count": 10,
            "vmSize": "Standard_D4ads_v5",
            "securityType": "TrustedLaunch"
        },
        "storage": {
            "fslogix": {"enabled": True, "performance": "Premium"}
        },
        "security": {
            "privateEndpoints": True,
            "diskEncryption": True
        }
    }
}

# Step 2: Generate diagram
generator = ArchitectureDiagramGenerator(spec)
mermaid_diagram = generator.generate()

print(mermaid_diagram)
# Output: Mermaid diagram code that can be rendered in GitHub, VS Code, etc.
```

---

## Integration Examples

### CI/CD Pipeline Integration

```yaml
# .github/workflows/avd-validation.yml
name: AVD Deployment Validation

on:
  pull_request:
    paths:
      - 'specs/**'
      - 'workload/bicep/**'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: pip install pyyaml
      
      - name: Run validation
        run: |
          python3 -c "
          import sys
          sys.path.insert(0, 'agents')
          from validation.pre_deployment_validator import PreDeploymentValidator
          
          validator = PreDeploymentValidator()
          validator.set_parameters({
              'deploymentPrefix': 'CI',
              'avdWorkloadSubsId': '${{ secrets.AZURE_SUBSCRIPTION_ID }}',
              'avdDeploySessionHostsCount': 2,
          })
          
          result = validator.validate()
          
          if not result.is_valid:
              print('Validation failed!')
              for error in result.errors:
                  print(f'  {error}')
              sys.exit(1)
          
          print('Validation passed!')
          print(f'Estimated cost: \${result.estimated_monthly_cost:,.2f}/month')
          "
```

### VS Code Task Integration

```json
// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AVD: Run Chat Advisor",
      "type": "shell",
      "command": "python3",
      "args": ["agents/chat/deployment_advisor.py"],
      "group": "build",
      "presentation": {
        "reveal": "always",
        "panel": "new"
      }
    },
    {
      "label": "AVD: Run Validation",
      "type": "shell",
      "command": "python3",
      "args": ["agents/validation/pre_deployment_validator.py"],
      "group": "test"
    }
  ]
}
```

---

## Requirements

### Python Dependencies

```txt
# requirements.txt
pyyaml>=6.0
```

### Supported Python Versions

- Python 3.8+
- Python 3.9+
- Python 3.10+
- Python 3.11+

### Optional Dependencies

```txt
# For JSON schema validation
jsonschema>=4.0

# For enhanced CLI experience  
rich>=13.0
```

---

## Command Reference

### Chat Advisor Commands

| Command | Description |
|---------|-------------|
| `next` | Move to next configuration section |
| `back` | Return to previous section |
| `skip` | Accept defaults and move forward |
| `review` | Jump to configuration review |
| `validate` | Run pre-deployment validation |
| `help` | Show help message |
| `recommendations` | Get contextual recommendations |
| `export yaml` | Export YAML specification |
| `export json` | Export JSON parameters |
| `export validation` | Export full validation report |
| `export validation json` | Export validation as JSON |
| `done` | Complete configuration |
| `quit` / `exit` | Exit the advisor |

### Parameter Setting

```
<parameter>=<value>     # e.g., deploymentPrefix=PROD
<parameter> <value>     # e.g., deploymentPrefix PROD
```

---

## Troubleshooting

### Import Errors

If you see import errors, ensure you're running from the repository root:

```bash
cd /path/to/avdaccelerator
python3 agents/chat/deployment_advisor.py
```

### YAML Module Not Found

Install PyYAML:

```bash
pip install pyyaml
```

### Validation Shows Errors

Common validation errors and solutions:

| Error | Solution |
|-------|----------|
| `Subscription ID is required` | Set `avdWorkloadSubsId` parameter |
| `Domain name is required for ADDS` | Set `identityDomainName` when using ADDS/EntraDS |
| `Deployment prefix must be 2-4 characters` | Use a prefix like `AVD1` or `PROD` |

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `python3 agents/validation/test_validator.py`
5. Submit a pull request

---

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

## Related Documentation

- [AVD Accelerator Main Documentation](../readme.md)
- [Baseline Deployment Guide](../workload/docs/deploy-baseline.md)
- [Custom Image Build Guide](../workload/docs/deploy-custom-image.md)
- [Spec-Driven Architecture](../spec-driven-architecture.md)
