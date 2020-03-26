Function Get-AllUnHealthyAGDatabases {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )

    $AGDBReplicas = @(Get-AllAGDatabaseReplicas -ServerInstance $ServerInstance)

    $UnHealthyAGs = @($AGDBReplicas | Where-Object { $_.SynchronizationHealth -ne "HEALTHY" `
                -or $_.ReplicaHealth -ne "HEALTHY" `
                -or $_.ReplicaConnectedState -ne "CONNECTED" })
    
   
    return $UnHealthyAGs
    
}