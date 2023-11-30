Function Invoke-FailoverSQLCommand {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $FailoverTargetServer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup,

        [Parameter(Mandatory = $false)]
        [Switch]$ScriptOnly = $true

    )
  
    $query = @"

    alter availability group [$AvailabilityGroup] failover;

"@

    if ($ScriptOnly){
        Write-Output "----Script Only mode----"
        Write-Output "Script to execute on Server: [$FailoverTargetServer]"
        Write-Output $query
        Write-Output "-----------------------"
        return
    }

    try {
        if ($PSCmdlet.ShouldProcess("FailoverTarget: $FailoverTargetServer - $AvailabilityGroup")) {

            Invoke-SqlCmd -TrustServerCertificate -ServerInstance $FailoverTargetServer -Database master -Query $query -QueryTimeout 60 -ErrorAction Stop
            
        }
    }
    
    catch {
        Write-Error "Failed to failover [$AvailabilityGroup] to Server: $FailoverTargetServer "
        Write-Error "Error Message: $_.Exception.Message" 
        exit
    }

    
    
}