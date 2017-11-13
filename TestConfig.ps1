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
        Service RemoteDesktopService
        {
            # Ensure the Remote Desktop Service is Set to Automatic and is Running
            Ensure = 'Present'
            Name = 'TermService'
            StartupType = 'Automatic'
            State = 'Running'
        }
        #File index
        #{            	
            # Download an HTML home page
            # net use Z: \\permanentlabdisks578.file.core.windows.net\myshare /u:AZURE\permanentlabdisks578 SQm+x0M2Vk4lLAatfLmIlS4ErI4fXC6JbPH9LevqgsU11Y/XM/dQg9gS+fCleyBDr51x+poYBalnXi1R7SOtZQ==
        #    Ensure = "Present"
        #    Type = "File"
            #SourcePath ="https://raw.githubusercontent.com/erjosito/DSC/master/index.html"
        #    SourcePath="\\permanentlabdisks578.file.core.windows.net\myshare\webfiles\index.html"
        #    DestinationPath = "C:\inetpub\wwwroot\index.html"
        #    Credential = $storageCredentials
        #    MatchSource = $true
        #}
        Script myScript
        { 
            GetScript = { $False }
            SetScript = { Invoke-WebRequest -uri https://raw.githubusercontent.com/erjosito/DSC/master/index.html -outfile C:\inetpub\wwwroot\index.html } 
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