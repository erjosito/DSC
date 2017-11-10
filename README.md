# DSC Automation and Sovereign Clouds

In this repo you can find some artifacts to play with DSC in Azure German Cloud. The main challenge there is that Azure Automation is not supported today, so you need to use Azure Automation in a different cloud (standard Azure). Since there is no easy way of registering VMs in MCD from an Automation account in say West Europe, you need to use some mechanism other than the Azure Automation GUI.

## How to use these templates

### Azure Automation Account

1. You need an Azure Automation account in the international cloud: I use West Europe. You need to import an example config (for example the TestConfig.ps1 file in this repo) and compile it. Verify that you have two Config Nodes
2. You need to copy the URL and key of your automation account and save them for later (Notepad is your friend)

### Resource Group and Vnet in the Azure German Cloud

I used Azure CLI for that:

1. Log into the German Cloud:

az cloud set -n AzureGermanCloud

"az login" with a token that you need to validate in https://aka.ms/deviceloginde did not work for me (the portal didnt take the token for some reason), so I had to use standard password-based auth:

```
az login -t your_tenant_id -u your_username -p your_password
```

2. Create a resource group. For example in Germany Central. You can set the default group to the newly created group, for ease of use:

```
az group create -n  dscTest --location germanycentral
```

```
az configure --defaults group=dscTest
```

3. Create a vnet. You could create the vnet as well in the ARM template, but I prefer it like this, to keep the template as flexible as possible:

```
az network vnet create -n myVnet --address-prefixes 192.168.0.0/16 --subnet-name subnet1 --subnet-prefix 192.168.1.0/24
```


### Deploy the template

You probably want to clone the repo to your local computer, so that you have the parameters file (the template could be referred with the URL). You can use this command:

Before deploying, make sure you replace the URL and Key in the parameters file with the ones of your Automation Account

```
az group deployment create --template-file ./azuredeploy.json --parameters @./azuredeploy.parameters.json
```

At this point it takes quite a lot of time to deploy, but after some (many) minutes, you should see the VM popping up in your automation account with the state "Compliant"


### CI/CD

You might want to automatically change the configuration of your VM when the source code for the DSC configuration changes. Although there is no native integration between Azure Automation DSC and Github, you could have a script which is triggered by Github through a Webhook upon every push, which updates the node configurations.

You can find an example of such a script in this repo (DownloadDscConfig.ps1). You can create a Powershell Runbook in Azure Automation, create a Webhook, and configure that Webhook in your Github repository.