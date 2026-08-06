<#
DWP Endpoint Health Report (Read-Only)
PowerShell Version: 5.1

Purpose:
- Collect endpoint health signals without changing system state.
- Output human-readable sections for service-desk triage.

Read-only guarantee:
- This script only reads system information, registry values, services, logs,
  and network responses.
- It does not write files, change settings, start/stop services, or install anything.
#>

# ------------------------------
# Pre-run verification items
# ------------------------------
# VERIFY BEFORE RUNNING:
# 1) Run context: Some data (certain event logs / process details) may require elevated PowerShell.
# 2) Internet speed section: Uses an external HTTPS test file URL. Confirm outbound access is allowed.
# 3) Defender section: On non-Defender-managed devices, service names may differ (to confirm).

$ErrorActionPreference = 'Stop'

# Helper to render section headers consistently.
function Write-SectionHeader {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )
    Write-Host "`n==================== $Title ===================="
}

# ------------------------------
# Section: System uptime
# Reads OS last boot time and computes uptime duration.
# ------------------------------
Write-SectionHeader -Title 'System Uptime'
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $lastBoot = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
    $uptime = (Get-Date) - $lastBoot

    [pscustomobject]@{
        LastBootTime = $lastBoot
        UptimeDays   = [math]::Floor($uptime.TotalDays)
        UptimeHours  = $uptime.Hours
        UptimeMins   = $uptime.Minutes
    } | Format-List
}
catch {
    Write-Warning "Unable to retrieve uptime: $($_.Exception.Message)"
}

# ------------------------------
# Section: Free disk space
# Reads logical disk usage for local fixed drives.
# ------------------------------
Write-SectionHeader -Title 'Free Disk Space'
try {
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
                      @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 2)}},
                      @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
                      @{Name='FreePercent';Expression={ if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 2) } else { $null } }} |
        Format-Table -AutoSize
}
catch {
    Write-Warning "Unable to retrieve disk space: $($_.Exception.Message)"
}

# ------------------------------
# Section: Pending reboot status
# Reads known registry indicators that signal reboot pending state.
# ------------------------------
Write-SectionHeader -Title 'Pending Reboot Check'
try {
    $pendingReasons = @()

    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') {
        $pendingReasons += 'CBS: RebootPending key exists'
    }

    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') {
        $pendingReasons += 'WindowsUpdate: RebootRequired key exists'
    }

    $sessionMgrPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
    $pendingRename = (Get-ItemProperty -Path $sessionMgrPath -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue).PendingFileRenameOperations
    if ($pendingRename) {
        $pendingReasons += 'Session Manager: PendingFileRenameOperations present'
    }

    $ccmPath = 'HKLM:\SOFTWARE\Microsoft\CCM\ClientSDK'
    $ccmValue = (Get-ItemProperty -Path $ccmPath -Name 'PendingReboot' -ErrorAction SilentlyContinue).PendingReboot
    if ($ccmValue -eq $true) {
        $pendingReasons += 'ConfigMgr ClientSDK: PendingReboot=True'
    }

    [pscustomobject]@{
        IsRebootPending = ($pendingReasons.Count -gt 0)
        Evidence        = if ($pendingReasons.Count -gt 0) { $pendingReasons -join '; ' } else { 'No known reboot-pending markers found' }
    } | Format-List
}
catch {
    Write-Warning "Unable to complete pending reboot check: $($_.Exception.Message)"
}

# ------------------------------
# Section: Top 5 processes by memory (Working Set)
# Reads running process working set and reports top memory consumers.
# ------------------------------
Write-SectionHeader -Title 'Top 5 Processes by Memory (Working Set)'
try {
    Get-Process |
        Sort-Object -Property WorkingSet64 -Descending |
        Select-Object -First 5 ProcessName, Id,
                      @{Name='WorkingSetMB';Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)}} |
        Format-Table -AutoSize
}
catch {
    Write-Warning "Unable to retrieve top memory processes: $($_.Exception.Message)"
}

# ------------------------------
# Section: Top 5 processes by CPU
# Reads cumulative CPU time consumed by running processes.
# ------------------------------
Write-SectionHeader -Title 'Top 5 Processes by CPU (Cumulative)'
try {
    Get-Process |
        Sort-Object -Property CPU -Descending |
        Select-Object -First 5 ProcessName, Id,
                      @{Name='CPUSeconds';Expression={ if ($_.CPU -ne $null) { [math]::Round($_.CPU, 2) } else { 0 } }} |
        Format-Table -AutoSize
}
catch {
    Write-Warning "Unable to retrieve top CPU processes: $($_.Exception.Message)"
}

# ------------------------------
# Section: Last 5 system log errors
# Reads newest error-level entries from the System event log.
# ------------------------------
Write-SectionHeader -Title 'Last 5 System Log Errors'
try {
    Get-WinEvent -FilterHashtable @{LogName='System'; Level=2} -MaxEvents 5 |
        Select-Object TimeCreated, Id, ProviderName, Message |
        Format-List
}
catch {
    Write-Warning "Unable to read System log errors: $($_.Exception.Message)"
}

