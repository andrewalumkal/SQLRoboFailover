Function Get-AllAGDatabaseReplicasOnServer {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )

    $query = @"
            select      ag.[name] as AGName
            ,ag.is_distributed as IsDistributed
            ,ar.replica_server_name as ReplicaServerName
            ,adc.[database_name] as DatabaseName
            ,ars.role_desc as ReplicaRole
            ,drs.synchronization_state_desc as SynchronizationState
            ,drs.synchronization_health_desc as SynchronizationHealth
            ,ar.availability_mode_desc AvailabilityMode
            ,(drs.redo_queue_size) / 1024 as RedoQueueSizeMB
            ,ars.synchronization_health_desc as ReplicaHealth
            ,ars.connected_state_desc as ReplicaConnectedState
            ,ag.cluster_type_desc as ClusterType
        from        sys.dm_hadr_database_replica_states drs
        join        sys.availability_databases_cluster as adc
        on          adc.group_database_id = drs.group_database_id
        join        sys.availability_groups ag
        on          drs.group_id = ag.group_id
        join        sys.dm_hadr_availability_replica_states ars
        on          ars.replica_id = drs.replica_id
        join        sys.availability_replicas ar
        on          ar.replica_id = ars.replica_id
        where       ar.replica_server_name = @@SERVERNAME
        order by    ag.[name]
                    ,adc.[database_name]
                    ,ars.role_desc asc;
"@

    try {
        
        $AllAGDBs = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 180 -ErrorAction Stop
        return $AllAGDBs
    }

    catch {
        Write-Error "Failed to retrieve Availability group databases from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }
    
}