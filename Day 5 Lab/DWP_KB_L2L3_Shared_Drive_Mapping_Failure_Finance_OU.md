# DWP L2/L3 Knowledge Base: Shared Drive Mapping Failure - Finance OU (Intune USER vs SYSTEM Context)

| Field | Detail |
|---|---|
| **Version** | v 1.0 |
| **Date** | 07/08/2026 |
| **Status** | Draft |
| **Audience** | DWP L2/L3 Engineer |

---

## Background
Finance users require drive `S:` (path `\\finbridge-fs01\Finance`) at sign-in for daily processing. During migration, drive mapping moved from a GPO logon script (USER context) to an Intune PowerShell script. If mapping runs in SYSTEM context, the user-session drive is not reliably created, so users lose access to shared Finance files.

---

## Symptom
What users report:
- "S: drive is missing"
- "Cannot open Finance shared drive"
- "Network name cannot be found" message

What engineer observes:
- `S:` absent in `Get-PSDrive -PSProvider FileSystem`
- Intune Management Extension log shows script failure with exit code `1`
- Event Viewer System log contains Event ID `98` indicating drive letter not assigned
- Group Policy may still be healthy (Event ID `1500` present), which helps isolate cause to Intune script path

---

## Root Cause
The migrated script `Map-FinBridgeDrives.ps1` executed in SYSTEM context (`Run this script using the logged on credentials = No`) and was not adapted for that context. SYSTEM could not access `\\finbridge-fs01\Finance` at execution time and the script exited with code `1` without retry.

Evidence that confirms root cause:
- Intune log line: `Script context is SYSTEM account`
- Intune log line: UNC path inaccessible / network name cannot be found
- Intune log line: `exit code 1`
- Intune log line: `No retry configured`
- Windows System Event ID `98` (Ntfs): drive letter `S:` not assigned
- GroupPolicy Operational Event ID `1500` success indicates GP was not primary cause

---

## Detection
Follow in order before any change.

### 1) Confirm Intune script failure signature
Action:
- On affected endpoint open `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` in Notepad.
- Use `Ctrl+End`, then `Ctrl+F` for `Map-FinBridgeDrives`.

Exact log location:
- File: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`

Field/value to check:
- Script name field/text: `Map-FinBridgeDrives.ps1`
- Context field/text: `Script context is SYSTEM account`
- Error field/text: `Network name cannot be found` or UNC not accessible
- Result field/text: `exit code 1`
- Retry field/text: `No retry configured`

Pass criteria:
- All above strings appear in same execution window.

### 2) Confirm drive assignment failure in Windows System log
Action:
- Open Event Viewer: `eventvwr.msc`.
- Path: `Windows Logs > System`.
- Right pane: `Filter Current Log...`.

Exact log location:
- `Event Viewer > Windows Logs > System`

Field/value to check:
- `<All Event IDs>` = `98`
- `Source` = `Ntfs`
- `Level` = `Warning`
- `General` message contains `could not map drive letter S:, drive letter not assigned`

Pass criteria:
- Event ID `98` found at incident time.

### 3) Confirm Group Policy baseline (rule-out check)
Action:
- In Event Viewer go to `Applications and Services Logs > Microsoft > Windows > GroupPolicy > Operational`.
- Filter Current Log: Event ID `1500`.

Exact log location:
- `Event Viewer > Applications and Services Logs > Microsoft > Windows > GroupPolicy > Operational`

Field/value to check:
- `<All Event IDs>` = `1500`
- `Source` = `GroupPolicy`
- `Level` = `Information`
- `General` contains `processed successfully`

Pass criteria:
- Event `1500` present near startup window.

### 4) Comparison check (affected vs control)
Action:
- Compare one affected Finance endpoint vs one control endpoint (non-affected device or pilot device with working mapping).

Compare these exact fields:
- Intune log context line: `SYSTEM account` (affected) vs no SYSTEM context failure pattern (control)
- Intune log result: `exit code 1` (affected) vs success / no failure (control)
- Windows System Event ID `98`: present (affected) vs absent (control)
- `Get-PSDrive` output: no `S:` (affected) vs `S: -> \\finbridge-fs01\Finance` (control)

Decision gate:
- Only proceed to Resolution when affected/control delta matches all four points.

### 5) Include full event set in ticket notes
Record these IDs even if some are informational:
- `7036` (Service Control Manager, Workstation running)
- `1500` (GroupPolicy success baseline)
- `98` (Ntfs drive mapping warning)

---

## Resolution
All steps below use Azure portal path and expected result.

> Elevated permissions required: Intune Administrator or Global Administrator.

1. Open Azure portal at `https://portal.azure.com`.
Expected result: Portal home page loads.

