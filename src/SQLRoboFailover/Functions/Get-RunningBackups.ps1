Function Get-RunningBackups {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $ServerInstance

    )

    $query = @"
    select      r.start_time as StartTime
                ,r.session_id as SessionID
                ,db_name(r.database_id) as [Database]
                ,s.program_name as ProgramName
                ,r.command as [Command]
                ,s.host_name as HostName
    from        sys.dm_exec_requests r
    left join   sys.dm_exec_sessions s
    on          r.session_id = s.session_id
    where       r.command like '%BACKUP DATABASE%';
"@

    try {
        
        $SQLOutput = Invoke-Sqlcmd -ServerInstance $ServerInstance -Database master -Query $query -QueryTimeout 60 -ErrorAction Stop
        return $SQLOutput
    }

    catch {
        Write-Error "Failed to check for active running backups on Server: $ServerInstance"
        Write-Error "Error Message: $_.Exception.Message"
        exit
    }
    
}