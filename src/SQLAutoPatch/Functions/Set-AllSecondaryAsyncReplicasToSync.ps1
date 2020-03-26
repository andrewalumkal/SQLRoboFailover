Function Set-AllSecondaryAsyncReplicasToSync {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $ExcludeAGs,

        [Parameter(Mandatory = $false)]
        [Switch]$ForceSingleSyncCopy,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm = $true

    )

    
    #Ignore DAG/ReadScale replicas
    $AllAGReplicas = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance | Where-Object -Property ClusterType -eq "wsfc")

    #Find all healthy sync commit secondary AGs
    $AllSecondaryAsyncAGs = @($AllAGReplicas | Where-Object -Property ReplicaRole -eq "SECONDARY" | `
            Where-Object -Property AvailabilityMode -eq "ASYNCHRONOUS_COMMIT" | `
            Where-Object -Property ReplicaHealth -eq "HEALTHY" | `
            Where-Object -Property ReplicaConnectedState -eq "CONNECTED")

    if ($AllSecondaryAsyncAGs.Count -eq 0) {
        Write-Output "No secondary asynchronous_commit AGs found on $ServerInstance"
        return
    }

    $ExcludeList = @($ExcludeAGs -split "," | foreach { $_.Trim() })
    $SecondaryAsyncAGs = @($AllSecondaryAsyncAGs | Where-Object { $ExcludeList -notcontains $_.AGName })

    Write-Output ""
    Write-Output "-----------------------------------"
    Write-Output "The following AGs were found to be secondary asynchronous_commit replicas on server: $ServerInstance"
    Write-Output ""                            
    Write-Output $SecondaryAsyncAGs.AGName
    Write-Output "-----------------------------------"
    Write-Output ""
    Start-Sleep -Seconds 2

    

    foreach ($SecondaryAG in $SecondaryAsyncAGs) {

        Write-Output "Analyzing [$($SecondaryAG.AGName)]..."
        Write-Output "------------------------------------------"
        Write-Output ""

        $PrimaryReplica = Find-PrimaryAGNodeFromSecondaryReplica -SecondaryServerInstance $ServerInstance -AvailabilityGroup $SecondaryAG.AGName

        $AGTopology = Get-AGTopology -PrimaryServerInstance $PrimaryReplica -AvailabilityGroup $SecondaryAG.AGName
    
            
        #Make Sync
        Write-Output "Setting $($SecondaryAG.AGName) to Synchronous_commit mode on $ServerInstance ..."
        Write-Output ""
        Start-Sleep -Seconds 1

        if ($ScriptOnly) {
            Set-AGReplicaToSyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$false -ScriptOnly:$ScriptOnly
        }

        else {
            Set-AGReplicaToSyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$Confirm -ScriptOnly:$false
        }
            
        
        if ($ForceSingleSyncCopy) {

            if ($AGTopology.SyncCommitSecondariesCount -gt 0) {

                #More than one sync commit replicas found
                Write-Output "More than one synchronous_commit secondaries found for AG: $($SecondaryAG.AGName)"
                Write-Output ""
                Write-Output "Synchronous_Commit Replicas for $($SecondaryAG.AGName) :"
                Write-Output "$($AGTopology.SyncCommitSecondaryServers)"
                Write-Output ""
                Start-Sleep -Seconds 1
    
                #Make all other Sync replicas to Async
                foreach ($SyncServer in $AGTopology.SyncCommitSecondaryServers) {
                    Write-Output "Setting $($SecondaryAG.AGName) to Asynchronous_commit mode on $SyncServer ..."
                    Write-Output ""
                    Start-Sleep -Seconds 1
    
                    if ($ScriptOnly) {
                        Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $SyncServer -AvailabilityGroup $SecondaryAG.AGName -Confirm:$false -ScriptOnly:$ScriptOnly
                    }
        
                    else {
                        Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $SyncServer -AvailabilityGroup $SecondaryAG.AGName -Confirm:$Confirm -ScriptOnly:$false
                    }
    
                }    
     
            }

        }

        

       

    }

    
}