# ------------------------------
# Section: Internet speed
# Performs a simple download-throughput estimate by reading a small public test file into memory.
# ------------------------------
Write-SectionHeader -Title 'Internet Speed (Estimated Download Throughput)'
# VERIFY: External URL access must be permitted in your environment.
# Some environments block specific hosts; use fallback URLs to avoid single-point failure.
$speedTestUrls = @(
    'https://speed.hetzner.de/1MB.bin',
    'https://proof.ovh.net/files/1Mb.dat',
    'https://ipv4.download.thinkbroadband.com/1MB.zip'
)

$speedResult = $null
foreach ($testUrl in $speedTestUrls) {
    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 30
        $sw.Stop()

        $bytes = 0
        if ($response.RawContentStream -and $response.RawContentStream.Length -gt 0) {
            $bytes = [double]$response.RawContentStream.Length
        }
        elseif ($response.Content) {
            $bytes = [double]([Text.Encoding]::UTF8.GetByteCount($response.Content))
        }

        if ($bytes -gt 0 -and $sw.Elapsed.TotalSeconds -gt 0) {
            $mbps = [math]::Round((($bytes * 8) / 1MB) / $sw.Elapsed.TotalSeconds, 2)
            $speedResult = [pscustomobject]@{
                TestUrl            = $testUrl
                DownloadedBytes    = [int64]$bytes
                ElapsedSeconds     = [math]::Round($sw.Elapsed.TotalSeconds, 2)
                EstimatedSpeedMbps = $mbps
                Note               = 'Single-sample estimate (to confirm with enterprise-approved speed test if needed)'
            }
            break
        }
        else {
            Write-Warning "Internet speed test returned no measurable payload from: $testUrl"
        }
    }
    catch {
        Write-Warning "Speed test endpoint failed ($testUrl): $($_.Exception.Message)"
    }
}

if ($speedResult) {
    $speedResult | Format-List
}
else {
    Write-Warning 'Unable to estimate internet speed: all speed test endpoints failed. Check DNS, proxy, or outbound web filtering policies.'
}

# ------------------------------
# Section: Microsoft Defender service status
# Reads service state for Defender-related service(s).
# ------------------------------
Write-SectionHeader -Title 'Microsoft Defender Service Status'
# VERIFY: Service names can vary by security stack and policy (to confirm).
try {
    $defenderServices = @('WinDefend', 'WdNisSvc')
    Get-Service -Name $defenderServices -ErrorAction SilentlyContinue |
        Select-Object Name, DisplayName, Status, StartType |
        Format-Table -AutoSize

    if (-not (Get-Service -Name $defenderServices -ErrorAction SilentlyContinue)) {
        Write-Warning 'No expected Defender services found. Confirm endpoint security stack (to confirm).'
    }
}
catch {
    Write-Warning "Unable to read Defender service status: $($_.Exception.Message)"
}

# ------------------------------
# Section: Logged-in user count
# Reads current session list and counts distinct usernames.
# ------------------------------
Write-SectionHeader -Title 'Logged-in User Count'
try {
    $sessionOutput = quser 2>$null
    if ($LASTEXITCODE -eq 0 -and $sessionOutput) {
        $users = @()
        foreach ($line in $sessionOutput | Select-Object -Skip 1) {
            $trimmed = ($line -replace '^\s*>?', '').Trim()
            if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
            $username = ($trimmed -split '\s+')[0]
            if (-not [string]::IsNullOrWhiteSpace($username)) {
                $users += $username
            }
        }

        $distinctUsers = $users | Sort-Object -Unique
        [pscustomobject]@{
            LoggedInUserCount = $distinctUsers.Count
            Users             = if ($distinctUsers.Count -gt 0) { $distinctUsers -join ', ' } else { 'None detected' }
        } | Format-List
    }
    else {
        Write-Warning 'Unable to query user sessions via quser. Run in an interactive user context (to confirm).'
    }
}
catch {
    Write-Warning "Unable to determine logged-in users: $($_.Exception.Message)"
}

# ------------------------------
# Section: Last Windows update time
# Reads installed update history from hotfix records and reports most recent install date.
# ------------------------------
Write-SectionHeader -Title 'Last Windows Update Installed'
try {
    $lastUpdate = Get-HotFix |
        Where-Object { $_.InstalledOn -and $_.InstalledOn -ne [datetime]::MinValue } |
        Sort-Object -Property InstalledOn -Descending |
        Select-Object -First 1

    if ($lastUpdate) {
        [pscustomobject]@{
            LastUpdateDate = $lastUpdate.InstalledOn
            HotFixId       = $lastUpdate.HotFixID
            Description    = $lastUpdate.Description
        } | Format-List
    }
    else {
        Write-Warning 'No installed update date found via Get-HotFix (to confirm).' 
    }
}
catch {
    Write-Warning "Unable to retrieve last Windows update info: $($_.Exception.Message)"
}

Write-Host "`nReport completed."
