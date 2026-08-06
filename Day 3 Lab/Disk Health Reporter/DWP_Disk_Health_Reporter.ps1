<#
DWP Disk Health Reporter (Strictly Read-Only)
PowerShell Version: 5.1

Purpose:
- Report disk health and optimization status for endpoint triage.

Read-only guarantee:
- This script only reads data via PowerShell cmdlets, WMI/CIM, and event/task reporting.
- It never runs defrag, TRIM, CHKDSK repair/fix, disk optimization actions, or configuration changes.
- It performs no remediation and does not modify endpoint state.
#>

[CmdletBinding()]
param(
    # Optional target drive filter. Examples: C, D, E
    [string[]]$DriveLetters,

    # Free space threshold for warning highlight.
    [ValidateRange(1, 99)]
    [int]$LowFreeSpacePercentThreshold = 15,

    # Optional output root for logs and reports.
    [string]$OutputRoot = (Join-Path -Path $PSScriptRoot -ChildPath 'DiskHealthReporterOutput')
)

$ErrorActionPreference = 'Stop'

# Section: Initialize output paths and run metadata.
# Creates timestamped output files and summary counters used at the end.
$runStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$scriptLabel = 'DWP_Disk_Health_Reporter'

$logRoot = Join-Path -Path $OutputRoot -ChildPath 'Logs'
$reportRoot = Join-Path -Path $OutputRoot -ChildPath 'Reports'

foreach ($folder in @($OutputRoot, $logRoot, $reportRoot)) {
    if (-not (Test-Path -LiteralPath $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }
}

$logFile = Join-Path -Path $logRoot -ChildPath ("{0}_{1}.log" -f $scriptLabel, $runStamp)
$csvReport = Join-Path -Path $reportRoot -ChildPath ("DiskHealth_{0}.csv" -f $runStamp)
$htmlReport = Join-Path -Path $reportRoot -ChildPath ("DiskHealth_{0}.html" -f $runStamp)

$summary = [ordered]@{
    TotalDisksDetected       = 0
    HealthyDisks             = 0
    WarningDisks             = 0
    CriticalDisks            = 0
    LowestFreeSpacePercent   = [double]100
    LowestFreeSpaceDrive     = ''
    StartTime                = Get-Date
    EndTime                  = $null
    DurationSeconds          = $null
    LogFile                  = $logFile
    CsvReport                = $csvReport
    HtmlReport               = $htmlReport
}

# Section: Logging helper.
# Logs every action, warning, and error to both console and timestamped log file.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $ts = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[{0}] [{1}] {2}" -f $ts, $Level, $Message
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line
}

# Section: Optimization status collector.
# Uses native scheduled task and event log reporting to infer maintenance status.
function Get-OptimizationStatusData {
    $status = [ordered]@{
        ScheduledTaskState      = 'Unknown'
        ScheduledTaskLastRun    = $null
        ScheduledTaskNextRun    = $null
        LastOptimizeEventTime   = $null
        LastOptimizeEventId     = $null
        LastOptimizeEventSource = ''
    }

    try {
        $task = Get-ScheduledTask -TaskPath '\\Microsoft\\Windows\\Defrag\\' -TaskName 'ScheduledDefrag' -ErrorAction Stop
        $taskInfo = Get-ScheduledTaskInfo -TaskPath '\\Microsoft\\Windows\\Defrag\\' -TaskName 'ScheduledDefrag' -ErrorAction Stop
        $status.ScheduledTaskState = [string]$task.State
        $status.ScheduledTaskLastRun = $taskInfo.LastRunTime
        $status.ScheduledTaskNextRun = $taskInfo.NextRunTime
        Write-Log -Message 'Retrieved ScheduledDefrag task status.'
    }
    catch {
        Write-Log -Level 'WARN' -Message ("Unable to read ScheduledDefrag task status: {0}" -f $_.Exception.Message)
    }

    # Try Defrag operational log first.
    try {
        $evt = Get-WinEvent -FilterHashtable @{ LogName='Microsoft-Windows-Defrag/Operational' } -MaxEvents 1 -ErrorAction Stop
        if ($evt) {
            $status.LastOptimizeEventTime = $evt.TimeCreated
            $status.LastOptimizeEventId = $evt.Id
            $status.LastOptimizeEventSource = $evt.ProviderName
            Write-Log -Message 'Retrieved last optimization event from Microsoft-Windows-Defrag/Operational.'
        }
    }
    catch {
        Write-Log -Level 'WARN' -Message ("Unable to read Defrag operational log: {0}" -f $_.Exception.Message)
    }

    # Fallback to Application log source Defrag if operational log not available.
    if (-not $status.LastOptimizeEventTime) {
        try {
            $evt2 = Get-WinEvent -FilterHashtable @{ LogName='Application'; ProviderName='Defrag' } -MaxEvents 1 -ErrorAction Stop
            if ($evt2) {
                $status.LastOptimizeEventTime = $evt2.TimeCreated
                $status.LastOptimizeEventId = $evt2.Id
                $status.LastOptimizeEventSource = $evt2.ProviderName
                Write-Log -Message 'Retrieved last optimization event from Application/Defrag.'
            }
        }
        catch {
            Write-Log -Level 'WARN' -Message ("Unable to read Application Defrag events: {0}" -f $_.Exception.Message)
        }
    }

    return [pscustomobject]$status
}

