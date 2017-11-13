#######################################################
#
# by Jose Moreno, November 2017
# Downloads a DSC file from Github and compiles it
# Ideally triggered from Github with a Webhook
#
#######################################################


# Variables
$connectionName = "AzureRunAsConnection"
$subName = "Visual Studio Enterprise"
$rg = "PermanentLab"
$accountName = "myDscAutomation"
$configUrl = "https://raw.githubusercontent.com/erjosito/DSC/master/TestConfig.ps1"
$configUrlSplit = $configUrl.Split("/")
$filename = $configUrlSplit[$configUrlSplit.Length - 1]
$tmpDir = $env:TEMP # in Azure Automation??
$tmpFilename = $tmpDir + "\" + $filename
$configName = $filename.Split(".")[0]
Write-Output ("Filename: " + $tmpFilename)
Write-Output ("Config name: " + $configName)

# Log into Azure with a Connection
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
    Write-Output ("Logging in to Azure...")
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
} catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# Check that we have access to the automation account
$myAccount = Get-AzureRmAutomationAccount -Name $accountName -ResourceGroupName $rg -ErrorAction SilentlyContinue
if ($myAccount) {
    Write-Output ("Automation account '" + $accountName + "' found in subscription '" + $subName + "'")
} else {
    Write-Output ("Automation account '" + $accountName + "' could not be found in subscription '" + $subName + "'")    
    Exit
}

# Update config
Write-Output ("Getting new config from URL " + $configUrl)
Invoke-WebRequest -Uri $configUrl -OutFile $tmpFilename
Import-AzureRmAutomationDscConfiguration -SourcePath $tmpFileName -ResourceGroupName $rg -AutomationAccountName $accountName -Verbose -Published -Force
$myConfig = Get-AzureRmAutomationDscConfiguration -Name $configName -ResourceGroupName $rg -AutomationAccountName $accountName -ErrorAction SilentlyContinue
if ($myConfig) {
    # Compile the new config
    Start-AzureRmAutomationDscCompilationJob -ConfigurationName $configName  -ResourceGroupName $rg -AutomationAccountName $accountName
} else {
    Write-Output ("The config '" + $configName + "' does not seem to exist in automation account '" + $accountName + "'")
}

# Download web files and copy them to an Azure Files share
# The goal here was to provide a repository from where DSC could deploy the files, since DSC does not support
#   downloading from HTTP URLs. However, the workaround is just using a Script resource in DSC with the 
#   powershell command Invoke-HttpRequest
<#
Write-Output ("Copying files from Github to local file system...")
$StorageAccountName = "permanentlabdisks578"
$rscgrp = "PermanentLab"
$shareName = "myshare"
$shareDir = "webfiles"
$srcDir = "https://raw.githubusercontent.com/erjosito/DSC/master/"
$localDir = $tmpDir + "\"
$files = @("index.html", "styles.css", "favicon.ico")
foreach ($file in $files) {
    $srcFile = $srcDir + $file
    $localFile = $localDir + $file
    Invoke-WebRequest -Uri $srcFile -OutFile $localFile
}
Write-Output ("Copying files from local file system to an Azure Files share...")
$myshare = Get-AzureRmStorageAccount -name $StorageAccountName -ResourceGroupName $rg | Get-AzureStorageShare -Name $shareName
if ($myshare) {
    Write-Output ("Share '" + $shareName + "' found in storage account '" + $StorageAccountName + "'")
} else {
    Write-Output ("Share '" + $shareName + "' could not be found in storage account '" + $StorageAccountName + "'")
    Exit    
}
foreach ($file in $files) {
    $localFile = $localDir + $file
    Set-AzureStorageFileContent -share $myshare -Source $localFile -Path $shareDir
}
#>