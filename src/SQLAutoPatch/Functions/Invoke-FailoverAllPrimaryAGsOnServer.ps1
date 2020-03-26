Function Invoke-FailoverAllPrimaryAGsOnServer {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance,

        [Parameter(Mandatory = $false)]
        [Switch]$RunPostFailoverChecks = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true,

        [Parameter(Mandatory = $false)]
        [Switch]$Confirm = $true

    )

    #Ignore DAGs / ReadScale AGs
    $PrimaryAGs = @(Get-AllPrimaryAvailabilityGroupReplicas -ServerInstance $ServerInstance | Where-Object -Property ClusterType -eq "wsfc")

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
            -RunPostFailoverChecks:$RunPostFailoverChecks -ScriptOnly:$ScriptOnly -Confirm:$Confirm

    }

  

}