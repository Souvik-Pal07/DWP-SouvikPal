# PowerShell Script Review: Production-Ready Analysis
## Collect-LoginPerformanceEvidence.ps1 — AI vs. Hand-Corrected

**Review Date:** 2026-08-14  
**Focus:** Production-readiness, safety, error handling, logging, output formatting

---

## ISSUE SUMMARY

### Issues Identified: 17 Critical/High Priority

| Category | Count | Severity |
|----------|-------|----------|
| Unsafe Commands | 4 | HIGH |
| Missing Error Handling | 6 | HIGH |
| Missing Validation | 4 | MEDIUM |
| Logging Improvements | 2 | MEDIUM |
| Output Formatting | 3 | LOW-MEDIUM |

---

## DETAILED ISSUE BREAKDOWN

### UNSAFE COMMANDS (4 Issues)

#### Issue #1: Deprecated Get-WmiObject
**Location:** Line ~167 (OS Version collection)  
**Problem:** `Get-WmiObject -Class Win32_OperatingSystem` is deprecated in PowerShell 7+  
**Risk:** Script may fail on newer systems; Microsoft recommends Get-CimInstance  
**Fix:** Replace with Get-CimInstance

#### Issue #2: Unconfirmed Remove-Item in Rollback
**Location:** Cleanup-Evidence function  
**Problem:** `Remove-Item -Path $Path -Recurse -Force` deletes without confirmation  
**Risk:** User could accidentally delete entire directory; -Force bypasses all warnings  
**Fix:** Add -Confirm switch; require explicit confirmation

#### Issue #3: Nested ConvertTo-Json within JSON Export
**Location:** Line ~293 (Events converted to JSON, then included in JSON)  
**Problem:** `ConvertTo-Json` embedded inside JSON structure creates double-escaped strings  
**Risk:** Output becomes unreadable; parser confusion  
**Fix:** Use native PSObject arrays instead of converting to JSON strings

#### Issue #4: Registry Access without Permission Check
**Location:** Multiple registry read operations  
**Problem:** No validation that registry key is readable before querying  
**Risk:** Silent failures if HKEY_LOCAL_MACHINE access denied (rare but possible)  
**Fix:** Check registry key access before attempting read

---

### MISSING ERROR HANDLING (6 Issues)

#### Issue #5: No Timeout on Event Log Queries
**Location:** Get-WinEvent calls (Sections 1, 3)  
**Problem:** `Get-WinEvent` can hang indefinitely on corrupted event logs  
**Risk:** Script hangs; never completes  
**Fix:** Add -MaxEvents parameter and wrap in timeout function

#### Issue #6: Get-Uptime Fails on Windows Server 2016
**Location:** Line ~168  
**Problem:** Get-Uptime cmdlet not available on older Windows versions  
**Risk:** Script crashes on legacy systems  
**Fix:** Wrap in try-catch; use alternative method for older OS

#### Issue #7: Null Array Operations
**Location:** Test 2.1, Test 2.2 (Application queries)  
**Problem:** `$installedApps | Sort-Object DisplayName -Unique` fails if null  
**Risk:** Null reference exception if no apps found  
**Fix:** Add null check before array operations

#### Issue #8: No Validation of JSON Serialization
**Location:** Export-JSON function  
**Problem:** `ConvertTo-Json -Depth 15` fails silently if data too complex; truncates deep objects  
**Risk:** Silent data loss; incomplete evidence export  
**Fix:** Validate JSON output; use -Depth 100 with size validation

#### Issue #9: Property Access on Null Objects
**Location:** Lines 227-231 (imeStatus property checks)  
**Problem:** `$imeStatus.LastCheckInTime` doesn't validate that $imeStatus is not null  
**Risk:** Null reference exception  
**Fix:** Add null coalescing checks

#### Issue #10: No Error Recovery for Failed Event Log Reads
**Location:** Test 1.3, Test 3.1-3.3  
**Problem:** Single event log failure doesn't log which event log failed  
**Risk:** Ambiguous error messages; difficult to diagnose  
**Fix:** Add specific event log name to error messages

