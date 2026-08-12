# DWP Knowledge Base — L2/L3 Engineer Article
# Autopilot Enrolment Failure: Legacy MDM Conflict (0x80180014)

---

## Version History

| Field | Detail |
|---|---|
| **Article ID** | KB-AUTOPILOT-L3-001 |
| **Version** | 1.0 |
| **Date** | 07/08/2026 |
| **Author** | Souvik Pal |
| **Reviewed by** | Self |
| **Status** | Draft |
| **Related Runbook** | RB-AUTOPILOT-001 |
| **Related RCA** | DWP_RCA_Detailed_Autopilot_Failure_0x80180014_5Why.md |
| **Applies to** | Windows 10/11 devices enrolled via Windows Autopilot, managed by Microsoft Intune, Azure AD joined |

---

## 1. Background

Windows Autopilot is the DWP mechanism for provisioning new or refreshed Windows devices without manual imaging. When a device is first powered on and connected to the internet, it contacts Microsoft's Autopilot service, retrieves the assigned deployment profile, and automatically enrols itself into Intune MDM (Mobile Device Management). Intune then pushes configuration profiles, compliance policies, and mandatory applications to the device.

This flow depends on the device having **no pre-existing MDM enrolment** at the point Autopilot runs. MDM allows only one management authority at a time. If a legacy MDM enrolment record exists — from a previous manual enrolment or a prior management channel — Windows will reject the new Autopilot enrolment attempt with a management authority conflict.

This is specifically relevant during migration waves where devices previously managed under a legacy MDM channel are being transitioned to Autopilot. If the old enrolment state is not fully removed from both the **tenant plane** (Intune and Entra records) and the **local device plane** (certificates, registry entries, scheduled tasks) before Autopilot runs, this failure will occur.

---

## 2. Symptom

### What the engineer observes
- Device fails to complete Autopilot enrolment and presents an error screen at the OOBE (Out-of-Box Experience) phase.
- MDM diagnostic export shows `EnrollmentState: Failed`.
- Error code in the export: `0x80180014`.
- Error description in the export: `The device is already enrolled in MDM`.
- PolicyManager section shows `ProfilesAttempted: 4` and `ProfilesApplied: 0`.
- PolicyManager section shows `LastError: 0x80070005` (Access Denied) — this is a **secondary symptom** caused by the enrolment failure, not a separate fault.
- ComplianceEngine section shows `EvaluationResult: Could not evaluate` with reason `Enrolment not complete`.

### What the user reports
- "My new laptop is stuck on a setup screen and won't move forward."
- "There is an error message on the screen during first sign-in."
- "The screen has been showing the same thing for more than 10 minutes."
- Device has not reached the Windows desktop.

### Healthy comparator — what a successful enrolment looks like
A device that has completed Autopilot enrolment correctly will show:
- `EnrollmentState: Succeeded` in the MDM diagnostic export.
- `ProfilesApplied: 4` (or equal to `ProfilesAttempted`) in PolicyManager.
- `EvaluationResult: Compliant` or `EvaluationResult: Not compliant` (either is valid — the key is that evaluation ran).
- `AzureAdJoined: Yes` in DeviceInfo.
- In Intune Admin Center (`https://intune.microsoft.com > Devices > All devices`), the device shows **Enrollment state: Succeeded** and a **Last check-in** within the last hour.

If you are investigating a suspected failure and an identical model device that enrolled successfully is available, compare its MDM diagnostic export side by side against the failing device's export. The healthy device will show none of the error codes above.

---

## 3. Root Cause

**Primary root cause:** A stale legacy manual MDM enrolment record established on `2023-11-04` remained active on the device (`EnrolmentSource: Legacy (manual MDM enrolment, 2023-11-04)` in the DeviceInfo section of the MDM export). When Autopilot attempted enrolment, the Windows MDM stack detected the existing enrolment channel and raised error `0x80180014`, halting the process.

**Downstream effect:** Because enrolment did not complete, the PolicyManager had no valid enrolment context in which to apply profiles — hence 0 of 4 profiles applied and `0x80070005` (Access Denied) on each attempt. The ComplianceEngine could not evaluate as it depends on a completed enrolment.

**Confirmed non-causal factors for this incident:**
- Azure AD join (`AzureADJoined: Yes`) — healthy, not the cause.
- Licensing (`M365LicenseFound: Yes`, `IntuneP1License: Yes`, `AutopilotLicense: Yes`) — all present, not the cause.
- Network connectivity (`login.microsoftonline.com OK`, `enrollment.manage.microsoft.com OK`, `enterpriseregistration.windows.net OK`, `ProxyDetected: No`) — healthy, not the cause.

