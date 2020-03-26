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
        $AvailabilityGroup,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true

    )

    #Get @@ServerName from SQL. Fully qualified servernames dont work when modifying replica.
    $SQLReplicaName = Get-ServerNameFromSQL -ServerInstance $ReplicaServer
  
    $QueryChangeFailoverMode = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$SQLReplicaName' WITH (FAILOVER_MODE = MANUAL); 

"@

    $QuerySetAsync = @"
    ALTER AVAILABILITY GROUP [$AvailabilityGroup]
    MODIFY REPLICA ON N'$SQLReplicaName' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT); 

"@

    if ($ScriptOnly){
        Write-Output "----Script Only mode----"
        Write-Output "Script to execute on Server: [$PrimaryServer]"
        Write-Output $QueryChangeFailoverMode
        Write-Output $QuerySetAsync
        Write-Output "-----------------------"
        return
    }

    try {

        if ($PSCmdlet.ShouldProcess("$SQLReplicaName - $AvailabilityGroup")) {

            Invoke-Sqlcmd -ServerInstance $PrimaryServer -Database master -Query $QueryChangeFailoverMode -QueryTimeout 60 -ErrorAction Stop
            Invoke-Sqlcmd -ServerInstance $PrimaryServer -Database master -Query $QuerySetAsync -QueryTimeout 60 -ErrorAction Stop

        }
    }
    
    catch {
        Write-Error "Failed to set AG: $AvailabilityGroup on Server: $PrimaryServer to asynchronous commit mode"
        Write-Error "Error Message: $_.Exception.Message" 
        exit
    }

    
    
}