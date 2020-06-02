Function Test-IsSQLServerHealthy {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckBIServices,

        [Parameter(Mandatory = $false)]
        [Switch]$RunExtendedAGChecks
    )

    Write-Verbose "Testing IsSQLServerHealthy..."
    Write-Verbose "-----------------------------"

    [bool]$IsSQLServerHealthy = 1

    $UnHealthyDBs = @(Get-UnHealthySQLDatabases -ServerInstance $ServerInstance)

    if ($UnHealthyDBs.Count -gt 0) {
        Write-Warning "Found unhealthy databases on the server"
        $IsSQLServerHealthy = 0
        return $IsSQLServerHealthy
    }

    #Check SQL Agent Service
    $SQLAgentService = @(Get-SQLAgentService -ServerInstance $ServerInstance)
        
    if ($SQLAgentService | Where-Object -Property Status -ne "Running") {
        Write-Warning "SQL Agent is not running"
        $IsSQLServerHealthy = 0
        return $IsSQLServerHealthy
    }


    $AGReplicas = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance)

    if ($AGReplicas.Count -gt 0) {

        if ($AGReplicas | Where-Object -Property ReplicaHealth -ne "HEALTHY") {
            Write-Warning "Found replicas that are not in a healthy state"
            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }
    
        if ($AGReplicas | Where-Object -Property ReplicaConnectedState -ne "CONNECTED") {
            Write-Warning "Found replicas that are not in a connected state"
            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }
    
        #Check DB Level AG health
        [bool]$TestAGDBState = 0
        $TestAGDBState = Test-AllAGDatabasesOnServerHealthy -ServerInstance $ServerInstance -RunExtendedChecks:$RunExtendedAGChecks

        if (!$TestAGDBState) {
            Write-Warning "Found AG databases that are not in a healthy state"
            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }

    }


    #Check SSRS / SSAS / PowerBI services
    if ($CheckBIServices) {
        $SQLReportServices = @(Get-SQLReportingServices -ServerInstance $ServerInstance)

        if ($SQLReportServices | Where-Object -Property Status -ne "Running") {
            Write-Warning "----Unhealthy BI Services Found----"

            foreach ($service in $SQLReportServices) {
                Write-Warning $service.Name
            }

            Write-Warning "--------------------------------"

            $IsSQLServerHealthy = 0
            return $IsSQLServerHealthy
        }
    }
    

    if ($IsSQLServerHealthy){
        Write-Verbose "SQL Server is healthy"
    }
    return $IsSQLServerHealthy
    
}