**5-Whys summary:**
The root cause traces back to missing rollout governance: there was no enforced preflight eligibility gate to detect and remove legacy enrolment state before a device entered the Autopilot wave. The runbook lacked a mandatory retire/remove step with pass/fail criteria.

---

## 4. Detection

Use this section to confirm you are dealing with this specific fault before taking any action. Every step references an exact log location and field name.

### Step D1 — Collect the MDM diagnostic export

On the failing device, open a command prompt as administrator and run:
```
mdmdiagnosticstool.exe -out C:\MDMLogs
```
Output folder: `C:\MDMLogs\`
Key files produced:
- `MDMDiagReport.html` — open in Edge or Chrome for readable output
- `MDMDiagReport.xml` — open in Notepad or any text editor; use Ctrl+F to search sections

All detection steps below reference fields within this export.

---

### Step D2 — Confirm primary error code

**File:** `MDMDiagReport.html` or `MDMDiagReport.xml`
**Section to search (Ctrl+F):** `EnrollmentStatus`
**Fields to read:**

| Field | Expected value for this fault |
|---|---|
| `EnrollmentState` | `Failed` |
| `ErrorCode` | `0x80180014` |
| `ErrorDescription` | `The device is already enrolled in MDM` |

If `ErrorCode` is not `0x80180014`, this KB article does not apply. Note the actual code and escalate to Endpoint Engineering.

**Windows Event Log cross-reference:**
- Log path on device: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider%4Admin.evtx`
- Open with Event Viewer: **Event Viewer > Applications and Services Logs > Microsoft > Windows > DeviceManagement-Enterprise-Diagnostics-Provider > Admin**
- Event ID to look for: **Event ID 76** — logged at the point MDM enrolment is rejected. The event description will contain the text `already enrolled` and error code `80180014`.
- Secondary Event ID: **Event ID 72** — logged immediately before Event 76; confirms the enrolment attempt was initiated. Use this to establish the exact timestamp of the failure.

---

### Step D3 — Confirm legacy enrolment source

**File:** `MDMDiagReport.html` or `MDMDiagReport.xml`
**Section to search (Ctrl+F):** `DeviceInfo`
**Fields to read:**

| Field | Expected value for this fault |
|---|---|
| `MDMEnrolled` | `Yes (previous enrolment)` |
| `EnrolmentSource` | `Legacy (manual MDM enrolment, 2023-11-04)` or similar legacy/manual label |

If `EnrolmentSource` shows `Autopilot` or `AAD`, the conflict has a different origin — do not proceed with this KB. Escalate.

---

### Step D4 — Confirm downstream policy and compliance failure

**File:** `MDMDiagReport.html` or `MDMDiagReport.xml`

**Section: `PolicyManager`**

| Field | Expected value for this fault |
|---|---|
| `ProfilesAttempted` | `4` (or the number of assigned profiles) |
| `ProfilesApplied` | `0` |
| `LastError` | `0x80070005` |

> Note: `0x80070005` (Access Denied) here is a **consequence** of failed enrolment, not an independent fault. Do not treat it as the primary error.

**Section: `ComplianceEngine`**

| Field | Expected value for this fault |
|---|---|
| `EvaluationResult` | `Could not evaluate` |
| `Reason` | `Enrolment not complete` |

**Windows Event Log cross-reference:**
- Log path: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider%4Admin.evtx`
- Event ID **404** — policy application failure. Description will reference the profile name and error `0x80070005`.
- Event ID **405** — compliance evaluation skipped. Description will reference incomplete enrolment state.

---

### Step D5 — Confirm non-causal factors are healthy (rule-out check)

**File:** `MDMDiagReport.html` or `MDMDiagReport.xml`

**Section: `DeviceInfo`**

| Field | Must show |
|---|---|
| `AzureADJoined` | `Yes` |

**Section: `NetworkCheck`**

| Endpoint | Must show |
|---|---|
| `login.microsoftonline.com` | `OK` |
| `enrollment.manage.microsoft.com` | `OK` |
| `enterpriseregistration.windows.net` | `OK` |
| `ProxyDetected` | `No` |

**Section: `Licensing`**

| Field | Must show |
|---|---|
| `M365LicenseFound` | `Yes` |
| `IntuneP1License` | `Yes` |
| `AutopilotLicense` | `Yes` |

If any of these fail, treat them as separate faults to resolve first. The legacy enrolment conflict cannot be the sole cause if network or licensing is also broken.

---

### Step D6 — Confirm in Intune Admin Center

1. Go to `https://intune.microsoft.com` > **Devices** > **All devices**.
2. Search by device name or serial number.
3. If two records exist for the same device — one with an old enrolment/check-in date and one recent — the stale record confirms the legacy enrolment artefact is still present in the tenant plane.
4. Open each record and compare:

