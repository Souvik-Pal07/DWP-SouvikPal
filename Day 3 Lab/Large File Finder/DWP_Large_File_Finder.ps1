<#
DWP Large File Finder (Read-Only)
PowerShell Version: 5.1

Purpose:
- Identify files larger than a configurable threshold.
- Provide operational reports for endpoint storage triage.

Strict read-only guarantee:
- This script only reads file system metadata and ACL owner information.
- It never deletes, moves, modifies, renames, compresses, or archives files.
#>

[CmdletBinding()]
param(
    # Size threshold in MB. Files at or above this value are included in the report.
    [ValidateRange(1, 1048576)]
    [int]$SizeThresholdMB = 100,

    # Root path to scan. Examples: C:\, C:\Users, D:\Data
    [ValidateNotNullOrEmpty()]
    [string]$TargetPath = 'C:\',

    # Include protected system folders that are excluded by default.
    [switch]$IncludeProtectedSystemFolders,

    # Optional output root folder for logs and reports.
    [string]$OutputRoot = (Join-Path -Path $PSScriptRoot -ChildPath 'LargeFileFinderOutput')
)

$ErrorActionPreference = 'Stop'

# Section: Initialize run metadata, output paths, and summary counters.
# Creates timestamped log/report paths and counters for final summary.
$runStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$scriptName = 'DWP_Large_File_Finder'

$logRoot = Join-Path -Path $OutputRoot -ChildPath 'Logs'
$reportRoot = Join-Path -Path $OutputRoot -ChildPath 'Reports'

foreach ($folder in @($OutputRoot, $logRoot, $reportRoot)) {
    if (-not (Test-Path -LiteralPath $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
    }
}

$logFile = Join-Path -Path $logRoot -ChildPath ("{0}_{1}.log" -f $scriptName, $runStamp)
$csvReport = Join-Path -Path $reportRoot -ChildPath ("LargeFiles_{0}.csv" -f $runStamp)
$txtReport = Join-Path -Path $reportRoot -ChildPath ("LargeFiles_{0}.txt" -f $runStamp)
$htmlReport = Join-Path -Path $reportRoot -ChildPath ("LargeFiles_{0}.html" -f $runStamp)

$thresholdBytes = [int64]$SizeThresholdMB * 1MB

$summary = [ordered]@{
    TargetPath                   = $TargetPath
    IncludeProtectedSystemFolder = [bool]$IncludeProtectedSystemFolders
    ThresholdMB                  = $SizeThresholdMB
    TotalFilesScanned            = 0
    TotalLargeFilesFound         = 0
    TotalLargeFileBytes          = [int64]0
    InaccessibleFolderCount      = 0
    StartTime                    = Get-Date
    EndTime                      = $null
    DurationSeconds              = $null
    LogFile                      = $logFile
    CsvReport                    = $csvReport
    TxtReport                    = $txtReport
    HtmlReport                   = $htmlReport
}

# Section: Logging helper.
# Logs every action, warning, skipped folder, and error to console and log file.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet('INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[{0}] [{1}] {2}" -f $timestamp, $Level, $Message
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line
}

# Section: Protected folder matcher.
# Excludes common protected paths by default to reduce noise and access failures.
function Test-IsProtectedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathToCheck
    )

    try {
        $normalized = [System.IO.Path]::GetFullPath($PathToCheck)
    }
    catch {
        return $false
    }

    $protectedRoots = @(
        "$env:SystemRoot\WinSxS",
        "$env:SystemRoot\System32\DriverStore",
        "$env:SystemRoot\System32\config",
        "$env:ProgramData\Microsoft\Windows\WER",
        "$env:SystemDrive\`$Recycle.Bin",
        "$env:SystemDrive\System Volume Information"
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($pr in $protectedRoots) {
        try {
            $prFull = [System.IO.Path]::GetFullPath($pr)
            if ($normalized.StartsWith($prFull, [System.StringComparison]::OrdinalIgnoreCase)) {
                return $true
            }
        }
        catch {
            continue
        }
    }

    return $false
}

# Section: File owner resolver.
# Retrieves owner using Get-Acl and returns blank when unavailable.
function Get-FileOwner {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        $acl = Get-Acl -LiteralPath $FilePath -ErrorAction Stop
        return $acl.Owner
    }
    catch {
        Write-Log -Level 'WARN' -Message ("Owner lookup failed for file: {0}. Reason: {1}" -f $FilePath, $_.Exception.Message)
        return ''
    }
}

