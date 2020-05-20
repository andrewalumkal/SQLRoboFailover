Function Get-SQLAgentService {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )
  
    $query = @"
            
    select  dss.servicename as [ServiceName]
       ,dss.status_desc as [Status]
       ,dss.startup_type_desc as [StartupType]
    from    sys.dm_server_services as dss
    where   dss.servicename like 'SQL Server Agent%';
        
"@

    try {
        $SQLAgentService = Invoke-Sqlcmd -ServerInstance $ServerInstance -query $query -Database master -QueryTimeout 60 -ErrorAction Stop
        return $SQLAgentService
        
    }
    
    catch {
        Write-Error "Failed to retrieve SQL Agent Service from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }

    
    
}