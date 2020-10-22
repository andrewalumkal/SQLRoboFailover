Function Invoke-MakeSQLServerRestartReady {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [Switch]$RunPostFailoverChecks = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckRunningBackups = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckRunningCheckDBs = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm = $true

    )
  

    [bool]$IsSQLServerHealthy = Test-IsSQLServerHealthy -ServerInstance $ServerInstance -Verbose

    if ($IsSQLServerHealthy) {
        Write-Output "Starting failover for all primary AGs on [$ServerInstance] ..."
        Invoke-FailoverAllPrimaryAGsOnServer -ServerInstance $ServerInstance -RunPostFailoverChecks:$false `
                -CheckRunningBackups:$CheckRunningBackups -CheckRunningCheckDBs:$CheckRunningCheckDBs -ScriptOnly:$ScriptOnly -Confirm:$Confirm
    }
    
    else {
        Write-Output "SQL Server is NOT healthy"
        return
    }

    #Run post failover health checks for all AGs
    Invoke-AGHealthPoll -ServerInstance $ServerInstance -MaxPollCount 25 -PollIntervalSeconds 15
    
    Set-AllSecondarySyncReplicasToAsync -ServerInstance $ServerInstance -MaintainHAForAGs -ScriptOnly:$ScriptOnly -Confirm:$Confirm
    
    [bool]$IsRestartReady = Test-IsRestartReady -ServerInstance $ServerInstance -Verbose
    
    if ($IsRestartReady){
        Write-Output "**** [$ServerInstance] is READY for patching / restarts****"
    }
    else {
        Write-Error "**** [$ServerInstance] is NOT ready for patching / restarts****"
    }
    
}