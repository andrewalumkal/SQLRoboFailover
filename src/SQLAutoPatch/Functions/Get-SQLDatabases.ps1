Function Get-SQLDatabases {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )
  
    $query = @"
            
        select  [name] as DatabaseName
                ,state_desc as StateDesc
        from    sys.databases;
        
"@

    try {
        $SQLDatabases = Invoke-Sqlcmd -ServerInstance $ServerInstance -query $query -Database master -QueryTimeout 60 -ErrorAction Stop
        return $SQLDatabases
        
    }
    
    catch {
        Write-Error "Failed to retrieve databases from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }

    
}