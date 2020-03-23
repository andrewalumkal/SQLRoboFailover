Function Get-UnHealthySQLDatabases {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )

    $SQLDatabases = @(Get-SQLDatabases -ServerInstance $ServerInstance)

    $UnHealthyDBs = @($SQLDatabases | Where-Object { $_.StateDesc -ne "ONLINE" `
                -and $_.StateDesc -ne "RESTORING" `
                -and $_.StateDesc -ne "OFFLINE" })
    
    return $UnHealthyDBs
    
}