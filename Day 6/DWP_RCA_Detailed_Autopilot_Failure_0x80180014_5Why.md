# DWP Detailed RCA - Autopilot Enrolment Failure (0x80180014)

## Document Control
- Prepared by: DWP Analyst
- Date: 2026-08-11
- Incident date: 2024-03-15
- Scope: Single-device Autopilot enrolment failure analysis with fleet prevention controls
- Device: DESKTOP-FB099
- User: FINBRIDGE\\rthomas
- OS build: 22621.2861

---

## 1) Executive Summary
Autopilot enrolment failed because the device had a pre-existing legacy manual MDM enrolment from 2023-11-04. The stale enrolment created a management authority conflict that prevented new Autopilot MDM enrolment from completing.

Key outcomes:
- Primary failure observed at enrolment stage with error 0x80180014.
- Policy stage showed 0 of 4 profiles applied and access denied (0x80070005), consistent with enrolment not completing.
- Azure AD join, licensing, and network connectivity were healthy and are not causal factors in this incident.

---

## 2) Incident Scope and Data Source
This RCA is based on the provided MDM diagnostic export and earlier triage outcomes for the same incident.

### In-scope questions answered
- Did enrolment succeed? No.
- Was device Azure AD joined? Yes.
- Was there existing MDM enrolment? Yes, legacy manual from 2023-11-04.
- Did policy apply? No, 0 of 4.
- Was licensing correct? Yes.
- Was network healthy? Yes.

---

## 3) Supporting Evidence Register

| Evidence ID | Export Section | Raw Evidence | Interpretation | Impact on RCA |
|---|---|---|---|---|
| E1 | EnrollmentStatus | EnrollmentState: Failed | Autopilot process did not complete | Confirms incident occurred |
| E2 | EnrollmentStatus | ErrorCode: 0x80180014 | Error raised at enrolment phase | Primary failure marker |
| E3 | EnrollmentStatus | ErrorDescription: The device is already enrolled in MDM | Explicit conflict statement | Directly supports root cause |
| E4 | DeviceInfo | MDMEnrolled: Yes (previous enrolment) | Existing enrolment state still present | Confirms stale/legacy channel existed |
| E5 | DeviceInfo | EnrolmentSource: Legacy (manual MDM enrolment, 2023-11-04) | Legacy enrolment predates Autopilot attempt | Establishes conflict origin and age |
| E6 | PolicyManager | ProfilesAttempted: 4; ProfilesApplied: 0 | No policy payload successfully applied | Shows downstream failure after enrolment break |
| E7 | PolicyManager | LastError: 0x80070005 (Access denied) | Policy engine denied applying profile context | Secondary symptom, not primary root cause |
| E8 | ComplianceEngine | EvaluationResult: Could not evaluate; Reason: Enrolment not complete | Compliance engine blocked by incomplete enrolment | Confirms dependency chain failure |
| E9 | DeviceInfo | AzureADJoined: Yes | Identity join state is valid | Removes AAD join as root cause |
| E10 | Licensing | M365LicenseFound: Yes; IntuneP1License: Yes; AutopilotLicense: Yes | Licensing prerequisites present | Removes licensing as root cause |
| E11 | NetworkCheck | login.microsoftonline.com OK; enrollment.manage.microsoft.com OK; enterpriseregistration.windows.net OK; ProxyDetected: No | Required endpoints reachable | Removes network/proxy as root cause |

---

## 4) Technical Timeline (UTC local capture time from export)

| Time | Event | Evidence | Significance |
|---|---|---|---|
| 2023-11-04 | Legacy manual MDM enrolment established | DeviceInfo: EnrolmentSource legacy/manual | Historical state that later conflicts with Autopilot |
| 2024-03-15 09:18:44 | Autopilot enrolment attempt fails | EnrollmentStatus: Failed, 0x80180014, already enrolled message | Primary failure event |
| 2024-03-15 09:19:01 | Policy processing attempts begin and fail | PolicyManager: 4 attempted, 0 applied, 0x80070005 | Secondary consequence of failed enrolment context |
| 2024-03-15 09:19:45 | Compliance evaluation cannot proceed | ComplianceEngine: Could not evaluate, enrolment not complete | Confirms end-to-end operational impact |
| 2024-03-15 09:22 (export time) | Diagnostic capture completed | Header timestamp | Snapshot used for analysis |

Timeline conclusion:
- The first decisive break is at enrolment with 0x80180014.
- Policy and compliance failures occur after, and because of, the enrolment break.

---

## 5) 5-Whys Analysis

### Problem Statement
Autopilot enrolment failed for DESKTOP-FB099 and the baseline policy did not apply.

1. Why did Autopilot enrolment fail?
- Because enrolment returned 0x80180014 and reported the device was already enrolled in MDM.

2. Why was the device already enrolled in MDM?
- Because a prior legacy manual MDM enrolment record from 2023-11-04 still existed.

3. Why did the legacy enrolment still exist at Autopilot time?
- Because there was no complete pre-Autopilot cleanup of old enrolment state (tenant object and local artefacts).