# Section: Main scan function.
# Recursively walks accessible folders, evaluates files by threshold, and tracks progress.
function Invoke-LargeFileScan {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath
    )

    $folderQueue = New-Object System.Collections.Generic.Queue[string]
    $folderQueue.Enqueue($RootPath)

    $processedFolders = 0
    $visitedFolders = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $resultRows = New-Object System.Collections.Generic.List[object]

    while ($folderQueue.Count -gt 0) {
        $currentFolder = $folderQueue.Dequeue()
        if ([string]::IsNullOrWhiteSpace($currentFolder)) { continue }

        if ($visitedFolders.Contains($currentFolder)) {
            continue
        }
        $visitedFolders.Add($currentFolder) | Out-Null
        $processedFolders++

        # Progress display for long-running scans.
        $progressMsg = "Scanning folder #{0}: {1}" -f $processedFolders, $currentFolder
        Write-Progress -Activity 'DWP Large File Finder' -Status $progressMsg -PercentComplete -1

        if (-not $IncludeProtectedSystemFolders -and (Test-IsProtectedPath -PathToCheck $currentFolder)) {
            Write-Log -Level 'WARN' -Message ("Skipped protected folder: {0}" -f $currentFolder)
            continue
        }

        # Enumerate subfolders with try/catch to continue gracefully on access errors.
        try {
            $subfolders = Get-ChildItem -LiteralPath $currentFolder -Directory -Force -ErrorAction Stop
            foreach ($sf in $subfolders) {
                if (-not $IncludeProtectedSystemFolders -and (Test-IsProtectedPath -PathToCheck $sf.FullName)) {
                    Write-Log -Level 'WARN' -Message ("Skipped protected subfolder: {0}" -f $sf.FullName)
                    continue
                }
                $folderQueue.Enqueue($sf.FullName)
            }
        }
        catch {
            $summary.InaccessibleFolderCount++
            Write-Log -Level 'WARN' -Message ("Inaccessible folder skipped: {0}. Reason: {1}" -f $currentFolder, $_.Exception.Message)
            continue
        }

        # Enumerate files with try/catch to continue gracefully on per-folder failures.
        try {
            $files = Get-ChildItem -LiteralPath $currentFolder -File -Force -ErrorAction Stop
            foreach ($file in $files) {
                $summary.TotalFilesScanned++

                # Per-file checks are wrapped so one failing file does not stop the scan.
                try {
                    if ($file.Length -ge $thresholdBytes) {
                        $owner = Get-FileOwner -FilePath $file.FullName

                        $row = [pscustomobject]@{
                            FileName          = $file.Name
                            FullPath          = $file.FullName
                            FileSizeMB        = [math]::Round($file.Length / 1MB, 2)
                            FileSizeGB        = [math]::Round($file.Length / 1GB, 4)
                            DateCreated       = $file.CreationTime
                            LastModifiedDate  = $file.LastWriteTime
                            FileOwner         = $owner
                        }

                        $resultRows.Add($row) | Out-Null
                        $summary.TotalLargeFilesFound++
                        $summary.TotalLargeFileBytes += [int64]$file.Length
                    }
                }
                catch {
                    Write-Log -Level 'ERROR' -Message ("File processing error: {0}. Reason: {1}" -f $file.FullName, $_.Exception.Message)
                    continue
                }
            }
        }
        catch {
            Write-Log -Level 'WARN' -Message ("Unable to enumerate files in folder: {0}. Reason: {1}" -f $currentFolder, $_.Exception.Message)
            continue
        }
    }

    Write-Progress -Activity 'DWP Large File Finder' -Completed -Status 'Scan complete.'

    return $resultRows
}

# Section: Input validation and startup logging.
# Confirms target path exists and announces read-only operation settings.
try {
    if (-not (Test-Path -LiteralPath $TargetPath)) {
        throw "Target path does not exist: $TargetPath"
    }

    $resolvedRoot = (Resolve-Path -LiteralPath $TargetPath).Path
    Write-Log -Message ("Read-only scan started. TargetPath={0}; ThresholdMB={1}; IncludeProtected={2}" -f $resolvedRoot, $SizeThresholdMB, [bool]$IncludeProtectedSystemFolders)
}
catch {
    Write-Log -Level 'ERROR' -Message ("Startup validation failed: {0}" -f $_.Exception.Message)
    throw
}

# Section: Execute scan and generate sorted report dataset.
# Produces descending size-ordered results for report export.
$results = Invoke-LargeFileScan -RootPath $resolvedRoot
$sortedResults = @($results | Sort-Object -Property FileSizeMB -Descending)

