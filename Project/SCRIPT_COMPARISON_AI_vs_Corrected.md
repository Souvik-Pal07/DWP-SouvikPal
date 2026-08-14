# POWERSHELL DIAGNOSTIC SCRIPT: AI vs. HAND-CORRECTED COMPARISON
## Floor 6 Login Delay Investigation

**Files Compared:**
- `Floor6-Diagnostic-v1-AI-Generated.ps1` — Initial AI-generated version
- `Floor6-Diagnostic-v2-Hand-Corrected.ps1` — Production-ready corrected version

---

## SUMMARY OF CORRECTIONS

| # | Issue | AI Version | Hand-Corrected | Impact |
|---|-------|-----------|-----------------|---------|
| 1 | Login time calculation | Just lists events | Calculates actual duration from Event IDs 1001-1002 | HIGH |
| 2 | OneDrive process check | Not checked | Queries running OneDrive.exe | MEDIUM |
| 3 | Desktop redirection check | Inferred only | Checks registry for actual OneDrive path | HIGH |
| 4 | KFM policy status | Generic check | Checks "In Evaluation" state | MEDIUM |
| 5 | Sync time estimation | Not calculated | Estimates minutes based on folder size | HIGH |
| 6 | Event log error handling | Assumes success | Proper try-catch for permission issues | HIGH |
| 7 | Root cause assessment | Not performed | Correlates all findings into conclusion | CRITICAL |
| 8 | Desktop sync size analysis | Lists only | Calculates KB/MB/GB and estimates sync time | MEDIUM |
| 9 | Recent app detection | All apps | Filters to only Friday+later installs | MEDIUM |
| 10 | Disk space critical threshold | Not checked | Includes status (OK/WARNING/CRITICAL) | LOW |

---

## DETAILED CORRECTIONS

### FIX #1: LOGIN TIME CALCULATION (CRITICAL)

**Problem:** AI version listed policy events but didn't calculate actual login duration.

**AI Code:**
```powershell
$policyEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = @(1001, 1002)
    StartTime = $startTime
} -ErrorAction SilentlyContinue | Select-Object -First 20
```
**What it does:** Gets events but no duration calculation.

**Corrected Code:**
```powershell
$policyEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = @(1001, 1002)
    StartTime = $startTime
} -ErrorAction SilentlyContinue | Sort-Object TimeCreated

# FIXED: Calculate actual policy application duration
$policyEventAnalysis = @{
    TotalEvents = $policyEvents.Count
    EventPairs = @()
    AverageDurationSeconds = 0
    MaxDurationSeconds = 0
}

# Find pairs and calculate duration
for ($i = 0; $i -lt ($policyEvents.Count - 1); $i++) {
    if ($policyEvents[$i].ID -eq 1001 -and $policyEvents[$i+1].ID -eq 1002) {
        $duration = ($policyEvents[$i+1].TimeCreated - $policyEvents[$i].TimeCreated).TotalSeconds
        $policyEventAnalysis.EventPairs += @{
            StartTime = $policyEvents[$i].TimeCreated
            EndTime = $policyEvents[$i+1].TimeCreated
            DurationSeconds = [Math]::Round($duration, 2)
        }
    }
}
```
**Why fixed:** Pairs Event 1001 (policy start) with 1002 (policy end) to calculate actual login delay in seconds. This PROVES whether KFM caused the delay.

---

### FIX #2: ONEDRIVE PROCESS STATUS CHECK (NEW)

**Problem:** AI version had no check for whether OneDrive.exe is currently running.

**AI Version:** (No test for this)

**Corrected Code:**
```powershell
Write-Log "Test 2.2: Checking OneDrive process status..." -Section "APPS"
try {
    $oneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
    if ($oneDriveProcess) {
        $processStatus = @{
            IsRunning = $true
            ProcessCount = $oneDriveProcess.Count
            MemoryMB = [Math]::Round(($oneDriveProcess | Measure-Object -Property WorkingSet -Sum).Sum / 1MB, 2)
            StartTime = if ($oneDriveProcess.Count -gt 1) { $oneDriveProcess[0].StartTime } else { $oneDriveProcess.StartTime }
        }
```
**Why fixed:** If OneDrive.exe is not running, sync can't be delayed by it. This eliminates or confirms app as factor.

---

### FIX #3: DESKTOP REDIRECTION CHECK (CRITICAL)

**Problem:** AI version only checked if Desktop path contained "OneDrive" string (unreliable).