4. Why was pre-cleanup not consistently performed?
- Because the migration/runbook lacked an enforced eligibility gate that blocks Autopilot start when legacy enrolment indicators are present.

5. Why was there no enforced eligibility gate?
- Because rollout governance did not include a mandatory legacy-enrolment preflight control with measurable pass/fail criteria.

### 5-Whys Root Cause Statement
The root cause is an unmanaged transition from legacy manual MDM enrolment to Autopilot-managed enrolment, without an enforced preflight process to detect and remove stale legacy enrolment state before Autopilot execution.

---

## 6) Confirmed Root Cause vs Non-Causal Factors

### Confirmed root cause
- Existing legacy manual MDM enrolment conflict (stale enrolment state) blocked Autopilot enrolment.

### Non-causal in this incident
- Azure AD join state (healthy).
- Licensing (Intune P1 and Autopilot licensing present).
- Network reachability and proxy state (healthy).

---

## 7) Corrective Actions (Immediate Incident Resolution)

### A. Intune and Entra admin actions
1. Intune Admin Center only: identify stale device records.
   - Path: Intune Admin Center > Devices > All devices.
   - Match by serial number, device name, and last check-in.

2. Intune Admin Center only: delete stale legacy managed device record(s).
   - Path: Intune Admin Center > Devices > All devices > select stale record > Delete.

3. Admin Center only (if duplicate exists): remove stale duplicate Entra device object.
   - Path: Entra Admin Center > Identity > Devices > All devices.

4. Intune Admin Center only: confirm Autopilot registration remains valid.
   - Path: Intune Admin Center > Devices > Windows > Windows enrollment > Devices (Windows Autopilot).
   - Confirm hardware hash present and assigned expected profile.

### B. Device-side actions
5. Device access required (physical or remote admin): disconnect legacy work or school MDM connection.
   - Path: Settings > Accounts > Access work or school > Disconnect old connection.

6. Device access required (physical or remote admin): clean stale local enrolment artefacts.
   - Remove old MDM certs, EnterpriseMgmt tasks, and stale enrolment registry GUID entries using approved enterprise cleanup method.

7. Device access required (physical): reboot.

8. Device access required (physical): return device to OOBE (Autopilot Reset/Fresh Start per DWP standard).

9. Device access required (physical): rerun Autopilot sign-in and completion flow.

### Mandatory order of operations
- Complete admin cleanup first, then local cleanup, then OOBE rerun.
- Do not rerun Autopilot before both tenant-side and local stale state are removed.

---

## 8) Verification Plan (Post-Remediation Success Criteria)

### Verification checks
1. Intune Admin Center only:
   - Device appears as current managed object.
   - Enrolment status indicates success.

2. Intune Admin Center only:
   - Device configuration policies show success.
   - Target baseline profile no longer fails with access denied.

3. Device access required:
   - Settings > Accounts > Access work or school shows active current corporate connection.
   - dsregcmd /status confirms AzureAdJoined = YES and expected tenant context.

### Objective success criteria
- EnrollmentState = Succeeded.
- No recurrence of 0x80180014.
- Policy application moves from 0 of 4 to expected applied/succeeded state.
- Compliance engine can evaluate successfully.

---

## 9) Preventive Actions (Fleet-Level)

### Preventive control 1: Pre-Autopilot legacy enrolment eligibility gate
- Owner: Endpoint Engineering
- Type: Process + technical control
- Requirement: device cannot enter Autopilot wave until legacy enrolment checks pass.

Implementation:
1. Intune Admin Center only: generate preflight report of devices with legacy/manual enrolment indicators or duplicate stale records.
2. Admin Center only: cleanse stale Intune/Entra duplicates before wave start.
3. Device access required (remote automation): run standard cleanup script package on flagged devices.
4. Admin Center only: enforce go/no-go checkpoint in wave tracker.

### Preventive control 2: Standardized decommission-to-Autopilot transition runbook
- Add mandatory step to retire/remove legacy MDM before Autopilot assignment.
- Require evidence capture (before/after IDs, timestamps, operator sign-off).

### Preventive control 3: KPI and monitoring
Track per rollout wave:
- Devices blocked by existing enrolment conflict.
- Mean time to remediate stale enrolment.
- Repeat incident rate per 100 devices.
- Percentage of devices passing preflight first time.

Suggested threshold:
- If enrolment-conflict failure rate exceeds 2% in a wave, pause next wave and execute focused cleanup campaign.

---

## 10) Residual Risk and Assumptions
- Assumption: Export reflects full state at capture time and no later manual edits changed device identity relationships.
- Residual risk: Partial cleanup (tenant-only or device-only) may still leave conflict and re-trigger failure.
- Mitigation: enforce dual-layer cleanup verification before Autopilot rerun.

---

## 11) Final Resolution Statement
This incident is attributed to stale legacy MDM enrolment state conflicting with Autopilot enrolment. The resolution is to remove stale state in both admin plane (Intune/Entra records) and local device plane (legacy enrolment artefacts), then rerun Autopilot from clean OOBE and verify successful enrolment and policy application.