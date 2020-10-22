Function Invoke-AGHealthPoll {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $MaxPollCount,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $PollIntervalSeconds

    )

    #Run the health poll first on all the primary AGs on this server (this gives us visibility to all other replicas of that AG as well)
    Write-Output ""
    Write-Output "###########################################################################"
    Write-Output "Running health poll on all primary AGs on server [$ServerInstance] ..."
    Write-Output "###########################################################################"
    Write-Output ""

    $AllAGsOnServer = @(Get-AvailabilityGroupsOnServer -ServerInstance $ServerInstance)

    $PrimaryAGs = @($AllAGsOnServer | Where-Object -Property ReplicaRole -eq "PRIMARY")

    foreach ($AG in $PrimaryAGs) {
        
        Invoke-PostFailoverHealthPoll -ServerInstance $ServerInstance -AvailabilityGroup $AG.AGName -MaxPollCount $MaxPollCount -PollIntervalSeconds $PollIntervalSeconds

    }


    ##If there are secondary AGs on this node, it will find the primary node for that AG and run the health poll on all AGs that primary replica
    ##Checking the health of an AG ONLY on a secondary replica doesnt give us the visibility of the health of all other servers, hence we need to poll the primary node
    Write-Output "###########################################################################"
    Write-Output "Running health poll on all secondary AGs on server [$ServerInstance] ..."
    Write-Output "###########################################################################"
    Write-Output ""

    $SecondaryAGs = @($AllAGsOnServer | Where-Object -Property ReplicaRole -ne "PRIMARY") #Catch all replica states other than primary

    foreach ($AG in $SecondaryAGs) {
        
        $PrimaryReplica = Find-PrimaryAGNodeFromSecondaryReplica -SecondaryServerInstance $ServerInstance -AvailabilityGroup $AG.AGName

        Write-Host "Polling health from primary node: [$PrimaryReplica] - $($AG.AGName)"
        Write-Host ""
        Invoke-PostFailoverHealthPoll -ServerInstance $PrimaryReplica -AvailabilityGroup $AG.AGName -MaxPollCount $MaxPollCount -PollIntervalSeconds $PollIntervalSeconds
            
    }


}