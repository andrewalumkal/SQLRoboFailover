#This is an example of an unconventional setup where node2 hosts AGs that we would NOT like to failover / or set to sync commit to node1 post patching
##Using -ExcludeAGs flag to exclude them from the failback process. 
###We only want to failback a single ag to node 1 (AG10)
import-module C:\Tools\SQLRoboFailover\src\SQLRoboFailover -Force
$ServerInstance = "node1.prod"
$FailbackFromServer = "node2.prod"
$ExcludeAGs = "AG4, AG6, AG8"

[bool]$IsSQLServerHealthy = Test-IsSQLServerHealthy -ServerInstance $ServerInstance -Verbose

if ($IsSQLServerHealthy) {

    Set-AllSecondaryAsyncReplicasToSync -ServerInstance $ServerInstance -ForceSingleSyncCopy -ExcludeAGs $ExcludeAGs -Confirm:$true -ScriptOnly:$false

    Invoke-FailoverAvailabilityGroup -PrimaryServerInstance $FailbackFromServer -AvailabilityGroup "AG10" -RunPostFailoverChecks -CheckRunningBackups -CheckRunningCheckDBs -Confirm:$true -ScriptOnly:$false
}

else {
    Write-Output "SQL Server - [$ServerInstance] is NOT healthy"
}



