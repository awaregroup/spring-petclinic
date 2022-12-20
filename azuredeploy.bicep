@description('The service name of the Azure Spring Apps service')
param springAppServiceName string

@description('The instance name of the Azure Spring Cloud resource')
param springAppInstanceName string

// @description('The name of the Application Insights instance for Azure Spring Cloud')
// param applicationInsightsName string

// @description('The name of the Log Analytics Workspace to back the App Insights instance')
// param logAnalyticsWorkspaceName string

@description('The name of the Azure region that resources should be deployed into, e.g. southeastasia')
param resourceLocationName string

// At the time of writing it didn't seem to like associating a LAWS and App Insights resource with an
// Azure Spring App, so they have been removed
// There is a guide here, but AFAIK we're using the same API versiond for resource (except the LAWS as that
// is not included in the example) and things don't work =\
// https://learn.microsoft.com/en-us/azure/spring-apps/quickstart-deploy-infrastructure-vnet-bicep?tabs=azure-spring-apps-standard
//
// Error:
// {"status":"Failed","error":{"code":"DeploymentFailed","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/DeployOperations for usage details.","details":[{"code":"BadRequest","message":"{\r\n  \"code\": \"ResourceTypeNotSupported\",\r\n  \"message\": \"The resource type 'microsoft.appplatform/spring/apps' does not support diagnostic settings.\"\r\n}"},{"code":"NotFound","message":"{\r\n  \"error\": {\r\n    \"code\": \"ResourceNotFound\",\r\n    \"message\": \"The Resource 'Microsoft.AppPlatform/Spring/pet-clinic-1' under resource group 'OssOnAzure-JavaSpring-Prod' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix\"\r\n  }\r\n}"}]}}

// resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
//   name: logAnalyticsWorkspaceName
//   location: resourceLocationName
//   properties: {
//     sku: {
//       name: 'pergb2018'
//     }
//     retentionInDays: 30
//     features: {
//       enableLogAccessUsingOnlyResourcePermissions: true
//     }
//     workspaceCapping: {
//       dailyQuotaGb: -1
//     }
//     publicNetworkAccessForIngestion: 'Enabled'
//     publicNetworkAccessForQuery: 'Enabled'
//   }
// }

// resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
//   name: applicationInsightsName
//   location: resourceLocationName
//   kind: 'web'
//   properties: {
//     Application_Type: 'web'
//     Flow_Type: 'Bluefield'
//     Request_Source: 'rest'
//     WorkspaceResourceId: logAnalyticsWorkspace.id
//   }
// }

resource springAppService 'Microsoft.AppPlatform/Spring@2022-03-01-preview' = {
  name: springAppServiceName
  location: resourceLocationName
  sku: {
    name: 'B0'
    tier: 'Basic'
  }
  properties: {
    zoneRedundant: false
  }
}

resource springAppInstance 'Microsoft.AppPlatform/Spring/apps@2022-03-01-preview' = {
  parent: springAppService
  name: springAppInstanceName
  location: resourceLocationName
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    addonConfigs: {
      applicationConfigurationService: {
      }
      serviceRegistry: {
      }
    }
    public: true
    httpsOnly: false
    temporaryDisk: {
      sizeInGB: 5
      mountPath: '/tmp'
    }
    persistentDisk: {
      sizeInGB: 0
      mountPath: '/persistent'
    }
    enableEndToEndTLS: false
  }
}

// resource springCloudMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2020-07-01' = {
//   name: '${springAppInstance.name}/default' // The only supported value is 'default'
//   properties: {
//     traceEnabled: true
//     appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
//   }
// }

// resource springCloudDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   name: 'monitoring'
//   scope: springAppInstance
//   properties: {
//     workspaceId: logAnalyticsWorkspace.id
//     logs: [
//       {
//         category: 'ApplicationConsole'
//         enabled: true
//         retentionPolicy: {
//           days: 30
//           enabled: false
//         }
//       }
//     ]
//   }
// }