# Section: Physical disk inventory collector.
# Uses Storage cmdlets with WMI/CIM fallback to capture model/media/health information.
function Get-PhysicalDiskMap {
    $map = @{}

    try {
        $physical = Get-PhysicalDisk -ErrorAction Stop
        foreach ($p in $physical) {
            try {
                $key = [string]$p.FriendlyName
                $map[$key] = [pscustomobject]@{
                    Model             = [string]$p.FriendlyName
                    MediaType         = [string]$p.MediaType
                    SerialNumber      = [string]$p.SerialNumber
                    OperationalStatus = ([string[]]$p.OperationalStatus) -join ','
                    HealthStatus      = [string]$p.HealthStatus
                }
            }
            catch {
                Write-Log -Level 'WARN' -Message ("Failed to process physical disk record: {0}" -f $_.Exception.Message)
            }
        }
        Write-Log -Message 'Physical disk data collected using Get-PhysicalDisk.'
    }
    catch {
        Write-Log -Level 'WARN' -Message ("Get-PhysicalDisk unavailable or failed; using CIM fallback. Reason: {0}" -f $_.Exception.Message)

        try {
            $cimDisks = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction Stop
            foreach ($d in $cimDisks) {
                try {
                    $mediaType = if ($d.MediaType) { [string]$d.MediaType } else { 'Unknown' }
                    $health = if ($d.Status) { [string]$d.Status } else { 'Unknown' }
                    $op = if ($d.Status) { [string]$d.Status } else { 'Unknown' }
                    $key2 = [string]$d.Model

                    $map[$key2] = [pscustomobject]@{
                        Model             = [string]$d.Model
                        MediaType         = $mediaType
                        SerialNumber      = [string]$d.SerialNumber
                        OperationalStatus = $op
                        HealthStatus      = $health
                    }
                }
                catch {
                    Write-Log -Level 'WARN' -Message ("Failed to process Win32_DiskDrive record: {0}" -f $_.Exception.Message)
                }
            }
            Write-Log -Message 'Physical disk data collected using Win32_DiskDrive fallback.'
        }
        catch {
            Write-Log -Level 'ERROR' -Message ("Failed to collect physical disk data via fallback: {0}" -f $_.Exception.Message)
        }
    }

    return $map
}

# Section: Volume-to-physical correlation helper.
# Attempts to map logical drive letter to physical model via partition and disk number.
function Get-PhysicalModelForDriveLetter {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DriveLetter
    )

    try {
        $partition = Get-Partition -DriveLetter $DriveLetter -ErrorAction Stop
        if (-not $partition) {
            return $null
        }

        $disk = Get-Disk -Number $partition.DiskNumber -ErrorAction Stop
        if (-not $disk) {
            return $null
        }

        if ($disk.FriendlyName) {
            return [string]$disk.FriendlyName
        }

        return [string]$disk.Model
    }
    catch {
        Write-Log -Level 'WARN' -Message ("Could not map drive {0}: to physical model. Reason: {1}" -f $DriveLetter, $_.Exception.Message)
        return $null
    }
}

# Section: Severity classifier.
# Flags warnings/critical conditions from free space and health status values.
function Get-DiskSeverity {
    param(
        [Parameter(Mandatory = $true)]
        [double]$FreePercent,
        [Parameter(Mandatory = $true)]
        [string]$HealthStatus
    )

    $h = if ([string]::IsNullOrWhiteSpace($HealthStatus)) { 'Unknown' } else { $HealthStatus }

    if ($FreePercent -lt 5 -or $h -match 'Unhealthy|Failed|Error|Unknown') {
        return 'Critical'
    }

    if ($FreePercent -lt $LowFreeSpacePercentThreshold -or $h -match 'Warning|Degraded') {
        return 'Warning'
    }

    return 'Healthy'
}

