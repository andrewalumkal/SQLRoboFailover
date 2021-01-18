import-module C:\Tools\SQLRoboFailover\src\SQLRoboFailover -Force
import-module C:\tools\SQLChecks\src\SQLChecks -Force
import-module C:\tools\viagogo.Database.Configuration\dbachecks\customchecks -Force

$ServerInstance = "node1.prod"

$IsHealthy = Test-IsSQLServerHealthy -ServerInstance $ServerInstance -Verbose

if (!$IsHealthy){
    Write-Output "Checks failed. SQL Server is NOT Healthy."
}