# DWP Large File Finder (PowerShell 5.1)

This folder contains a strictly read-only script for identifying large files on Windows endpoints.

- Script: `DWP_Large_File_Finder.ps1`

## Read-only guarantee

The script only reads:

- File and folder metadata
- ACL owner information

It never:

- Deletes files
- Moves files
- Modifies files
- Renames files
- Compresses files
- Archives files

## Features

- Configurable size threshold (`-SizeThresholdMB`, default `100`)
- Configurable target scan path (`-TargetPath`)
- Recursive scanning of accessible folders
- Protected system folder exclusion by default
- Optional include flag for protected folders (`-IncludeProtectedSystemFolders`)
- Progress display during scan (`Write-Progress`)
- Graceful handling of inaccessible folders and access-denied conditions
- Action/warning/error logging to timestamped log file
- Report export to CSV, TXT, and HTML
- End summary with counts and storage totals
- Idempotent behavior (read-only and repeatable)

## Parameters

- `-SizeThresholdMB <int>`
  - Minimum file size in MB to include in report.
  - Default: `100`

- `-TargetPath <string>`
  - Drive/folder to scan, such as `C:\`, `D:\Data`, or `C:\Users`.
  - Must exist.

- `-IncludeProtectedSystemFolders`
  - Includes protected system folders that are skipped by default.

- `-OutputRoot <string>`
  - Optional output root for logs and reports.
  - Default: `LargeFileFinderOutput` under script folder.

## Output reports

Generated under `OutputRoot\Reports`:

- `LargeFiles_<timestamp>.csv`
- `LargeFiles_<timestamp>.txt`
- `LargeFiles_<timestamp>.html`

Generated under `OutputRoot\Logs`:

- `DWP_Large_File_Finder_<timestamp>.log`

## Report fields

Each report contains:

- File Name
- Full Path
- File Size (MB)
- File Size (GB)
- Date Created
- Last Modified Date
- File Owner (if available)

Sorted descending by file size (largest to smallest).

## Usage examples

### 1) Scan C drive with default threshold (100 MB)

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Large_File_Finder.ps1 -TargetPath "C:\"
```

### 2) Scan a specific folder with 500 MB threshold

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Large_File_Finder.ps1 -TargetPath "D:\Data" -SizeThresholdMB 500
```

### 3) Scan including protected system folders

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\DWP_Large_File_Finder.ps1 -TargetPath "C:\" -IncludeProtectedSystemFolders
```

## Summary output

At completion, the script reports:

- Total files scanned
- Total large files found
- Total storage consumed by matching files
- Inaccessible folder count
- Log/report output paths

## Limitations

- Some folders/files may remain inaccessible due to permissions, endpoint hardening, or security controls.
- File owner lookup may fail on certain files and will be recorded as blank in the report.
- Scanning entire system volumes can take significant time on large endpoints.
- The script does not detect sparse/compressed logical-vs-physical usage differences; it uses reported file length.
