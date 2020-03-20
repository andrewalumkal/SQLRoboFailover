Function Get-AllPrimaryAvailabilityGroupReplicas {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance
    )

    $PrimaryAGReplicas = @(Get-AllAvailabilityGroupReplicas -ServerInstance $ServerInstance | Where-Object -Property ReplicaRole -eq "PRIMARY")
   
    return $PrimaryAGReplicas
    
}