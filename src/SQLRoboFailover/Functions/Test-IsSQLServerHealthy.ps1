Function Test-IsSQLServerHealthy {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [Switch]$RunExtendedAGChecks
    )

    Write-Verbose "Testing IsSQLServerHealthy..."

    [bool]$IsSQLServerHealthy = 1

    $UnHealthyDBs = @(Get-UnHealthySQLDatabases -ServerInstance $ServerInstance)

    if ($UnHealthyDBs.Count -gt 0) {
        Write-Verbose "Found unhealthy databases on the server"
        $IsSQLServerHealthy = 0
        return $IsSQLServerHealthy
    }


    $AGReplicas = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance)

    if ($AGReplicas.Count -gt 0) {

        if ($AGReplicas | Where-Object -Property ReplicaHealth -ne "HEALTHY") {
            Write-Verbose "Found replicas that are not in a healthy state"
            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }
    
        if ($AGReplicas | Where-Object -Property ReplicaConnectedState -ne "CONNECTED") {
            Write-Verbose "Found replicas that are not in a connected state"
            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }
    
        #Check DB Level AG health
        [bool]$TestAGDBState = 0
        $TestAGDBState = Test-AllAGDatabasesOnServerHealthy -ServerInstance $ServerInstance -RunExtendedChecks:$RunExtendedAGChecks

        if(!$TestAGDBState){
            Write-Verbose "Found AG databases that are not in a healthy state"
            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }
        

    }
    
    return $IsSQLServerHealthy
    
}