2. In top search bar, search `Microsoft Intune` and open it.
Expected result: Intune blade opens in Azure portal.

3. In Intune, navigate to `Devices > Scripts and remediations > Platform scripts`.
Expected result: Platform scripts list is visible.

4. Open script `Map-FinBridgeDrives.ps1`.
Expected result: Script overview page opens.

5. Open `Properties`, then click `Edit`.
Expected result: Edit wizard opens (`Basics > Script settings > Assignments > Review + save`).

6. In `Script settings`, set `Run this script using the logged on credentials` to `Yes`.
Expected result: Setting value shows `Yes`.

7. Download current script backup, then upload corrected script with retry logic (3 retries, 15 seconds delay) for mapping `S:` to `\\finbridge-fs01\Finance`.
Expected result: New script file is attached in Script settings.

8. Go to `Assignments` and confirm Finance device group remains included.
Expected result: Correct Finance group visible; no unintended groups added.

9. Go to `Review + save` and click `Save`.
Expected result: Save confirmation banner appears; script modified timestamp updates.

10. Navigate to `Devices > All devices`, open each affected endpoint, click `Sync`.
Expected result: `Sync request sent` notification appears for each device.

11. After 5 to 10 minutes, re-open endpoint log `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`.
Expected result: New run block appears after sync timestamp with success mapping line and no `exit code 1`.

---

## Verification
Confirm all checks before closure:

1. Endpoint PowerShell:
`Get-PSDrive -PSProvider FileSystem | Select Name,Root`
Pass: `S` exists and `Root` is `\\finbridge-fs01\Finance`.

2. Endpoint PowerShell:
`Test-Path "\\finbridge-fs01\Finance"`
Pass: returns `True`.

3. Intune log (`C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log`):
Pass: most recent run shows mapping success and no `SYSTEM account` failure pattern.

4. User sign-out/sign-in test:
Pass: `S:` persists after re-login.

5. User functional test:
Pass: user opens files from `S:` without error.

---

## Rollback
Use if issue worsens after change.

1. Azure portal path: `https://portal.azure.com > Microsoft Intune > Devices > Scripts and remediations > Platform scripts > Map-FinBridgeDrives.ps1 > Properties > Edit`.
Action: set `Run this script using the logged on credentials` back to `No` and re-upload original backup script.
Expected result: Original script configuration restored.

2. Save and force device sync from `Devices > All devices > <device> > Sync`.
Expected result: Reverted script distributed.

3. Apply temporary local workaround on affected endpoint:
`New-PSDrive -Name "S" -PSProvider FileSystem -Root "\\finbridge-fs01\Finance" -Persist -Scope Global`
Expected result: `S:` available for immediate user continuity (temporary).

4. Escalate to Endpoint Engineering with: script version, group assignment, affected hostnames, timestamps, event IDs `98/1500/7036`, and Intune log excerpts.
Expected result: Ownership transferred with complete diagnostics.

---

## Preventive
Implement these specific controls to prevent recurrence:

1. Add a mandatory `Execution Context Gate` in change workflow:
- Owner: Change manager | Timing: Before deployment | Mode: Manual [REQUIRES: ITSM form update].
- Signal: required field `Run context validated: USER/SYSTEM` populated with evidence link.
- Pass/Fail: Pass = field completed and evidence attached; Fail = blank field or missing evidence.
- If fail: CAB rejects change; Automation note: enforce mandatory field with workflow validation.

2. Add automated pre-deploy script lint rule:
- Owner: Release engineer | Timing: Before deployment | Mode: Automated [REQUIRES: script lint pipeline].
- Signal: lint checks for drive-map commands plus setting `Run this script using the logged on credentials`.
- Pass/Fail: Pass = USER-context setting is `Yes` for user-drive mapping scripts; Fail = mismatch.
- If fail: block deployment artifact and return change to image owner/DWP engineer.

