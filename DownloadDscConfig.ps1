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