| Field | Stale record (confirms fault) | Current record |
|---|---|---|
| Enrolment date | Matches legacy MDM period (e.g. 2023-11-04) | Matches Autopilot attempt date |
| Last check-in | Old / months ago | Today or failure date |
| Management type | MDM | MDM |
| Enrollment state | May show Succeeded (stale) | Failed |

---

## 5. Resolution

Complete Section A (admin-plane) fully before starting Section B (device-plane). Do not reverse the order.

### Section A — Admin-plane cleanup ⚠️ Elevated permission required

**R-A1.** Go to `https://intune.microsoft.com`. Sign in with a DWP account holding **Intune Administrator** or **Cloud Device Administrator** role.
- Navigate: left panel > **Devices** > **All devices**.
- Search for the device by name. If no result, use the **Filter** button and filter by **Serial number**.
- Expected result: Device record(s) load.

**R-A2.** Identify the stale record (old enrolment date, old last check-in). Click on it to open the device detail page.
- At the top toolbar of the device detail page, click **Delete**. Click **Delete** again in the confirmation dialog.
- Expected result: Record disappears from the All devices list on re-search.
- Record in ticket: device record name and deletion timestamp.

**R-A3.** Navigate in Intune Admin Center: left panel > **Devices** > **Windows** > **Windows enrollment** > (under Windows Autopilot heading) **Devices**.
- Search by device serial number.
- Confirm: hardware hash is present in the **Hardware hash** column; a profile name appears in the **Profile** column (not `Unassigned`).
- Expected result: Valid Autopilot registration confirmed.
- ⛔ If Profile is `Unassigned` or missing, stop. Raise with Endpoint Engineering to re-register the hardware hash before continuing.

**R-A4.** Go to `https://entra.microsoft.com`. Sign in with a DWP account holding **Cloud Device Administrator** or **Global Administrator** role.
- Navigate: left panel > **Identity** > **Devices** > **All devices**.
- Search by device name.
- For each object returned, check the **Registered** date and **Activity** (last sign-in) date.
- If a stale duplicate object exists (Registered date matching the legacy period, low activity), click on it and copy the **Object ID** from the URL or properties pane. Paste into the ticket.
- Click **Delete** and confirm.
- Expected result: Only the current valid Entra object remains.

> Before moving to Section B, add a ticket note: stale Intune record name, deletion time, Autopilot profile confirmed, Entra Object ID deleted (if applicable).

---

### Section B — Device-plane cleanup ⚠️ Admin rights on device required

**R-B1.** On the device (physical or via approved DWP remote tool), press `Windows key + I` to open Settings.
- Navigate: **Accounts** > **Access work or school**.
- Identify the legacy MDM connection tile (labelled with the old domain/org, separate from the current DWP corporate tile).
- Click the tile to expand it. Click **Disconnect**. Click **Yes** to confirm.
- Expected result: Legacy tile removed. Only the current corporate connection remains (or the page is empty if no current connection yet).

**R-B2.** Open a command prompt as administrator (right-click Start > **Windows Terminal (Admin)** or search `cmd` > **Run as administrator**).
- Run the approved enterprise cleanup script at the path provided by Endpoint Engineering:
  ```
  C:\DWP\Scripts\MDMCleanup\Run-MDMCleanup.ps1
  ```
