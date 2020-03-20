import-module C:\Tools\SQLAutoPatch\src\SQLAutoPatch -Force
#$ServerInstance = "933995-report2.viagogors.prod"
$ServerInstance = "vm-az-qa-sql01"
[bool]$ConfirmVar = $false


#Set all secondary replicas to Async
#Ignore dag/readscale replicas
$AllAGReplicas = Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance | Where-Object -Property ClusterType -eq "wsfc"



$SecondarySyncAGs = $AllAGReplicas | Where-Object -Property ReplicaRole -eq "SECONDARY" | `
    Where-Object -Property AvailabilityMode -eq "SYNCHRONOUS_COMMIT" | `
    Where-Object -Property ReplicaHealth -eq "HEALTHY" | `
    Where-Object -Property ReplicaConnectedState -eq "CONNECTED"

#Check for count here. If none exists - then exit
Write-Output ""
Write-Output "-----------------------------------"
Write-Output "The following AGs were found to be secondary synchronous_commit replicas on server: $ServerInstance "
Write-Output ""                            
Write-Output $SecondarySyncAGs.AGName
Write-Output "-----------------------------------"
Write-Output ""
Start-Sleep -Seconds 1.5



foreach ($SecondaryAG in $SecondarySyncAGs) {

    $PrimaryReplica = Find-PrimaryAGNodeFromSecondaryReplica -SecondaryServerInstance $ServerInstance -AvailabilityGroup $SecondaryAG.AGName
    Write-Output "$($SecondaryAG.AGName) - $PrimaryReplica"

    $AGTopology = Get-AGTopology -ServerInstance $PrimaryReplica -AvailabilityGroup $SecondaryAG.AGName

    
    if ($AGTopology.TotalSecondaryReplicas -lt 2) {
        #Less than 2 total replicas available

        $InfoMessage = "No other replica available to make synchronous for $($SecondaryAG.AGName) . Total Replicas for this AG = "
        $InfoMessage += $AGTopology.TotalReplicas
        Write-Output $InfoMessage

        #Make Async
        Write-Output "Making Async"
        Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$ConfirmVar
    }

    elseif ($AGTopology.SyncCommitSecondariesCount -gt 1) {
        #More than one sync commit replicas found
        Write-Output "More than one sync commit secondaries found for AG: $($SecondaryAG.AGName). No action necessary"
    }

    elseif ($AGTopology.SyncCommitSecondariesCount -lt 2 -and $AGTopology.AsyncCommitSecondariesCount -gt 0) {
        #Set async replica to synchronous
        Write-Output "Setting additional replica to sync commit"

        #Make Sync
        Write-Output "Making Sync"
        $AsyncServers = @($AGTopology.AsyncCommitSecondaryServers)
        Set-AGReplicaToSyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $AsyncServers[0] -AvailabilityGroup $SecondaryAG.AGName -Confirm:$ConfirmVar
        
        #Then make this replica async
        Write-Output "Making Async"
        Set-AGReplicaToAsyncCommit -PrimaryServer $PrimaryReplica -ReplicaServer $ServerInstance -AvailabilityGroup $SecondaryAG.AGName -Confirm:$ConfirmVar

    }
    else {
        continue
    }

}


#[bool]$ConfirmVar = $true
#$ServerInstance = '933994-report3.viagogors.prod'
#$AvailabilityGroup = "947929-AG4"
#Get-AGNodes -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup
#Get-AGTopology -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup
#Set-AGReplicaToAsyncCommit -PrimaryServer "vm-az-qa-sql02" -ReplicaServer "vm-az-qa-sql01" -AvailabilityGroup "azqa-ag1" -Confirm:$ConfirmVar

