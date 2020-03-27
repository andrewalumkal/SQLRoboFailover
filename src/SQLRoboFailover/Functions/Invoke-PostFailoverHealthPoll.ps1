Function Invoke-PostFailoverHealthPoll {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $MaxPollCount,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $PollIntervalSeconds


    )


    Write-Output "Querying Server:[$ServerInstance] for AG health information..."
    Write-Output ""
    
    $PollCount = 1
    $UnHealthyDatabases = @(Get-UnHealthyAGDatabases -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup)

    while ($UnHealthyDatabases.Count -gt 0) {

        $PollCount++

        Write-Output "Unhealthy databases found on AG:[$AvailabilityGroup]"
        Write-Output ""

        $DBOutput = $UnHealthyDatabases | Select-Object AGName, DatabaseName, ReplicaServerName, ReplicaRole, SynchronizationHealth, ReplicaHealth
        Write-Output $DBOutput | Format-Table
        Write-Output ""
        Start-Sleep -Seconds 2

        if ($PollCount -gt $MaxPollCount) {
            Write-Error "AG Databases for [$AvailabilityGroup] are unhealthy post-failover."
            exit         
        }

        $RemainingPolls = $MaxPollCount - ($PollCount-1)
        Write-Output "Waiting $PollIntervalSeconds seconds before polling health again. Max Polls = $MaxPollCount , Remaining Polls = $RemainingPolls"
        Write-Output ""
        Start-Sleep -Seconds $PollIntervalSeconds

        Write-Output "Querying Server:[$ServerInstance] for AG health information..."
        Write-Output ""
        $UnHealthyDatabases = @()
        $UnHealthyDatabases = @(Get-UnHealthyAGDatabases -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup)
       
    }                    

    if ($UnHealthyDatabases.Count -eq 0) {
        Write-Output "Post failover checks are healthy for AG:[$AvailabilityGroup]"
        Write-Output ""
        return
    }

}