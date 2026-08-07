# Prompt
---
you are a PowerShell Developer(version 5.1). write a PowerShell script for a DWP engineer to report disk health and optimization status and the script should be safe to use on windows endpoint with following requirement

1. The script must be strictly read-only and must never run defragmentation, TRIM operations, disk repair, CHKDSK fixes, optimization actions, or make configuration changes.
2. Report Drive Letter, Volume Label, File System, Total Capacity, Used Space, Free Space, and Free Space Percentage.
3. Report Physical Disk information including Model, Media Type (SSD/HDD), Serial Number (if available), Operational Status, and Health Status.
4. Report disk optimization status using native Windows reporting mechanisms.
5. Report the last optimization or maintenance date if available.
6. Highlight disks with low free space, warning health status, or unknown health status.
7. Use only read-only PowerShell commands and WMI/CIM queries.
8. Use try/catch error handling for every disk and health query.
9. Continue execution even if information for one disk cannot be retrieved.
10. Log every action, warning, and error to a date and timestamped log file.
11. Generate reports in Console, CSV, and HTML format.
12. Report a summary at the end showing total disks detected, healthy disks, warning disks, critical disks, and the lowest free space percentage.
13. Add comments to every section explaining what it does.
14. Ensure the script execution is idempotent.
15. Clearly document within the script and README that the script is strictly read-only and performs no remediation activities.
16. Create a readme file explaining the collected metrics, report formats, limitations, and available script parameters.

Create the script under Day 3 Lab folder inside Disk Health Reporter folder

# DWP Disk Health Reporter (PowerShell 5.1)

This folder contains a strictly read-only disk health and optimization status reporting script for Windows endpoints.

- Script: `DWP_Disk_Health_Reporter.ps1`

## Strict read-only statement

The script is strictly read-only.

It only performs reporting through PowerShell, WMI/CIM, scheduled task status, and event log reads.

It does not run any remediation and never performs:

- Defragmentation
- TRIM operations
- CHKDSK repair/fix operations
- Disk repair operations
- Optimization actions
- Configuration changes

## Collected metrics

For each logical disk/volume, the script reports:

- Drive Letter
- Volume Label
- File System
- Total Capacity (GB)
- Used Space (GB)
- Free Space (GB)
- Free Space Percentage

Physical disk context (best effort):

- Model
- Media Type (SSD/HDD/Unknown depending on system support)
- Serial Number (if available)
- Operational Status
- Health Status

Optimization/maintenance context:

- ScheduledDefrag task state
- Last maintenance run date (ScheduledDefrag task last run)
- Last optimization event date (from Defrag event sources when available)

Highlighting:

- Low free space
- Warning/degraded health
- Unknown health

## Script parameters

- `-DriveLetters <string[]>`
  - Optional filter (examples: `C`, `D`).
  - If omitted, all mounted drive-letter volumes are reported.

- `-LowFreeSpacePercentThreshold <int>`
  - Warning threshold for low free space.
  - Default: `15`

- `-OutputRoot <string>`
  - Optional output root for logs and reports.
  - Default: `DiskHealthReporterOutput` under script folder.

## Report formats

The script generates:

- Console table output
- CSV report (`DiskHealth_<timestamp>.csv`)
- HTML report (`DiskHealth_<timestamp>.html`)

Log file:

- `DWP_Disk_Health_Reporter_<timestamp>.log`

## Summary output

At completion, the script reports:

- Total disks detected
- Healthy disks
- Warning disks
- Critical disks
- Lowest free space percentage (and drive)
- Output file paths

## Usage examples

### 1) Report all mounted volumes

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Disk_Health_Reporter.ps1
```

### 2) Report only C and D drives

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Disk_Health_Reporter.ps1 -DriveLetters C,D
```

### 3) Change low-space warning threshold to 20%

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Disk_Health_Reporter.ps1 -LowFreeSpacePercentThreshold 20
```

## Limitations

- Physical disk mapping to each volume is best-effort and can vary by storage controller/driver support.
- Some fields may show `Unknown` if the endpoint does not expose that metadata.
- Event log retention policies may limit visibility of older optimization/maintenance events.
- Access to certain telemetry can vary with privileges and endpoint hardening.

## Idempotency

The script is idempotent because it is read-only and does not modify endpoint state.
Running it repeatedly only creates new timestamped report/log files.
