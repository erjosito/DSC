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
        File index
        {            	
            # Download an HTML home page
            Ensure = "Present"
            Type = "File"
            SourcePath ="https://raw.githubusercontent.com/erjosito/DSC/master/index.html"
            DestinationPath = "C:\inetpub\wwwroot\index.html"
            MatchSource = $true
        }
        File favicon
        {            	
            # favicon.ico for the previous home page
            Ensure = "Present"
            Type = "File"
            SourcePath ="https://raw.githubusercontent.com/erjosito/DSC/master/favicon.ico"
            DestinationPath = "C:\inetpub\wwwroot\favicon.ico"
            MatchSource = $false
        }
        File cssfile
        {            	
            # And the CSS styles file for the home page
            Ensure = "Present"
            Type = "File"
            SourcePath ="https://raw.githubusercontent.com/erjosito/DSC/master/styles.css"
            DestinationPath = "C:\inetpub\wwwroot\styles.css"
            MatchSource = $false
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