3. Add standard retry module to all drive-mapping scripts:
- Owner: Image owner | Timing: Before deployment | Mode: Manual+Automated [REQUIRES: shared script module repository].
- Signal: script includes retry policy (`3` attempts, `15s` delay) and explicit non-zero exit on failure.
- Pass/Fail: Pass = module imported and checks pass; Fail = retry logic absent or altered.
- If fail: reject script PR and prevent script assignment to Finance scope.

4. Add ring deployment policy for Intune scripts:
- Owner: Release engineer | Timing: During deployment | Mode: Manual gate with automated evidence [REQUIRES: ring checklist].
- Signal: Ring 0 -> 1 device, Ring 1 -> 5 devices, Ring 2 -> full OU; evidence from `Get-PSDrive`, `Test-Path`, relogin persistence.
- Pass/Fail: Pass = all ring checks green with `0` failures; Fail = any device in ring fails mapping.
- If fail: halt progression and rollback current ring assignment.

5. Add monitoring alert for known failure pattern:
- Owner: DWP engineer | Timing: During deployment | Mode: Automated [REQUIRES: IME log ingestion + alert rule].
- Signal: correlated pattern `SYSTEM account` + `exit code 1` + `Network name cannot be found`.
- Pass/Fail: Pass = pattern below threshold; Fail = 3 or more devices in 30 minutes.
- If fail: auto-create incident, page on-call, and pause deployment to full Finance OU.

6. Pre-deployment test gate (smoke test before release)
- Owner: Release engineer | Timing: Before deployment | Mode: Automated [REQUIRES: pre-release test stage].
- Signal: test device run shows `S:` present, `Test-Path \\finbridge-fs01\Finance = True`, and no Event `98` in startup window.
- Pass/Fail: Pass = all smoke checks pass; Fail = any check fails.
- If fail: block release from entering Ring 0.

7. In-flight monitoring (alert during rollout window)
- Owner: Service desk lead | Timing: During deployment | Mode: Manual+Automated [REQUIRES: rollout dashboard].
- Signal: 15-minute trend of Event `98`, IME `exit code 1`, and missing-drive tickets in Finance queue.
- Pass/Fail: Pass = no sustained increase and no threshold breach; Fail = increase across two intervals.
- If fail: stop rollout and open incident bridge with DWP engineer.

8. Post-deployment validation before change closure
- Owner: Change manager | Timing: After deployment | Mode: Manual.
- Signal: sample of 10 Finance devices confirms `S:` mapping persists after sign-out/sign-in and IME log has no SYSTEM-context failure pattern.
- Pass/Fail: Pass = 10/10 devices healthy; Fail = any sampled device fails.
- If fail: keep change open and rollback assignment to previous script version.

9. Rollback trigger threshold
- Owner: Change manager | Timing: During deployment | Mode: Manual threshold trigger [REQUIRES: documented trigger in change plan].
- Signal: trigger met if 5+ Finance devices show Event `98` or IME `exit code 1` within 30 minutes.
- Pass/Fail: Pass = threshold not reached; Fail = threshold reached.
- If fail: execute rollback section immediately and suspend further sync triggers.

10. Knowledge update control
- Owner: DWP engineer | Timing: After deployment | Mode: Manual [REQUIRES: KB/runbook review workflow].
- Signal: KB/runbook updated with confirmed signatures (`SYSTEM account`, `exit code 1`, Event `98`, Event `1500`) and validated commands.
- Pass/Fail: Pass = publication completed within 2 business days and linked in incident; Fail = SLA missed.
- If fail: escalate to service desk lead and delay problem record closure.

---

## Related
- RCA: `Day 4 Lab/DWP_RCA_Shared_Drive_Access_Failure_Finance_OU_Resolved_2026-08-07.md`
- Runbook: `Day 5 Lab/DWP_Runbook_Shared_Drive_Mapping_Failure_Finance_OU_Intune.md`
- Related runbook (dependency check): `Day 5 Lab/DWP_Runbook_Group_Policy_Failure_Finance_OU_DHCP_DNS.md`
- L1 article (user-facing): `Day 5 Lab/DWP_KB_Article_L1_Shared_Drive_Missing_Finance.md`
