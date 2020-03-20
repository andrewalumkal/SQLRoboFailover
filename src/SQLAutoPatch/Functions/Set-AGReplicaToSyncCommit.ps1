Function Set-AGReplicaToSyncCommit {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $PrimaryServer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ReplicaServer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )
  

    $QuerySetSync = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$ReplicaServer' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT); 

"@

    $QueryChangeFailoverMode = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$ReplicaServer' WITH (FAILOVER_MODE = AUTOMATIC); 

"@


    try {
        if ($PSCmdlet.ShouldProcess("$ReplicaServer - $AvailabilityGroup")) {
            Write-Output "Testing - Would run on server: $PrimaryServer"
            Write-Output $QuerySetSync
            Write-Output $QueryChangeFailoverMode
        }
    }
    
    catch {
        Write-Error "Failed to set AG: $AvailabilityGroup on Server: $PrimaryServer to synchronous commit mode"
        Write-Error "Error Message: $_.Exception.Message" 
        exit
    }

    
    
}