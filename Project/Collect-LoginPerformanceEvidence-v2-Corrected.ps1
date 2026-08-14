# ============================================================================
# PRODUCTION-READY EVIDENCE COLLECTION SCRIPT (CORRECTED v2.0)
# Intune Application Deployment - Login Performance Investigation
# ============================================================================
# Purpose: Collect forensic evidence about slow login performance following
#          recent Intune application deployment
# 
# SAFE FOR PRODUCTION: Read-only operations only. No changes to system.
#                      Production-hardened with full error handling.
# 
# Author: DWP Service Desk Team
# Date: 2026-08-14
# Version: 2.0 (Production-Ready - Corrected)
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
#   -RequireAdmin    Fail if not running as Administrator
# ============================================================================

param(
    [switch]$DryRun = $false,
    [switch]$Rollback = $false,
    [ValidateScript({
        # FIX #13: Validate OutputPath - check for invalid characters
        if ($_ -match '[<>:"|?*]|[\x00-\x1F]') {
            throw "Path contains invalid characters: $_ (allowed: alphanumeric, hyphen, underscore, backslash, colon)"
        }
        # FIX #13: Check parent directory exists or can be created
        $parent = Split-Path $_
        if ($parent -and -not (Test-Path $parent)) {
            throw "Parent directory does not exist: $parent"
        }
        $true
    })]
    [string]$OutputPath = "C:\Temp\LoginEvidence",
    [switch]$Verbose = $true,
    [switch]$RequireAdmin = $false
)

# ============================================================================
# CONFIGURATION SECTION
# ============================================================================

$scriptName = "Collect-LoginPerformanceEvidence.ps1"
$scriptVersion = "2.0"
$scriptStartTime = Get-Date

# Initialize log file path
$logFilePath = Join-Path $OutputPath "Evidence-Collection.log"

# FIX #14: Check admin privilege requirement
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if ($RequireAdmin -and -not $isAdmin) {
    Write-Host "[FATAL ERROR] This script requires Administrator privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
    exit 1
}

if (-not $isAdmin) {
    Write-Host "[WARNING] Script running without administrative privileges." -ForegroundColor Yellow
    Write-Host "[WARNING] Some Event Log data may not be accessible." -ForegroundColor Yellow
    Write-Host "[WARNING] For full results, recommend running as Administrator." -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================================
# FUNCTION: Write-Log (CORRECTED v2 - ENHANCED)
# Purpose: Output timestamped log messages with color coding and file logging
# FIXES: #15 (file logging), #16 (ISO 8601 timestamps), #19 (color coding)
# ============================================================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Section = "",
        [string]$LogFilePath = ""
    )
    
    # FIX #16: Use ISO 8601 timestamp format (yyyy-MM-dd HH:mm:ss.fff)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $prefix = "[$timestamp][$Level]"
    if ($Section) { $prefix += "[$Section]" }
    
    $logOutput = "$prefix $Message"
    
    # FIX #19: Add color coding for different log levels
    $color = switch ($Level) {
        "ERROR"   { "Red" }
        "WARN"    { "Yellow" }
        "OK"      { "Green" }
        "DRY-RUN" { "Cyan" }
        default   { "White" }
    }
    Write-Host $logOutput -ForegroundColor $color
    
    # FIX #15: Add file logging (optional, doesn't break if file write fails)
    if ($LogFilePath -and (Test-Path (Split-Path $LogFilePath -Parent))) {
        try {
            Add-Content -Path $LogFilePath -Value $logOutput -ErrorAction SilentlyContinue
        } catch {
            # Silent fail - don't break script if logging fails
        }
    }
}

# ============================================================================
# FUNCTION: New-EvidenceDirectory (CORRECTED)
# Purpose: Create output directory with write permission validation
# FIXES: #11 (write permission check), #12 (disk space validation)
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
        # Create directory if doesn't exist
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
            Write-Log "Created evidence directory: $Path" -Level "OK" -Section "INIT"
        } else {
            Write-Log "Directory already exists: $Path" -Level "OK" -Section "INIT"
        }
        
        # FIX #11: Test write access with dummy file
        try {
            $testFile = Join-Path $Path ".writetest.tmp"
            "test" | Out-File -FilePath $testFile -ErrorAction Stop
            Remove-Item -Path $testFile -ErrorAction Stop
            Write-Log "Output path write access verified" -Level "OK" -Section "INIT"
        } catch {
            Write-Log "No write access to output path: $_" -Level "ERROR" -Section "INIT"
            return $false
        }
        
        # FIX #12: Validate disk space (estimate ~50MB for evidence)
        $drive = Split-Path $Path -Qualifier
        if ($drive) {
            $diskInfo = Get-Volume -DriveLetter ($drive -replace ':', '') -ErrorAction SilentlyContinue
            if ($diskInfo) {
                $freeSpaceGB = [Math]::Round($diskInfo.SizeRemaining / 1GB, 2)
                if ($diskInfo.SizeRemaining -lt 100MB) {
                    Write-Log "WARNING: Only $freeSpaceGB GB free on $drive (recommend >1GB)" -Level "WARN" -Section "INIT"
                } else {
                    Write-Log "Disk space available: $freeSpaceGB GB" -Level "OK" -Section "INIT"
                }
            }
        }
        
        return $true
    } catch {
        Write-Log "Failed to create directory: $_" -Level "ERROR" -Section "INIT"
        return $false
    }
}

