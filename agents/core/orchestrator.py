"""
AVD Spec-Driven Deployment - Core Orchestrator

This module orchestrates the agent-based workflow for converting
AVD specifications into deployment artifacts.
"""

import json
import yaml
from pathlib import Path
from typing import Dict, Any, List
from dataclasses import dataclass
from enum import Enum


class AgentType(Enum):
    """Types of agents in the system"""
    ANALYSIS = "analysis"
    ARCHITECTURE = "architecture"
    DEPLOYMENT = "deployment"
    DOCUMENTATION = "documentation"
    VALIDATION = "validation"


@dataclass
class AgentResult:
    """Result from an agent execution"""
    agent_type: AgentType
    success: bool
    artifacts: List[Path]
    messages: List[str]
    errors: List[str]


class AVDOrchestrator:
    """
    Main orchestrator for spec-driven AVD deployments.
    
    Coordinates multiple AI agents to generate:
    - Architecture diagrams
    - IaC templates (Bicep/Terraform)
    - Documentation
    - CI/CD pipelines
    """
    
    def __init__(self, spec_path: Path, output_dir: Path):
        """
        Initialize the orchestrator.
        
        Args:
            spec_path: Path to the AVD specification YAML file
            output_dir: Directory for generated artifacts
        """
        self.spec_path = spec_path
        self.output_dir = output_dir
        self.spec: Dict[str, Any] = {}
        self.results: List[AgentResult] = []
        
    def load_specification(self) -> bool:
        """
        Load and validate the AVD specification.
        
        Returns:
            True if specification is valid, False otherwise
        """
        try:
            with open(self.spec_path, 'r') as f:
                self.spec = yaml.safe_load(f)
            
            # Basic validation
            required_keys = ['apiVersion', 'kind', 'metadata', 'spec']
            for key in required_keys:
                if key not in self.spec:
                    raise ValueError(f"Missing required key: {key}")
            
            if self.spec['kind'] != 'AVDDeployment':
                raise ValueError(f"Invalid kind: {self.spec['kind']}")
            
            print(f"✓ Loaded specification: {self.spec['metadata']['name']}")
            print(f"  Environment: {self.spec['metadata']['environment']}")
            print(f"  Region: {self.spec['metadata'].get('region', 'not specified')}")
            
            return True
            
        except Exception as e:
            print(f"✗ Error loading specification: {e}")
            return False
    
    def run(self, agents: List[AgentType] = None) -> bool:
        """
        Execute the orchestration workflow.
        
        Args:
            agents: List of agents to run. If None, runs all agents.
        
        Returns:
            True if all agents executed successfully
        """
        if not self.load_specification():
            return False
        
        # Default to running all agents
        if agents is None:
            agents = list(AgentType)
        
        print(f"\n{'='*60}")
        print(f"Starting AVD Deployment Generation")
        print(f"{'='*60}\n")
        
        # Create output directories
        self._create_output_structure()
        
        # Execute agents in sequence
        for agent_type in agents:
            result = self._execute_agent(agent_type)
            self.results.append(result)
            
            if not result.success:
                print(f"\n✗ Agent {agent_type.value} failed!")
                for error in result.errors:
                    print(f"  Error: {error}")
                return False
        
        # Summary
        self._print_summary()
        return True
    
    def _create_output_structure(self):
        """Create the output directory structure"""
        subdirs = [
            'architecture/diagrams',
            'architecture/topology',
            'iac/bicep',
            'iac/terraform',
            'docs/deployment-guides',
            'docs/runbooks',
            'docs/troubleshooting',
            'pipelines/github-actions',
            'pipelines/azure-devops'
        ]
        
        for subdir in subdirs:
            (self.output_dir / subdir).mkdir(parents=True, exist_ok=True)
    
    def _execute_agent(self, agent_type: AgentType) -> AgentResult:
        """
        Execute a specific agent.
        
        Args:
            agent_type: Type of agent to execute
        
        Returns:
            Result of agent execution
        """
        print(f"\n→ Executing {agent_type.value} agent...")
        
        # Import and execute the appropriate agent
        if agent_type == AgentType.ANALYSIS:
            from agents.analysis.analysis_agent import AnalysisAgent
            agent = AnalysisAgent(self.spec, self.output_dir)
            return agent.execute()
        
        elif agent_type == AgentType.ARCHITECTURE:
            from agents.architecture.diagram_generator import ArchitectureAgent
            agent = ArchitectureAgent(self.spec, self.output_dir)
            return agent.execute()
        
        elif agent_type == AgentType.DEPLOYMENT:
            from agents.deployment.bicep_generator import DeploymentAgent
            agent = DeploymentAgent(self.spec, self.output_dir)
            return agent.execute()
        
        elif agent_type == AgentType.DOCUMENTATION:
            from agents.documentation.doc_generator import DocumentationAgent
            agent = DocumentationAgent(self.spec, self.output_dir, self.results)
            return agent.execute()
        
        elif agent_type == AgentType.VALIDATION:
            from agents.validation.validator import ValidationAgent
            agent = ValidationAgent(self.spec, self.output_dir, self.results)
            return agent.execute()
        
        else:
            return AgentResult(
                agent_type=agent_type,
                success=False,
                artifacts=[],
                messages=[],
                errors=[f"Unknown agent type: {agent_type}"]
            )
    
    def _print_summary(self):
        """Print execution summary"""
        print(f"\n{'='*60}")
        print(f"Deployment Generation Summary")
        print(f"{'='*60}\n")
        
        total_artifacts = sum(len(r.artifacts) for r in self.results)
        successful = sum(1 for r in self.results if r.success)
        
        print(f"Agents executed: {len(self.results)}")
        print(f"Successful: {successful}/{len(self.results)}")
        print(f"Total artifacts generated: {total_artifacts}\n")
        
        # List artifacts by agent
        for result in self.results:
            status = "✓" if result.success else "✗"
            print(f"{status} {result.agent_type.value.upper()}")
            for artifact in result.artifacts:
                print(f"  → {artifact.relative_to(self.output_dir)}")
            for message in result.messages:
                print(f"  ℹ {message}")
        
        print(f"\nOutput directory: {self.output_dir}")


def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='AVD Spec-Driven Deployment Orchestrator'
    )
    parser.add_argument(
        'spec',
        type=Path,
        help='Path to AVD specification YAML file'
    )
    parser.add_argument(
        '--output-dir',
        type=Path,
        default=Path('./generated'),
        help='Output directory for generated artifacts'
    )
    parser.add_argument(
        '--agents',
        nargs='+',
        choices=[a.value for a in AgentType],
        help='Specific agents to run (default: all)'
    )
    
    args = parser.parse_args()
    
    # Convert agent names to AgentType enum
    agents = None
    if args.agents:
        agents = [AgentType(a) for a in args.agents]
    
    # Run orchestrator
    orchestrator = AVDOrchestrator(args.spec, args.output_dir)
    success = orchestrator.run(agents)
    
    exit(0 if success else 1)


if __name__ == '__main__':
    main()
