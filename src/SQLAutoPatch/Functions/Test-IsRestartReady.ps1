Function Test-IsRestartReady {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance
    )
    

    [bool]$IsRestartReady = 1

    $AGReplicas = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance)
    
    if ($AGReplicas | Where-Object -Property ReplicaRole -ne "SECONDARY") {
        Write-Verbose "Found replicas that are not in secondary role"
        $IsRestartReady = 0
        return $IsRestartReady
    }

    if ($AGReplicas | Where-Object -Property AvailabilityMode -ne "ASYNCHRONOUS_COMMIT") {
        Write-Verbose "Found replicas that are not in asynchronous_commit mode"
        $IsRestartReady = 0
        return $IsRestartReady
    }

    if ($AGReplicas | Where-Object -Property ReplicaConnectedState -ne "CONNECTED") {
        Write-Verbose "Found replicas that are not in a connected state"
        $IsRestartReady = 0
        return $IsRestartReady
    }

    #Check DB Level AG health
    $IsRestartReady = Test-AllAGDatabasesOnServerHealthy -ServerInstance $ServerInstance 

    #CHECK ALL DBS ARE ONLINE ON SERVER

    return $IsRestartReady
    
}