# ============================================================================
# PRODUCTION-SAFE EVIDENCE COLLECTION SCRIPT
# Intune Application Deployment - Login Performance Investigation
# ============================================================================
# Purpose: Collect forensic evidence about slow login performance following
#          recent Intune application deployment
# 
# SAFE FOR PRODUCTION: Read-only operations only. No changes to system.
# 
# Author: DWP Service Desk Team
# Date: 2026-08-14
# 
# USAGE:
#   .\Collect-LoginPerformanceEvidence.ps1
#   .\Collect-LoginPerformanceEvidence.ps1 -DryRun
#   .\Collect-LoginPerformanceEvidence.ps1 -OutputPath "C:\Evidence"
#   .\Collect-LoginPerformanceEvidence.ps1 -Rollback
# 
# PARAMETERS:
#   -DryRun          Show what would be collected without actually collecting
#   -OutputPath      Custom path for evidence export (default: C:\Temp\LoginEvidence)
#   -Rollback        Remove evidence files (cleanup)
#   -Verbose         Show detailed operation logs
# ============================================================================

param(
    [switch]$DryRun = $false,
    [switch]$Rollback = $false,
    [string]$OutputPath = "C:\Temp\LoginEvidence",
    [switch]$Verbose = $true
)

# ============================================================================
# CONFIGURATION SECTION
# ============================================================================

$scriptName = "Collect-LoginPerformanceEvidence.ps1"
$scriptVersion = "1.0"
$scriptStartTime = Get-Date

# Verify administrative privileges (needed for Event Viewer access)
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "[WARNING] Script running without administrative privileges."
    Write-Host "[WARNING] Some Event Log data may not be accessible."
    Write-Host "[WARNING] Recommend running as Administrator for full results."
    Write-Host ""
}

# ============================================================================
# FUNCTION: Write-Log
# Purpose: Output timestamped log messages
# ============================================================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Section = ""
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = "[$timestamp][$Level]"
    if ($Section) { $prefix += "[$Section]" }
    
    Write-Host "$prefix $Message"
}

# ============================================================================
# FUNCTION: New-EvidenceDirectory
# Purpose: Create output directory for evidence collection
# ============================================================================
function New-EvidenceDirectory {
    param(
        [string]$Path,
        [bool]$DryRunMode
    )
    
    if ($DryRunMode) {
        Write-Log "Would create directory: $Path" -Level "DRY-RUN" -Section "INIT"
        return $true
    }
    
    try {
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
            Write-Log "Created evidence directory: $Path" -Level "OK" -Section "INIT"
        } else {
            Write-Log "Directory already exists: $Path" -Level "OK" -Section "INIT"
        }
        return $true
    } catch {
        Write-Log "Failed to create directory: $_" -Level "ERROR" -Section "INIT"
        return $false
    }
}

# ============================================================================
# FUNCTION: Export-JSON
# Purpose: Export results to JSON file safely
# ============================================================================
function Export-JSON {
    param(
        [PSObject]$Data,
        [string]$FilePath,
        [bool]$DryRunMode
    )
    
    if ($DryRunMode) {
        Write-Log "Would export JSON to: $FilePath" -Level "DRY-RUN"
        return $true
    }
    
    try {
        $Data | ConvertTo-Json -Depth 15 | Out-File -FilePath $FilePath -Encoding UTF8 -Force
        Write-Log "Exported evidence to: $FilePath" -Level "OK" -Section "EXPORT"
        return $true
    } catch {
        Write-Log "Failed to export JSON: $_" -Level "ERROR" -Section "EXPORT"
        return $false
    }
}

# ============================================================================
# FUNCTION: Cleanup-Evidence
# Purpose: Remove collected evidence files (rollback)
# ============================================================================
function Cleanup-Evidence {
    param(
        [string]$Path
    )
    
    Write-Host ""
    Write-Log "Rollback: Removing evidence directory..." -Level "WARN" -Section "CLEANUP"
    
    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Log "Removed evidence directory: $Path" -Level "OK" -Section "CLEANUP"
        } else {
            Write-Log "Evidence directory not found: $Path" -Level "WARN" -Section "CLEANUP"
        }
        return $true
    } catch {
        Write-Log "Failed to remove evidence directory: $_" -Level "ERROR" -Section "CLEANUP"
        return $false
    }
}