- Expected result: Script outputs a summary confirming removal of: MDM certificates, `EnterpriseMgmt` scheduled tasks, stale enrolment registry GUID entries under `HKLM\SOFTWARE\Microsoft\Enrollments\`.
- Log file written to: `C:\DWP\Logs\MDMCleanup_<date>.log` — attach to ticket.
- ⛔ Do not manually edit `HKLM\SOFTWARE\Microsoft\Enrollments\`, `HKLM\SOFTWARE\Microsoft\EnterpriseResourceManager\`, or the certificate stores. Use the approved script only.

**R-B3.** Reboot the device: **Start** > **Power** > **Restart**.
- Expected result: Device restarts cleanly to sign-in screen or OOBE.

**R-B4.** Perform Autopilot Reset to return the device to OOBE. ⚠️ Elevated permission required.
- On device: **Settings** > **System** > **Recovery** > **Reset this PC** > **Remove everything** > **Cloud download** (or Local reinstall per DWP standard) > confirm.
- Or remotely from Intune Admin Center: `https://intune.microsoft.com` > **Devices** > **All devices** > select device > **Autopilot Reset** (top toolbar).
- Expected result: Device wipes to OOBE screen showing DWP or Microsoft sign-in prompt.

**R-B5.** At the OOBE screen, sign in with the assigned user's UPN (e.g. `rthomas@finbridge.gov.uk`).
- Do not interrupt the Autopilot flow. Allow all progress screens to complete.
- Expected result: Screen shows *Setting up your device for work* and *Applying your organisation's policies* without error 0x80180014 appearing. Device reaches Windows desktop with baseline policy applied.

---

## 6. Verification

All four checks must pass before closing the ticket. Log each result in the ticket.

**V1 — Enrolment state in Intune**
- Go to `https://intune.microsoft.com` > **Devices** > **All devices** > search device name > open device detail page.
- Field to check: **Enrollment state** (right-hand overview pane).
- ✅ Pass: `Enrollment state: Succeeded` and **Last check-in** within the last 30 minutes.
- ❌ Fail: Still shows `Failed` — re-examine Section A cleanup; do not close.

**V2 — Configuration profile application in Intune**
- Still on the device detail page > left menu > **Device configuration**.
- Check the **State** column for every profile listed.
- ✅ Pass: All profiles show `Succeeded`. No `Error`, `Failed`, or `Conflict` states.
- ❌ Fail: Any profile shows `Error` or `Failed` — click the profile to read the error code. If `0x80070005` persists, enrolment is not fully complete; raise with Endpoint Engineering.
- Log to attach: `C:\Windows\System32\winevt\Logs\Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider%4Admin.evtx` from the device.

**V3 — Azure AD join state on device**
- On device, open admin command prompt and run: `dsregcmd /status`
- Save output: `dsregcmd /status > C:\MDMLogs\dsregcmd_post.txt`
- ✅ Pass: `AzureAdJoined : YES` and `TenantName` matches the DWP tenant.
- ❌ Fail: `AzureAdJoined : NO` — Azure AD join has broken; trigger rollback RB5 immediately.

**V4 — No legacy connection on device**
- On device: **Settings** > **Accounts** > **Access work or school**.
- ✅ Pass: One connection tile showing current DWP tenant/UPN. No legacy tile present.
- ❌ Fail: Legacy tile still present — repeat R-B1 and R-B2 and retest.

---

## 7. Rollback

Execute the matching scenario. Each is designed to be completed in under 3 minutes.

**RB1 — Wrong Intune device record deleted (current, not stale)**
1. Go to `https://intune.microsoft.com` > **Devices** > **All devices**. Confirm the record is gone.
2. Do NOT attempt to recreate it.
3. Add to ticket: device name, serial number, deletion timestamp (from your browser history).
4. Contact Endpoint Engineering immediately: *"Wrong Intune record deleted. Need restore and Autopilot re-registration. Device: [name], Serial: [number], deleted at [time]."*
5. Set ticket status: **On Hold — Pending Endpoint Engineering**. Do not reboot or reset the device.

**RB2 — Wrong Entra device object deleted (current, not stale)**
1. Open browser history (Ctrl+H). Find the Entra device URL. Copy the Object ID from the URL (string after `/devices/`). Paste into ticket immediately.
2. Go to `https://entra.microsoft.com` > **Identity** > **Devices** > **All devices**. Confirm deletion.
3. Do NOT attempt manual recreation.
4. Contact Endpoint Engineering: *"Wrong Entra object deleted. Object ID: [paste]. Device: [name]. Need restore and Autopilot re-registration."*
5. Set ticket status: **On Hold — Pending Endpoint Engineering**.

