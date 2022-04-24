# Instructions

## Creating VM

* generate an ssh key
* set up vars:
  * virtualNetworkName=<vnet_created>
  * subnetName=<appSubnet>
* run the command: az deployment group create --template-file build-vm.bicep --parameters virtualNetworkName=$virtualNetworkName subnetName=$subnetName authenticationType=sshPublicKey 

## uploading private certificate to web apps

* Generate certificate in .pfx format

```bash
openssl req -new -x509 -key https.key -out https.cert -days 3650 -subj /CN="*.azurewebsites.net"
openssl pkcs12 -export -out myserver.pfx -inkey https.key -in https.cert
```

* When prompted, define an export password. You'll use this password when uploading your TLS/SSL certificate to App Service later.
* on your web app page, select `TLS/SSL settings (preview)` blade
* click `+ Add Certificate`
* for `Source` select `Upload certificate (.pfx)`
* upload `myserver.pfx` created in previous step

## installing web app application and SQL DB schema

* login to VM using bastion host
  * on Azure Portal, search for `virtual machines`
  * select the VM that was created earlier
  * on the `bastion host blade` set `username` to `azureuser` and use `SSH Key from Local FIle` to log in
* run the following commands:

```bash
sudo apt update

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

git clone https://github.com/Azure-Samples/msdocs-app-service-sqldb-dotnetcore.git
cd msdocs-app-service-sqldb-dotnetcore

az login --use-device-code
az configure --defaults group=<rg_name>
az webapp deployment source config-local-git -n <webapp_name>

git remote add azure https://<your-app-name>.scm.azurewebsites.net/<your-app-name>.git
git push azure main:master
```

* Retrieve the deployment credentials for your application. These will be needed for Git to authenticate to Azure when you push code to Azure in a later step
* az webapp deployment list-publishing-credentials -n <webapp_name> --query "{Username:publishingUserName, Password:publishingPassword}"
* We can retrieve the Connection String for our database using the az sql db show-connection-string command. This command allows us to add the Connection String to our App Service configuration settings. Copy this Connection String value for later use

```cli
az sql db show-connection-string \
    --client ado.net \
    --name coreDb \
    --server <your-server-name>
```

* Next, let's assign the Connection String to our App Service using the command below. MyDbConnection is the name of the Connection String in our appsettings.json file, which means it gets loaded by our app during startup.

* **Replace the username and password** in the connection string with your own before running the command.

```bash
az webapp config connection-string set \
    -n <your-app-name> \
    -t SQLServer \
    --settings MyDbConnection=<your-connection-string>
```

```bash
cd DotNetCoreSqlDb
```

* update the `appsettings.json` file in our local app code with the Connection String of our Azure SQL Database
* **Replace the server name, username and password placeholders** with the values you chose when creating your database.

```json
"ConnectionStrings": {
    "MyDbConnection": "Server=tcp:<server_name>.database.windows.net,1433;
        Initial Catalog=coredb;
        Persist Security Info=False;
        User ID=<username>;Password=<password>;
        Encrypt=True;
        TrustServerCertificate=False;"
  }
```

* run the following commands to install the necessary CLI tools for Entity Framework Core. 
* Create an initial database migration file and apply those changes to update the database

```bash
dotnet tool install -g dotnet-ef \
dotnet ef migrations add InitialCreate \
dotnet ef database update
```


