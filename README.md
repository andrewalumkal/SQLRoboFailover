# SQLRoboFailover

All in one solution to failover AlwaysOn Availability Groups in SQL Server.

Functions to run health checks, failover all availability groups, complete post failover health checks, set AG replicas to sync / async modes. Can be combined with the [Update-DbaInstance](https://docs.dbatools.io/#Update-DbaInstance) function for a fully automated patching solution. 

Requires the `SqlServer` module.
Optional: Install [dbatools](https://dbatools.io/) module for patching functionality.

## Core Functions

This solution is built to be flexible. Functions can be pieced together to build a fully automated solution. Detailed documentation to core functions can be found [here](./docs/CoreFunctions.md). 

## Example Usage

Import the module.

```powershell
Import-Module .\src\SQLRoboFailover -Force
```

### Prepping a server for patching
```powershell
Invoke-FailoverAllPrimaryAGsOnServer -ServerInstance <ServerName> -RunPostFailoverChecks -ScriptOnly:$false -Confirm
```
---------------------------------
### Set all synchronous_commit Availability Groups to asynchronous_commit
```powershell
Set-AllSecondarySyncReplicasToAsync -ServerInstance <ServerInstance> -MaintainHAForAGs -ScriptOnly:$false -Confirm
```


### Set all synchronous_commit Availability Groups to asynchronous_commit
```powershell
Set-AllSecondarySyncReplicasToAsync -ServerInstance <ServerInstance> -MaintainHAForAGs -ScriptOnly:$false -Confirm
```

### Set all synchronous_commit Availability Groups to asynchronous_commit
```powershell
Set-AllSecondarySyncReplicasToAsync -ServerInstance <ServerInstance> -MaintainHAForAGs -ScriptOnly:$false -Confirm
```


