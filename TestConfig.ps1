configuration TestConfig
{
    Node myConfig1
    {
        WindowsFeature IIS
        {
            # IIS enabled
            Ensure               = 'Present'
            Name                 = 'Web-Server'
            IncludeAllSubFeature = $true
        }

        WindowsFeature staticContent
        {
            Ensure = 'Present'
            Name = 'Web-Static-Content'
            DependsOn = 'IIS'
        }

        Service RemoteDesktopService
        {
            # Ensure the Remote Desktop Service is Set to Automatic and is Running
            Ensure = 'Present'
            Name = 'TermService'
            StartupType = 'Automatic'
            State = 'Running'
        }
        <#
        # Since DSC cannot download from a Web URL, the script resource right after seems like a quick & dirty
        #  solution. Otherwise putting the files in an interim Azure Files share might be an idea.
        File webPage
        {            	
            # Download an HTML home page
            Ensure = "Present"
            Type = "File"
            SourcePath="\\permanentlabdisks578.file.core.windows.net\myshare\webfiles\index.html"
            DestinationPath = "C:\inetpub\wwwroot\index.html"
            Credential = $storageCredentials
            MatchSource = $true
        }
        #>
        Script myScript
        { 
            GetScript = { @{ Result = (Get-Content C:\inetpub\wwwroot\index.html) } }
            SetScript = {
                Invoke-WebRequest -uri https://raw.githubusercontent.com/erjosito/DSC/master/index.html -outfile C:\inetpub\wwwroot\index.html
                Invoke-WebRequest -uri https://raw.githubusercontent.com/erjosito/DSC/master/styles.css -outfile C:\inetpub\wwwroot\styles.css
                Invoke-WebRequest -uri https://raw.githubusercontent.com/erjosito/DSC/master/favicon.ico -outfile C:\inetpub\wwwroot\favicon.ico
            } 
            TestScript = { $False }
        }

    }

    Node myConfig2
    {
        WindowsFeature IIS
        {
            # IIS disabled
            Ensure               = 'Absent'
            Name                 = 'Web-Server'
        }
    }
}