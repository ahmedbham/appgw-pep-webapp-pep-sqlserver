## What gets Deployed
* vnet with four subnets
  * subnet1 has AppGateway with a public IP address, and backend pool talking to private endpoints of two web apps in subnet3
  * subnet2 has two webapps deployed, and outbound traffic restricted to subnet3
  * subnet3 has three private endpoints: one each for two web apps, and one for SQL Server deployed in subnet4
  * subnet4 has a SQL Server which is only accessible via private endpoint deployed in subnet3

## Instructions

* login to Azure: `az login` or `az login --use-device-code`
* create a resource group: `az group create --name <rg_name> --location <location>`
* set the resource group as a default: `az configure --defaults group=<rg_name>`
* run the command: `az deployment group create --template-file main.bicep --parameters sqlAdministratorLogin=<admin_name> `
  * when prompted, enter a password for SQL Server
* when deployment completes, get the output appGatewayUrl from the resulting json

## Next Steps
* deploy a web application in one of the webapp which access SQL server data and shows it to the user by opening [README.md](appgw-appsvc-sqldb/README.md)
