Function Get-AGNodes {
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
            
    select  replica_server_name as ReplicaServer
    from    sys.dm_hadr_availability_replica_cluster_nodes
    where   replica_server_name <> @@SERVERNAME
    and     group_name = '$AvailabilityGroup';
        
"@

    try {
        $AGNodes = Invoke-Sqlcmd -ServerInstance $ServerInstance -query $query -Database master -QueryTimeout 60 -ErrorAction Stop
        return $AGNodes
        
    }
    
    catch {
        Write-Error "Failed to retrieve AG nodes from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }

    
    
}