# Section: Export reports in CSV, TXT, and HTML formats.
# Writes all report formats for operational and stakeholder consumption.
try {
    $sortedResults | Export-Csv -LiteralPath $csvReport -NoTypeInformation -Encoding UTF8
    Write-Log -Message ("CSV report exported: {0}" -f $csvReport)
}
catch {
    Write-Log -Level 'ERROR' -Message ("Failed to export CSV report: {0}" -f $_.Exception.Message)
}

try {
    $txtLines = New-Object System.Collections.Generic.List[string]
    $txtLines.Add("DWP Large File Finder Report") | Out-Null
    $txtLines.Add(("Generated: {0}" -f (Get-Date))) | Out-Null
    $txtLines.Add(("Target Path: {0}" -f $resolvedRoot)) | Out-Null
    $txtLines.Add(("Threshold (MB): {0}" -f $SizeThresholdMB)) | Out-Null
    $txtLines.Add('') | Out-Null

    foreach ($r in $sortedResults) {
        $txtLines.Add(("File Name: {0}" -f $r.FileName)) | Out-Null
        $txtLines.Add(("Full Path: {0}" -f $r.FullPath)) | Out-Null
        $txtLines.Add(("File Size MB: {0}" -f $r.FileSizeMB)) | Out-Null
        $txtLines.Add(("File Size GB: {0}" -f $r.FileSizeGB)) | Out-Null
        $txtLines.Add(("Date Created: {0}" -f $r.DateCreated)) | Out-Null
        $txtLines.Add(("Last Modified: {0}" -f $r.LastModifiedDate)) | Out-Null
        $txtLines.Add(("File Owner: {0}" -f $r.FileOwner)) | Out-Null
        $txtLines.Add('------------------------------------------------------------') | Out-Null
    }

    $txtLines | Out-File -LiteralPath $txtReport -Encoding UTF8
    Write-Log -Message ("TXT report exported: {0}" -f $txtReport)
}
catch {
    Write-Log -Level 'ERROR' -Message ("Failed to export TXT report: {0}" -f $_.Exception.Message)
}

try {
    $htmlHeader = @"
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 16px; }
h1 { color: #1f4e79; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #d0d0d0; padding: 6px; text-align: left; }
th { background-color: #f3f6fa; }
tr:nth-child(even) { background-color: #fafafa; }
</style>
"@

    $preContent = @(
        "<h1>DWP Large File Finder Report</h1>",
        "<p><strong>Generated:</strong> $(Get-Date)</p>",
        "<p><strong>Target Path:</strong> $resolvedRoot</p>",
        "<p><strong>Threshold (MB):</strong> $SizeThresholdMB</p>"
    ) -join "`n"

    $sortedResults |
        ConvertTo-Html -Property FileName, FullPath, FileSizeMB, FileSizeGB, DateCreated, LastModifiedDate, FileOwner -Head $htmlHeader -PreContent $preContent |
        Out-File -LiteralPath $htmlReport -Encoding UTF8

    Write-Log -Message ("HTML report exported: {0}" -f $htmlReport)
}
catch {
    Write-Log -Level 'ERROR' -Message ("Failed to export HTML report: {0}" -f $_.Exception.Message)
}

# Section: Final summary output.
# Displays summary metrics and writes them to the log for auditability.
$summary.EndTime = Get-Date
$summary.DurationSeconds = [math]::Round((New-TimeSpan -Start $summary.StartTime -End $summary.EndTime).TotalSeconds, 2)

$totalLargeGB = [math]::Round($summary.TotalLargeFileBytes / 1GB, 4)

Write-Host "`n==================== Large File Finder Summary ===================="
$summaryLines = @(
    ("TargetPath: {0}" -f $summary.TargetPath),
    ("ThresholdMB: {0}" -f $summary.ThresholdMB),
    ("TotalFilesScanned: {0}" -f $summary.TotalFilesScanned),
    ("TotalLargeFilesFound: {0}" -f $summary.TotalLargeFilesFound),
    ("TotalStorageConsumedByMatchingFilesGB: {0}" -f $totalLargeGB),
    ("InaccessibleFolderCount: {0}" -f $summary.InaccessibleFolderCount),
    ("DurationSeconds: {0}" -f $summary.DurationSeconds),
    ("LogFile: {0}" -f $summary.LogFile),
    ("CsvReport: {0}" -f $summary.CsvReport),
    ("TxtReport: {0}" -f $summary.TxtReport),
    ("HtmlReport: {0}" -f $summary.HtmlReport)
)

foreach ($line in $summaryLines) {
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line
}
Write-Host "==================================================================="

# Section: Read-only completion marker.
# Explicitly states no changes were made to endpoint files.
Write-Log -Message 'Read-only scan completed successfully. No file system modifications were performed.'