---

### MISSING VALIDATION (4 Issues)

#### Issue #11: No Output Path Write Permission Check
**Location:** New-EvidenceDirectory function  
**Problem:** Doesn't validate write permissions before creating directory  
**Risk:** Directory created but script fails later when writing JSON  
**Fix:** Test write permissions with dummy file; delete if successful

#### Issue #12: No Disk Space Validation
**Location:** After directory creation  
**Problem:** No check if disk has enough space for evidence collection  
**Risk:** Partial evidence written; script exits without clear indication  
**Fix:** Check disk space; estimate evidence size vs. available space

#### Issue #13: OutputPath Not Validated for Invalid Characters
**Location:** Parameter validation  
**Problem:** `$OutputPath` parameter accepts paths with invalid characters  
**Risk:** Directory creation fails with confusing error  
**Fix:** Add ValidateScript to path parameter

#### Issue #14: No Validation of Admin Privilege Requirement
**Location:** Line ~52-58 (Admin check)  
**Problem:** Script warns about lack of admin but continues anyway  
**Risk:** Misleading results if event logs can't be read due to permissions  
**Fix:** Fail fast if admin required and not running as admin (add -RequireAdmin switch)

---

### LOGGING IMPROVEMENTS (2 Issues)

#### Issue #15: Write-Log Doesn't Write to File
**Location:** Write-Log function  
**Problem:** All logging goes to console only; no file log created  
**Risk:** No audit trail; hard to troubleshoot after-the-fact  
**Fix:** Add optional file logging to Write-Log

#### Issue #16: Timestamps Not ISO 8601 Format
**Location:** Write-Log function (HH:mm:ss format)  
**Problem:** Custom format makes sorting/parsing harder  
**Risk:** Log aggregation tools can't parse timestamps  
**Fix:** Use ISO 8601 format: yyyy-MM-dd HH:mm:ss.fff

---

### OUTPUT FORMATTING (3 Issues)

#### Issue #17: No Progress Indicator During Long Operations
**Location:** Event log collection (can take 30+ seconds)  
**Problem:** User sees nothing for extended periods  
**Risk:** Appears hung; user might interrupt script  
**Fix:** Add Write-Progress during event log queries

#### Issue #18: No Summary Statistics
**Location:** Final output  
**Problem:** No clear summary of what was collected (X apps found, Y events found, etc.)  
**Risk:** User can't quickly verify completeness  
**Fix:** Add summary section with statistics

#### Issue #19: Console Output Not Color-Coded
**Location:** Write-Host statements throughout  
**Problem:** Errors, warnings, successes all in same color  
**Risk:** Hard to spot issues when scanning output  
**Fix:** Add color coding (Green=OK, Yellow=WARN, Red=ERROR)

---

## CHANGES SUMMARY TABLE

| # | Issue | Category | Severity | Line(s) | Fix Type |
|---|-------|----------|----------|---------|----------|
| 1 | Get-WmiObject deprecated | Unsafe | HIGH | 167 | Replace with Get-CimInstance |
| 2 | Remove-Item -Force no confirm | Unsafe | HIGH | 157 | Add -Confirm parameter |
| 3 | Nested ConvertTo-Json | Unsafe | HIGH | 293 | Use PSObject arrays |
| 4 | No registry permission check | Unsafe | MEDIUM | 186+ | Add Test-RegistryPath |
| 5 | Event log query timeout | Error Handling | HIGH | 243+ | Add -MaxEvents, timeout wrapper |
| 6 | Get-Uptime on old OS | Error Handling | HIGH | 168 | Try-catch with fallback |
| 7 | Null array operations | Error Handling | HIGH | 330 | Add null checks |
| 8 | JSON serialization silent fail | Error Handling | HIGH | 148 | Validate JSON size |
| 9 | Null property access | Error Handling | MEDIUM | 227 | Add null coalescing |
| 10 | Ambiguous error messages | Error Handling | MEDIUM | 240+ | Add context to errors |
| 11 | No write permission check | Validation | HIGH | 112 | Test write access |
| 12 | No disk space validation | Validation | MEDIUM | 112 | Check available space |
| 13 | OutputPath invalid chars | Validation | MEDIUM | 28 | ValidateScript parameter |
| 14 | Admin requirement ambiguous | Validation | MEDIUM | 52 | Fail fast if needed |
| 15 | Write-Log no file output | Logging | MEDIUM | 56 | Add file logging |
| 16 | Non-ISO timestamps | Logging | LOW | 64 | Use ISO 8601 format |
| 17 | No progress indicator | Output | MEDIUM | 243+ | Add Write-Progress |
| 18 | No summary statistics | Output | LOW | 600+ | Add summary section |
| 19 | No color coding | Output | LOW | 56+ | Add Write-Color function |

