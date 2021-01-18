#Enable TLS 1.2 to properly get modules
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Need to update dbatools to be able to recognize new patch files
Write-Output "Installing dbatools..."
Install-Module dbatools -AllowClobber -Force
Write-Output "Complete"
Write-Output ""

Import-Module dbatools -force
import-module C:\Tools\SQLRoboFailover\src\SQLRoboFailover -Force

$ServerInstance = "node1.prod"

[bool]$IsSQLServerHealthy = Test-IsSQLServerHealthy -ServerInstance $ServerInstance -Verbose
[bool]$IsRestartReady = Test-IsRestartReady -ServerInstance $ServerInstance -Verbose

if ($IsSQLServerHealthy -and $IsRestartReady) {
    $Credential = Get-Credential
    Update-DbaInstance -ComputerName $ServerInstance -Version 2017CU22 -Path "\\myfileshare.prod\dfs\FileShare\PatchAutomation\UpgradeMedia\SQL2017" -Credential $Credential -Confirm
}

else {
    Write-Output "SQL Server - [$ServerInstance] is NOT ready to patch"
}
