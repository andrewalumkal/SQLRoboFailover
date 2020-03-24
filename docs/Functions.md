# Failover Functions

## Invoke-FailoverAvailabilityGroup
```powershell
Invoke-FailoverAvailabilityGroup -PrimaryServerInstance <PrimaryServerName> -AvailabilityGroup <AGName> -ScriptOnly:$false
```
Failover AG to an available synchronous_commit replica

#### Parameters
```powershell
-PrimaryServerInstance -AvailabilityGroup <AGName> -ScriptOnly:$false
```
Server / listener to the primary AG replica