**RB3 — Autopilot Reset left device unbootable or stuck at recovery screen**
1. Photograph the exact error text/code on screen.
2. Do NOT attempt a second reset or power-cycle more than once.
3. Add to ticket: exact error text, physical device state.
4. Contact Endpoint Engineering: *"Device unbootable after Autopilot Reset. Error: [text]. Device: [name]. Marking as physically unavailable."*
5. Attach label to device: **DO NOT USE — Awaiting Endpoint Engineering — [your name] — [date/time]**.
6. Set ticket status: **P1 — Endpoint Engineering Required**.

**RB4 — 0x80180014 recurs on second Autopilot attempt**
1. Do not trigger another reset. Leave device at the error screen.
2. Check `https://intune.microsoft.com` > **Devices** > **All devices** — confirm whether a new stale record has re-appeared.
3. Check `https://entra.microsoft.com` > **Identity** > **Devices** > **All devices** — check for duplicate Entra object.
4. Re-run: `mdmdiagnosticstool.exe -out C:\MDMLogs` on the device. Zip `C:\MDMLogs\` and attach to ticket.
5. Contact Endpoint Engineering: *"0x80180014 recurred post full procedure. New MDM diagnostic attached."*
6. Set ticket status: **On Hold — Pending Endpoint Engineering**.

**RB5 — V3 shows AzureAdJoined = NO after procedure**
1. On device, run: `dsregcmd /status > C:\MDMLogs\dsregcmd_rollback.txt`
2. Zip `C:\MDMLogs\` and attach to ticket.
3. Go to `https://entra.microsoft.com` > **Identity** > **Devices** > **All devices**. Screenshot current state and attach.
4. Do NOT attempt manual Azure AD rejoin.
5. Contact Endpoint Engineering: *"AzureAdJoined = NO post-procedure. dsregcmd output and Entra screenshot attached. Need re-join assessment."*
6. Set ticket status: **On Hold — Pending Endpoint Engineering**.

---

## 8. Preventive Actions

These are specific changes to process and tooling — not generic recommendations. Each control names the owner role, timing, pass/fail signal, and whether it is manual or automated.

---

### P1 — Pre-Autopilot legacy enrolment eligibility gate
**Owner:** Release Engineer | **Timing:** Before deployment — must complete before wave go/no-go | **Type:** Manual (automation candidate — see note)

**What to do:**
Before any device enters an Autopilot rollout wave, export the Intune device list and run a preflight check:
1. Go to `https://intune.microsoft.com` > **Devices** > **All devices** > click **Export** (top-right). Open the CSV. Filter for rows where **Enrollment type** = `Device enrollment manager` OR `User enrollment` AND **Last check-in** is older than 90 days. Any match against the wave device list is a blocked device.
2. For each blocked device: delete the stale Intune record, check for a duplicate Entra object at `https://entra.microsoft.com` > **Identity** > **Devices** > **All devices**, run the cleanup script package remotely, and confirm clean state before adding the device to the wave tracker.
3. In the wave tracker, a mandatory **Preflight passed (Y/N)** column must be present. A device cannot move to the **Ready** state until a second Release Engineer has ticked this column.

**Pass signal:** Zero devices in the wave tracker show `Preflight passed = N` at wave start. Intune CSV shows no legacy enrolment type for any wave device.
**Fail signal:** Any device shows `Preflight passed = N` at go/no-go time, OR the CSV filter returns one or more matches against the wave list.
**If it fails:** Block that device from the wave. Do not pause the whole wave unless more than 2% of devices are flagged — if the 2% threshold is breached, pause the entire wave and run a focused cleanup campaign before resuming.
**Automation note:** [REQUIRES: Intune Graph API reporting pipeline] This check can be automated using the Microsoft Graph API (`GET /deviceManagement/managedDevices`) filtered on `enrollmentType eq 'userEnrollment'` and `lastSyncDateTime lt <90-days-ago>`, outputting a daily pre-wave report to the wave tracker.

---

### P2 — Mandatory legacy MDM retire/remove gate in the decommission-to-Autopilot runbook
**Owner:** DWP Engineer (executing) + Change Manager (approving) | **Timing:** Before deployment — must complete before Autopilot profile is assigned in Intune | **Type:** Manual

**What to do:**
Insert the following as a hard-gated step in the decommission-to-Autopilot transition runbook, before the step that assigns the Autopilot deployment profile:

