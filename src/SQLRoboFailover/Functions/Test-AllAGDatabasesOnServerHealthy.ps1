Function Test-AllAGDatabasesOnServerHealthy {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [Switch]$RunExtendedChecks

    )

    [bool]$AllAGsHealthy = 1

    $UnHealthyAGs = @(Get-AllUnHealthyAGDatabases -ServerInstance $ServerInstance)
    
    if ($UnHealthyAGs.Count -gt 0) {
        $AllAGsHealthy = 0
        return $AllAGsHealthy
    }


    if ($RunExtendedChecks) {
        Write-Verbose "Running Extended Checks"
        ##If this is a secondary replica, it will find the primary node and check if entire AG topology is healthy

        $SecondaryAGs = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance | Where-Object -Property ReplicaRole -eq "SECONDARY")

        foreach ($AG in $SecondaryAGs) {
        
            $PrimaryReplica = Find-PrimaryAGNodeFromSecondaryReplica -SecondaryServerInstance $ServerInstance -AvailabilityGroup $AG.AGName

            Write-Verbose "Checking $PrimaryReplica - $($AG.AGName)"
            $UnHealthyAGsFromPrimary = @(Get-AllUnHealthyAGDatabases -ServerInstance $PrimaryReplica)
    
            if ($UnHealthyAGsFromPrimary.Count -gt 0) {
                $AllAGsHealthy = 0
                return $AllAGsHealthy
            }
            
        }

    }

    return $AllAGsHealthy

    
}