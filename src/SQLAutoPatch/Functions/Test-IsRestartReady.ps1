Function Test-IsRestartReady {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )

    #ALSO CHECK AGAINST CONFIG TO MAKE SURE ALL REPLICAS ARE HEALTHY PRIOR TO PATCHING
    
    $AGReplicas = @(Get-AllAvailabilityGroupReplicas -ServerInstance $ServerInstance)
    [bool]$IsRestartReady = 1

    if ($AGReplicas | Where-Object -Property ReplicaHealth -ne "HEALTHY"){
        
        Write-Verbose "Found replicas that are not healthy"
        $IsRestartReady = 0
    }

    if ($AGReplicas | Where-Object -Property ReplicaRole -ne "SECONDARY"){
        
        Write-Verbose "Found replicas that are not in secondary role"
        $IsRestartReady = 0
    }

    if ($AGReplicas | Where-Object -Property AvailabilityMode -ne "ASYNCHRONOUS_COMMIT"){
        
        Write-Verbose "Found replicas that are not in asynchronous_commit mode"
        $IsRestartReady = 0
    }

    if ($AGReplicas | Where-Object -Property ReplicaConnectedState -ne "CONNECTED"){
        
        Write-Verbose "Found replicas that are not in a connected state"
        $IsRestartReady = 0
    }

    return $IsRestartReady
    
}