# Section: Gather volume inventory and build report dataset.
# Reads volume capacity/usage metrics and enriches with physical and optimization metadata.
$optimization = Get-OptimizationStatusData
$physicalMap = Get-PhysicalDiskMap
$reportRows = New-Object System.Collections.Generic.List[object]

try {
    $volumes = Get-Volume -ErrorAction Stop | Where-Object { $_.DriveLetter -ne $null -and $_.Size -gt 0 }
    Write-Log -Message ("Discovered {0} mounted volumes with drive letters." -f ($volumes.Count))
}
catch {
    Write-Log -Level 'ERROR' -Message ("Unable to enumerate volumes: {0}" -f $_.Exception.Message)
    $volumes = @()
}

if ($DriveLetters -and $DriveLetters.Count -gt 0) {
    $normalized = @($DriveLetters | ForEach-Object { $_.TrimEnd(':').ToUpperInvariant() })
    $volumes = @($volumes | Where-Object { $normalized -contains $_.DriveLetter.ToUpperInvariant() })
    Write-Log -Message ("Applied DriveLetters filter: {0}" -f ($normalized -join ', '))
}

foreach ($v in $volumes) {
    # Per-disk query block with try/catch so one volume failure does not stop execution.
    try {
        $drive = [string]$v.DriveLetter
        $label = [string]$v.FileSystemLabel
        $fs = [string]$v.FileSystem
        $size = [double]$v.Size
        $free = [double]$v.SizeRemaining
        $used = $size - $free
        $freePct = if ($size -gt 0) { [math]::Round(($free / $size) * 100, 2) } else { 0 }

        if ($freePct -lt $summary.LowestFreeSpacePercent) {
            $summary.LowestFreeSpacePercent = $freePct
            $summary.LowestFreeSpaceDrive = $drive
        }

        $physicalModel = Get-PhysicalModelForDriveLetter -DriveLetter $drive
        $physicalInfo = $null
        if ($physicalModel -and $physicalMap.ContainsKey($physicalModel)) {
            $physicalInfo = $physicalMap[$physicalModel]
        }
        elseif ($physicalMap.Count -gt 0) {
            $physicalInfo = $null
        }

        $model = if ($physicalInfo) { $physicalInfo.Model } else { $physicalModel }
        $mediaType = if ($physicalInfo) { $physicalInfo.MediaType } else { 'Unknown' }
        $serial = if ($physicalInfo) { $physicalInfo.SerialNumber } else { '' }
        $operational = if ($physicalInfo) { $physicalInfo.OperationalStatus } else { 'Unknown' }
        $health = if ($physicalInfo) { $physicalInfo.HealthStatus } else { 'Unknown' }

        $severity = Get-DiskSeverity -FreePercent $freePct -HealthStatus $health
        switch ($severity) {
            'Healthy' { $summary.HealthyDisks++ }
            'Warning' { $summary.WarningDisks++ }
            'Critical' { $summary.CriticalDisks++ }
        }

        $highlightReason = @()
        if ($freePct -lt $LowFreeSpacePercentThreshold) {
            $highlightReason += ("Low free space ({0}%)" -f $freePct)
        }
        if ($health -match 'Warning|Degraded|Unknown|Unhealthy|Failed|Error') {
            $highlightReason += ("Health status={0}" -f $health)
        }

        $row = [pscustomobject]@{
            DriveLetter               = "$drive:"
            VolumeLabel               = $label
            FileSystem                = $fs
            TotalCapacityGB           = [math]::Round($size / 1GB, 2)
            UsedSpaceGB               = [math]::Round($used / 1GB, 2)
            FreeSpaceGB               = [math]::Round($free / 1GB, 2)
            FreeSpacePercent          = $freePct
            PhysicalModel             = $model
            MediaType                 = $mediaType
            SerialNumber              = $serial
            OperationalStatus         = $operational
            HealthStatus              = $health
            OptimizationTaskState     = $optimization.ScheduledTaskState
            LastOptimizationDate      = $optimization.LastOptimizeEventTime
            LastMaintenanceRunDate    = $optimization.ScheduledTaskLastRun
            Highlight                 = if ($highlightReason.Count -gt 0) { $highlightReason -join '; ' } else { '' }
            Severity                  = $severity
            ReadOnlySafetyNote        = 'Read-only report only; no remediation actions were executed.'
        }

        $reportRows.Add($row) | Out-Null
        $summary.TotalDisksDetected++
        Write-Log -Message ("Processed drive {0}: Free={1}% Health={2} Severity={3}" -f $row.DriveLetter, $row.FreeSpacePercent, $row.HealthStatus, $row.Severity)
    }
    catch {
        Write-Log -Level 'ERROR' -Message ("Failed processing volume {0}: {1}" -f $v.DriveLetter, $_.Exception.Message)
        continue
    }
}

