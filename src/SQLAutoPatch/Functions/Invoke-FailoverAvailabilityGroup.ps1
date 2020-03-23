Function Invoke-FailoverAvailabilityGroup {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $PrimaryServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )

    Write-Output "Running health checks for [$AvailabilityGroup] ..."
    Write-Output ""

    $PrimaryAG = $null
    $PrimaryAG = @(Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance $PrimaryServerInstance | Where-Object -Property AGName -eq $AvailabilityGroup)

    if (!$PrimaryAG) {
        Write-Output "[$AvailabilityGroup] does not exist or is not in primary role on this server"
        Write-Output ""
        return
    }

    $AGTopology = Get-AGTopology -PrimaryServerInstance $PrimaryServerInstance -AvailabilityGroup $AvailabilityGroup
    #$AGTopology

    if ($AGTopology.SyncCommitSecondariesCount -eq 0) {
        Write-Output "No synchronous_commit secondaries available to failover [$AvailabilityGroup]"
        Write-Output ""
        return
    }

    $AGDatabases = @(Get-AGDatabases -ServerInstance $PrimaryServerInstance -AvailabilityGroup $AvailabilityGroup)
    $PrimaryDBs = @($AGDatabases | Where-Object -Property ReplicaRole -eq "PRIMARY")

    #Check if AG databases are healthy
    $UnHealthyAGDatabases = @($AGDatabases | Where-Object { $_.SynchronizationHealth -ne "HEALTHY" `
                -or $_.ReplicaHealth -ne "HEALTHY" `
                -or $_.ReplicaConnectedState -ne "CONNECTED" })

    if ($UnHealthyAGDatabases.Count -gt 0) {
        Write-Error "[$AvailabilityGroup] databases are not in a healthy state. Not attempting failover."
        Write-Output ""
        exit
    }                

    #Get first available sync secondary
    $SyncCommitServers = @($AGTopology.SyncCommitSecondaryServers)
    $FailoverTargetServer = $SyncCommitServers[0]

    #Check all target databases are in synchronized state
    $TargetDBs = @($AGDatabases | Where-Object { $_.ReplicaServerName -eq $FailoverTargetServer `
                -and $_.SynchronizationState -eq "SYNCHRONIZED" })


    if ($TargetDBs.Count -ne $PrimaryDBs.Count) {
        Write-Output "Databases for failover partner [$FailoverTargetServer] are not synchronized. Skipping failover attempt."
        Write-Output ""
        return
    }

    Write-Output "All checks are clean"
    Write-Output ""
    Start-Sleep -Seconds 2

    if ($PSCmdlet.ShouldProcess("FailoverTarget: $FailoverTargetServer - $AvailabilityGroup")) {

        Write-Output "Starting failover for AG:[$AvailabilityGroup] to Server:[$FailoverTargetServer]..."
        Write-Output ""
        Start-Sleep -Seconds 1.5

        Invoke-FailoverSQLCommand -FailoverTargetServer $FailoverTargetServer -AvailabilityGroup $AvailabilityGroup -Confirm:$false

        Write-Output "Failover command successfully executed on Server:[$FailoverTargetServer]..."
        Write-Output ""

        Start-Sleep -Seconds 5

        Write-Output "Running post failover checks for AG:[$AvailabilityGroup]"
        Write-Output ""

        Invoke-PostFailoverHealthPoll -PrimaryServerInstance $FailoverTargetServer -AvailabilityGroup $AvailabilityGroup -MaxPollCount 5 -PollIntervalSeconds 30


    }
    
   

}