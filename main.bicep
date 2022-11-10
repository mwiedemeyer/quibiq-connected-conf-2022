targetScope = 'subscription'

@allowed([ 'westeurope', 'eastus' ])
@description('Location for the resources.')
param location string = 'westeurope'

var deployLogicApp = true

var uniqueSuffix = substring(uniqueString(tenant().tenantId, subscription().subscriptionId, location), 0, 6)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${uniqueSuffix}'
  location: location
  tags: {
    environment: 'dev'
    'cost-center': '1234'
  }
}

module logic 'modules/logicapp.bicep' = if (deployLogicApp) {
  name: 'logicapp'
  scope: rg
  params: {
    location: rg.location
    suffix: uniqueSuffix
  }
}

output logicAppUrl string = logic.outputs.logicappUrl
output logicAppPrincipalId string = logic.outputs.principalId
