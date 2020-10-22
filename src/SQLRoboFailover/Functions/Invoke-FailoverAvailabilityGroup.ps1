Function Invoke-FailoverAvailabilityGroup {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $PrimaryServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckRunningBackups = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckRunningCheckDBs = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$RunPostFailoverChecks = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true

    )

    Write-Output ""
    Write-Output "----------------------------------------------------------"
    Write-Output "Getting AG information for [$AvailabilityGroup] ..."
    Write-Output ""

    $AGGroupReplicas = @(Get-AllAvailabilityGroupReplicas -ServerInstance $PrimaryServerInstance `
        | Where-Object { $_.ClusterType -eq "wsfc" -and $_.AGName -eq $AvailabilityGroup })

    $PrimaryAG = $null
    $PrimaryAG = @($AGGroupReplicas | Where-Object -Property ReplicaRole -eq "PRIMARY")
    

    if (!$PrimaryAG) {
        Write-Output "[$AvailabilityGroup] does not exist or is not in primary role on this server"
        Write-Output ""
        return
    }

    Write-Output "Running health checks for [$AvailabilityGroup] ..."
    Write-Output ""

    $AGTopology = Get-AGTopology -PrimaryServerInstance $PrimaryServerInstance -AvailabilityGroup $AvailabilityGroup
    #$AGTopology

    if ($AGTopology.SyncCommitSecondariesCount -eq 0) {
        Write-Output "No synchronous_commit secondaries available to failover [$AvailabilityGroup]"
        Write-Output ""
        return
    }

    #Check AG health
    $UnHealthyAG = @($AGGroupReplicas | Where-Object { $_.ReplicaHealth -ne "HEALTHY" `
                -or $_.ReplicaConnectedState -ne "CONNECTED" })
    
    if ($UnHealthyAG.Count -gt 0) {
        Write-Error "Found [$AvailabilityGroup] replicas that are not in a healthy state. Not attempting failover."
        Write-Output ""
        return
    }  
    
    
    #Check AG database level health
    $AGDatabases = @(Get-AGDatabases -ServerInstance $PrimaryServerInstance -AvailabilityGroup $AvailabilityGroup)
    $PrimaryDBs = @($AGDatabases | Where-Object -Property ReplicaRole -eq "PRIMARY")

    
    $UnHealthyAGDatabases = @($AGDatabases | Where-Object { $_.SynchronizationHealth -ne "HEALTHY" `
                -or $_.ReplicaHealth -ne "HEALTHY" `
                -or $_.ReplicaConnectedState -ne "CONNECTED" })

    if ($UnHealthyAGDatabases.Count -gt 0) {
        Write-Error "[$AvailabilityGroup] databases are not in a healthy state. Not attempting failover."
        Write-Output ""
        return
    }                

    #Get first available sync secondary
    $SyncCommitServers = @($AGTopology.SyncCommitSecondaryServers)
    $FailoverTargetServer = $SyncCommitServers[0]

    #Check all target databases are in synchronized state
    $TargetDBs = @($AGDatabases | Where-Object { $_.ReplicaServerName -eq $FailoverTargetServer `
                -and $_.SynchronizationState -eq "SYNCHRONIZED" })


    if ($TargetDBs.Count -ne $PrimaryDBs.Count) {
        Write-Error "Databases for failover partner [$FailoverTargetServer] are not synchronized. Skipping failover attempt."
        Write-Output ""
        return
    }

    #Check there's no redo queue greater than 10 MB
    $DBsWithRedoQueue = @($AGDatabases | Where-Object { $_.ReplicaServerName -eq $FailoverTargetServer `
                -and $_.RedoQueueSizeMB -gt 10 })

    if ($DBsWithRedoQueue.Count -gt 0) {
        Write-Error "Databases found with redo queue greater than 10 MB on [$FailoverTargetServer]. Skipping failover attempt."
        Write-Output ""
        return
    }                               

    #Check for in flight full backups running on primary and failover target
    if ($CheckRunningBackups) {

        #Check Primary
        $AllRunningBackupsOnPrimary = Get-RunningBackups -ServerInstance $PrimaryServerInstance 
        $FoundRunningBackupsPrimary = @($AllRunningBackupsOnPrimary | Where-Object { $PrimaryDBs.DatabaseName -contains $_.Database })
        
        if ($FoundRunningBackupsPrimary.Count -gt 0) {
            Write-Error "In-Flight backups found running on primary:[$PrimaryServerInstance]. Skipping failover attempt."
            Write-Output ""
            Write-Output "--------------------------------------------------------"
            Write-Output $FoundRunningBackupsPrimary | Format-Table
            return
        }

        #Check failover target
        $AllRunningBackupsOnTarget = Get-RunningBackups -ServerInstance $FailoverTargetServer 
        $FoundRunningBackupsTarget = @($AllRunningBackupsOnTarget | Where-Object { $PrimaryDBs.DatabaseName -contains $_.Database })
        
        if ($FoundRunningBackupsTarget.Count -gt 0) {
            Write-Error "In-Flight backups found running on failover target:[$FailoverTargetServer]. Skipping failover attempt."
            Write-Output ""
            Write-Output "--------------------------------------------------------"
            Write-Output $FoundRunningBackupsTarget | Format-Table
            return
        }
        
    }


    #Check for in flight CheckDBs running on primary and failover target
    if ($CheckRunningCheckDBs) {

        #Check Primary
        $AllRunningCheckDBsOnPrimary = Get-RunningCheckDBs -ServerInstance $PrimaryServerInstance 
        $FoundRunningCheckDBsPrimary = @($AllRunningCheckDBsOnPrimary | Where-Object { $PrimaryDBs.DatabaseName -contains $_.Database })
        
        if ($FoundRunningCheckDBsPrimary.Count -gt 0) {
            Write-Error "In-Flight CheckDB found running on primary:[$PrimaryServerInstance]. Skipping failover attempt."
            Write-Output ""
            Write-Output "--------------------------------------------------------"
            Write-Output $FoundRunningCheckDBsPrimary | Format-Table
            return
        }

        #Check failover target
        $AllRunningCheckDBsOnTarget = Get-RunningCheckDBs -ServerInstance $FailoverTargetServer 
        $FoundRunningCheckDBsTarget = @($AllRunningCheckDBsOnTarget | Where-Object { $PrimaryDBs.DatabaseName -contains $_.Database })
        
        if ($FoundRunningCheckDBsTarget.Count -gt 0) {
            Write-Error "In-Flight CheckDB found running on failover target:[$FailoverTargetServer]. Skipping failover attempt."
            Write-Output ""
            Write-Output "--------------------------------------------------------"
            Write-Output $FoundRunningCheckDBsTarget | Format-Table
            return
        }
        
    }

    #Checks complete#
    ##########################################################################################################################

    Write-Output "All checks are clean"
    Write-Output ""
    Start-Sleep -Seconds 2

    if ($ScriptOnly) {
        Invoke-FailoverSQLCommand -FailoverTargetServer $FailoverTargetServer -AvailabilityGroup $AvailabilityGroup -Confirm:$false -ScriptOnly:$ScriptOnly
        return
    }

    if ($PSCmdlet.ShouldProcess("FailoverTarget: $FailoverTargetServer - $AvailabilityGroup")) {

        Write-Output "Starting failover for AG:[$AvailabilityGroup] to Server:[$FailoverTargetServer]..."
        Write-Output ""
        Start-Sleep -Seconds 1.5

        Invoke-FailoverSQLCommand -FailoverTargetServer $FailoverTargetServer -AvailabilityGroup $AvailabilityGroup -Confirm:$false -ScriptOnly:$false

        Write-Output "Failover command successfully executed on Server:[$FailoverTargetServer]..."
        Write-Output ""

        Start-Sleep -Seconds 5

        if ($RunPostFailoverChecks) {

            Write-Output "Running post failover checks for AG:[$AvailabilityGroup]"
            Write-Output ""

            Invoke-PostFailoverHealthPoll -ServerInstance $FailoverTargetServer -AvailabilityGroup $AvailabilityGroup -MaxPollCount 25 -PollIntervalSeconds 15
        }

        

    }
    
   

}