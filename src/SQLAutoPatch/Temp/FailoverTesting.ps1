import-module C:\Tools\SQLAutoPatch\src\SQLAutoPatch -Force
$PrimaryServerInstance = "vm-az-qa-sql01"
$FailoverTargetServer = "vm-az-qa-sql01"
$AvailabilityGroup = "azqa-ag8"
#[bool]$Confirm  = $true

#Failover All AGs
#$PrimaryAGs = @(Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance $PrimaryServerInstance)

Invoke-FailoverAvailabilityGroup -PrimaryServerInstance $PrimaryServerInstance -AvailabilityGroup $AvailabilityGroup -Confirm:$false

Invoke-PostFailoverHealthPoll -PrimaryServerInstance $FailoverTargetServer -AvailabilityGroup $AvailabilityGroup -MaxPollCount 3 -PollIntervalSeconds 10

