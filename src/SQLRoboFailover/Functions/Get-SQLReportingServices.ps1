Function Get-SQLReportingServices {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance
    )
  
    
    try {
        $SQLReportingServices = @(Invoke-Command -ComputerName $ServerInstance -ScriptBlock {Get-Service -Name "*MSSQLServerOLAP*", "*PowerBIReport*", "*SQLServerReportingServices*"} )
        return $SQLReportingServices 
    }
    
    catch {
        Write-Error "Failed to retrieve SQL Reporting Services using Invoke-Command(Get-Service) from Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }
 
}