> - In Intune Admin Center: Retire the device (`Devices > All devices > [device] > Retire`). Wait for status to change from `Retire pending` to the device disappearing from the managed device list — this confirms the management relationship is removed.
> - In Entra Admin Center: Search for the device at `Identity > Devices > All devices`. If a duplicate object exists with a Registered date matching the legacy period, copy its Object ID, then delete it.
> - Run the approved cleanup script on the device (`C:\DWP\Scripts\MDMCleanup\Run-MDMCleanup.ps1`). Attach the output log (`C:\DWP\Logs\MDMCleanup_<date>.log`) as evidence.
> - A second DWP Engineer must countersign the change record before the Autopilot profile assignment step is unlocked.

**Pass signal:** Change record shows countersignature present; Intune retire confirmed (device absent from managed list); cleanup log attached with exit code 0.
**Fail signal:** Any of the three evidence items missing from the change record at the point of profile assignment.
**If it fails:** Change Manager blocks profile assignment. Device is returned to the cleanup queue. Change record remains open until all evidence is present.
**Automation note:** [REQUIRES: ITSM change workflow integration] The profile assignment step in the change workflow can be set as a dependent task that only unlocks when the three evidence fields are marked complete.

---

### P3 — KPI monitoring per rollout wave
**Owner:** Release Engineer (data collection) + Service Desk Lead (threshold review) | **Timing:** During and after deployment — reviewed at wave close and at 7-day post-wave checkpoint | **Type:** Manual (automation candidate — see note)

Track the following metrics per wave. Review at wave close and again 7 days post-wave:

| Metric | Target | Observable signal | Action if breached |
|---|---|---|---|
| Devices blocked by enrolment conflict per wave | < 2% | Count of tickets with error code `0x80180014` in wave window | Pause next wave; run cleanup campaign on remaining devices |
| Mean time to remediate stale enrolment | < 2 hours | Ticket open-to-close time for `0x80180014` tickets | Review cleanup script; consider remote pre-staging |
| Repeat incident rate per 100 devices | 0 | Count of `0x80180014` tickets for devices already remediated once | Full RCA on each repeat; update preflight checklist |
| Devices passing preflight first time | > 98% | `Preflight passed = Y` on first check in wave tracker, no rework | Review wave prep process; increase preflight lead time |

**Pass signal:** All four metrics within target at wave close review.
**Fail signal:** Any metric breaches its target threshold.
**If it fails:** Service Desk Lead escalates to Release Engineer and Change Manager within 24 hours of breach detection. A focused remediation sprint is initiated before the next wave is approved.
**Automation note:** [REQUIRES: ITSM reporting dashboard] Ticket tagging by error code (`0x80180014`) enables automated metric extraction; wave tracker data can feed a Power BI or equivalent dashboard for real-time visibility.

---

### P4 — Pre-deployment smoke test gate (NEW — gap fill)
**Owner:** Release Engineer | **Timing:** Before deployment — run on 1–2 pilot devices before the main wave begins | **Type:** Manual

**What to do:**
Before committing any wave to full rollout, run Autopilot end-to-end on two representative devices (one previously manually enrolled, one clean) and confirm both complete successfully.

**Pass signal:** Both pilot devices reach `EnrollmentState: Succeeded` in Intune and show `ProfilesApplied` equal to `ProfilesAttempted` with no errors. `dsregcmd /status` on both shows `AzureAdJoined : YES`.
**Fail signal:** Either pilot device returns `0x80180014` or any profile shows `Error`/`Failed`.
**If it fails:** Full wave is blocked. Release Engineer investigates the pilot failure using this KB article before wave proceeds.

---

### P5 — In-flight monitoring alert during rollout window (NEW — gap fill)
**Owner:** DWP Engineer (on-call during wave) | **Timing:** During deployment — active for the full duration of the rollout window | **Type:** Manual monitoring (automation candidate — see note)

**What to do:**
During the wave window, the on-call engineer monitors Intune for enrolment failures every 30 minutes:
- Go to `https://intune.microsoft.com` > **Devices** > **Monitor** > **Enrollment failures**.
- Filter by **Error code** = `80180014` (Intune displays hex without `0x` prefix in this view).
- If any new failures appear, count them against the wave total. If count reaches the 2% threshold, immediately notify the Change Manager.

**Pass signal:** Zero new `80180014` failures in the Enrollment failures view throughout the wave window.
**Fail signal:** One or more `80180014` failures appear during the wave.
**If it fails:** On-call engineer raises a wave-pause request to the Change Manager within 15 minutes of breach.
**Automation note:** [REQUIRES: Intune Endpoint Analytics or Azure Monitor integration] An alert rule can be configured via Azure Monitor on the Intune diagnostic log stream to fire when `EnrollmentErrorCode = 80180014` is detected, removing the need for manual polling.