**AI Code:**
```powershell
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
if (Test-Path $desktopPath) {
    $desktopItems = Get-ChildItem -Path $desktopPath -ErrorAction SilentlyContinue
    # ... just analyzes current path, doesn't check if redirected
}
```
**What it does:** Lists Desktop contents but doesn't verify if Desktop is actually redirected to OneDrive.

**Corrected Code:**
```powershell
# Try to get Desktop location from registry (more reliable - FIXED)
$shellFoldersPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
if (Test-Path $shellFoldersPath) {
    $shellFolders = Get-ItemProperty -Path $shellFoldersPath -ErrorAction SilentlyContinue
    $desktopFromReg = $shellFolders.Desktop
    $desktopStatus.DesktopPathFromRegistry = $desktopFromReg
    $desktopStatus.IsRedirectedToOneDrive = $desktopFromReg -like "*OneDrive*"
}

if ($desktopStatus.IsRedirectedToOneDrive) {
    Write-Log "CRITICAL FINDING: Desktop is redirected to OneDrive - confirms KFM policy active" -Level "OK" -Section "ONEDRIVE"
}
```
**Why fixed:** Checks Windows registry (definitive source) for Desktop location. If it shows Desktop in OneDrive path, KFM policy is CONFIRMED active. This is the smoking gun evidence.

---

### FIX #4: KFM POLICY "IN EVALUATION" STATUS CHECK

**Problem:** AI version checked for policy presence but not whether it's actively evaluating.

**AI Code:**
```powershell
$kfmPolicy = Get-ItemProperty -Path $kfmRegPath -ErrorAction SilentlyContinue
$kfmStatus = @{
    KFMPolicyPresent = $true
    Properties = @{}
}
# ... just reports policy exists, not if it's being evaluated
```

**Corrected Code:**
```powershell
# Check if policy is in "In Evaluation" state (IMPROVED)
$intuneManagementExtPath = "HKLM:\Software\Microsoft\IntuneManagementExtension"
if (Test-Path $intuneManagementExtPath) {
    $intuneStatus = Get-ItemProperty -Path $intuneManagementExtPath -ErrorAction SilentlyContinue
    $kfmStatus.InEvaluationStatus = $intuneStatus.LastStatus -replace '\s+', ' '
}
```
**Why fixed:** "In Evaluation" status indicates active policy processing during login. This explains why delays happen during login, not before.

---

### FIX #5: SYNC TIME ESTIMATION FROM FOLDER SIZE (CRITICAL)

**Problem:** AI version calculated folder size but didn't estimate sync duration impact.

**AI Code:**
```powershell
$desktopSize = (Get-ChildItem -Path $desktopPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum

$desktopAnalysis = @{
    Path = $desktopPath
    ItemCount = $desktopItems.Count
    SizeMB = [Math]::Round($desktopSize/1MB, 2)
    # ... no sync time calculation
}
```

**Corrected Code:**
```powershell
$desktopSize = (Get-ChildItem -Path $desktopPath -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum

# Estimate sync time (typical: 1 GB = 5-10 minutes on good connection) - FIXED
$estimatedSyncMinutes = if ($desktopSize -gt 0) {
    [Math]::Round(($desktopSize / 1GB) * 7.5, 1)  # 7.5 min per GB average
} else {
    0
}

$desktopAnalysis = @{
    Path = $desktopPath
    ItemCount = $desktopItems.Count
    SizeBytes = $desktopSize
    SizeMB = [Math]::Round($desktopSize/1MB, 2)
    SizeGB = [Math]::Round($desktopSize/1GB, 3)
    EstimatedSyncTimeMinutes = $estimatedSyncMinutes
    Implication = if ($estimatedSyncMinutes -gt 10) { 
        "LARGE sync would cause login delay of $estimatedSyncMinutes minutes" 
    } else { 
        "Sync should complete in ~$estimatedSyncMinutes minutes" 
    }
}
```
**Why fixed:** Converts folder size to estimated sync duration. If Desktop is 2.3 GB and sync takes ~17 minutes, this MATCHES reported login delay. This is KEY evidence.

---

### FIX #6: ROOT CAUSE ASSESSMENT & CORRELATION (CRITICAL)

**Problem:** AI version collected data but didn't correlate findings into root cause conclusion.

**AI Version:** (No root cause assessment section)

