targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

// =========== //
// Variable declaration //
// =========== //


// =========== //
// Deployments //
// =========== //

resource imageTemplateBuildAutomationRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'Image Template Build Automation'
}

resource imageTemplateContributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'Image Template Contributor'
}

// =========== //
// Outputs     //
// =========== //
output imageTemplateBuildAutomationRoleId string = imageTemplateBuildAutomationRole.id
output imageTemplateContributorRoleId string = imageTemplateContributorRole.id
