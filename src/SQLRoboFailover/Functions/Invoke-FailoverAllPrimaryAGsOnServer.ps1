Function Invoke-FailoverAllPrimaryAGsOnServer {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $ExcludeAGs,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckRunningBackups = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$CheckRunningCheckDBs = $false,

        [Parameter(Mandatory = $false)]
        [Switch]$RunPostFailoverChecks = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm = $true

    )

    #Ignore DAGs / ReadScale AGs
    $AllPrimaryAGs = @(Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance $ServerInstance | Where-Object -Property ClusterType -eq "wsfc")

    $ExcludeList = @($ExcludeAGs -split "," | foreach { $_.Trim() })
    $PrimaryAGs = @($AllPrimaryAGs | Where-Object { $ExcludeList -notcontains $_.AGName })

    if ($PrimaryAGs.Count -eq 0) {
        Write-Output "No Primary availability groups found on this server"
        Write-Output ""
        return
    }


    Write-Output ""
    Write-Output "-----------------------------------"
    Write-Output "The following Primary AGs were found on server: $ServerInstance"
    Write-Output ""                            
    Write-Output $PrimaryAGs.AGName
    Write-Output "-----------------------------------"
    Write-Output ""
    Start-Sleep -Seconds 2

    foreach ($PrimaryAG in $PrimaryAGs) {

        Invoke-FailoverAvailabilityGroup -PrimaryServerInstance $ServerInstance -AvailabilityGroup $PrimaryAG.AGName `
            -RunPostFailoverChecks:$false -CheckRunningBackups:$CheckRunningBackups `
            -CheckRunningCheckDBs:$CheckRunningCheckDBs -ScriptOnly:$ScriptOnly -Confirm:$Confirm

    }

    #Run failover checks after all failovers
    if ($RunPostFailoverChecks) {
        Invoke-AGHealthPoll -ServerInstance $ServerInstance -MaxPollCount 25 -PollIntervalSeconds 15
    }
    

  

}