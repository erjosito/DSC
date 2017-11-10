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