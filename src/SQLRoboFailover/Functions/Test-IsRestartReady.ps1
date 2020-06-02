Function Test-IsRestartReady {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance
    )

    Write-Verbose "Testing IsRestartReady..."
    Write-Verbose "-------------------------"

    [bool]$IsRestartReady = 1

    $UnHealthyDBs = @(Get-UnHealthySQLDatabases -ServerInstance $ServerInstance)

    if ($UnHealthyDBs.Count -gt 0) {
        Write-Warning "Found unhealthy databases on the server"
        $IsRestartReady = 0
        return $IsRestartReady
    }


    $AGReplicas = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance)

    if ($AGReplicas.Count -gt 0) {

        if ($AGReplicas | Where-Object -Property ReplicaRole -ne "SECONDARY") {
            Write-Warning "Found replicas that are not in secondary role"
            $IsRestartReady = 0
            return $IsRestartReady
        }
    
        if ($AGReplicas | Where-Object -Property AvailabilityMode -ne "ASYNCHRONOUS_COMMIT") {
            Write-Warning "Found replicas that are not in asynchronous_commit mode"
            $IsRestartReady = 0
            return $IsRestartReady
        }

        if ($AGReplicas | Where-Object -Property ReplicaHealth -ne "HEALTHY") {
            Write-Warning "Found replicas that are not in a healthy state"
            $IsRestartReady = 0
            return $IsRestartReady
        }
    
        if ($AGReplicas | Where-Object -Property ReplicaConnectedState -ne "CONNECTED") {
            Write-Warning "Found replicas that are not in a connected state"
            $IsRestartReady = 0
            return $IsRestartReady
        }
    
        #Check DB Level AG health
        [bool]$TestAGDBState = 0
        $TestAGDBState = Test-AllAGDatabasesOnServerHealthy -ServerInstance $ServerInstance

        if(!$TestAGDBState){
            Write-Warning "Found AG databases that are not in a healthy state"
            $IsRestartReady = 0
            return $IsRestartReady
        }
        

    }
    
    if ($IsRestartReady){
        Write-Verbose "SQL Server is ready to restart"
        Write-Verbose "------------------------------"
    }
    return $IsRestartReady
    
}