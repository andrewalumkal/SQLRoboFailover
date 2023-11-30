Function Get-ServerNameFromSQL {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )
    
    #Get servername as registered in SQL Server.
    #This is useful when modifying AG replicas as some replica names may not have fully qualified strings.
    $query = @"
            
    select @@SERVERNAME as ServerName;
        
"@

    try {
        $ServerNameFromSQL = Invoke-SqlCmd -TrustServerCertificate -ServerInstance $ServerInstance -query $query -Database master -QueryTimeout 30 -ErrorAction Stop
        return ($ServerNameFromSQL.ServerName)
        
    }
    
    catch {
        Write-Error "Failed to retrieve @@ServerName from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }

    
    
}