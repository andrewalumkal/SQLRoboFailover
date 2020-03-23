Function Invoke-FailoverSQLCommand {
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $FailoverTargetServer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $AvailabilityGroup

    )
  
    $query = @"

    alter availability group [$AvailabilityGroup] failover;

"@



    try {
        if ($PSCmdlet.ShouldProcess("FailoverTarget: $FailoverTargetServer - $AvailabilityGroup")) {
            Write-Output "Testing - Would run on server: $FailoverTargetServer"
            Write-Output $query
            #Set query timeout to 60 seconds at least
        }
    }
    
    catch {
        Write-Error "Failed to failover [$AvailabilityGroup] to Server: $FailoverTargetServer "
        Write-Error "Error Message: $_.Exception.Message" 
        exit
    }

    
    
}