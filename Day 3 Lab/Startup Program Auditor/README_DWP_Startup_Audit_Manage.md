# DWP Startup Audit and Management Script (PowerShell 5.1)

This folder includes:

- Script: `DWP_Startup_Audit_Manage.ps1`

The script audits startup programs and optionally disables entries by program name. It supports dry run, backup before changes, rollback, per-operation error handling, and detailed logging.

## Data sources audited

The script enumerates startup entries from:

- Startup folders:
  - Current User startup folder
  - All Users startup folder
- Registry Run keys:
  - `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
  - `HKLM:\Software\Microsoft\Windows\CurrentVersion\Run`
- Scheduled Tasks configured with logon triggers

## Report fields

The report (CSV) includes:

- Program Name
- Startup Location
- Executable Path
- Publisher (if available)
- Status (`Enabled`/`Disabled`)

## Parameters

- `-Audit`
  - Optional switch for explicit audit mode.
  - Default mode if no other mode is selected.

- `-DisableProgramName <string>`
  - Enables disable mode.
  - Disables startup entries where Program Name contains the provided text.

- `-DryRun`
  - Used with disable mode.
  - Shows what would be disabled without making changes.

- `-Rollback`
  - Enables rollback mode.

- `-BackupFile <string>`
  - Used with rollback mode.
  - Path to the JSON backup created before a disable run.

- `-ReportPath <string>`
  - Optional path for output report CSV.
  - Default is under `StartupState\Reports`.

- `-StateRoot <string>`
  - Optional root folder for logs, backups, and reports.
  - Default is `StartupState` under script directory.

## Behavior notes

- The script validates existence of entries before modifying them.
- Every modification operation is wrapped in try/catch.
- Script continues execution if one disable operation fails.
- All actions, warnings, and errors are logged to a timestamped log file.
- Script is idempotent:
  - Already-disabled items are skipped safely.
  - Rollback skips entries already restored.

## Usage examples

### 1) Audit only

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Startup_Audit_Manage.ps1
```

### 2) Dry-run disable by program name

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Startup_Audit_Manage.ps1 -DisableProgramName "Teams" -DryRun
```

### 3) Disable matching entries

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Startup_Audit_Manage.ps1 -DisableProgramName "OneDrive"
```

### 4) Rollback from backup

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Startup_Audit_Manage.ps1 -Rollback -BackupFile ".\StartupState\Backups\Startup_Backup_20260805_090000.json"
```

## Rollback procedure

1. Run a disable operation (non-dry-run). A backup JSON is created in `StartupState\Backups`.
2. Locate the backup file path from the console output or log.
3. Execute rollback mode with `-Rollback -BackupFile <path>`.
4. Confirm restored state using a new audit run and review the generated report.

## Summary output

At run completion, the script reports:

- Total startup entries found
- Enabled entries
- Disabled entries
- Modified entries
- Warning/error counts
- Report path, backup path (if created), and log path
