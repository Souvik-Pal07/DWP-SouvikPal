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
