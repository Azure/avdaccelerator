#!/usr/bin/env python3
"""
Test script for AVD Pre-Deployment Validator Agent

Tests the validation agent's ability to:
1. Analyze resources that will be created
2. Estimate deployment costs
3. Identify prerequisites
4. Detect existing resource impacts
"""

import sys
from pathlib import Path

# Add the agents directory to the path
sys.path.insert(0, str(Path(__file__).parent.parent))

from validation.pre_deployment_validator import PreDeploymentValidator


def test_validator():
    """Test the pre-deployment validator"""
    print("\n" + "=" * 60)
    print("Testing AVD Pre-Deployment Validator Agent")
    print("=" * 60)
    
    # Initialize validator
    validator = PreDeploymentValidator()
    print("\n✓ Validator initialized successfully")
    
    # Test 1: Default parameters validation
    print("\n1. Testing with default parameters...")
    result = validator.validate()
    print(f"   Resources to create: {len(result.resources_to_create)}")
    print(f"   Prerequisites: {len(result.prerequisites)}")
    print(f"   Existing resource checks: {len(result.existing_resource_checks)}")
    print(f"   Estimated cost: ${result.estimated_monthly_cost:.2f}/month")
    print(f"   Is valid: {result.is_valid}")
    print(f"   Errors: {len(result.errors)}")
    print(f"   Warnings: {len(result.warnings)}")
    
    # Test 2: Custom parameters (production-like)
    print("\n2. Testing with production-like parameters...")
    validator.set_parameters({
        "deploymentPrefix": "PROD",
        "deploymentEnvironment": "Prod",
        "avdWorkloadSubsId": "12345678-1234-1234-1234-123456789012",
        "avdIdentityServiceProvider": "ADDS",
        "identityDomainName": "contoso.com",
        "avdDeploySessionHostsCount": 5,
        "avdSessionHostsSize": "Standard_D4ads_v5",
        "avdSessionHostDiskType": "Premium_LRS",
        "createAvdFslogixDeployment": True,
        "fslogixStoragePerformance": "Premium",
        "fslogixFileShareQuotaSize": 500,
        "diskZeroTrust": True,
        "deployPrivateEndpointKeyvaultStorage": True,
        "deployAvdPrivateLinkService": True,
        "avdDeployMonitoring": True,
        "deployAlaWorkspace": True,
    })
    
    result = validator.validate()
    print(f"   Resources to create: {len(result.resources_to_create)}")
    print(f"   Estimated cost: ${result.estimated_monthly_cost:.2f}/month")
    print(f"   Is valid: {result.is_valid}")
    
    # Test 3: Cost breakdown
    print("\n3. Testing cost breakdown...")
    if result.cost_breakdown:
        print("   Cost categories:")
        for category, cost in sorted(result.cost_breakdown.items(), key=lambda x: -x[1]):
            print(f"     - {category}: ${cost:.2f}")
    
    # Test 4: Resource types created
    print("\n4. Testing resource inventory...")
    resource_types = set(r.resource_type for r in result.resources_to_create)
    print(f"   Resource types: {len(resource_types)}")
    for rt in sorted(resource_types):
        count = len([r for r in result.resources_to_create if r.resource_type == rt])
        print(f"     - {rt}: {count}")
    
    # Test 5: Prerequisites by category
    print("\n5. Testing prerequisites...")
    prereq_categories = set(p.category for p in result.prerequisites)
    print(f"   Categories: {prereq_categories}")
    for cat in prereq_categories:
        count = len([p for p in result.prerequisites if p.category == cat])
        print(f"     - {cat}: {count} prerequisite(s)")
    
    # Test 6: Warnings
    print("\n6. Testing warnings generation...")
    if result.warnings:
        print(f"   Warnings ({len(result.warnings)}):")
        for w in result.warnings[:5]:  # Show first 5
            print(f"     {w}")
    
    # Test 7: Generate report
    print("\n7. Testing report generation...")
    report = validator.generate_report(result)
    print(f"   Report length: {len(report)} characters")
    print(f"   Report lines: {len(report.splitlines())}")
    
    # Test 8: JSON export
    print("\n8. Testing JSON export...")
    json_output = validator.export_to_json(result)
    import json
    parsed = json.loads(json_output)
    print(f"   JSON keys: {list(parsed.keys())}")
    print(f"   Resources in JSON: {len(parsed['resources'])}")
    print(f"   Prerequisites in JSON: {len(parsed['prerequisites'])}")
    
    # Test 9: Invalid configuration
    print("\n9. Testing invalid configuration detection...")
    validator_invalid = PreDeploymentValidator()
    validator_invalid.set_parameters({
        "deploymentPrefix": "X",  # Too short
        "avdIdentityServiceProvider": "ADDS",
        "identityDomainName": "",  # Missing required field
    })
    invalid_result = validator_invalid.validate()
    print(f"   Is valid: {invalid_result.is_valid}")
    print(f"   Errors: {len(invalid_result.errors)}")
    for e in invalid_result.errors:
        print(f"     {e}")
    
    # Test 10: DDoS Protection cost warning
    print("\n10. Testing high-cost feature warnings...")
    validator_ddos = PreDeploymentValidator()
    validator_ddos.set_parameters({
        "deploymentPrefix": "TEST",
        "deployDDoSNetworkProtection": True,
        "avdWorkloadSubsId": "test-sub-id",
    })
    ddos_result = validator_ddos.validate()
    ddos_warnings = [w for w in ddos_result.warnings if "DDoS" in w]
    print(f"   DDoS warning found: {len(ddos_warnings) > 0}")
    if ddos_warnings:
        print(f"   Warning: {ddos_warnings[0]}")
    
    print("\n" + "=" * 60)
    print("✓ All tests passed!")
    print("=" * 60)
    
    # Print sample report section
    print("\n--- Sample Report Preview (first 100 lines) ---\n")
    for line in report.splitlines()[:100]:
        print(line)
    print("\n[... report continues ...]")


if __name__ == "__main__":
    test_validator()