---

## SIDE-BY-SIDE CODE COMPARISONS

### Fix #1: Replace Get-WmiObject with Get-CimInstance

**BEFORE (AI Version - UNSAFE):**
```powershell
OSVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version
```
**Line:** ~167  
**Problem:** Get-WmiObject deprecated in PowerShell 7.0+; fails on newer systems

**AFTER (Corrected - SAFE):**
```powershell
OSVersion = if ($null -ne (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue)) { 
    (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue).Version 
} else { 
    "Unknown" 
}
```
**Fix Explanation:** Replace with Get-CimInstance (modern cmdlet); add error handling for systems where WMI is unavailable

---

### Fix #2: Add Confirmation to Rollback

**BEFORE (AI Version - UNSAFE):**
```powershell
Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
```
**Line:** ~157  
**Problem:** -Force bypasses all confirmation prompts; user could accidentally delete directory

**AFTER (Corrected - SAFE):**
```powershell
Write-Host "WARNING: This will delete: $Path" -ForegroundColor Yellow
Write-Host "Are you sure? Press CTRL+C to cancel, or wait 10 seconds to proceed..."
Start-Sleep -Seconds 10
Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop -Confirm
Write-Log "Evidence directory removed with user confirmation" -Level "OK" -Section "CLEANUP"
```
**Fix Explanation:** Add user confirmation prompt; warn before deletion; log the action; use -Confirm for additional safety

---

### Fix #3: Validate Output Path Write Access

**BEFORE (AI Version - UNSAFE):**
```powershell
if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
}
```
**Line:** ~112  
**Problem:** No validation that directory can be written to; may fail later during JSON export

**AFTER (Corrected - SAFE):**
```powershell
# Validate output path
if (-not (Test-Path $Path)) {
    try {
        New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop | Out-Null
    } catch {
        Write-Log "Failed to create directory. Check permissions: $_" -Level "ERROR" -Section "INIT"
        return $false
    }
}

# Test write access with dummy file
try {
    $testFile = Join-Path $Path "writetest.tmp"
    "test" | Out-File -FilePath $testFile -ErrorAction Stop
    Remove-Item -Path $testFile -ErrorAction Stop
    Write-Log "Output path write access verified" -Level "OK" -Section "INIT"
} catch {
    Write-Log "No write access to output path: $_" -Level "ERROR" -Section "INIT"
    return $false
}
```
**Fix Explanation:** Test actual write access before proceeding; catch and report permission errors explicitly; fail fast if can't write

---

### Fix #4: Add Timeout to Event Log Queries

**BEFORE (AI Version - UNSAFE):**
```powershell
$policyEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = @(1001, 1002)
    StartTime = (Get-Date).AddDays(-3)
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 10
```
**Line:** ~243  
**Problem:** Can hang indefinitely if event log is corrupted; no timeout or max events limit

**AFTER (Corrected - SAFE):**
```powershell
$policyEvents = @()
try {
    $policyEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ID = @(1001, 1002)
        StartTime = (Get-Date).AddDays(-3)
    } -MaxEvents 100 -ErrorAction Stop | Sort-Object TimeCreated -Descending | Select-Object -First 10
    Write-Log "Found $($policyEvents.Count) policy events" -Level "OK" -Section "INTUNE"
} catch [System.Exception] {
    if ($_.Exception.Message -like "*No events were found*") {
        Write-Log "No policy events found (normal if new device)" -Level "OK" -Section "INTUNE"
    } else {
        Write-Log "Error reading policy events: $($_.Exception.Message)" -Level "WARN" -Section "INTUNE"
    }
}
```
**Fix Explanation:** Add -MaxEvents to prevent hanging; catch specific exceptions; distinguish "no events" from "error reading"; provide context

