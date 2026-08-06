<#
DWP Startup Audit and Management (PowerShell 5.1)

Purpose:
- Audit startup programs from Startup folders, Registry Run keys, and Scheduled Tasks at logon.
- Provide safe disable and rollback capabilities for service-desk operations.

Safety model:
- Read operations are non-destructive.
- Disable operations support dry-run and create backups before changes.
- Per-modification try/catch prevents one failure from stopping execution.
#>

[CmdletBinding(DefaultParameterSetName = 'Audit')]
param(
    # Generates a report only (default behavior).
    [Parameter(ParameterSetName = 'Audit')]
    [switch]$Audit,

    # Disables entries matching the supplied display/program name.
    [Parameter(ParameterSetName = 'Disable', Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$DisableProgramName,

    # Preview matching entries that would be disabled; makes no changes.
    [Parameter(ParameterSetName = 'Disable')]
    [switch]$DryRun,

    # Rolls back previously disabled entries from a backup JSON file.
    [Parameter(ParameterSetName = 'Rollback', Mandatory = $true)]
    [switch]$Rollback,

    # Backup file path used for rollback mode.
    [Parameter(ParameterSetName = 'Rollback', Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$BackupFile,

    # Optional custom report path; default writes under script folder.
    [string]$ReportPath,

    # Root folder for logs and backups.
    [string]$StateRoot = (Join-Path -Path $PSScriptRoot -ChildPath 'StartupState')
)

$ErrorActionPreference = 'Stop'

# Section: Initialize folders, run metadata, and summary counters.
# Creates timestamped log/report/backups and keeps run counters for final summary.
$runStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$runId = [guid]::NewGuid().ToString()
$scriptLabel = 'DWP_Startup_Audit_Manage'

$logRoot = Join-Path -Path $StateRoot -ChildPath 'Logs'
$backupRoot = Join-Path -Path $StateRoot -ChildPath 'Backups'
$reportRoot = Join-Path -Path $StateRoot -ChildPath 'Reports'

foreach ($dir in @($StateRoot, $logRoot, $backupRoot, $reportRoot)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

$logFile = Join-Path -Path $logRoot -ChildPath ("{0}_{1}.log" -f $scriptLabel, $runStamp)
if (-not $ReportPath) {
    $ReportPath = Join-Path -Path $reportRoot -ChildPath ("Startup_Report_{0}.csv" -f $runStamp)
}

$summary = [ordered]@{
    Mode               = $PSCmdlet.ParameterSetName
    DryRun             = [bool]$DryRun
    StartupEntries     = 0
    EnabledEntries     = 0
    DisabledEntries    = 0
    ModifiedEntries    = 0
    Warnings           = 0
    Errors             = 0
    BackupFile         = $null
    ReportPath         = $ReportPath
    LogFile            = $logFile
    StartTime          = Get-Date
    EndTime            = $null
    DurationSeconds    = $null
}

# Section: Logging helper.
# Writes all informational, warning, and error records to console and log file.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    if ($Level -eq 'WARN') { $summary.Warnings++ }
    if ($Level -eq 'ERROR') { $summary.Errors++ }

    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[{0}] [{1}] {2}" -f $ts, $Level, $Message
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line
}

# Section: Utility to parse executable path from command lines.
# Handles quoted and unquoted startup commands to extract binary path candidates.
function Get-ExecutablePathFromCommand {
    param([string]$Command)

    if ([string]::IsNullOrWhiteSpace($Command)) { return $null }

    $trimmed = $Command.Trim()
    if ($trimmed.StartsWith('"')) {
        $parts = $trimmed -split '"'
        if ($parts.Length -ge 2) {
            return $parts[1]
        }
    }

    $firstToken = ($trimmed -split '\s+')[0]
    return $firstToken
}

# Section: Utility to resolve Authenticode publisher when available.
# Reads signature info for filesystem executables and returns signer subject.
function Get-Publisher {
    param([string]$ExecutablePath)

    if ([string]::IsNullOrWhiteSpace($ExecutablePath)) { return '' }

    try {
        $expanded = [Environment]::ExpandEnvironmentVariables($ExecutablePath)
        if (-not (Test-Path -LiteralPath $expanded)) { return '' }

        $sig = Get-AuthenticodeSignature -FilePath $expanded
        if ($sig -and $sig.SignerCertificate) {
            return $sig.SignerCertificate.Subject
        }
    }
    catch {
        return ''
    }

    return ''
}

# Section: Startup folder enumeration.
# Collects startup shortcuts/files from current-user and all-users startup folders.
function Get-StartupFolderEntries {
    $entries = New-Object System.Collections.Generic.List[object]

    $paths = @(
        [pscustomobject]@{ Scope = 'CurrentUser'; Path = [Environment]::GetFolderPath('Startup') },
        [pscustomobject]@{ Scope = 'AllUsers'; Path = [Environment]::GetFolderPath('CommonStartup') }
    )

    foreach ($item in $paths) {
        if (-not (Test-Path -LiteralPath $item.Path)) {
            Write-Log -Level 'WARN' -Message ("Startup folder missing: {0}" -f $item.Path)
            continue
        }

        Get-ChildItem -LiteralPath $item.Path -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
            $f = $_
            $publisher = ''
            $exePath = $f.FullName

            if ($f.Extension -ieq '.lnk') {
                # For .lnk files, executable path may not be directly resolvable in PS 5.1 without COM parsing.
                $exePath = $f.FullName
            }
            else {
                $publisher = Get-Publisher -ExecutablePath $f.FullName
            }

            $entries.Add([pscustomobject]@{
                ProgramName      = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
                StartupLocation  = "StartupFolder-$($item.Scope)"
                EntryType        = 'StartupFolder'
                EntryKey         = $f.FullName
                ExecutablePath   = $exePath
                Publisher        = $publisher
                Status           = 'Enabled'
            }) | Out-Null
        }
    }

    return $entries
}

# Section: Registry Run key enumeration.
# Collects HKCU/HKLM Run values and identifies disabled values by naming convention.
function Get-RegistryRunEntries {
    $entries = New-Object System.Collections.Generic.List[object]

    $regTargets = @(
        [pscustomobject]@{ Hive = 'HKCU'; Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' },
        [pscustomobject]@{ Hive = 'HKLM'; Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run' }
    )

    foreach ($rt in $regTargets) {
        if (-not (Test-Path -LiteralPath $rt.Path)) {
            Write-Log -Level 'WARN' -Message ("Registry path missing: {0}" -f $rt.Path)
            continue
        }

        try {
            $key = Get-Item -LiteralPath $rt.Path
            foreach ($valueName in $key.GetValueNames()) {
                $rawData = [string]$key.GetValue($valueName)
                $status = if ($valueName -like 'DWP_DISABLED_*') { 'Disabled' } else { 'Enabled' }
                $displayName = if ($valueName -like 'DWP_DISABLED_*') { $valueName.Substring(13) } else { $valueName }
                $exePath = Get-ExecutablePathFromCommand -Command $rawData
                $publisher = Get-Publisher -ExecutablePath $exePath

                $entries.Add([pscustomobject]@{
                    ProgramName      = $displayName
                    StartupLocation  = "RegistryRun-$($rt.Hive)"
                    EntryType        = 'RegistryRun'
                    EntryKey         = "$($rt.Path)|$valueName"
                    ExecutablePath   = $rawData
                    Publisher        = $publisher
                    Status           = $status
                }) | Out-Null
            }
        }
        catch {
            Write-Log -Level 'ERROR' -Message ("Failed reading registry path {0}: {1}" -f $rt.Path, $_.Exception.Message)
        }
    }

    return $entries
}

# Section: Scheduled task enumeration.
# Collects tasks with logon trigger and records enabled/disabled state.
function Get-LogonScheduledTaskEntries {
    $entries = New-Object System.Collections.Generic.List[object]

    try {
        $tasks = Get-ScheduledTask -ErrorAction Stop
        foreach ($task in $tasks) {
            $hasLogonTrigger = $false
            foreach ($trigger in $task.Triggers) {
                if ($trigger.TriggerType -eq 'Logon') {
                    $hasLogonTrigger = $true
                    break
                }
            }

            if (-not $hasLogonTrigger) {
                continue
            }

            $actions = @($task.Actions | ForEach-Object {
                if ($_.Execute) {
                    if ($_.Arguments) {
                        "{0} {1}" -f $_.Execute, $_.Arguments
                    }
                    else {
                        $_.Execute
                    }
                }
            }) -join '; '

            $firstExec = $null
            if ($task.Actions -and $task.Actions[0] -and $task.Actions[0].Execute) {
                $firstExec = $task.Actions[0].Execute
            }

            $publisher = Get-Publisher -ExecutablePath $firstExec
            $status = if ($task.State -eq 'Disabled') { 'Disabled' } else { 'Enabled' }

            $entries.Add([pscustomobject]@{
                ProgramName      = $task.TaskName
                StartupLocation  = "ScheduledTask-$($task.TaskPath)"
                EntryType        = 'ScheduledTask'
                EntryKey         = "$($task.TaskPath)|$($task.TaskName)"
                ExecutablePath   = $actions
                Publisher        = $publisher
                Status           = $status
            }) | Out-Null
        }
    }
    catch {
        Write-Log -Level 'ERROR' -Message ("Failed to enumerate scheduled tasks: {0}" -f $_.Exception.Message)
    }

    return $entries
}

# Section: Unified startup inventory.
# Aggregates entries from all required sources for reporting and actions.
function Get-AllStartupEntries {
    $all = New-Object System.Collections.Generic.List[object]

    foreach ($e in (Get-StartupFolderEntries)) { $all.Add($e) | Out-Null }
    foreach ($e in (Get-RegistryRunEntries)) { $all.Add($e) | Out-Null }
    foreach ($e in (Get-LogonScheduledTaskEntries)) { $all.Add($e) | Out-Null }

    return $all
}

# Section: Backup creation.
# Exports complete startup inventory before any modification operation.
function New-StartupBackup {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Entries
    )

    $backupFile = Join-Path -Path $backupRoot -ChildPath ("Startup_Backup_{0}.json" -f $runStamp)
    $payload = [pscustomobject]@{
        RunId      = $runId
        CreatedOn  = (Get-Date).ToString('o')
        Entries    = $Entries
    }

    $payload | ConvertTo-Json -Depth 6 | Out-File -LiteralPath $backupFile -Encoding utf8
    $summary.BackupFile = $backupFile
    Write-Log -Message ("Backup created: {0}" -f $backupFile)
}

# Section: Disable operation for startup folder entries.
# Disables by moving entry file into a dedicated Disabled folder.
function Disable-StartupFolderEntry {
    param([Parameter(Mandatory = $true)]$Entry)

    try {
        $source = $Entry.EntryKey
        if (-not (Test-Path -LiteralPath $source)) {
            Write-Log -Level 'WARN' -Message ("Startup file not found, skipping: {0}" -f $source)
            return $false
        }

        $parent = Split-Path -Path $source -Parent
        $disabledDir = Join-Path -Path $parent -ChildPath 'DWP_Disabled_Startup'
        if (-not (Test-Path -LiteralPath $disabledDir)) {
            New-Item -Path $disabledDir -ItemType Directory -Force | Out-Null
        }

        $dest = Join-Path -Path $disabledDir -ChildPath (Split-Path -Path $source -Leaf)
        if (Test-Path -LiteralPath $dest) {
            Write-Log -Level 'WARN' -Message ("Disabled target already exists, treating as already disabled: {0}" -f $dest)
            return $false
        }

        Move-Item -LiteralPath $source -Destination $dest -Force
        Write-Log -Message ("Disabled startup folder entry: {0}" -f $source)
        return $true
    }
    catch {
        Write-Log -Level 'ERROR' -Message ("Failed to disable startup folder entry {0}: {1}" -f $Entry.EntryKey, $_.Exception.Message)
        return $false
    }
}

# Section: Disable operation for registry Run entries.
# Disables by renaming value to a managed disabled prefix.
function Disable-RegistryRunEntry {
    param([Parameter(Mandatory = $true)]$Entry)

    try {
        $parts = $Entry.EntryKey -split '\|', 2
        $regPath = $parts[0]
        $valueName = $parts[1]

        if ($valueName -like 'DWP_DISABLED_*') {
            Write-Log -Level 'WARN' -Message ("Registry value already disabled: {0}" -f $Entry.EntryKey)
            return $false
        }

        if (-not (Test-Path -LiteralPath $regPath)) {
            Write-Log -Level 'WARN' -Message ("Registry path missing, skipping: {0}" -f $regPath)
            return $false
        }

        $key = Get-Item -LiteralPath $regPath
        $data = $key.GetValue($valueName, $null)
        if ($null -eq $data) {
            Write-Log -Level 'WARN' -Message ("Registry value missing, skipping: {0}" -f $Entry.EntryKey)
            return $false
        }

        $disabledName = "DWP_DISABLED_{0}" -f $valueName
        if ($key.GetValue($disabledName, $null) -ne $null) {
            Write-Log -Level 'WARN' -Message ("Disabled registry value already exists, skipping: {0}" -f $disabledName)
            return $false
        }

        New-ItemProperty -Path $regPath -Name $disabledName -Value $data -PropertyType String -Force | Out-Null
        Remove-ItemProperty -Path $regPath -Name $valueName -Force

        Write-Log -Message ("Disabled registry startup value: {0} -> {1}" -f $valueName, $disabledName)
        return $true
    }
    catch {
        Write-Log -Level 'ERROR' -Message ("Failed to disable registry entry {0}: {1}" -f $Entry.EntryKey, $_.Exception.Message)
        return $false
    }
}

# Section: Disable operation for scheduled tasks.
# Disables task using Disable-ScheduledTask cmdlet.
function Disable-ScheduledTaskEntry {
    param([Parameter(Mandatory = $true)]$Entry)

    try {
        $parts = $Entry.EntryKey -split '\|', 2
        $taskPath = $parts[0]
        $taskName = $parts[1]

        $task = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
        if (-not $task) {
            Write-Log -Level 'WARN' -Message ("Scheduled task missing, skipping: {0}" -f $Entry.EntryKey)
            return $false
        }

        if ($task.State -eq 'Disabled') {
            Write-Log -Level 'WARN' -Message ("Scheduled task already disabled: {0}" -f $Entry.EntryKey)
            return $false
        }

        Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop | Out-Null
        Write-Log -Message ("Disabled scheduled task: {0}{1}" -f $taskPath, $taskName)
        return $true
    }
    catch {
        Write-Log -Level 'ERROR' -Message ("Failed to disable scheduled task {0}: {1}" -f $Entry.EntryKey, $_.Exception.Message)
        return $false
    }
}

# Section: Disable dispatcher.
# Finds matching entries by program name and disables with per-entry fault tolerance.
function Invoke-DisableMode {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Entries
    )

    $matches = @($Entries | Where-Object { $_.ProgramName -like "*$DisableProgramName*" })

    if ($matches.Count -eq 0) {
        Write-Log -Level 'WARN' -Message ("No startup entry matched Program Name filter: {0}" -f $DisableProgramName)
        return
    }

    Write-Log -Message ("Matched entries: {0}" -f $matches.Count)

    if ($DryRun) {
        foreach ($m in $matches) {
            Write-Log -Message ("DRY-RUN would disable [{0}] {1} ({2})" -f $m.EntryType, $m.ProgramName, $m.EntryKey)
        }
        return
    }

    New-StartupBackup -Entries $Entries

    foreach ($m in $matches) {
        # Try/catch is inside each type-specific function to satisfy per-modification handling.
        $changed = $false

        switch ($m.EntryType) {
            'StartupFolder' { $changed = Disable-StartupFolderEntry -Entry $m }
            'RegistryRun'   { $changed = Disable-RegistryRunEntry -Entry $m }
            'ScheduledTask' { $changed = Disable-ScheduledTaskEntry -Entry $m }
            default {
                Write-Log -Level 'WARN' -Message ("Unknown entry type, skipping: {0}" -f $m.EntryType)
            }
        }

        if ($changed) {
            $summary.ModifiedEntries++
        }
    }
}

# Section: Rollback implementation.
# Restores disabled startup entries from the supplied backup snapshot.
function Invoke-RollbackMode {
    if (-not (Test-Path -LiteralPath $BackupFile)) {
        throw "Backup file not found: $BackupFile"
    }

    $summary.BackupFile = $BackupFile
    $payload = Get-Content -LiteralPath $BackupFile -Raw | ConvertFrom-Json
    $entries = @($payload.Entries)

    Write-Log -Message ("Rollback entries loaded: {0}" -f $entries.Count)

    foreach ($e in $entries) {
        if ($e.Status -ne 'Enabled') {
            continue
        }

        switch ($e.EntryType) {
            'StartupFolder' {
                try {
                    $source = [string]$e.EntryKey
                    $parent = Split-Path -Path $source -Parent
                    $disabledDir = Join-Path -Path $parent -ChildPath 'DWP_Disabled_Startup'
                    $disabledFile = Join-Path -Path $disabledDir -ChildPath (Split-Path -Path $source -Leaf)

                    if (Test-Path -LiteralPath $source) {
                        Write-Log -Level 'WARN' -Message ("Startup file already present, rollback skip (idempotent): {0}" -f $source)
                        continue
                    }

                    if (-not (Test-Path -LiteralPath $disabledFile)) {
                        Write-Log -Level 'WARN' -Message ("Disabled startup file not found for rollback: {0}" -f $disabledFile)
                        continue
                    }

                    Move-Item -LiteralPath $disabledFile -Destination $source -Force
                    $summary.ModifiedEntries++
                    Write-Log -Message ("Rolled back startup folder entry: {0}" -f $source)
                }
                catch {
                    Write-Log -Level 'ERROR' -Message ("Rollback failed for startup folder entry {0}: {1}" -f $e.EntryKey, $_.Exception.Message)
                }
            }
            'RegistryRun' {
                try {
                    $parts = ([string]$e.EntryKey) -split '\|', 2
                    $regPath = $parts[0]
                    $valueName = $parts[1]
                    $disabledName = "DWP_DISABLED_{0}" -f $valueName

                    if (-not (Test-Path -LiteralPath $regPath)) {
                        Write-Log -Level 'WARN' -Message ("Registry path missing during rollback: {0}" -f $regPath)
                        continue
                    }

                    $key = Get-Item -LiteralPath $regPath
                    if ($key.GetValue($valueName, $null) -ne $null) {
                        Write-Log -Level 'WARN' -Message ("Registry value already enabled, rollback skip (idempotent): {0}" -f $valueName)
                        continue
                    }

                    $data = $key.GetValue($disabledName, $null)
                    if ($null -eq $data) {
                        Write-Log -Level 'WARN' -Message ("Disabled registry value not found for rollback: {0}" -f $disabledName)
                        continue
                    }

                    New-ItemProperty -Path $regPath -Name $valueName -Value $data -PropertyType String -Force | Out-Null
                    Remove-ItemProperty -Path $regPath -Name $disabledName -Force
                    $summary.ModifiedEntries++
                    Write-Log -Message ("Rolled back registry entry: {0}" -f $e.EntryKey)
                }
                catch {
                    Write-Log -Level 'ERROR' -Message ("Rollback failed for registry entry {0}: {1}" -f $e.EntryKey, $_.Exception.Message)
                }
            }
            'ScheduledTask' {
                try {
                    $parts = ([string]$e.EntryKey) -split '\|', 2
                    $taskPath = $parts[0]
                    $taskName = $parts[1]

                    $task = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
                    if (-not $task) {
                        Write-Log -Level 'WARN' -Message ("Task missing during rollback: {0}" -f $e.EntryKey)
                        continue
                    }

                    if ($task.State -ne 'Disabled') {
                        Write-Log -Level 'WARN' -Message ("Task already enabled, rollback skip (idempotent): {0}" -f $e.EntryKey)
                        continue
                    }

                    Enable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction Stop | Out-Null
                    $summary.ModifiedEntries++
                    Write-Log -Message ("Rolled back scheduled task: {0}" -f $e.EntryKey)
                }
                catch {
                    Write-Log -Level 'ERROR' -Message ("Rollback failed for scheduled task {0}: {1}" -f $e.EntryKey, $_.Exception.Message)
                }
            }
            default {
                Write-Log -Level 'WARN' -Message ("Unsupported entry type in backup: {0}" -f $e.EntryType)
            }
        }
    }
}

# Section: Summary counter refresh.
# Re-evaluates current startup state to provide accurate final counts after actions.
function Update-SummaryFromEntries {
    param([object[]]$Entries)

    $summary.StartupEntries = $Entries.Count
    $summary.EnabledEntries = @($Entries | Where-Object { $_.Status -eq 'Enabled' }).Count
    $summary.DisabledEntries = @($Entries | Where-Object { $_.Status -eq 'Disabled' }).Count
}

# Section: Main flow.
# Performs audit/disable/rollback and emits report plus final summary.
try {
    Write-Log -Message ("Script started. Mode: {0}" -f $PSCmdlet.ParameterSetName)

    $entries = @(Get-AllStartupEntries)
    Update-SummaryFromEntries -Entries $entries

    switch ($PSCmdlet.ParameterSetName) {
        'Audit' {
            Write-Log -Message 'Audit mode selected. No modifications will be made.'
        }
        'Disable' {
            Write-Log -Message ("Disable mode selected. Program filter: {0}" -f $DisableProgramName)
            Invoke-DisableMode -Entries $entries
        }
        'Rollback' {
            Write-Log -Message 'Rollback mode selected.'
            Invoke-RollbackMode
        }
        default {
            throw 'Unknown parameter set.'
        }
    }

    # Re-read entries so report and summary reflect post-action state.
    $finalEntries = @(Get-AllStartupEntries)
    Update-SummaryFromEntries -Entries $finalEntries

    $finalEntries |
        Select-Object ProgramName, StartupLocation, ExecutablePath, Publisher, Status |
        Export-Csv -LiteralPath $ReportPath -NoTypeInformation -Encoding UTF8

    Write-Log -Message ("Report generated: {0}" -f $ReportPath)
}
catch {
    Write-Log -Level 'ERROR' -Message ("Fatal error: {0}" -f $_.Exception.Message)
}
finally {
    # Section: Final summary display.
    # Prints concise run metrics and saves them into the log for traceability.
    $summary.EndTime = Get-Date
    $summary.DurationSeconds = [math]::Round((New-TimeSpan -Start $summary.StartTime -End $summary.EndTime).TotalSeconds, 2)

    Write-Host "`n==================== Startup Script Summary ===================="
    foreach ($item in $summary.GetEnumerator()) {
        $line = "{0}: {1}" -f $item.Key, $item.Value
        Write-Host $line
        Add-Content -LiteralPath $logFile -Value $line
    }
    Write-Host "================================================================"
}
