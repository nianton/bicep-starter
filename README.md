# Bicep starter template
A template repository to get started with an bicep infrastructure-as-code project, including the azure naming module to facilitate naming conventions. For the full reference of the supported resource types, head to the main module repository: **[https://github.com/nianton/azure-naming](https://github.com/nianton/azure-naming#bicep-azure-naming-module)**

As in bicep the 'name' property of the resources to be created has to be know compile-time, the naming module cannot be directly consumed to name a resource but only as parameter to a module, we are resorting to have a subscription-level deployment **`azure.deploy.bicep`** which is passing as input parameter to the **`main.bicep`** deployment the naming part.

```bicep
targetScope = 'subscription'

param location string
param applicationName string
param environment string
param tags object = {}

var defaultTags = union({
  applicationName: applicationName
  environment: environment
}, tags)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${applicationName}-${environment}'
  location: location
  tags: defaultTags
}

module naming 'modules/naming.module.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'NamingDeployment'  
  params: {
    suffix: [
      applicationName
      environment
    ]
    uniqueLength: 6
    uniqueSeed: rg.id
  }
}

module main 'main.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'MainDeployment'
  params: {
    location: location
    naming: naming.outputs.names
    tags: defaultTags
  }
}

output resourceGroupName string = rg.name
output naming object = naming.outputs.names
```

The main deployment is handled by the **`main.bicep`** file, which dictates the resources to be created within the created resource group and is responsible to consume the naming module as input.

In the **`modules`** folder, there is a sample module implementation for a storage account named **`storage.module.bicep`**.