---

### Fix #5: Handle Get-Uptime on Older Systems

**BEFORE (AI Version - UNSAFE):**
```powershell
SystemUptime = (Get-Uptime).ToString()
```
**Line:** ~168  
**Problem:** Get-Uptime cmdlet not available on Windows Server 2016, Windows 10 pre-1809

**AFTER (Corrected - SAFE):**
```powershell
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
```
**Fix Explanation:** Try modern Get-Uptime first; fall back to WMI method on older systems; return "Unknown" if both fail

---

### Fix #6: Add Null Check to Array Operations

**BEFORE (AI Version - UNSAFE):**
```powershell
$installedApps = $installedApps | Sort-Object DisplayName -Unique

# If $installedApps is null, this fails
$appData = @{
    TotalApplications = $installedApps.Count
    Applications = @($installedApps | Select-Object DisplayName, DisplayVersion, Publisher)
}
```
**Line:** ~330  
**Problem:** If no apps found, $installedApps is null; calling .Count on null returns 0 but operations may fail

**AFTER (Corrected - SAFE):**
```powershell
if ($installedApps.Count -eq 0) {
    Write-Log "No installed applications found (unusual)" -Level "WARN" -Section "APPS"
    $installedApps = @()
}

$installedApps = @($installedApps | Sort-Object DisplayName -Unique)

$appData = @{
    TotalApplications = @($installedApps).Count
    Applications = @($installedApps | Select-Object -Property DisplayName, DisplayVersion, Publisher)
}
```
**Fix Explanation:** Explicitly check for empty results; force array type with @(); use explicit Count property; handle edge case

---

### Fix #7: Add File Logging to Write-Log

**BEFORE (AI Version - LIMITED):**
```powershell
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
```
**Line:** ~56  
**Problem:** No file logging; console-only output; timestamps not ISO 8601; no color coding