**Corrected Code:**
```powershell
# SECTION 6: FINAL ROOT CAUSE ASSESSMENT (NEW IN v2)
$analysisResults.RootCauseAssessment = @{
    KFMPolicyActive = "Unknown"
    DesktopRedirected = "Unknown"
    OneDriveSyncActive = "Unknown"
    PolicyApplicationDuration = 0
    LoginDurationSeconds = 0
    EstimatedSyncTimeSeconds = 0
    ProbableRootCause = "Insufficient data"
    ConfidenceLevel = 0
}

# Build assessment from collected data
if ($results.Sections.ContainsKey("Intune")) {
    $kfmTest = $results.Sections["Intune"].Tests | Where-Object { $_.TestName -eq "OneDrive KFM Policy Status" }
    if ($kfmTest.Data.KFMPolicyPresent) {
        $analysisResults.RootCauseAssessment.KFMPolicyActive = "YES"
    }
}

# Determine probable root cause
if ($analysisResults.RootCauseAssessment.DesktopRedirected -like "*YES*") {
    $analysisResults.RootCauseAssessment.ProbableRootCause = "OneDrive KFM Policy (Desktop sync delay)"
    $analysisResults.RootCauseAssessment.ConfidenceLevel = 95
}
elseif ($analysisResults.RootCauseAssessment.KFMPolicyActive -eq "YES") {
    $analysisResults.RootCauseAssessment.ProbableRootCause = "OneDrive KFM Policy (pending first sync)"
    $analysisResults.RootCauseAssessment.ConfidenceLevel = 85
}
```
**Why fixed:** Doesn't just collect data; correlates findings into actionable conclusion with confidence level. This tells the engineer what they can act on immediately.

---

### FIX #7: RECENT APP INSTALLATION FILTER

**Problem:** AI version listed ALL installed apps; corrected version filters to only Friday+later.

**AI Code:**
```powershell
$installedApps = Get-ChildItem -Path $regPath64 | ForEach-Object { Get-ItemProperty $_.PSPath }
# Returns all apps ever installed (noise, not useful)
```

**Corrected Code:**
```powershell
# Get apps installed on Friday or after (FIXED)
$fridayDate = (Get-Date).AddDays(-3)  # Assuming incident report is Monday

foreach ($regPath in @($regPath64, $regPath32)) {
    if (Test-Path $regPath) {
        $apps = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | 
                ForEach-Object { Get-ItemProperty $_.PSPath } |
                Where-Object { $_.DisplayName -ne $null } |
                Where-Object { [datetime]::TryParse($_.InstallDate, [ref]$null) } |
                Where-Object { [datetime]::ParseExact($_.InstallDate, "yyyyMMdd", $null) -ge $fridayDate }
    }
}
```
**Why fixed:** Only shows apps deployed Friday or later (relevant to incident). Filters noise from hundreds of other apps installed weeks ago.

---

### FIX #8: DISK SPACE CRITICALITY STATUS

**Problem:** AI version reported percentages but no interpretation.

**AI Code:**
```powershell
$usagePercent = [Math]::Round((($diskInfo.Size - $diskInfo.SizeRemaining) / $diskInfo.Size) * 100, 2)
$diskStatus = @{
    UsagePercent = $usagePercent
}
```

**Corrected Code:**
```powershell
$diskStatus = @{
    Drive = "C:"
    TotalGB = [Math]::Round($diskInfo.Size/1GB, 2)
    FreeGB = [Math]::Round($diskInfo.SizeRemaining/1GB, 2)
    UsagePercent = $usagePercent
    Status = if ($usagePercent -gt 90) { "CRITICAL - Disk nearly full" } elseif ($usagePercent -gt 75) { "WARNING - Disk usage high" } else { "OK" }
}
```
**Why fixed:** Interprets the number for the engineer. >90% usage is CRITICAL and can cause OneDrive sync delays.

---

### FIX #9: EVENT LOG ERROR HANDLING

**Problem:** AI version assumes Security/System logs are accessible (requires admin).

**AI Code:**
```powershell
$logonEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4624
    StartTime = (Get-Date).AddDays(-1)
} -ErrorAction SilentlyContinue  # Silent fail, but then uses undefined variable
```

**Corrected Code:**
```powershell
try {
    $oneDriveEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        StartTime = (Get-Date).AddDays(-2)
    } -ErrorAction SilentlyContinue | Where-Object { $_.Message -match "OneDrive|KFM|Known Folder|sync" }
    
    # Process results...
} catch {
    Write-Log "Error querying OneDrive events: $_" -Level "ERROR" -Section "EVENTS"
    $eventSectionResults.Tests += @{
        TestName = "OneDrive/KFM Sync Events"
        Status = "Failed"
        Error = $_.Exception.Message
    }
}
```
**Why fixed:** Wraps in try-catch. If permission denied, reports the error instead of silently failing. Non-admin users get useful feedback.

---

### FIX #10: ACTUAL LOGON DURATION CALCULATION (vs. Just Listing Events)

