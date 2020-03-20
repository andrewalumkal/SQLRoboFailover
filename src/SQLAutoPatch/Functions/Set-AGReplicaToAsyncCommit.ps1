Function Set-AGReplicaToAsyncCommit {
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
  
    $QueryChangeFailoverMode = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$ReplicaServer' WITH (FAILOVER_MODE = MANUAL); 

"@

    $QuerySetAsync = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$ReplicaServer' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT); 

"@




    try {

        if ($PSCmdlet.ShouldProcess("$ReplicaServer - $AvailabilityGroup")) {
            Write-Output "Testing - Would run on server: $PrimaryServer"
            Write-Output $QueryChangeFailoverMode
            Write-Output $QuerySetAsync
        }
    }
    
    catch {
        Write-Error "Failed to set AG: $AvailabilityGroup on Server: $PrimaryServer to asynchronous commit mode"
        Write-Error "Error Message: $_.Exception.Message" 
        exit
    }

    
    
}