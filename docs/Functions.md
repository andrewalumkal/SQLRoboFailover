# Failover Functions

## Invoke-FailoverAvailabilityGroup
```powershell
Invoke-FailoverAvailabilityGroup -PrimaryServerInstance <PrimaryServerName> -AvailabilityGroup <AGName> -ScriptOnly:$false -Confirm:$true
```
Failover AG to an available synchronous_commit replica. 
- Runs all health checks prior to failover for the specified AG (all databases are healthy, synchronized state) 
- Performs failover
- Runs post failover checks to ensure all databases are healthy on all replicas. Polling mechanism built in to keep polling health state if found unhealthy. Health status will be printed to console on every poll

### Parameters
```powershell
-PrimaryServerInstance
```
Server / listener to the primary AG replica

```powershell
-AvailabilityGroup
```
Availability Group Name
```powershell
-ScriptOnly
```
Script out all actions. No actions will actully be performed.
Default = $true

```powershell
-Confirm
```
Prompt for confirmation prior to taking action
Default = $true

# Availability Group Setting Functions

## Invoke-FailoverAvailabilityGroup
```powershell
Set-AllSecondarySyncReplicasToAsync -ServerInstance <ServerInstance> -MaintainHAForAGs:$true -ScriptOnly:$false -Confirm:$true

```
Sets all *secondary* synchronous_commit availability groups on a specified server to asynchronous commit. Useful for prepping a replica to be ready for patching / restarts.
- Finds all *secondary* synchronous_commit availability groups on the server
- Finds the primary replica and checks AG topology
- Sets the availability groups to asynchronous_commit. If `-MaintainsHAForAGs:$true` the functions will set another available asynchronous_commit replica in the topology to synchronous_commit to maintain HA.

### Parameters
```powershell
-ServerInstance
```
Server to set all synchronous_commit availability groups to asynchronous_commit

```powershell
-MaintainHAForAGs
```
Automatically set another available asynchronous_commit replica in the topology to synchronous_commit to maintain HA for the AG
```powershell
-ScriptOnly
```
Script out all actions. No actions will actully be performed.
Default = $true

```powershell
-Confirm
```
Prompt for confirmation prior to taking action
Default = $true
