# Instructions

## Creating VM

* set up variable: `export hubVnetName=<hub-vnet_name>`
* run the command:

```bash
az deployment group create --template-file build-vm.bicep --parameters virtualNetworkName=$hubVnetName authenticationType=password 
```

## installing web app application and SQL DB schema

* login to VM using bastion host
  * on Azure Portal, search for `virtual machines`
  * select the VM that was created earlier
  * on the `bastion host blade` use `Password` to log in
* run the following commands:

```bash
sudo apt update

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get install jq -y
```

* install dotnet 6.0 SDK and runtime

```bash
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y dotnet-sdk-6.0
sudo apt-get install -y dotnet-runtime-6.0
dotnet tool install -g dotnet-ef
```

* clone sample repo

```bash
git clone https://github.com/Azure-Samples/msdocs-app-service-sqldb-dotnetcore.git
```

## Test your web app access via Application Gateway

* open a new browser window and enter Application Gateway URL
