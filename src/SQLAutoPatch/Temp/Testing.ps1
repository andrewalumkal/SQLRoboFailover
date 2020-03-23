import-module C:\Tools\SQLAutoPatch\src\SQLAutoPatch -Force
#$ServerInstance = "933996-REPORT1"
$ServerInstance = "vm-az-qa-sql01"

[bool]$IsHealthy = $false
#$IsHealthy = Test-AllAGDatabasesOnServerHealthy -ServerInstance $ServerInstance -Verbose
$IsHealthy = Test-IsRestartReady -ServerInstance $ServerInstance -Verbose
$IsHealthy


[bool]$ReadyToRestart = 0
$ReadyToRestart = Test-IsRestartReady -ServerInstance 933995-report2.viagogors.prod -Verbose
$ReadyToRestart 

Get-AllAvailabilityGroupReplicas -ServerInstance vm-az-qa-sql01.viagogo.corp

#Update-DbaInstance -ComputerName AndrewSQL2017 -Version 2017CU19 -Path C:\Tools\SQLPatchFiles\2017 -Confirm

$AGReplicas = @(Get-AllAvailabilityGroupReplicas -ServerInstance vm-az-qa-sql01.viagogo.corp)

Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance vm-az-qa-sql01.viagogo.corp

Get-AGDatabaseReplicaState -ServerInstance 933994-report3.viagogors.prod  -AvailabilityGroup "947929-AG4"
Get-AGDatabaseSummary -ServerInstance 933994-report3.viagogors.prod  -AvailabilityGroup "947929-AG4"


Set-AllSecondarySyncReplicasToAsync -ServerInstance "933995-report2.viagogors.prod" #-MaintainHAForAGs:$true -Confirm:$false

