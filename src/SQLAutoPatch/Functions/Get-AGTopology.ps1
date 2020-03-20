Function Get-AGTopology {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )

    $AGReplicas = @(Get-AllAvailabilityGroupReplicas -ServerInstance $ServerInstance | Where-Object -Property AGName -eq $AvailabilityGroup) 
   
    $AGTopology = [PSCustomObject]@{
        AGName                      = $AvailabilityGroup
        PrimaryReplica              = ($AGReplicas | Where-Object -Property ReplicaRole -eq "PRIMARY").ReplicaServerName
        TotalReplicas               = $AGReplicas.Count
        TotalSecondaryReplicas      = @($AGReplicas | Where-Object -Property ReplicaRole -eq "SECONDARY").Count
        AllSecondaryReplicas        = @($AGReplicas | Where-Object -Property ReplicaRole -eq "SECONDARY").ReplicaServerName
        SyncCommitSecondariesCount  = @($AGReplicas | Where-Object -Property AvailabilityMode -eq "SYNCHRONOUS_COMMIT" | Where-Object -Property ReplicaRole -eq "SECONDARY").Count
        SyncCommitSecondaryServers  = @($AGReplicas | Where-Object -Property AvailabilityMode -eq "SYNCHRONOUS_COMMIT" | Where-Object -Property ReplicaRole -eq "SECONDARY").ReplicaServerName
        AsyncCommitSecondariesCount = @($AGReplicas | Where-Object -Property AvailabilityMode -eq "ASYNCHRONOUS_COMMIT" | Where-Object -Property ReplicaRole -eq "SECONDARY").Count
        AsyncCommitSecondaryServers = @($AGReplicas | Where-Object -Property AvailabilityMode -eq "ASYNCHRONOUS_COMMIT" | Where-Object -Property ReplicaRole -eq "SECONDARY").ReplicaServerName
  
    }
    return $AGTopology
    
}