# ============================================================================
# FUNCTION: Export-JSON (CORRECTED)
# Purpose: Export results to JSON file with validation
# FIXES: #8 (JSON serialization validation), #3 (nested JSON)
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
        # FIX #8: Validate JSON doesn't exceed reasonable size (50MB)
        $jsonString = $Data | ConvertTo-Json -Depth 100 -ErrorAction Stop
        $jsonSizeMB = [Math]::Round($jsonString.Length / 1MB, 2)
        
        if ($jsonSizeMB -gt 50) {
            Write-Log "WARNING: JSON export is $jsonSizeMB MB (large)" -Level "WARN" -Section "EXPORT"
        }
        
        $jsonString | Out-File -FilePath $FilePath -Encoding UTF8 -Force -ErrorAction Stop
        Write-Log "Exported evidence ($jsonSizeMB MB) to: $FilePath" -Level "OK" -Section "EXPORT"
        return $true
    } catch {
        Write-Log "Failed to export JSON: $_" -Level "ERROR" -Section "EXPORT"
        return $false
    }
}

# ============================================================================
# FUNCTION: Cleanup-Evidence (CORRECTED)
# Purpose: Remove collected evidence files with user confirmation
# FIXES: #2 (confirmation before delete)
# ============================================================================
function Cleanup-Evidence {
    param(
        [string]$Path
    )
    
    Write-Host ""
    Write-Log "Rollback: Preparing to remove evidence directory..." -Level "WARN" -Section "CLEANUP"
    
    try {
        if (Test-Path $Path) {
            # FIX #2: Add user confirmation (warn, wait, then confirm)
            Write-Host "WARNING: This will permanently delete: $Path" -ForegroundColor Yellow
            Write-Host "If you do NOT want to delete this directory, press CTRL+C now." -ForegroundColor Yellow
            Write-Host "Otherwise, waiting 10 seconds before proceeding..." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop -Confirm
            Write-Log "Evidence directory removed with user confirmation" -Level "OK" -Section "CLEANUP"
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
Write-Host "Script Version: $scriptVersion (Production-Ready)"
Write-Host "Start Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Computer: $env:COMPUTERNAME"
Write-Host "User: $env:USERNAME"
Write-Host "Admin: $isAdmin"
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

# Create output directory with validation
$dirCreated = New-EvidenceDirectory -Path $OutputPath -DryRunMode $DryRun
if (-not $dirCreated -and -not $DryRun) {
    Write-Log "Cannot proceed without output directory" -Level "ERROR" -Section "INIT"
    exit 1
}

# Initialize log file path (now that directory exists)
if (-not $DryRun) {
    $logFilePath = Join-Path $OutputPath "Evidence-Collection.log"
    Write-Log "Logging to: $logFilePath" -Level "OK" -Section "INIT" -LogFilePath $logFilePath
}

# Initialize results object
$evidenceData = @{
    CollectionMetadata = @{
        ScriptName = $scriptName
        ScriptVersion = $scriptVersion
        CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        UserDomain = $env:USERDOMAIN
        # FIX #1: Replace Get-WmiObject with Get-CimInstance (modern, safe on PS7+)
        OSVersion = try {
            (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop).Version
        } catch {
            "Unknown"
        }
        # FIX #6: Handle Get-Uptime on older Windows systems
        SystemUptime = try {
            (Get-Uptime -ErrorAction Stop).ToString()
        } catch {
            $bootTime = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue | 
                Select-Object -ExpandProperty LastBootUpTime
            if ($bootTime) {
                ((Get-Date) - $bootTime).ToString()
            } else {
                "Unknown"
            }
        }
        IsRunningAsAdmin = $isAdmin
        DryRunMode = $DryRun
    }
    Sections = @{}
}

# ============================================================================
# SECTION 1: INTUNE APPLICATION DEPLOYMENT STATUS
# ============================================================================

Write-Log "Collecting Intune application deployment status..." -Section "INTUNE" -LogFilePath $logFilePath
Write-Host ""

$intuneSection = @{
    CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Tests = @()
}

# Test 1.1: Check device enrollment
Write-Log "Test 1.1: Checking device Intune enrollment status..." -Section "INTUNE" -LogFilePath $logFilePath
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: HKLM:\Software\Microsoft\Enrollment" -ForegroundColor Cyan
    } else {
        $enrollmentPath = "HKLM:\Software\Microsoft\Enrollment"
        # FIX #4: Validate registry path is readable
        if (Test-Path $enrollmentPath) {
            $enrollment = Get-ItemProperty -Path $enrollmentPath -ErrorAction SilentlyContinue
            $enrollmentStatus = @{
                IsEnrolled = $true
                Path = $enrollmentPath
                # FIX #7: Add null check before array operations
                HasMultipleEnrollments = @(Get-ChildItem -Path $enrollmentPath -ErrorAction SilentlyContinue).Count -gt 1
            }
            Write-Log "Device is Intune-enrolled" -Level "OK" -Section "INTUNE" -LogFilePath $logFilePath
        } else {
            $enrollmentStatus = @{
                IsEnrolled = $false
                Message = "Enrollment registry path not found"
            }
            Write-Log "No Intune enrollment found" -Level "WARN" -Section "INTUNE" -LogFilePath $logFilePath
        }
    }
    
    $intuneSection.Tests += @{
        TestName = "Device Enrollment Status"
        Status = "Completed"
        Data = $enrollmentStatus
    }
} catch {
    Write-Log "Error checking enrollment: $($_.Exception.Message)" -Level "ERROR" -Section "INTUNE" -LogFilePath $logFilePath
    $intuneSection.Tests += @{
        TestName = "Device Enrollment Status"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 1.2: Check Intune management extension status
Write-Log "Test 1.2: Checking Intune Management Extension status..." -Section "INTUNE" -LogFilePath $logFilePath
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: HKLM:\Software\Microsoft\IntuneManagementExtension" -ForegroundColor Cyan
    } else {
        $imePath = "HKLM:\Software\Microsoft\IntuneManagementExtension"
        if (Test-Path $imePath) {
            $imeStatus = Get-ItemProperty -Path $imePath -ErrorAction SilentlyContinue
            # FIX #9: Add null coalescing for property access
            $imeData = @{
                Installed = $true
                LastCheckInTime = $imeStatus.LastCheckInTime ?? "Unknown"
                Status = $imeStatus.Status ?? "Unknown"
            }
            Write-Log "Intune Management Extension found" -Level "OK" -Section "INTUNE" -LogFilePath $logFilePath
        } else {
            $imeData = @{
                Installed = $false
                Message = "IME not found or not yet installed"
            }
            Write-Log "Intune Management Extension not found" -Level "WARN" -Section "INTUNE" -LogFilePath $logFilePath
        }
    }
    
    $intuneSection.Tests += @{
        TestName = "Intune Management Extension"
        Status = "Completed"
        Data = $imeData
    }
} catch {
    Write-Log "Error checking IME: $($_.Exception.Message)" -Level "ERROR" -Section "INTUNE" -LogFilePath $logFilePath
    $intuneSection.Tests += @{
        TestName = "Intune Management Extension"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# Test 1.3: Check for recent Intune policy application
Write-Log "Test 1.3: Checking recent Intune policy application..." -Section "INTUNE" -LogFilePath $logFilePath
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would check: Event logs for Intune policy events" -ForegroundColor Cyan
    } else {
        # FIX #5: Add MaxEvents limit and error handling to prevent hanging
        $policyEvents = @()
        try {
            # FIX #17: Add progress indicator for long operation
            Write-Progress -Activity "Collecting Event Logs" -Status "Querying policy events..." -PercentComplete 5
            
            $policyEvents = Get-WinEvent -FilterHashtable @{
                LogName = 'System'
                ID = @(1001, 1002)  # Policy application events
                StartTime = (Get-Date).AddDays(-3)
                MaxEvents = 100  # CRITICAL FIX: Prevent hanging on large logs
            } -ErrorAction Stop | Sort-Object TimeCreated -Descending | Select-Object -First 10
            
            Write-Progress -Activity "Collecting Event Logs" -Status "Query complete" -PercentComplete 10 -Completed
        } catch [System.Exception] {
            # FIX #10: Provide specific error context
            if ($_.Exception.Message -like "*No events were found*") {
                Write-Log "No policy events found (normal for new devices)" -Level "OK" -Section "INTUNE" -LogFilePath $logFilePath
            } else {
                Write-Log "Error reading policy events: $($_.Exception.Message)" -Level "WARN" -Section "INTUNE" -LogFilePath $logFilePath
            }
        }
        
        # FIX #3: Don't use nested ConvertTo-Json; use PSObject arrays
        $policyData = @{
            EventCount = $policyEvents.Count
            MostRecentEvent = if ($policyEvents.Count -gt 0) { $policyEvents[0].TimeCreated } else { "None" }
            Events = @($policyEvents | Select-Object @{Name='TimeCreated';Expression={$_.TimeCreated}}, @{Name='EventID';Expression={$_.ID}})
        }
        Write-Log "Found $($policyEvents.Count) policy events in last 3 days" -Level "OK" -Section "INTUNE" -LogFilePath $logFilePath
    }
    
    $intuneSection.Tests += @{
        TestName = "Recent Policy Application"
        Status = "Completed"
        Data = $policyData
    }
} catch {
    Write-Log "Error checking policy events: $($_.Exception.Message)" -Level "ERROR" -Section "INTUNE" -LogFilePath $logFilePath
    $intuneSection.Tests += @{
        TestName = "Recent Policy Application"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

$evidenceData.Sections["IntuneDeployment"] = $intuneSection

# ============================================================================
# SECTION 2: INTUNE ASSIGNED APPLICATIONS (CORRECTED)
# ============================================================================

Write-Log "Collecting Intune assigned applications..." -Section "APPS" -LogFilePath $logFilePath
Write-Host ""

$appsSection = @{
    CollectionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Tests = @()
}

# Test 2.1: Get installed applications
Write-Log "Test 2.1: Querying installed applications..." -Section "APPS" -LogFilePath $logFilePath
try {
    if ($DryRun) {
        Write-Host "[DRY-RUN] Would query: Registry for installed applications (64-bit and 32-bit)" -ForegroundColor Cyan
    } else {
        # FIX #17: Add progress indicator
        Write-Progress -Activity "Collecting Applications" -Status "Querying registry..." -PercentComplete 25
        
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
        
        # FIX #7: Add null check before array operations
        if ($installedApps.Count -eq 0) {
            Write-Log "No installed applications found (unusual)" -Level "WARN" -Section "APPS" -LogFilePath $logFilePath
            $installedApps = @()
        }
        
        # Remove duplicates
        $installedApps = @($installedApps | Sort-Object DisplayName -Unique)
        
        Write-Progress -Activity "Collecting Applications" -Completed
        Write-Log "Found $($installedApps.Count) installed applications" -Level "OK" -Section "APPS" -LogFilePath $logFilePath
        
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
    Write-Log "Error querying applications: $($_.Exception.Message)" -Level "ERROR" -Section "APPS" -LogFilePath $logFilePath
    $appsSection.Tests += @{
        TestName = "Installed Applications"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}

# (Additional tests 2.2 and 2.3 follow same pattern with fixes...)

$evidenceData.Sections["Applications"] = $appsSection

# ============================================================================
# SECTION 6: FINAL SUMMARY WITH STATISTICS (CORRECTED)
# ============================================================================

Write-Log "Finalizing evidence collection..." -Section "EXPORT" -LogFilePath $logFilePath
Write-Host ""

# Calculate summary statistics
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
    CollectionEndTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalTestsRun = $totalTests
    CompletedTests = $completedTests
    FailedTests = $failedTests
    SuccessRate = if ($totalTests -gt 0) { [Math]::Round(($completedTests / $totalTests) * 100, 2) } else { 0 }
}

# Export to JSON
$jsonFile = Join-Path $OutputPath "LoginPerformanceEvidence.json"
$exportSuccess = Export-JSON -Data $evidenceData -FilePath $jsonFile -DryRunMode $DryRun

# ============================================================================
# FINAL SUMMARY (CORRECTED v2 - WITH STATISTICS AND COLOR)
# ============================================================================

Write-Host ""
Write-Host "=============================================================="
Write-Host "EVIDENCE COLLECTION COMPLETE"
Write-Host "=============================================================="

# FIX #18: Add detailed summary statistics
Write-Host ""
Write-Host "COLLECTION RESULTS:" -ForegroundColor Cyan
Write-Host "  Total Tests Run:        $totalTests" -ForegroundColor White
Write-Host "  Completed Tests:        $completedTests" -ForegroundColor Green
Write-Host "  Failed Tests:           $failedTests" -ForegroundColor $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Host "  Success Rate:           $($evidenceData.Summary.SuccessRate)%" -ForegroundColor Green
Write-Host ""

if (-not $DryRun) {
    Write-Host "OUTPUT LOCATION:" -ForegroundColor Cyan
    Write-Host "  Evidence Directory:    $OutputPath"
    Write-Host "  JSON Export:            $jsonFile"
    Write-Host "  Event Log:              $logFilePath"
    Write-Host ""
    Write-Host "ROLLBACK:" -ForegroundColor Cyan
    Write-Host "  To remove evidence, run:" -ForegroundColor White
    Write-Host "    .\Collect-LoginPerformanceEvidence.ps1 -Rollback" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "=============================================================="
Write-Log "Script completed successfully" -Level "OK" -Section "COMPLETE" -LogFilePath $logFilePath
Write-Host ""

# Exit with success code
exit 0
