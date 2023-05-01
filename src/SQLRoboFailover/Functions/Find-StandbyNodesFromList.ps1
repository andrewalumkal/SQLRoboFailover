Function Find-StandbyNodesFromList {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerArrayList,

        [Parameter(Mandatory = $false)]
        $OptionalFQDNAppendString

    )

    $StandbyNodes = @()

    foreach ($Node in $ServerArrayList){
       
        if ($OptionalFQDNAppendString) {
            $FQNode = "$($Node).$($OptionalFQDNAppendString)"
        }
        else {
            $FQNode = $Node
        }
       
       $PrimaryAGs = @()
       $PrimaryAGs = @(Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance $FQNode | Where-Object -Property ClusterType -eq "wsfc")
   
       if ($PrimaryAGs.Count -eq 0){
           $StandbyNodes += $Node
       }
   
    }

    return $StandbyNodes

    
}