# ============================================================================
# MAIN: HEADER AND INITIALIZATION
# ============================================================================

Write-Host ""
Write-Host "=============================================================="
Write-Host "EVIDENCE COLLECTION SCRIPT - Intune Deployment Investigation"
Write-Host "Script Version: $scriptVersion"
Write-Host "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Computer: $env:COMPUTERNAME"
Write-Host "User: $env:USERNAME"
Write-Host "Dry Run Mode: $DryRun"
Write-Host "Rollback Mode: $Rollback"
Write-Host "=============================================================="
Write-Host ""

# Handle rollback mode
if ($Rollback) {
    $result = Cleanup-Evidence -Path $OutputPath
    if ($result) {
        Write-Host "[ROLLBACK COMPLETE] Evidence files removed successfully."
    } else {
        Write-Host "[ROLLBACK FAILED] Some files may not have been removed."
    }
    exit 0
}

# Create output directory
$dirCreated = New-EvidenceDirectory -Path $OutputPath -DryRunMode $DryRun
if (-not $dirCreated -and -not $DryRun) {
    Write-Log "Cannot proceed without output directory" -Level "ERROR" -Section "INIT"
    exit 1
}

# Initialize results object
$evidenceData = @{
    CollectionMetadata = @{
        ScriptName = $scriptName
        ScriptVersion = $scriptVersion
        CollectionTime = Get-Date
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        UserDomain = $env:USERDOMAIN
        OSVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version
        SystemUptime = (Get-Uptime).ToString()
        IsRunningAsAdmin = $isAdmin
        DryRunMode = $DryRun
    }
    Sections = @{}
}

# ============================================================================
# SECTION 1: INTUNE APPLICATION DEPLOYMENT STATUS
# ============================================================================

Write-Log "Collecting Intune application deployment status..." -Section "INTUNE"
Write-Host ""

$intuneSection = @{
    CollectionTime = Get-Date
    Tests = @()
}

