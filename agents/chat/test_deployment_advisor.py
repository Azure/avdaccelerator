#!/usr/bin/env python3
"""Test script for the Deployment Advisor Agent"""

import sys
sys.path.insert(0, '.')

from agents.chat.deployment_advisor import DeploymentAdvisorAgent, ConversationStage, BASELINE_PARAMETERS

def test_agent():
    print("=" * 60)
    print("Testing AVD Deployment Advisor Agent")
    print("=" * 60)
    print()
    
    # Initialize agent
    agent = DeploymentAdvisorAgent()
    print(f"✓ Agent initialized successfully")
    print(f"  Parameters defined: {len(BASELINE_PARAMETERS)}")
    print(f"  Categories: {sorted(set(p.category for p in BASELINE_PARAMETERS.values()))}")
    print()
    
    # Test welcome message
    print("1. Testing welcome message...")
    welcome = agent.format_welcome_message()
    assert "Azure Virtual Desktop" in welcome
    assert "Deployment Advisor" in welcome
    print("   ✓ Welcome message OK")
    print()
    
    # Test navigation
    print("2. Testing navigation (next)...")
    response = agent.process_input('next')
    assert agent.get_current_stage() == ConversationStage.BASICS
    print(f"   ✓ Stage: {agent.get_current_stage().value}")
    print()
    
    # Test parameter setting
    print("3. Testing parameter setting...")
    response = agent.process_input('deploymentPrefix=TEST')
    assert agent.get_parameter_value('deploymentPrefix') == 'TEST'
    print(f"   ✓ deploymentPrefix = {agent.get_parameter_value('deploymentPrefix')}")
    
    response = agent.process_input('deploymentEnvironment=Prod')
    assert agent.get_parameter_value('deploymentEnvironment') == 'Prod'
    print(f"   ✓ deploymentEnvironment = {agent.get_parameter_value('deploymentEnvironment')}")
    print()
    
    # Test validation
    print("4. Testing parameter validation...")
    success, msg = agent.set_parameter('deploymentPrefix', 'TOOLONG')
    assert not success
    print(f"   ✓ Rejected invalid prefix: {msg}")
    
    success, msg = agent.set_parameter('hostPoolMaxSessions', 5)
    assert success
    print(f"   ✓ Accepted valid max sessions: {agent.get_parameter_value('hostPoolMaxSessions')}")
    print()
    
    # Test recommendations
    print("5. Testing contextual recommendations...")
    agent.set_parameter('avdIdentityServiceProvider', 'EntraID')
    recs = agent.get_contextual_recommendations()
    assert len(recs) > 0
    print(f"   ✓ Got {len(recs)} recommendations for EntraID")
    for rec in recs[:2]:
        print(f"     - {rec[:60]}...")
    print()
    
    # Test review
    print("6. Testing review...")
    agent.process_input('review')
    assert agent.get_current_stage() == ConversationStage.REVIEW
    review = agent.format_review()
    assert "deploymentPrefix" in review
    assert "TEST" in review
    print("   ✓ Review generated successfully")
    print()
    
    # Test JSON export
    print("7. Testing JSON export...")
    json_output = agent.export_to_json_parameters()
    assert '"deploymentPrefix"' in json_output
    assert '"TEST"' in json_output
    print("   ✓ JSON export OK")
    print(f"   Preview: {json_output[:150]}...")
    print()
    
    # Test YAML export
    print("8. Testing YAML export...")
    yaml_output = agent.export_to_yaml()
    assert 'deploymentPrefix' in yaml_output
    assert 'TEST' in yaml_output
    print("   ✓ YAML export OK")
    print(f"   Preview: {yaml_output[:200]}...")
    print()
    
    print("=" * 60)
    print("✓ All tests passed!")
    print("=" * 60)

if __name__ == '__main__':
    test_agent()
