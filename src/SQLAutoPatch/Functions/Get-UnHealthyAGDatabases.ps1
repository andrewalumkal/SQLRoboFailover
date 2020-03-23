Function Get-UnHealthyAGDatabases {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )

    $AGDatabases = @(Get-AGDatabases -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup)

    $UnHealthyDBs = @($AGDatabases | Where-Object { $_.SynchronizationHealth -ne "HEALTHY" `
                -or $_.ReplicaHealth -ne "HEALTHY" `
                -or $_.ReplicaConnectedState -ne "CONNECTED" })
    
   
    return $UnHealthyDBs
    
}