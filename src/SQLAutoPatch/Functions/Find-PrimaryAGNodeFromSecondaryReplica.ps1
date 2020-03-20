Function Find-PrimaryAGNodeFromSecondaryReplica {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $SecondaryServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )

    $PrimaryNode = $null
    [bool]$TestResult = 0

    $AGNodes = @(Get-AGNodes -ServerInstance $ServerInstance -AvailabilityGroup $AvailabilityGroup)

    foreach ($Node in $AGNodes.ReplicaServer) {
        
        $TestResult = Test-IsPrimaryReplica -ServerInstance $Node -AvailabilityGroup $AvailabilityGroup
       
        if ($TestResult) {
            $PrimaryNode = $Node
            break
        }

    }

    if ($PrimaryNode -eq $null) {
        Write-Error "Could not find primary replica node for Server: $ServerInstance , AG: $AvailabilityGroup"
        exit
    }

    else {
        return $PrimaryNode
    }



    
}