# DWP Communications — Autopilot Enrolment Failure (0x80180014)
## Three-Audience Pack

- Incident date: 2024-03-15
- Device: DESKTOP-FB099 | User: FINBRIDGE\rthomas
- Source: DWP Detailed RCA — Autopilot Enrolment Failure (0x80180014)
- Date issued: 2026-08-11

---

## Audience 1 — Non-Technical Executive

Your access and data are safe — this issue did not affect any information or accounts.

One device was unable to complete its scheduled IT setup process on 15 March 2024 due to a configuration conflict carried over from a previous IT management system. The conflict has been identified and resolved. The affected device is being returned to full working order. No action is required from you.

---

## Audience 2 — Affected End-User Team

**Your data is safe and your accounts have not been affected.**

On 15 March 2024, one device (DESKTOP-FB099) could not finish its IT setup because it still had an old IT management connection that clashed with the new setup process. The IT team has identified the cause and is resolving it.

If your own device fails to complete setup or shows an error during sign-in after an IT refresh, please do not attempt to fix it yourself — raise a ticket with the IT Service Desk straight away and mention the device name shown on the screen.

**Contact:** IT Service Desk — [your organisation's service desk contact details]

---

## Audience 3 — Engineer-to-Engineer Internal Note

**Incident:** Autopilot enrolment failure — DESKTOP-FB099 / FINBRIDGE\rthomas — 2024-03-15 09:18:44 UTC

---

### Root Cause
Stale legacy manual MDM enrolment (EnrolmentSource: manual, established 2023-11-04) was still present on the device and in Intune at the time of the Autopilot attempt. MDM raised **0x80180014** ("The device is already enrolled in MDM") at enrolment phase, blocking the entire downstream chain:
- PolicyManager: ProfilesAttempted: 4 / ProfilesApplied: 0 — LastError: **0x80070005** (Access denied)
- ComplianceEngine: EvaluationResult: Could not evaluate — Reason: Enrolment not complete

Azure AD join (AzureADJoined: Yes), licensing (M365 / IntuneP1 / AutopilotLicense all present), and network (all required endpoints reachable, ProxyDetected: No) are confirmed non-causal.

---

### Action Taken (mandatory order)

**Admin plane first:**
1. Intune Admin Center > Devices > All devices — identify and delete stale legacy managed device record (match on serial number, device name, last check-in).
2. Entra Admin Center > Identity > Devices > All devices — remove duplicate stale Entra device object if present.
3. Intune Admin Center > Devices > Windows > Windows enrollment > Devices (Windows Autopilot) — confirm hardware hash intact and Autopilot profile correctly assigned.

**Device plane second (physical or remote admin):**
4. Settings > Accounts > Access work or school — Disconnect legacy MDM connection.
5. Remove stale local enrolment artefacts: old MDM certs, EnterpriseMgmt scheduled tasks, stale enrolment registry GUID entries (use approved enterprise cleanup method).
6. Reboot.
7. Autopilot Reset / Fresh Start (per DWP standard) to return to OOBE.
8. Rerun Autopilot sign-in flow.

Do **not** trigger OOBE rerun before both admin-plane and local-plane cleanup are confirmed complete — partial cleanup will re-trigger 0x80180014.

---

### Verification Steps (post-remediation success criteria)
- Intune Admin Center: EnrollmentState = Succeeded; device visible as current managed object.
- Intune Admin Center: all target configuration profiles show applied/succeeded; no recurrence of 0x80070005.
- On device: `dsregcmd /status` — AzureAdJoined = YES, expected tenant context confirmed.
- Settings > Accounts > Access work or school: active current corporate connection visible.
- ComplianceEngine able to evaluate successfully.

---

### Preventive Action Required
**Enforce a pre-Autopilot legacy enrolment eligibility gate before every rollout wave:**
- Generate preflight report of devices with legacy/manual enrolment indicators or duplicate stale Intune/Entra records (Intune Admin Center).
- Cleanse all flagged records before wave start.
- Run standard cleanup script package on flagged devices via remote automation.
- Enforce a go/no-go checkpoint in the wave tracker — no device enters Autopilot wave until preflight passes.

**Update the decommission-to-Autopilot runbook:**
- Add mandatory retire/remove legacy MDM step before Autopilot assignment.
- Require evidence capture: before/after device IDs, timestamps, operator sign-off.

**KPI thresholds to track per wave:**
- Devices blocked by existing enrolment conflict.
- Mean time to remediate stale enrolment.
- Repeat incident rate per 100 devices.
- % devices passing preflight first time.
- If enrolment-conflict failure rate exceeds **2% in a wave**: pause next wave and run focused cleanup campaign.

---

### Key Diagnostic Signals (for future identification)
| Signal | Location | Value |
|---|---|---|
| ErrorCode | EnrollmentStatus | 0x80180014 |
| ErrorDescription | EnrollmentStatus | "The device is already enrolled in MDM" |
| EnrolmentSource | DeviceInfo | Legacy (manual MDM enrolment) |
| ProfilesAttempted / ProfilesApplied | PolicyManager | 4 / 0 |
| LastError | PolicyManager | 0x80070005 (Access denied) |
| EvaluationResult | ComplianceEngine | Could not evaluate — enrolment not complete |

**Residual risk:** Partial cleanup (admin-only or device-only) will leave the conflict in place and re-trigger failure on next Autopilot attempt. Always verify both layers before OOBE rerun.