**AFTER (Corrected - ENHANCED):**
```powershell
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Section = "",
        [string]$LogFilePath = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $prefix = "[$timestamp][$Level]"
    if ($Section) { $prefix += "[$Section]" }
    
    $logOutput = "$prefix $Message"
    
    # Console output with color
    $color = switch ($Level) {
        "ERROR"   { "Red" }
        "WARN"    { "Yellow" }
        "OK"      { "Green" }
        "DRY-RUN" { "Cyan" }
        default   { "White" }
    }
    Write-Host $logOutput -ForegroundColor $color
    
    # File logging
    if ($LogFilePath -and (Test-Path (Split-Path $LogFilePath))) {
        try {
            Add-Content -Path $LogFilePath -Value $logOutput -ErrorAction SilentlyContinue
        } catch {
            # Silent fail - don't break script if logging fails
        }
    }
}
```
**Fix Explanation:** Add ISO 8601 timestamps; add color coding; add optional file logging; make logging robust (doesn't break script if file write fails)

---

### Fix #8: Add OutputPath Validation

**BEFORE (AI Version - NO VALIDATION):**
```powershell
param(
    [switch]$DryRun = $false,
    [switch]$Rollback = $false,
    [string]$OutputPath = "C:\Temp\LoginEvidence",
    [switch]$Verbose = $true
)
```
**Line:** ~28  
**Problem:** No validation of OutputPath; accepts invalid paths

**AFTER (Corrected - VALIDATED):**
```powershell
param(
    [switch]$DryRun = $false,
    [switch]$Rollback = $false,
    [ValidateScript({
        # Validate path doesn't contain invalid characters
        if ($_ -match '[<>:"|?*]|[\x00-\x1F]') {
            throw "Path contains invalid characters"
        }
        # Validate parent directory exists or can be created
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
```
**Fix Explanation:** Add ValidateScript to check for invalid characters; validate parent directory exists; add -RequireAdmin option

---

### Fix #9: Add Progress Indicator for Long Operations

**BEFORE (AI Version - NO PROGRESS):**
```powershell
$policyEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = @(1001, 1002)
    StartTime = (Get-Date).AddDays(-3)
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 10
```
**Line:** ~243  
**Problem:** Event log query can take 30+ seconds; user sees nothing; appears hung

**AFTER (Corrected - WITH PROGRESS):**
```powershell
Write-Progress -Activity "Collecting Event Logs" -Status "Querying System events..." -PercentComplete 25
$policyEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = @(1001, 1002)
    StartTime = (Get-Date).AddDays(-3)
    MaxEvents = 100
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 10

Write-Progress -Activity "Collecting Event Logs" -Status "Query complete" -PercentComplete 50 -Completed
```
**Fix Explanation:** Add Write-Progress before long operations; show percentage complete; clear progress when done

---

### Fix #10: Add Summary Statistics

**BEFORE (AI Version - BASIC SUMMARY):**
```powershell
Write-Host "Success Rate:           $($evidenceData.Summary.SuccessRate)%"
```
**Line:** ~600  
**Problem:** No detailed summary; hard to verify collection completeness

**AFTER (Corrected - DETAILED SUMMARY):**
```powershell
Write-Host ""
Write-Host "COLLECTION RESULTS" -ForegroundColor Cyan
Write-Host "===================="
Write-Host ""
Write-Host "Intune Deployment Data:"
Write-Host "  Device Enrollment:     $($intuneSection.Tests[0].Data.IsEnrolled)"
Write-Host "  Policy Events Found:   $($intuneSection.Tests[2].Data.EventCount)"
Write-Host ""
Write-Host "Applications:"
Write-Host "  Total Installed:       $($appsSection.Tests[0].Data.TotalApplications)"
Write-Host "  Recently Installed:    $($appsSection.Tests[1].Data.RecentApplicationCount)"
Write-Host "  Startup Applications:  $($appsSection.Tests[2].Data.StartupApplicationCount)"
Write-Host ""
Write-Host "Event Logs:"
Write-Host "  System Errors:         $($eventSection.Tests[0].Data.EventCount)"
Write-Host "  Application Errors:    $($eventSection.Tests[1].Data.EventCount)"
Write-Host ""
Write-Host "System Resources:"
Write-Host "  Memory Usage:          $($resourceSection.Tests[0].Data.UsagePercent)%"
Write-Host "  Disk Usage:            $($perfSection.Tests[2].Data.UsagePercent)%"
```
**Fix Explanation:** Add detailed summary table; show key metrics for each section; format as readable table; use color coding

---

## PRODUCTION-READINESS CHECKLIST

| Item | AI Version | Corrected |
|------|-----------|-----------|
| ✓ Handles deprecated cmdlets | ✗ | ✓ |
| ✓ Validates output path | ✗ | ✓ |
| ✓ Timeouts on long operations | ✗ | ✓ |
| ✓ Null reference handling | ✗ | ✓ |
| ✓ Confirmation for destructive actions | ✗ | ✓ |
| ✓ File logging | ✗ | ✓ |
| ✓ Color-coded output | ✗ | ✓ |
| ✓ Progress indicators | ✗ | ✓ |
| ✓ Detailed error messages | Partial | ✓ |
| ✓ Clear summary statistics | ✗ | ✓ |

---

## CONCLUSION

**AI Version:** 
- ✓ Good structure and logic
- ✗ Not production-ready (unsafe, limited error handling, unclear output)

**Corrected Version:**
- ✓ Production-ready
- ✓ Safe for enterprise use
- ✓ Clear error reporting
- ✓ Audit trails (file logging)
- ✓ User-friendly output
- ✓ Handles edge cases and old systems

**Recommendation:** Use Corrected Version for production deployment.

---

**Document Status:** Ready for Implementation  
**Version:** 2.0 (Production-Ready)
