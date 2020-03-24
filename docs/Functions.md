# Failover Functions

## Invoke-FailoverAvailabilityGroup
```powershell
Invoke-FailoverAvailabilityGroup -PrimaryServerInstance <PrimaryServerName> -AvailabilityGroup <AGName> -ScriptOnly:$false
```
Failover AG to an available synchronous_commit replica. 
- Runs all health checks prior to failover for the specified AG (all databases are healthy, synchronized state) 
- Performs failover
- Runs post failover checks to ensure all databases are healthy on all replicas. Polling mechanism built in to keep polling health state if found unhealthy. Health status will be printed to console periodically for every poll

#### Parameters
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
Script out failover actions.
Default = $true
