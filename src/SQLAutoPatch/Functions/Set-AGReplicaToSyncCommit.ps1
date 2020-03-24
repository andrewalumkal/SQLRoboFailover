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
        $AvailabilityGroup,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true

    )
  

    $QuerySetSync = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$ReplicaServer' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT); 

"@

    $QueryChangeFailoverMode = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$ReplicaServer' WITH (FAILOVER_MODE = AUTOMATIC); 

"@

    if ($ScriptOnly) {
        Write-Output "----Script Only mode----"
        Write-Output "Script to execute on Server: [$PrimaryServer]"
        Write-Output $QuerySetSync
        Write-Output $QueryChangeFailoverMode
        Write-Output "-----------------------"
        return
    }

    try {
        if ($PSCmdlet.ShouldProcess("$ReplicaServer - $AvailabilityGroup")) {
            
            Invoke-Sqlcmd -ServerInstance $PrimaryServer -Database master -Query $QuerySetSync -QueryTimeout 60 -ErrorAction Stop
            Invoke-Sqlcmd -ServerInstance $PrimaryServer -Database master -Query $QueryChangeFailoverMode -QueryTimeout 60 -ErrorAction Stop

        }
    }
    
    catch {
        Write-Error "Failed to set AG: $AvailabilityGroup on Server: $PrimaryServer to synchronous commit mode"
        Write-Error "Error Message: $_.Exception.Message" 
        exit
    }

    
    
}