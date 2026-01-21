# AVD Spec-Driven Deployment - Getting Started

## Overview

This spec-driven deployment system enables you to declare your Azure Virtual Desktop requirements in a simple YAML file, and AI agents will automatically generate:

- **Architecture diagrams** (Mermaid, visual documentation)
- **Infrastructure as Code** (Bicep or Terraform)
- **Deployment documentation** (step-by-step guides, runbooks)
- **CI/CD pipelines** (GitHub Actions, Azure DevOps)

## Quick Start

### 1. Install Dependencies

```bash
# Python 3.9+ required
pip install pyyaml jsonschema

# Optional: For diagram rendering
npm install -g @mermaid-js/mermaid-cli
```

### 2. Create Your Specification

Start with an example specification:

```bash
# Copy an example spec
cp specs/examples/basic-deployment.yaml my-deployment.yaml

# Edit with your requirements
code my-deployment.yaml
```

### 3. Generate Deployment Artifacts

Run the orchestrator to generate all artifacts:

```bash
python agents/core/orchestrator.py my-deployment.yaml --output-dir ./generated
```

This will create:
```
generated/
├── architecture/
│   ├── diagrams/          # Mermaid diagrams
│   └── topology/          # Topology documentation
├── iac/
│   ├── bicep/            # Bicep templates
│   └── terraform/        # Terraform modules
├── docs/
│   ├── deployment-guides/ # Step-by-step guides
│   ├── runbooks/         # Operational procedures
│   └── troubleshooting/  # Common issues
└── pipelines/
    ├── github-actions/   # GitHub workflows
    └── azure-devops/     # Azure Pipelines
```

### 4. Review Generated Artifacts

The agents will create:

- **Architecture diagrams** showing your AVD deployment topology
- **Bicep/Terraform code** ready to deploy
- **Documentation** for deployment and operations
- **CI/CD pipelines** for automated deployment

### 5. Deploy

```bash
# Using Azure CLI with generated Bicep
cd generated/iac/bicep
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters @parameters.json

# Or using Terraform
cd generated/iac/terraform
terraform init
terraform plan
terraform apply
```

## Specification Examples

### Basic Development Environment

```yaml
apiVersion: avd.azure.com/v1
kind: AVDDeployment
metadata:
  name: dev-avd
  environment: dev
  region: eastus

spec:
  identity:
    provider: EntraID
  
  hostPools:
    - name: hp-dev
      type: Pooled
      location: eastus
      sessionHosts:
        count: 2
        vmSize: Standard_D2s_v5
  
  networking:
    createNew: true
    vnet:
      addressSpace: "10.200.0.0/16"
```

### Enterprise Production Environment

```yaml
apiVersion: avd.azure.com/v1
kind: AVDDeployment
metadata:
  name: prod-avd
  environment: production
  region: eastus2

spec:
  identity:
    provider: ADDS
    domainName: contoso.com
  
  hostPools:
    - name: hp-production
      type: Pooled
      sessionHosts:
        count: 20
        vmSize: Standard_D4s_v5
      scaling:
        enabled: true
  
  networking:
    createNew: true
    hubVnet:
      enabled: true
  
  security:
    encryption:
      encryptionAtHost: true
    privateLink:
      enabled: true
  
  monitoring:
    logAnalytics:
      enabled: true
      retentionDays: 90
```

## Agent Capabilities

### 1. Analysis Agent
- Validates specifications
- Checks prerequisites
- Identifies resource requirements

### 2. Architecture Agent
- Generates visual diagrams
- Creates topology documentation
- Maps resource dependencies

### 3. Deployment Agent
- Converts specs to Bicep/Terraform
- Applies naming conventions (CAF compliant)
- Creates parameter files
- Generates deployment scripts

### 4. Documentation Agent
- Creates deployment guides
- Generates runbooks
- Builds troubleshooting docs
- Produces cost estimates

### 5. Validation Agent
- Reviews generated artifacts
- Checks against Azure best practices
- Validates naming conventions
- Ensures security compliance

## Running Specific Agents

You can run individual agents:

```bash
# Only generate architecture
python agents/core/orchestrator.py my-deployment.yaml \
  --agents architecture

# Generate architecture and IaC
python agents/core/orchestrator.py my-deployment.yaml \
  --agents architecture deployment

# Run all agents (default)
python agents/core/orchestrator.py my-deployment.yaml
```

## Validating Your Specification

Before generation, validate your spec:

```bash
python agents/core/spec_parser.py my-deployment.yaml
```

This will:
- Check schema compliance
- List resources to be created
- Show deployment summary

## Advanced Features

### Multi-Region Deployments

```yaml
spec:
  hostPools:
    - name: hp-primary
      location: eastus2
      ...
    - name: hp-dr
      location: westus2
      ...
```

### Custom Naming

```yaml
spec:
  deploymentPrefix: "ACME"
  # Resources will be named: st-acme-*, kv-acme-*, etc.
```

### Using Existing Resources

```yaml
spec:
  networking:
    createNew: false
    vnet:
      resourceId: "/subscriptions/.../vnet-existing"
```

## Troubleshooting

### Common Issues

**Schema validation fails:**
- Check your YAML syntax
- Ensure all required fields are present
- Verify enum values match allowed options

**Missing dependencies:**
```bash
pip install -r requirements.txt
```

**Agent execution errors:**
- Check the error messages in output
- Verify your specification is valid
- Ensure output directory is writable

## Next Steps

1. **Customize your specification** - Start with an example and modify for your needs
2. **Generate artifacts** - Run the orchestrator to create deployment resources
3. **Review and test** - Examine generated code and documentation
4. **Deploy** - Use the generated IaC to deploy your AVD environment
5. **Iterate** - Update your spec and regenerate as needed

## Documentation

- [Specification Schema](specs/schema/avd-spec-v1.schema.json)
- [Architecture Overview](spec-driven-architecture.md)
- [Example Specifications](specs/examples/)

## Support

For issues or questions:
- Check existing [Issues](https://github.com/Azure/avdaccelerator/issues)
- Review [Troubleshooting Guide](docs/troubleshooting.md)
- Consult [AVD Documentation](https://learn.microsoft.com/azure/virtual-desktop/)
