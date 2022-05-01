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

* run the following commands to install az cli and jq utility:

```bash
sudo apt update

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo apt-get install jq -y
```

* install dotnet 6.0 SDK, runtime, and dotnet-ef tool

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

* set up Azure Actions Runner

```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.290.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.290.1/actions-runner-linux-x64-2.290.1.tar.gz
tar xzf ./actions-runner-linux-x64-2.290.1.tar.gz
./config.sh --url https://github.com/ahmedbham/appgw-pep-webapp-pep-sqlserver --token AD6P6TJKEQGKSUHUYAF6WRDCN2RZE
./run.sh
```

## Test your web app access via Application Gateway

* open a new browser window and enter Application Gateway URL
