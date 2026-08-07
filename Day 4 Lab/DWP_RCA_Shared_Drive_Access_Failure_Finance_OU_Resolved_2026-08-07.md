# DWP Root Cause Analysis (RCA) - Shared Drive Access Failure (Finance OU)

Date: 2026-08-07  
Analyst: DWP Engineer  
Incident Type: Shared drive mapping failure after migration  
Status: Resolved  
Resolution Time: 09:09 AM

## 1) Executive Summary
Following the overnight device-management migration, Finance users on OU=Finance devices could not access mapped shared drives because drive letter S: was not assigned. Investigation confirmed the new Intune mapping script ran in SYSTEM context, failed to access the Finance UNC path, and exited without retry. The prior GPO method had run in USER context, and the migrated script was not updated for SYSTEM-context behavior. The fix was applied and verified, and user login/host use was confirmed working at 09:09 AM with no issues reported.

## 2) Scope and Impact
- Affected users: All Finance users (approximately 45 users).
- Affected endpoints: OU=Finance devices (DESKTOP-FB*).
- Symptom: Shared drive mapping failure; drive letter S: not assigned.
- Start condition: Began after overnight migration from GPO logon script to Intune PowerShell script.

## 3) Supporting Evidence

### 3.1 Intune Management Extension Evidence
- 08:00:01, ScriptRunner Info: Executing `Map-FinBridgeDrives.ps1`.
- 08:00:02, ScriptRunner Info: Script context is SYSTEM account.
- 08:00:03, ScriptRunner Warning: Network path `\\finbridge-fs01\Finance` not accessible from SYSTEM context at execution time.
- 08:00:03, ScriptRunner Error: Script failed, exit code 1, error "Network name cannot be found."
- 08:00:04, ScriptRunner Info: No retry configured.

### 3.2 System Log Evidence (DESKTOP-FB041)
- 08:00:05, Event 7036 (Service Control Manager): Workstation service entered running state.
- 08:00:06, Event 1500 (GroupPolicy): Group Policy processed successfully.
- 08:00:07, Event 98 (Ntfs, Warning): File system could not map drive letter S:, drive letter not assigned.

### 3.3 Change Record Evidence
- 2024-03-14 23:30 migration note: Drive mapping changed from GPO logon script (runs as USER) to Intune PowerShell script (runs as SYSTEM).
- Change note also states script was not updated to handle SYSTEM context where UNC path mapping/credential behavior differs at login time.

## 4) Timeline (Incident to Resolution)
- 2024-03-14 23:30: Migration implemented from GPO USER-context mapping to Intune SYSTEM-context mapping.
- 08:00:01: Mapping script begins execution.
- 08:00:02: Script context logged as SYSTEM.
- 08:00:03: UNC path access failure and script exit code 1 logged.
- 08:00:04: No retry configured logged.
- 08:00:05: Workstation service running state logged.
- 08:00:06: Group Policy success logged (rules out GP failure as primary cause).
- 08:00:07: Drive S: not assigned logged.
- Remediation window: Corrected mapping approach and deployment behavior applied.
- 09:09 AM: Recovery verified; user logged in to host successfully; no issues reported.

## 5) Root Cause Statement
Primary root cause: The migrated Intune drive-mapping process executed under SYSTEM context instead of USER context, and the script was not adapted for this context shift. As a result, the script could not access `\\finbridge-fs01\Finance` at execution time, failed immediately, and with no retry logic configured, drive letter S: was never assigned.

## 6) 5 Whys Analysis
1. Why were Finance users unable to access mapped shared drives?
- Because drive letter S: was not assigned on affected devices.

2. Why was drive letter S: not assigned?
- Because `Map-FinBridgeDrives.ps1` failed during sign-in and exited with code 1.

3. Why did the script fail?
- Because the UNC path `\\finbridge-fs01\Finance` was not accessible from the script's SYSTEM context at execution time.

4. Why was the script running in a context that could not complete the mapping as implemented?
- Because migration changed execution from GPO USER context to Intune SYSTEM context.

5. Why did the migrated solution fail broadly and persist?
- Because the script was not updated for SYSTEM-context behavior and no retry mechanism was configured to recover from first-attempt failure.

## 7) Corrective Actions Applied
1. Reconfigured mapping approach so drive mapping executes in USER context for sign-in session ownership of S:.
2. Updated script behavior to include execution-time checks and resilient retry handling before final failure.
3. Redeployed corrected script/configuration through Intune to Finance scope.
4. Triggered client sync/re-execution and validated drive mapping outcome.

## 8) Verification of Recovery
- Technical verification:
  - Script execution completed with corrected behavior.
  - Drive letter S: assignment restored on affected host(s).
  - No repeat of immediate failure pattern after remediation run.
- User verification:
  - User login to host confirmed working at 09:09 AM.
  - No further issues reported.

## 9) Preventive Actions (CAPA)
1. Migration context gate
- Require explicit USER vs SYSTEM compatibility validation before cutover of any login-time mapping workflow.

2. Resilience requirement for mapping automation
- Mandate retry logic and dependency checks (network path availability) for sign-in-time scripts.

3. Post-change smoke test standard
- Define required validation set: context confirmation, UNC path reachability, drive-letter assignment, and relogin persistence.

4. Change-quality control
- Block production rollout when script context assumptions from legacy delivery model are not revalidated in target management platform.

5. Runbook update
- Add known-error detection pattern to DWP KB using these signals: ScriptRunner SYSTEM context line, UNC inaccessible warning, exit code 1 network-name error, and Event 98 S: not assigned.

## 10) Closure Statement
Incident is closed. Root cause was verified as context mismatch introduced by migration (USER to SYSTEM) combined with no retry behavior in the new mapping path. Corrective changes restored service, and recovery was validated at 09:09 AM with successful user login and no issues reported.