---

### P6 — Post-deployment validation before change closure (NEW — gap fill)
**Owner:** Release Engineer | **Timing:** After deployment — must complete before the change record is closed | **Type:** Manual

**What to do:**
At wave close, before the Change Manager closes the change record, the Release Engineer must confirm:
1. Go to `https://intune.microsoft.com` > **Devices** > **All devices**. Filter by **Enrollment date** within the wave window. Export to CSV. Confirm the **Enrollment state** column shows `Succeeded` for 100% of wave devices.
2. Confirm the **Enrollment failures** view (`Devices > Monitor > Enrollment failures`) shows zero open failures for the wave cohort.
3. Attach the filtered CSV as evidence to the change record.

**Pass signal:** CSV shows `Succeeded` for all wave devices; Enrollment failures view shows zero for the cohort.
**Fail signal:** Any device in the CSV shows `Failed` or is absent from the managed device list.
**If it fails:** Change record remains open. Failed devices are triaged individually before closure is approved.

---

### P7 — Rollback trigger threshold (NEW — gap fill)
**Owner:** Change Manager (decision) + Release Engineer (execution) | **Timing:** During deployment — evaluated continuously against the 2% threshold | **Type:** Manual decision, manual execution

**What to do:**
If the enrolment conflict failure rate (`0x80180014`) for a wave reaches or exceeds 2% of wave devices at any point during the rollout window:
1. Change Manager calls a wave pause immediately.
2. Release Engineer stops assigning new Autopilot profiles in Intune (`https://intune.microsoft.com` > **Devices** > **Windows** > **Windows enrollment** > **Deployment profiles` — set the affected profile to `Unassigned` for remaining devices).
3. All remaining undeployed wave devices are returned to the cleanup queue for full preflight (P1) before the wave resumes.

**Pass signal:** Failure rate stays below 2% throughout the wave window — no pause triggered.
**Fail signal:** Running failure count hits 2% of wave total.
**If it fails (threshold breached):** Pause is immediate; no exceptions. A post-pause RCA is completed before the wave resumes.
**Automation note:** [REQUIRES: ITSM + Intune integration] The pause action (unassigning profiles) can be scripted using the Graph API (`PATCH /deviceManagement/windowsAutopilotDeploymentProfiles/{id}` setting `assignedDevices` to exclude remaining cohort).

---

### P8 — Knowledge base and runbook update after each wave (NEW — gap fill)
**Owner:** DWP Engineer (who resolved the incident) + Service Desk Lead (approving update) | **Timing:** After deployment — within 5 business days of wave close | **Type:** Manual

**What to do:**
After each wave where a `0x80180014` incident occurred, the resolving engineer must:
1. Review this KB article (KB-AUTOPILOT-L3-001) and runbook (RB-AUTOPILOT-001) against what actually happened.
2. If any step was incorrect, missing, or took longer than expected, update the relevant section and increment the version number.
3. If a new edge case was encountered, add it to the **Notes** section of the runbook.
4. Service Desk Lead reviews and approves the update within 5 business days.

**Pass signal:** KB article and runbook version numbers are incremented within 5 business days of any wave incident; update is logged in the version history table.
**Fail signal:** No update made within 5 business days of a wave incident.
**If it fails:** Service Desk Lead flags the gap to the Change Manager; update becomes a mandatory action item on the next wave go/no-go checklist.

---

## 9. Related Articles and Incidents

| Reference | Type | Detail |
|---|---|---|
| RB-AUTOPILOT-001 | Runbook | Step-by-step fix procedure for this fault |
| KB-AUTOPILOT-L1-001 | L1 KB article | End-user self-service article for device stuck at setup |
| DWP_RCA_Detailed_Autopilot_Failure_0x80180014_5Why.md | RCA document | Full 5-Whys analysis, evidence register, and timeline |
| DWP_Known_Error_Autopilot_Enrolment_Failure_0x80180014.md | Known Error Record | Six-field known error entry for the knowledge base |
| Reference incident | Incident | DESKTOP-FB099 / FINBRIDGE\rthomas — 2024-03-15 |
| Microsoft Docs | External | [Troubleshoot Windows Autopilot — Microsoft Learn](https://learn.microsoft.com/en-us/autopilot/troubleshoot-oobe) |
| Microsoft Docs | External | MDM error 0x80180014 — device already enrolled conflict |
