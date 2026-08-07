# Prompt
---
You are a DWP engineer analysing shared drive access incident, using only the scope fact. Produce a ranked list of the 5 most likely causes for the shared drive access failure symptom.

Most probable first. For each give:

• Why this cause fits the scope facts
• The single fastest check to confirm or eliminate it
Do not commit to one cause yet.

scope facts:
symptom : Finance users unable to access mapped shared drives
who : All Finance users (approximately 45 users)
location : OU=Finance devices (DESKTOP-FB*)
since : Following the overnight device management migration
change : Drive mapping process was migrated from a Group Policy logon script to an Intune PowerShell script.
observations :

Issue affects all Finance users rather than a single device
Group Policy processing is successful
Shared drive mapping is failing
Drive letter is not being assigned
Intune script executes during sign-in process
No automatic retry is configured
A similar drive mapping process previously worked before the migration
save this analysis and hypothesis as file under day 4 Lab

# DWP Ranked Cause Analysis - Shared Drive Access Failure (Finance OU)

Date: 2026-08-07  
Analyst: DWP Engineer  
Status: Hypothesis only (no single cause selected)

## Scope Facts Used
- Symptom: Finance users unable to access mapped shared drives.
- Who: All Finance users (approximately 45 users).
- Location: OU=Finance devices (DESKTOP-FB*).
- Since: Following overnight device management migration.
- Change: Drive mapping moved from Group Policy logon script to Intune PowerShell script.
- Observations:
  - Issue affects all Finance users rather than one device.
  - Group Policy processing is successful.
  - Shared drive mapping is failing.
  - Drive letter is not being assigned.
  - Intune script executes during sign-in process.
  - No automatic retry is configured.
  - Similar mapping process worked before migration.

## Ranked Likely Causes (Most Probable First)

### 1) Intune PowerShell script logic/targeting does not assign the drive letter under Finance OU sign-in conditions
Why this fits scope facts:
- The failure began immediately after the migration change from GPO script to Intune script.
- The impact is broad (all Finance users), which aligns with a centralized script behavior issue.
- Group Policy is successful, so the break is likely in the new mapping path, not baseline policy processing.

Single fastest check:
- Review Intune script execution output/status for a representative affected Finance device and confirm whether the exact command that assigns the drive letter completed successfully or failed.

### 2) Script runs before required network/session dependency is ready, and with no retry the one-time mapping attempt is missed
Why this fits scope facts:
- Script is confirmed to execute during sign-in, and no automatic retry is configured.
- Symptom is specifically "drive letter not assigned," consistent with a missed one-time mapping window.
- Previous process worked pre-migration, suggesting execution timing/trigger behavior changed.

Single fastest check:
- Compare script run timestamp to first successful reachability/authentication of the file share on one affected device; if script runs earlier and never retries, this hypothesis is supported.

### 3) Intune assignment/filtering mismatch applies wrong script context or parameters to Finance OU devices
Why this fits scope facts:
- All Finance OU users are affected in a consistent pattern, suggesting a shared assignment/configuration issue.
- The mapping mechanism changed to Intune, making assignment scope and execution context primary suspects.
- Group Policy success indicates endpoints are otherwise processing managed configuration.

Single fastest check:
- Validate the Intune assignment for the mapping script specifically against the Finance device/user group and confirm the intended script version and parameters are what affected devices actually received.

### 4) Execution context/permissions of the Intune script differ from the prior GPO logon model and cannot complete user drive mapping
Why this fits scope facts:
- The migration changed delivery mechanism, which can also change run context.
- The script does execute, but mapping outcome fails (no drive letter), which is consistent with context mismatch at mapping time.
- Uniform impact across users points to a common context behavior, not isolated endpoint corruption.

Single fastest check:
- On one affected endpoint, verify the script run context used by Intune at sign-in and test whether that same context can map the target drive letter interactively.

### 5) Mapping script lacks resilient error handling and exits on first transient failure during sign-in
Why this fits scope facts:
- No automatic retry is configured.
- Symptom is persistent absence of drive letter assignment despite script execution.
- A similar process worked previously, implying migration introduced a less resilient execution path.

Single fastest check:
- Inspect script/transcript output for first error and confirm whether script exits immediately without retry or delayed second attempt logic.

## Note
- Ranking is based only on provided scope facts.
- This output intentionally does not conclude a single root cause yet.

## Evidence Assessment Against Each Hypothesis (Incident Window 08:00:01 onward)

### 1) Intune PowerShell script logic/targeting does not assign the drive letter under Finance OU sign-in conditions
Judgement: Supports

Why:
- The mapping script executes, then fails immediately, and the drive letter remains unassigned.

Determining evidence:
- ScriptRunner Info at 08:00:01: Executing `Map-FinBridgeDrives.ps1`.
- ScriptRunner Error at 08:00:03: Script failed with exit code 1 and "Network name cannot be found."
- Event 98 at 08:00:07 (Ntfs, Warning): Drive letter S: has not been assigned.

### 2) Script runs before required network/session dependency is ready, and with no retry the one-time mapping attempt is missed
Judgement: Supports

