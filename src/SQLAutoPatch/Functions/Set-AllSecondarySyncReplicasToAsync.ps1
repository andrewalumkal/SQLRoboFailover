Function Set-AllSecondarySyncReplicasToAsync {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [Switch]$MaintainHAForAGs = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm = $true

    )

    
    #Ignore DAG/ReadScale replicas
    $AllAGReplicas = Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance | Where-Object -Property ClusterType -eq "wsfc"

    #Find all healthy sync commit secondary AGs
    $SecondarySyncAGs = @($AllAGReplicas | Where-Object -Property ReplicaRole -eq "SECONDARY" | `
            Where-Object -Property AvailabilityMode -eq "SYNCHRONOUS_COMMIT" | `
            Where-Object -Property ReplicaHealth -eq "HEALTHY" | `
            Where-Object -Property ReplicaConnectedState -eq "CONNECTED")

    if ($SecondarySyncAGs.Count -eq 0) {
        Write-Output "No secondary synchronous_commit AGs found on $ServerInstance"
        return
    }

    Write-Output ""
    Write-Output "-----------------------------------"
    Write-Output "The following AGs were found to be secondary synchronous_commit replicas on server: $ServerInstance"
    Write-Output ""                            
    Write-Output $SecondarySyncAGs.AGName
    Write-Output "-----------------------------------"
    Write-Output ""
    Start-Sleep -Seconds 2


    foreach ($SecondaryAG in $SecondarySyncAGs) {

        Write-Output "Analyzing [$($SecondaryAG.AGName)]..."
        Write-Output "------------------------------------------"
        Write-Output ""

        $PrimaryReplica = Find-PrimaryAGNodeFromSecondaryReplica -SecondaryServerInstance $ServerInstance -AvailabilityGroup $SecondaryAG.AGName

        $AGTopology = Get-AGTopology -PrimaryServerInstance $PrimaryReplica -AvailabilityGroup $SecondaryAG.AGName
    
        if ($AGTopology.TotalSecondaryReplicas -lt 2) {
            #Less than 2 total replicas available

            $InfoMessage = "No other replica available to set to synchronous for $($SecondaryAG.AGName) . Total Replicas for this AG = "
            $InfoMessage += $AGTopology.TotalReplicas
            Write-Output $InfoMessage
            Write-Output ""
            Start-Sleep -Seconds 1

            #Make Async
            Write-Output "Setting $($SecondaryAG.AGName) to Asynchronous_commit mode on $ServerInstance ..."
            Write-Output ""
            Start-Sleep -Seconds 1
            Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$Confirm
        
        }

        elseif ($AGTopology.SyncCommitSecondariesCount -gt 1) {
            #More than one sync commit replicas found
            Write-Output "More than one synchronous_commit secondaries found for AG: $($SecondaryAG.AGName)"
            Write-Output ""
            Write-Output "Synchronous_Commit Replicas for $($SecondaryAG.AGName) :"
            Write-Output ""
            Write-Output "$($AGTopology.SyncCommitSecondaryServers)"
            Write-Output ""
            Start-Sleep -Seconds 1

            #Make Async
            Write-Output "Setting $($SecondaryAG.AGName) to Asynchronous_commit mode on $ServerInstance ..."
            Write-Output ""
            Start-Sleep -Seconds 1
            Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$Confirm
        
        }

        elseif ($AGTopology.SyncCommitSecondariesCount -lt 2 -and $AGTopology.AsyncCommitSecondariesCount -gt 0) {
            
            #If user wants to maintain HA, set available async replicas to sync_commit
            if ($MaintainHAForAGs) {
                $AsyncServers = @($AGTopology.AsyncCommitSecondaryServers)
                $OutputMessage = "Maintaining HA - Found an additional asynchronous_commit replica to set to synchronous_commit: "
                $OutputMessage += $AsyncServers[0]
                Write-Output $OutputMessage
                Write-Output ""
                Start-Sleep -Seconds 1

                #Make Sync
                Write-Output "Setting replica to synchronous_commit..."
                Write-Output ""
                Start-Sleep -Seconds 1
                Set-AGReplicaToSyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $AsyncServers[0] -AvailabilityGroup $SecondaryAG.AGName -Confirm:$Confirm
        
            }
            
            #Make Async
            Write-Output "Setting $($SecondaryAG.AGName) to Asynchronous_commit mode on $ServerInstance ..."
            Write-Output ""
            Start-Sleep -Seconds 1
            Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$Confirm
        
        }
        else {
            continue
        }

    }

    
}