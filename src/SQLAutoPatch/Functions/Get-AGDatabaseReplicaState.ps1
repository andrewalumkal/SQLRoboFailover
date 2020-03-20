Function Get-AGDatabaseReplicaState {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup
    )

    $query = @"
            select  ag.name as AGName
            ,ar.replica_server_name as ReplicaServerName
            ,adc.database_name
            ,drs.synchronization_state_desc
            ,drs.redo_queue_size
            ,drs.is_primary_replica
        from    sys.dm_hadr_database_replica_states as drs
        join    sys.availability_groups as ag
        on      ag.group_id = drs.group_id
        join    sys.availability_databases_cluster as adc
        on      adc.group_database_id = drs.group_database_id
        join    sys.dm_hadr_availability_replica_states ars
        on      ars.replica_id = drs.replica_id
        join    sys.availability_replicas ar
        on      ar.replica_id = ars.replica_id
        where ag.name = '$availabilityGroup'
"@


    $queryResults = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 60


    $queryResults | ForEach-Object {
        [pscustomobject]@{
            ServerInstance       = $ServerInstance
            AvailabilityGroup    = $AvailabilityGroup
            DatabaseName         = $_.database_name
            SynchronizationState = $_.synchronization_state_desc
            RedoQueueSize        = $_.redo_queue_size
            IsPrimaryReplica     = [bool] $_.is_primary_replica
        }
    }
}