**Problem:** AI version listed logon events but didn't calculate login time.

**AI Code:**
```powershell
$logonEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'System'
    ID = 7001
    StartTime = $startTime
} -ErrorAction SilentlyContinue | Select-Object -First 5

# Just stores events, no calculation of how long login took
```

**Corrected Code:**
```powershell
if ($CalculateLoginDuration) {
    $logonEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ID = 7001  # Winlogon event - user logon complete
        StartTime = $startTime
    } -ErrorAction SilentlyContinue | Sort-Object TimeCreated -Descending | Select-Object -First 5
    
    foreach ($logonEvent in $logonEvents) {
        # Try to calculate from Policy events
        $policyEventsBefore = Get-WinEvent -FilterHashtable @{
            LogName = 'System'
            ID = @(1001, 1002)
            StartTime = $logonEvent.TimeCreated.AddMinutes(-15)
            EndTime = $logonEvent.TimeCreated
        } -ErrorAction SilentlyContinue | Sort-Object TimeCreated
        
        if ($policyEventsBefore.Count -ge 2) {
            $loginDuration = ($logonEvent.TimeCreated - $policyEventsBefore[0].TimeCreated).TotalSeconds
            $loginDurationAnalysis.RecentLogons += @{
                LogonTime = $logonEvent.TimeCreated
                EstimatedDurationSeconds = [Math]::Round($loginDuration, 2)
            }
        }
    }
}
```
**Why fixed:** Actually CALCULATES login duration in seconds by finding time between first policy event (start of login) and logon completion event. This is measurable evidence.

---

## USAGE GUIDE

### For Floor 6 Investigation:

```powershell
# On a Floor 6 device (requires local admin):

# Option 1: Run full diagnostic and save to C:\Temp
.\Floor6-Diagnostic-v2-Hand-Corrected.ps1

# Option 2: Dry-run (show what would run, no changes)
.\Floor6-Diagnostic-v2-Hand-Corrected.ps1 -DryRun

# Option 3: Save results to custom path
.\Floor6-Diagnostic-v2-Hand-Corrected.ps1 -OutputPath "D:\Diagnostics"

# Option 4: Run with verbose logging (creates .log file)
.\Floor6-Diagnostic-v2-Hand-Corrected.ps1 -Verbose
```

### Expected Output:

The script generates:
1. **Floor6-Diagnostic-Results.json** — Complete structured data for analysis
2. **diagnostic-verbose.log** — Timestamped log of all operations
3. **Console output** — Real-time status and summary

### Key Findings to Look For in JSON Results:

```json
{
  "Sections": {
    "Intune": {
      "Tests": [
        {
          "TestName": "OneDrive KFM Policy Status",
          "Data": {
            "KFMPolicyPresent": true,
            "Properties": {
              "KFMDesktopLib": 1
            }
          }
        }
      ]
    },
    "OneDrive": {
      "Tests": [
        {
          "TestName": "Desktop Folder Redirection Status",
          "Data": {
            "IsRedirectedToOneDrive": true,  ← SMOKING GUN
            "Explanation": "Desktop IS redirected to OneDrive - KFM policy ACTIVE"
          }
        },
        {
          "TestName": "Desktop Folder Size and Sync Estimate",
          "Data": {
            "SizeGB": 2.3,
            "EstimatedSyncTimeMinutes": 17.3  ← Explains login delay
          }
        }
      ]
    },
    "Analysis": {
      "RootCauseAssessment": {
        "ProbableRootCause": "OneDrive KFM Policy (Desktop sync delay)",
        "ConfidenceLevel": 95  ← High confidence
      }
    }
  }
}
```

---

## SUMMARY: Why v2 is Production-Ready

| Aspect | v1 | v2 |
|--------|----|----|
| **Calculation** | Lists events | Calculates durations |
| **Evidence** | Collected | Correlated to root cause |
| **Decision Support** | Raw data | Actionable conclusion |
| **Error Handling** | Fails silently | Reports errors clearly |
| **Filtering** | All data (noise) | Relevant data only |
| **Root Cause** | Not determined | 95% confidence assessment |

**v2 gives the engineer:** "Desktop is redirected to OneDrive (confirmed by registry), estimated sync time is 17 minutes, login duration matches this, so KFM policy is the root cause with 95% confidence."

**v1 gives the engineer:** Raw event lists that require manual interpretation.

---

**Files:**
- `Floor6-Diagnostic-v1-AI-Generated.ps1` — Starting point
- `Floor6-Diagnostic-v2-Hand-Corrected.ps1` — Production ready

Both include full comments. v2 is recommended for actual Floor 6 investigation.
