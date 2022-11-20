param naming object
param location string = resourceGroup().location
param tags object

// App Service Plan name should be unique within the resource group, opting for the simple 'name' property
resource appServicePlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: naming.appServicePlan.name
  location: location
  tags: tags
  sku: {
    name: 'F1'
    capacity: 1
  }
}

// Web application name should be globally unique, we prefer the 'nameUnique' property here
resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: naming.appService.nameUnique
  location: location
  tags: union({
    'hidden-related:${resourceGroup().id}/providers/Microsoft.Web/serverfarms/${appServicePlan.name}': 'Resource'
  }, tags)
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// Deploying a module, passing in the necessary naming parameters (storage account name should be also globally unique)
module storage 'modules/storage.module.bicep' = {
  name: 'StorageAccountDeployment'
  params: {
    location: location
    kind: 'StorageV2'
    skuName: 'Standard_LRS'
    name: naming.storageAccount.nameUnique
    tags: tags
  }
}

output storageAccountName string = storage.outputs.name
output appServiceName string = webApplication.name
output appServicePlanName string = appServicePlan.name
