Function Test-IsPrimaryReplica {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )

    [bool]$IsPrimaryReplica = 0
  
    $results = @(Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance $ServerInstance | Where-Object -Property AGName -eq $AvailabilityGroup)

    if ($results.Count -gt 0){

        $IsPrimaryReplica = 1
    }

    return $IsPrimaryReplica
    
}