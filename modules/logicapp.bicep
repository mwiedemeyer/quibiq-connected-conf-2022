param location string
param suffix string
param appSettings array = []

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'stg${suffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

resource asp 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-${suffix}'
  location: location
  sku: {
    name: 'WS1'
    tier: 'WorkflowStandard'
    size: 'WS1'
  }
  kind: 'elastic'
}

resource logicapp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'logicapp-${suffix}'
  location: location
  kind: 'functionapp,workflowapp'
  properties: {
    serverFarmId: asp.id
    siteConfig: {
      http20Enabled: true
      appSettings: concat(appSettings, [
          {
            name: 'APP_KIND'
            value: 'workflowApp'
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'node'
          }
          {
            name: 'AzureFunctionsJobHost__extensionBundle__id'
            value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
          }
          {
            name: 'AzureFunctionsJobHost__extensionBundle__version'
            value: '[1.*, 2.0.0)'
          }
          {
            name: 'WEBSITE_NODE_DEFAULT_VERSION'
            value: '~14'
          }
          {
            name: 'AzureWebJobsStorage'
            value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storage.id, storage.apiVersion).keys[0].value}'
          }
          {
            name: 'my-custom-setting'
            value: '1'
          }
        ])
    }
  }
}

output logicappUrl string = logicapp.properties.defaultHostName
output principalId string = logicapp.identity.principalId
