# AVD Spec-Driven Deployment - Project Structure

This document describes the organization of the spec-driven deployment system.

## Directory Structure

```
avdaccelerator/
│
├── specs/                              # Specification files
│   ├── schema/
│   │   └── avd-spec-v1.schema.json    # JSON Schema for validation
│   ├── examples/
│   │   ├── basic-deployment.yaml       # Simple dev/test deployment
│   │   └── enterprise-production.yaml  # Full production deployment
│   └── templates/
│       └── default-template.yaml       # Starter template
│
├── agents/                             # AI Agent implementations
│   ├── core/
│   │   ├── orchestrator.py            # Main orchestration engine
│   │   └── spec_parser.py             # Specification parser & validator
│   ├── analysis/
│   │   └── analysis_agent.py          # Analyzes specs & prerequisites
│   ├── architecture/
│   │   ├── diagram_generator.py       # Generates Mermaid diagrams
│   │   └── topology_builder.py        # Creates topology docs
│   ├── deployment/
│   │   ├── bicep_generator.py         # Generates Bicep templates
│   │   ├── terraform_generator.py     # Generates Terraform (planned)
│   │   └── naming_service.py          # CAF-compliant naming
│   ├── documentation/
│   │   ├── doc_generator.py           # Creates deployment guides
│   │   └── templates/                 # Doc templates
│   └── validation/
│       └── validator.py                # Validates artifacts
│
├── generated/                          # Agent-generated output
│   ├── architecture/
│   │   ├── diagrams/                  # Mermaid & visual diagrams
│   │   └── topology/                  # Topology documentation
│   ├── iac/
│   │   ├── bicep/                     # Generated Bicep templates
│   │   └── terraform/                 # Generated Terraform
│   ├── docs/
│   │   ├── deployment-guides/         # Step-by-step guides
│   │   ├── runbooks/                  # Operational procedures
│   │   └── troubleshooting/           # Common issues
│   └── pipelines/
│       ├── github-actions/            # GitHub workflow files
│       └── azure-devops/              # Azure Pipelines
│
├── tests/                              # Test suite
│   ├── unit/                          # Unit tests for agents
│   ├── integration/                   # Integration tests
│   └── e2e/                           # End-to-end tests
│
├── docs/                               # Framework documentation
│   ├── spec-driven-architecture.md    # Architecture overview
│   ├── getting-started.md             # Getting started guide
│   └── agent-development.md           # Agent development guide
│
├── workload/                           # Original AVD accelerator
│   ├── bicep/                         # Manual Bicep templates
│   ├── terraform/                     # Manual Terraform
│   └── ...
│
├── SPEC_DRIVEN_README.md              # This README
├── SPEC_DRIVEN_GETTING_STARTED.md     # Quick start guide
├── spec-driven-architecture.md         # Technical architecture
├── requirements.txt                    # Python dependencies
└── README.md                           # Original AVD accelerator README
```

## Key Components

### Specifications (`specs/`)
- **schema/** - JSON Schema definitions for validation
- **examples/** - Ready-to-use example specifications
- **templates/** - Starter templates for new deployments

### Agents (`agents/`)
- **core/** - Core orchestration and parsing logic
- **analysis/** - Requirement analysis and validation
- **architecture/** - Diagram and topology generation
- **deployment/** - IaC generation (Bicep/Terraform)
- **documentation/** - Guide and runbook generation
- **validation/** - Best practice validation

### Generated Output (`generated/`)
All agent-generated artifacts organized by type:
- **architecture/** - Visual and topology documentation
- **iac/** - Infrastructure as Code templates
- **docs/** - Deployment and operational documentation
- **pipelines/** - CI/CD automation

## Workflow

1. **Create Specification** - Define AVD requirements in YAML
2. **Run Orchestrator** - Execute agents to generate artifacts
3. **Review Output** - Examine generated code and docs
4. **Deploy** - Use generated IaC to deploy AVD
5. **Operate** - Follow generated runbooks

## File Naming Conventions

### Specifications
- `{deployment-name}.yaml` - Deployment specification
- `{deployment-name}-{environment}.yaml` - Environment-specific

### Generated Files
- `{deployment-name}-architecture.mmd` - Mermaid diagram
- `{deployment-name}-topology.md` - Topology documentation
- `main.bicep` - Main Bicep template
- `parameters.json` - Parameters file
- `deploy.ps1` - Deployment script

## Agent Execution Order

1. **Analysis Agent** - Validates spec and checks prerequisites
2. **Architecture Agent** - Generates diagrams and topology
3. **Deployment Agent** - Creates IaC templates
4. **Documentation Agent** - Generates guides and runbooks
5. **Validation Agent** - Reviews all generated artifacts

## Integration Points

### With Original AVD Accelerator
The spec-driven system complements the original accelerator:
- Can generate code compatible with existing patterns
- Leverages same modules and best practices
- Provides alternative deployment path

### With External Systems
- **Azure DevOps** - Generated pipeline templates
- **GitHub Actions** - Automated deployment workflows
- **Azure CLI/PowerShell** - Generated deployment scripts
- **Terraform Cloud** - Remote state management

## Customization

### Adding New Agents
1. Create agent module in appropriate directory
2. Implement `execute()` method returning `AgentResult`
3. Register in orchestrator
4. Add tests

### Extending Schema
1. Update `avd-spec-v1.schema.json`
2. Update parser logic
3. Update agent generation logic
4. Add examples
5. Update documentation

### Custom Templates
- Add to `agents/{agent-type}/templates/`
- Reference in agent code
- Test with example specs

## Best Practices

### Specifications
- Use descriptive deployment names
- Include comprehensive tags
- Document non-obvious choices
- Version control specs

### Agents
- Keep agents focused and single-purpose
- Return comprehensive results
- Handle errors gracefully
- Log important decisions

### Generated Code
- Don't manually edit generated files
- Customize via specs, not generated output
- Use version control for generated code
- Document customizations

## Support Files

- **requirements.txt** - Python dependencies
- **tests/** - Test suite for validation
- **docs/** - Additional documentation

## Future Enhancements

- Web UI for specification builder
- Real-time validation
- Cost estimation integration
- Migration from existing deployments
- Multi-cloud support
