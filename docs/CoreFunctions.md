# Patch Functions

## Update-DbaInstance

The core patching function used in this solution is `Update-DbaInstance` by [dbatools.io](https://dbatools.io/). For more information on this function, please check this [link](https://docs.dbatools.io/#Update-DbaInstance).

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
Prompt for confirmation prior to taking action.
Default = $true

# Availability Group Setting Functions

## Set-AllSecondarySyncReplicasToAsync
```powershell
Set-AllSecondarySyncReplicasToAsync -ServerInstance <ServerInstance> -MaintainHAForAGs:$true -ScriptOnly:$false -Confirm:$true
```
Sets all *secondary* synchronous_commit availability groups on a specified server to asynchronous commit. Useful for prepping a replica to be ready for patching / restarts.
- Finds all *secondary* synchronous_commit availability groups on the server
- Finds the primary replica for each AG and checks AG topology (set commands need to be run on the primary replica)
- Sets the availability groups to asynchronous_commit. If `-MaintainsHAForAGs:$true` the function will set another available asynchronous_commit replica in the topology to synchronous_commit to maintain HA.

### Parameters
```powershell
-ServerInstance
```
Server to set all synchronous_commit availability groups to asynchronous_commit

```powershell
-MaintainHAForAGs
```
Automatically set another available asynchronous_commit replica in the topology to synchronous_commit to maintain HA for the AG.
Default = $true
```powershell
-ScriptOnly
```
Script out all actions. No actions will actully be performed.
Default = $true

```powershell
-Confirm
```
Prompt for confirmation prior to taking action.
Default = $true

## Set-AGReplicaToSyncCommit
```powershell
Set-AGReplicaToSyncCommit -PrimaryServer <PrimaryServer> -ReplicaServer <ReplicaServer> -AvailabilityGroup <AGName> -ScriptOnly:$false -Confirm:$true
```
Sets an AG replica to synchronous_commit + automatic failover mode.

```powershell
-PrimaryServer
```
Server that hosts the primary AG replica

```powershell
-ReplicaServer
```
AG replica to set to synchronous_commit

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
Prompt for confirmation prior to taking action.
Default = $true

## Set-AGReplicaToAsyncCommit
```powershell
Set-AGReplicaToAsyncCommit -PrimaryServer <PrimaryServer> -ReplicaServer <ReplicaServer> -AvailabilityGroup <AGName> -ScriptOnly:$false -Confirm:$true
```
Sets an AG replica to asynchronous_commit + manual failover mode.

```powershell
-PrimaryServer
```
Server that hosts the primary AG replica

```powershell
-ReplicaServer
```
AG replica to set to asynchronous_commit

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
Prompt for confirmation prior to taking action.
Default = $true

# Health Test Functions
## Test-IsRestartReady

```powershell
Test-IsRestartReady -ServerInstance <ServerInstance> -Verbose

```
Checks if a server is ready to restart. Returns a boolean value.

Checks for the following:
- Any unhealthy databases on the instance. (Databases that are not in an online, restoring, or offline state)
- Any AG replicas that are in a primary role
- Any AG replicas that are in a synchronous_commit role
- Any AG replicas that are not in a connected state
- Any unhealthy AG databases on the server

If any of the conditions are met, the function will return false. Run function with `-Verbose` to print reason for failure.

### Parameters
```powershell
-ServerInstance
```
Server to run test

## Test-AllAGDatabasesOnServerHealthy

```powershell
Test-AllAGDatabasesOnServerHealthy -ServerInstance <ServerInstance> -RunExtendedChecks:$true -Verbose

```
Checks if all AG databases on the Sql Server instance are are healthy. Returns a boolean value.

Checks for the following:
- Any unhealthy AG databases on the server
- If `-RunExtendedChecks` is enabled, function will also find the primary replica for all *secondary* AGs on the server and check the entire topology for unhealthy AG databases. This check is already done by default if an AG is the primary replica on the server.

If any of the conditions are met, the function will return false. Run function with `-Verbose` to print reason for failure.

### Parameters
```powershell
-ServerInstance
```
Server to run test

```powershell
-RunExtendedChecks
```
Finds the primary replica for all *secondary* AGs on the server and check the entire topology for unhealthy AG databases. This check is already done by default if an AG is the primary replica on the server.
