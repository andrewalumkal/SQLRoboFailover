Function Get-AvailabilityGroupsOnServer {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )
  
    $query = @"
            
            select      ag.[name] as AGName
            ,ag.is_distributed as IsDistributed
            ,rp.replica_server_name as ReplicaServerName
            ,rps.role_desc as [ReplicaRole]
            ,rp.availability_mode_desc as AvailabilityMode
            ,rp.failover_mode_desc as FailoverMode
            ,rps.synchronization_health_desc as ReplicaHealth
            ,rps.connected_state_desc as ReplicaConnectedState
            ,ag.cluster_type_desc as ClusterType
        from        sys.availability_replicas rp
        join  sys.availability_groups ag
        on          ag.group_id = rp.group_id
        join  sys.dm_hadr_availability_replica_states rps
        on          rps.group_id = rp.group_id
        and         rps.replica_id = rp.replica_id
        where rp.replica_server_name = @@SERVERNAME
        order by   ag.[name], rps.role_desc 
        
"@

    try {
        $AGReplicas = Invoke-Sqlcmd -ServerInstance $ServerInstance -query $query -Database master -ErrorAction Stop
        return $AGReplicas
        
    }
    
    catch {
        Write-Error "Failed to retrieve Availability group replicas from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }

    
    
}