# Test 1.1: Check device enrollment
Write-Log "Test 1.1: Checking device Intune enrollment status..." -Section "INTUNE"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: HKLM:\Software\Microsoft\Enrollment"
    } else {
        $enrollmentPath = "HKLM:\Software\Microsoft\Enrollment"
        if (Test-Path $enrollmentPath) {
            $enrollment = Get-ItemProperty -Path $enrollmentPath -ErrorAction SilentlyContinue
            $enrollmentStatus = @{
                IsEnrolled = $true
                Path = $enrollmentPath
                HasMultipleEnrollments = (Get-ChildItem -Path $enrollmentPath -ErrorAction SilentlyContinue).Count -gt 1
            }
            Write-Log "Device is Intune-enrolled" -Level "OK" -Section "INTUNE"
        } else {
            $enrollmentStatus = @{
                IsEnrolled = $false
                Message = "Enrollment registry path not found"
            }
            Write-Log "No Intune enrollment found" -Level "WARN" -Section "INTUNE"
        }
    }
    
    $intuneSection.Tests += @{
        TestName = "Device Enrollment Status"
        Status = "Completed"
        Data = $enrollmentStatus
    }
} catch {
    Write-Log "Error checking enrollment: $_" -Level "ERROR" -Section "INTUNE"
    $intuneSection.Tests += @{
        TestName = "Device Enrollment Status"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 1.2: Check Intune management extension status
Write-Log "Test 1.2: Checking Intune Management Extension status..." -Section "INTUNE"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: HKLM:\Software\Microsoft\IntuneManagementExtension"
    } else {
        $imePath = "HKLM:\Software\Microsoft\IntuneManagementExtension"
        if (Test-Path $imePath) {
            $imeStatus = Get-ItemProperty -Path $imePath -ErrorAction SilentlyContinue
            $imeData = @{
                Installed = $true
                LastCheckInTime = if ($imeStatus.LastCheckInTime) { $imeStatus.LastCheckInTime } else { "Unknown" }
                Status = if ($imeStatus.Status) { $imeStatus.Status } else { "Unknown" }
            }
            Write-Log "Intune Management Extension found" -Level "OK" -Section "INTUNE"
        } else {
            $imeData = @{
                Installed = $false
                Message = "IME not found or not yet installed"
            }
            Write-Log "Intune Management Extension not found" -Level "WARN" -Section "INTUNE"
        }
    }
    
    $intuneSection.Tests += @{
        TestName = "Intune Management Extension"
        Status = "Completed"
        Data = $imeData
    }
} catch {
    Write-Log "Error checking IME: $_" -Level "ERROR" -Section "INTUNE"
    $intuneSection.Tests += @{
        TestName = "Intune Management Extension"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 1.3: Check for recent Intune policy application
Write-Log "Test 1.3: Checking recent Intune policy application..." -Section "INTUNE"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: Event logs for Intune policy events"
    } else {
        $policyEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            ID = @(1001, 1002)  # Policy application events
            StartTime = (Get-Date).AddDays(-3)
        } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 10
        
        $policyData = @{
            EventCount = $policyEvents.Count
            MostRecentEvent = if ($policyEvents.Count -gt 0) { $policyEvents[0].TimeCreated } else { "None" }
            Events = $policyEvents | Select-Object @{Name='TimeCreated';Expression={$_.TimeCreated}}, @{Name='EventID';Expression={$_.ID}} | ConvertTo-Json
        }
        Write-Log "Found $($policyEvents.Count) policy events in last 3 days" -Level "OK" -Section "INTUNE"
    }
    
    $intuneSection.Tests += @{
        TestName = "Recent Policy Application"
        Status = "Completed"
        Data = $policyData
    }
} catch {
    Write-Log "Error checking policy events: $_" -Level "ERROR" -Section "INTUNE"
    $intuneSection.Tests += @{
        TestName = "Recent Policy Application"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

$evidenceData.Sections["IntuneDeployment"] = $intuneSection

# ============================================================================
# SECTION 2: INTUNE ASSIGNED APPLICATIONS
# ============================================================================

Write-Log "Collecting Intune assigned applications..." -Section "APPS"
Write-Host ""

$appsSection = @{
    CollectionTime = Get-Date
    Tests = @()
}

# Test 2.1: Get installed applications
Write-Log "Test 2.1: Querying installed applications..." -Section "APPS"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would query: Registry for installed applications (64-bit and 32-bit)"
    } else {
        $installedApps = @()
        
        # Query 64-bit registry
        $regPath64 = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
        if (Test-Path $regPath64) {
            $apps64 = Get-ChildItem -Path $regPath64 -ErrorAction SilentlyContinue | 
                      ForEach-Object { Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue } |
                      Where-Object { $_.DisplayName -ne $null } |
                      Select-Object DisplayName, DisplayVersion, InstallDate, Publisher
            $installedApps += $apps64
        }
        
        # Query 32-bit registry
        $regPath32 = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        if (Test-Path $regPath32) {
            $apps32 = Get-ChildItem -Path $regPath32 -ErrorAction SilentlyContinue | 
                      ForEach-Object { Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue } |
                      Where-Object { $_.DisplayName -ne $null } |
                      Select-Object DisplayName, DisplayVersion, InstallDate, Publisher
            $installedApps += $apps32
        }
        
        # Remove duplicates
        $installedApps = $installedApps | Sort-Object DisplayName -Unique
        
        Write-Log "Found $($installedApps.Count) installed applications" -Level "OK" -Section "APPS"
        
        $appData = @{
            TotalApplications = $installedApps.Count
            Applications = @($installedApps | Select-Object DisplayName, DisplayVersion, Publisher)
        }
    }
    
    $appsSection.Tests += @{
        TestName = "Installed Applications"
        Status = "Completed"
        Data = $appData
    }
} catch {
    Write-Log "Error querying applications: $_" -Level "ERROR" -Section "APPS"
    $appsSection.Tests += @{
        TestName = "Installed Applications"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 2.2: Check for recently installed applications
Write-Log "Test 2.2: Checking for recently installed applications..." -Section "APPS"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: Applications installed in last 7 days"
    } else {
        $recentDate = (Get-Date).AddDays(-7)
        
        $recentApps = $installedApps | Where-Object {
            if ($_.InstallDate) {
                try {
                    $installDate = [datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null)
                    $installDate -ge $recentDate
                } catch {
                    $false
                }
            } else {
                $false
            }
        }
        
        $recentAppData = @{
            RecentApplicationCount = $recentApps.Count
            Applications = @($recentApps | Select-Object DisplayName, DisplayVersion, InstallDate, Publisher)
        }
        
        Write-Log "Found $($recentApps.Count) applications installed in last 7 days" -Level "OK" -Section "APPS"
    }
    
    $appsSection.Tests += @{
        TestName = "Recently Installed Applications"
        Status = "Completed"
        Data = $recentAppData
    }
} catch {
    Write-Log "Error checking recent installations: $_" -Level "ERROR" -Section "APPS"
    $appsSection.Tests += @{
        TestName = "Recently Installed Applications"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 2.3: Check application startup entries
Write-Log "Test 2.3: Checking application startup entries..." -Section "APPS"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: Registry and file system for startup entries"
    } else {
        $startupApps = @()
        
        # Check registry Run key
        $runPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
        if (Test-Path $runPath) {
            $runApps = Get-ItemProperty -Path $runPath -ErrorAction SilentlyContinue
            if ($runApps) {
                foreach ($prop in $runApps.PSObject.Properties) {
                    if ($prop.Name -notmatch "PSPath|PSParentPath|PSChildName|PSDrive|PSProvider") {
                        $startupApps += @{
                            Name = $prop.Name
                            Path = $prop.Value
                            Type = "Registry (Run)"
                        }
                    }
                }
            }
        }
        
        # Check Startup folder
        $startupFolder = "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        if (Test-Path $startupFolder) {
            $startupItems = Get-ChildItem -Path $startupFolder -ErrorAction SilentlyContinue
            foreach ($item in $startupItems) {
                $startupApps += @{
                    Name = $item.Name
                    Path = $item.FullName
                    Type = "File (Startup Folder)"
                }
            }
        }
        
        $startupData = @{
            StartupApplicationCount = $startupApps.Count
            Applications = @($startupApps)
        }
        
        Write-Log "Found $($startupApps.Count) startup applications" -Level "OK" -Section "APPS"
    }
    
    $appsSection.Tests += @{
        TestName = "Startup Applications"
        Status = "Completed"
        Data = $startupData
    }
} catch {
    Write-Log "Error checking startup applications: $_" -Level "ERROR" -Section "APPS"
    $appsSection.Tests += @{
        TestName = "Startup Applications"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

$evidenceData.Sections["Applications"] = $appsSection

# ============================================================================
# SECTION 3: EVENT VIEWER LOGS
# ============================================================================

Write-Log "Collecting Event Viewer logs..." -Section "EVENTS"
Write-Host ""

$eventSection = @{
    CollectionTime = Get-Date
    Tests = @()
}

# Test 3.1: System event logs
Write-Log "Test 3.1: Collecting System event logs..." -Section "EVENTS"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would collect: System event log entries from last 3 days"
    } else {
        $systemEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            Level = @(1, 2)  # Critical, Error
            StartTime = (Get-Date).AddDays(-3)
        } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 50
        
        $systemEventData = @{
            EventCount = $systemEvents.Count
            Events = $systemEvents | Select-Object @{Name='TimeCreated';Expression={$_.TimeCreated}}, 
                                                    @{Name='Level';Expression={$_.LevelDisplayName}}, 
                                                    @{Name='Source';Expression={$_.ProviderName}}, 
                                                    @{Name='EventID';Expression={$_.ID}},
                                                    @{Name='Message';Expression={($_.Message -replace '\s+', ' ').Substring(0, [Math]::Min(200, $_.Message.Length))}}
        }
        
        Write-Log "Collected $($systemEvents.Count) System error events" -Level "OK" -Section "EVENTS"
    }
    
    $eventSection.Tests += @{
        TestName = "System Event Logs"
        Status = "Completed"
        Data = $systemEventData
    }
} catch {
    Write-Log "Error collecting System events: $_" -Level "ERROR" -Section "EVENTS"
    $eventSection.Tests += @{
        TestName = "System Event Logs"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 3.2: Application event logs
Write-Log "Test 3.2: Collecting Application event logs..." -Section "EVENTS"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would collect: Application event log entries from last 3 days"
    } else {
        $appEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Application'
            Level = @(1, 2)  # Critical, Error
            StartTime = (Get-Date).AddDays(-3)
        } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 50
        
        $appEventData = @{
            EventCount = $appEvents.Count
            Events = $appEvents | Select-Object @{Name='TimeCreated';Expression={$_.TimeCreated}}, 
                                                 @{Name='Level';Expression={$_.LevelDisplayName}}, 
                                                 @{Name='Source';Expression={$_.ProviderName}}, 
                                                 @{Name='EventID';Expression={$_.ID}},
                                                 @{Name='Message';Expression={($_.Message -replace '\s+', ' ').Substring(0, [Math]::Min(200, $_.Message.Length))}}
        }
        
        Write-Log "Collected $($appEvents.Count) Application error events" -Level "OK" -Section "EVENTS"
    }
    
    $eventSection.Tests += @{
        TestName = "Application Event Logs"
        Status = "Completed"
        Data = $appEventData
    }
} catch {
    Write-Log "Error collecting Application events: $_" -Level "ERROR" -Section "EVENTS"
    $eventSection.Tests += @{
        TestName = "Application Event Logs"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 3.3: PowerShell event logs
Write-Log "Test 3.3: Collecting PowerShell event logs..." -Section "EVENTS"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would collect: PowerShell operational logs from last 3 days"
    } else {
        $psEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Windows PowerShell'
            StartTime = (Get-Date).AddDays(-3)
        } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 30
        
        $psEventData = @{
            EventCount = $psEvents.Count
            Events = $psEvents | Select-Object @{Name='TimeCreated';Expression={$_.TimeCreated}}, 
                                                @{Name='EventID';Expression={$_.ID}},
                                                @{Name='Message';Expression={($_.Message -replace '\s+', ' ').Substring(0, [Math]::Min(200, $_.Message.Length))}}
        }
        
        Write-Log "Collected $($psEvents.Count) PowerShell events" -Level "OK" -Section "EVENTS"
    }
    
    $eventSection.Tests += @{
        TestName = "PowerShell Event Logs"
        Status = "Completed"
        Data = $psEventData
    }
} catch {
    Write-Log "Error collecting PowerShell events: $_" -Level "ERROR" -Section "EVENTS"
    $eventSection.Tests += @{
        TestName = "PowerShell Event Logs"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

$evidenceData.Sections["EventLogs"] = $eventSection

# ============================================================================
# SECTION 4: STARTUP AND LOGIN PERFORMANCE
# ============================================================================

Write-Log "Collecting startup and login performance data..." -Section "PERF"
Write-Host ""

$perfSection = @{
    CollectionTime = Get-Date
    Tests = @()
}

# Test 4.1: System uptime and boot time
Write-Log "Test 4.1: Collecting system uptime and boot time..." -Section "PERF"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would collect: System uptime and boot time information"
    } else {
        $uptime = Get-Uptime
        $bootTime = (Get-Date) - $uptime
        
        $uptimeData = @{
            Uptime = $uptime.ToString()
            BootTime = $bootTime
            UptimeDays = [Math]::Round($uptime.TotalDays, 2)
            UptimeHours = [Math]::Round($uptime.TotalHours, 2)
        }
        
        Write-Log "System uptime: $($uptimeData.UptimeDays) days" -Level "OK" -Section "PERF"
    }
    
    $perfSection.Tests += @{
        TestName = "System Uptime"
        Status = "Completed"
        Data = $uptimeData
    }
} catch {
    Write-Log "Error collecting uptime data: $_" -Level "ERROR" -Section "PERF"
    $perfSection.Tests += @{
        TestName = "System Uptime"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 4.2: Login time from Event Logs
Write-Log "Test 4.2: Analyzing login times from Event Logs..." -Section "PERF"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would analyze: Login time from recent logon events"
    } else {
        # Get logon events (Event ID 4624 from Security log or ID 7001 from System)
        $logonEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            ID = 7001  # User logon complete
            StartTime = (Get-Date).AddDays(-7)
        } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 5
        
        $loginTimeData = @{
            RecentLogonCount = $logonEvents.Count
            RecentLogons = $logonEvents | Select-Object @{Name='TimeCreated';Expression={$_.TimeCreated}}
        }
        
        Write-Log "Found $($logonEvents.Count) recent logon events" -Level "OK" -Section "PERF"
    }
    
    $perfSection.Tests += @{
        TestName = "Recent Login Times"
        Status = "Completed"
        Data = $loginTimeData
    }
} catch {
    Write-Log "Error analyzing login times: $_" -Level "ERROR" -Section "PERF"
    $perfSection.Tests += @{
        TestName = "Recent Login Times"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 4.3: Disk performance during startup
Write-Log "Test 4.3: Checking startup performance metrics..." -Section "PERF"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: Disk usage and I/O performance metrics"
    } else {
        $diskInfo = Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter -eq 'C' }
        
        if ($diskInfo) {
            $usagePercent = if ($diskInfo.Size -gt 0) { 
                [Math]::Round((($diskInfo.Size - $diskInfo.SizeRemaining) / $diskInfo.Size) * 100, 2) 
            } else { 
                0 
            }
            
            $diskData = @{
                Drive = "C:"
                TotalGB = [Math]::Round($diskInfo.Size / 1GB, 2)
                FreeGB = [Math]::Round($diskInfo.SizeRemaining / 1GB, 2)
                UsedGB = [Math]::Round(($diskInfo.Size - $diskInfo.SizeRemaining) / 1GB, 2)
                UsagePercent = $usagePercent
                Status = if ($usagePercent -gt 90) { "CRITICAL" } elseif ($usagePercent -gt 75) { "WARNING" } else { "OK" }
            }
            
            Write-Log "Disk usage: $usagePercent%" -Level "OK" -Section "PERF"
        } else {
            $diskData = @{ Message = "Unable to retrieve disk information" }
        }
    }
    
    $perfSection.Tests += @{
        TestName = "Disk Performance"
        Status = "Completed"
        Data = $diskData
    }
} catch {
    Write-Log "Error checking disk performance: $_" -Level "ERROR" -Section "PERF"
    $perfSection.Tests += @{
        TestName = "Disk Performance"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

$evidenceData.Sections["Performance"] = $perfSection

# ============================================================================
# SECTION 5: CPU AND MEMORY STATUS
# ============================================================================

Write-Log "Collecting CPU and memory status..." -Section "RESOURCES"
Write-Host ""

$resourceSection = @{
    CollectionTime = Get-Date
    Tests = @()
}

# Test 5.1: Memory status
Write-Log "Test 5.1: Collecting memory status..." -Section "RESOURCES"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would collect: Physical memory information"
    } else {
        $memInfo = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        $memPhysical = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
        
        $totalMemoryGB = [Math]::Round($memPhysical.Sum / 1GB, 2)
        
        # Get available memory
        $availableMemory = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
        $availableMemoryGB = [Math]::Round($availableMemory.FreePhysicalMemory / 1MB, 2)
        $usedMemoryGB = $totalMemoryGB - $availableMemoryGB
        $memoryUsagePercent = if ($totalMemoryGB -gt 0) { [Math]::Round(($usedMemoryGB / $totalMemoryGB) * 100, 2) } else { 0 }
        
        $memoryData = @{
            TotalMemoryGB = $totalMemoryGB
            UsedMemoryGB = $usedMemoryGB
            AvailableMemoryGB = $availableMemoryGB
            UsagePercent = $memoryUsagePercent
            Status = if ($memoryUsagePercent -gt 90) { "CRITICAL" } elseif ($memoryUsagePercent -gt 75) { "WARNING" } else { "OK" }
        }
        
        Write-Log "Memory usage: $memoryUsagePercent%" -Level "OK" -Section "RESOURCES"
    }
    
    $resourceSection.Tests += @{
        TestName = "Memory Status"
        Status = "Completed"
        Data = $memoryData
    }
} catch {
    Write-Log "Error collecting memory data: $_" -Level "ERROR" -Section "RESOURCES"
    $resourceSection.Tests += @{
        TestName = "Memory Status"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 5.2: CPU status
Write-Log "Test 5.2: Collecting CPU status..." -Section "RESOURCES"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would collect: CPU information and utilization"
    } else {
        $cpuInfo = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        
        # Get CPU usage (average over last 1 second)
        $cpuUsage = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor -ErrorAction SilentlyContinue | 
                    Where-Object { $_.Name -eq '_Total' } |
                    Select-Object -Property PercentProcessorTime
        
        $cpuData = @{
            ProcessorName = if ($cpuInfo) { $cpuInfo.Name } else { "Unknown" }
            CoreCount = if ($cpuInfo) { $cpuInfo.NumberOfCores } else { "Unknown" }
            LogicalProcessors = if ($cpuInfo) { $cpuInfo.NumberOfLogicalProcessors } else { "Unknown" }
            CurrentUsagePercent = if ($cpuUsage) { [Math]::Round($cpuUsage.PercentProcessorTime, 2) } else { "Unknown" }
        }
        
        Write-Log "CPU cores: $($cpuData.CoreCount), Usage: $($cpuData.CurrentUsagePercent)%" -Level "OK" -Section "RESOURCES"
    }
    
    $resourceSection.Tests += @{
        TestName = "CPU Status"
        Status = "Completed"
        Data = $cpuData
    }
} catch {
    Write-Log "Error collecting CPU data: $_" -Level "ERROR" -Section "RESOURCES"
    $resourceSection.Tests += @{
        TestName = "CPU Status"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 5.3: Process startup performance
Write-Log "Test 5.3: Analyzing high-resource processes..." -Section "RESOURCES"
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would analyze: Top CPU and memory consuming processes"
    } else {
        $topProcesses = Get-Process -ErrorAction SilentlyContinue | 
                       Select-Object Name, CPU, WorkingSet, StartTime | 
                       Sort-Object -Property WorkingSet -Descending | 
                       Select-Object -First 15
        
        $processData = @{
            TopProcessCount = $topProcesses.Count
            TopProcesses = $topProcesses | ForEach-Object {
                @{
                    Name = $_.Name
                    CPUTime = [Math]::Round($_.CPU, 2)
                    MemoryMB = [Math]::Round($_.WorkingSet / 1MB, 2)
                    StartTime = $_.StartTime
                }
            }
        }
        
        Write-Log "Analyzed $($topProcesses.Count) top processes" -Level "OK" -Section "RESOURCES"
    }
    
    $resourceSection.Tests += @{
        TestName = "Top Resource Consuming Processes"
        Status = "Completed"
        Data = $processData
    }
} catch {
    Write-Log "Error analyzing processes: $_" -Level "ERROR" -Section "RESOURCES"
    $resourceSection.Tests += @{
        TestName = "Top Resource Consuming Processes"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

$evidenceData.Sections["Resources"] = $resourceSection

# ============================================================================
# SECTION 6: SUMMARY AND EXPORT
# ============================================================================

Write-Log "Finalizing evidence collection..." -Section "EXPORT"
Write-Host ""

# Add summary statistics
$totalTests = 0
$completedTests = 0
$failedTests = 0

foreach ($section in $evidenceData.Sections.Keys) {
    foreach ($test in $evidenceData.Sections[$section].Tests) {
        $totalTests++
        if ($test.Status -eq "Completed") { $completedTests++ }
        elseif ($test.Status -eq "Failed") { $failedTests++ }
    }
}

$evidenceData.Summary = @{
    CollectionEndTime = Get-Date
    TotalTestsRun = $totalTests
    CompletedTests = $completedTests
    FailedTests = $failedTests
    SuccessRate = if ($totalTests -gt 0) { [Math]::Round(($completedTests / $totalTests) * 100, 2) } else { 0 }
}

# Export to JSON
$jsonFile = Join-Path $OutputPath "LoginPerformanceEvidence.json"
$exportSuccess = Export-JSON -Data $evidenceData -FilePath $jsonFile -DryRunMode $DryRun

# ============================================================================
# FINAL SUMMARY
# ============================================================================

Write-Host ""
Write-Host "=============================================================="
Write-Host "EVIDENCE COLLECTION COMPLETE"
Write-Host "=============================================================="
Write-Host "Collection Time:        $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Total Tests Run:        $totalTests"
Write-Host "Completed Tests:        $completedTests"
Write-Host "Failed Tests:           $failedTests"
Write-Host "Success Rate:           $($evidenceData.Summary.SuccessRate)%"
Write-Host ""
if (-not $DryRun) {
    Write-Host "Output Location:        $OutputPath"
    Write-Host "JSON Export:            $jsonFile"
    Write-Host ""
    Write-Host "ROLLBACK:"
    Write-Host "To remove this evidence, run:"
    Write-Host "  .\Collect-LoginPerformanceEvidence.ps1 -Rollback"
}
Write-Host "=============================================================="
Write-Host ""

# Exit with success code
exit 0
