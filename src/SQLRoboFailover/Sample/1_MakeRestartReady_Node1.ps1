import-module C:\Tools\SQLRoboFailover\src\SQLRoboFailover -Force
$ServerInstance = "node1.prod"

Invoke-MakeSQLServerRestartReady -ServerInstance $ServerInstance -RunPostFailoverChecks -CheckRunningBackups -CheckRunningCheckDBs -ScriptOnly:$false -Confirm:$true