Why:
- The script reports network path inaccessible at execution time, then fails, and no retry is configured.

Determining evidence:
- ScriptRunner Warning at 08:00:03: `\\finbridge-fs01\\Finance` not accessible from SYSTEM context at execution time.
- ScriptRunner Error at 08:00:03: Mapping script failed (exit code 1).
- ScriptRunner Info at 08:00:04: No retry configured.

### 3) Intune assignment/filtering mismatch applies wrong script context or parameters to Finance OU devices
Judgement: Contradicts

Why:
- Evidence shows the intended script did execute, which argues against a pure assignment/filtering miss where script would not run or wrong payload would be absent.

Determining evidence:
- ScriptRunner Info at 08:00:01: `Map-FinBridgeDrives.ps1` is executed on affected device.
- ScriptRunner Info at 08:00:02: Context explicitly logged as SYSTEM for that execution.

### 4) Execution context/permissions of the Intune script differ from the prior GPO logon model and cannot complete user drive mapping
Judgement: Supports

Why:
- Logs explicitly show script running as SYSTEM and failing to access UNC path in that context; migration note states old method ran as USER and script was not updated for SYSTEM context.

Determining evidence:
- ScriptRunner Info at 08:00:02: Script context is SYSTEM account.
- ScriptRunner Warning at 08:00:03: UNC path not accessible from SYSTEM context at execution time.
- ScriptRunner Error at 08:00:03: Exit code 1, "Network name cannot be found."
- Migration change note (2024-03-14 23:30): Process changed from USER-context GPO script to SYSTEM-context Intune script without context handling update.

### 5) Mapping script lacks resilient error handling and exits on first transient failure during sign-in
Judgement: Supports

Why:
- Failure occurs on first attempt and there is no retry path, leaving drive letter unassigned.

Determining evidence:
- ScriptRunner Error at 08:00:03: Script fails on initial attempt.
- ScriptRunner Info at 08:00:04: No retry configured.
- Event 98 at 08:00:07 (Ntfs, Warning): Drive letter S: not assigned after failure.

## Interim Position
- All five hypotheses were assessed against provided evidence.
- No final winner is selected in this section by design.

## Addendum - Updated Event Details, Surviving Hypothesis, and Resolution

### Updated Event Details (Evidence-Linked)
- 08:00:01, ScriptRunner Info: `Map-FinBridgeDrives.ps1` execution started.
- 08:00:02, ScriptRunner Info: Script executed in SYSTEM account context.
- 08:00:03, ScriptRunner Warning: UNC path `\\finbridge-fs01\Finance` was not accessible from SYSTEM context at execution time.
- 08:00:03, ScriptRunner Error: Script failed with exit code 1 and error "Network name cannot be found."
- 08:00:04, ScriptRunner Info: No retry configured after failure.
- 08:00:05, Event 7036 (Service Control Manager): Workstation service entered running state.
- 08:00:06, Event 1500 (GroupPolicy): Group Policy processed successfully, confirming this is not a GP processing fault.
- 08:00:07, Event 98 (Ntfs, Warning): Drive letter S: was not assigned.
- Change-log evidence (2024-03-14 23:30): Mapping moved from GPO logon script (USER context) to Intune PowerShell script (SYSTEM context), and script was not updated for SYSTEM-context access behavior.

### Surviving Hypothesis (Post-Elimination)
The surviving hypothesis is that the migrated Intune mapping script ran in SYSTEM context instead of USER context, failed to access the Finance UNC path at sign-in, and because no retry existed, the drive letter assignment never occurred.

Why it survives the evidence:
- Execution context is explicitly SYSTEM at 08:00:02.
- UNC accessibility failure from SYSTEM context is explicitly logged at 08:00:03.
- Immediate script failure and no retry are explicitly logged at 08:00:03-08:00:04.
- Resulting symptom (S: not assigned) is explicitly logged at 08:00:07.
- GP success at 08:00:06 removes GP as the causal path.

### Detailed Resolution Steps (Operational)
1. Change mapping to user context
- Reconfigure deployment so drive mapping executes in USER context at sign-in, not SYSTEM context.
- Keep mapping ownership with the user session that requires drive letter S:.

2. Update script behavior for sign-in timing
- Add pre-check for UNC availability before mapping attempt.
- Add retry logic with short backoff so transient startup timing does not cause permanent failure.
- Mark success only when S: is actually assigned.

3. Redeploy corrected script through Intune
- Publish corrected script version to Finance scope.
- Confirm assignment targets intended Finance population and active script revision.

4. Recover affected endpoints
- Remove failed/partial mapping state for S: if present.
- Trigger Intune sync and require one sign-out/sign-in cycle to execute corrected flow.

5. Verify technical recovery
- Confirm script logs show USER-context execution.
- Confirm UNC path is reachable during script run.
- Confirm Event 98 is absent and drive letter S: is assigned.

6. Prevent recurrence
- Introduce migration gate: USER vs SYSTEM context compatibility must be tested before cutover.
- Require retry logic for sign-in-time drive mapping workflows.
- Add post-change smoke test: context check, UNC reachability, drive assignment, and persistence across relogin.