if ($summary.TotalDisksDetected -eq 0) {
    $summary.LowestFreeSpacePercent = 0
}

# Section: Console report output.
# Displays key disk findings in console for immediate operator use.
try {
    $reportRows |
        Sort-Object -Property DriveLetter |
        Select-Object DriveLetter, VolumeLabel, FileSystem, TotalCapacityGB, UsedSpaceGB, FreeSpaceGB, FreeSpacePercent, MediaType, HealthStatus, Severity, Highlight |
        Format-Table -AutoSize
}
catch {
    Write-Log -Level 'WARN' -Message ("Console rendering failed: {0}" -f $_.Exception.Message)
}

# Section: CSV export.
# Writes machine-readable report for further analysis and ticket attachment.
try {
    $reportRows | Export-Csv -LiteralPath $csvReport -NoTypeInformation -Encoding UTF8
    Write-Log -Message ("CSV report exported: {0}" -f $csvReport)
}
catch {
    Write-Log -Level 'ERROR' -Message ("CSV export failed: {0}" -f $_.Exception.Message)
}

# Section: HTML export.
# Writes a styled human-readable report for stakeholder sharing.
try {
    $style = @"
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 16px; }
h1 { color: #1f4e79; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #d0d0d0; padding: 6px; text-align: left; }
th { background-color: #f1f5fb; }
tr:nth-child(even) { background-color: #fafafa; }
</style>
"@

    $pre = @(
        '<h1>DWP Disk Health Reporter</h1>',
        ("<p><strong>Generated:</strong> {0}</p>" -f (Get-Date)),
        '<p><strong>Read-only:</strong> No optimization or remediation action was executed.</p>'
    ) -join "`n"

    $reportRows |
        Select-Object DriveLetter, VolumeLabel, FileSystem, TotalCapacityGB, UsedSpaceGB, FreeSpaceGB, FreeSpacePercent, PhysicalModel, MediaType, SerialNumber, OperationalStatus, HealthStatus, OptimizationTaskState, LastOptimizationDate, LastMaintenanceRunDate, Highlight, Severity |
        ConvertTo-Html -Head $style -PreContent $pre |
        Out-File -LiteralPath $htmlReport -Encoding UTF8

    Write-Log -Message ("HTML report exported: {0}" -f $htmlReport)
}
catch {
    Write-Log -Level 'ERROR' -Message ("HTML export failed: {0}" -f $_.Exception.Message)
}

# Section: Final summary.
# Prints run totals including healthy/warning/critical counts and lowest free-space drive.
$summary.EndTime = Get-Date
$summary.DurationSeconds = [math]::Round((New-TimeSpan -Start $summary.StartTime -End $summary.EndTime).TotalSeconds, 2)

Write-Host "`n==================== Disk Health Summary ===================="
$summaryLines = @(
    ("TotalDisksDetected: {0}" -f $summary.TotalDisksDetected),
    ("HealthyDisks: {0}" -f $summary.HealthyDisks),
    ("WarningDisks: {0}" -f $summary.WarningDisks),
    ("CriticalDisks: {0}" -f $summary.CriticalDisks),
    ("LowestFreeSpacePercent: {0}" -f $summary.LowestFreeSpacePercent),
    ("LowestFreeSpaceDrive: {0}" -f $summary.LowestFreeSpaceDrive),
    ("DurationSeconds: {0}" -f $summary.DurationSeconds),
    ("LogFile: {0}" -f $summary.LogFile),
    ("CsvReport: {0}" -f $summary.CsvReport),
    ("HtmlReport: {0}" -f $summary.HtmlReport)
)

foreach ($line in $summaryLines) {
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line
}
Write-Host "============================================================="

# Section: Explicit safety completion statement.
# Reiterates no endpoint modifications were made during execution.
Write-Log -Message 'Read-only execution complete. No disk optimization, repair, or configuration changes were performed.'
