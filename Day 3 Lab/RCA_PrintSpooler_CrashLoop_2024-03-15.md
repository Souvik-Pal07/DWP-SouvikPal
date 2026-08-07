# Root Cause Analysis — Print Spooler Service Crash Loop
**Incident Date:** 2024-03-15  
**Analyst:** DWP Analyst  
**Document Created:** 2026-08-06  
**Severity:** High — All printing services unavailable; Print Spooler unable to recover  
**Status:** Root Cause Identified

---

## 1. Event ID Reference — What Each Event Records

| Event ID | Source | Level | Purpose |
|----------|--------|-------|---------|
| **7034** | Service Control Manager | Error | Records that a Windows service **terminated unexpectedly** — it crashed or was killed without a clean shutdown. Tracks a running count of how many times this has occurred since the last clean start. Does **not** by itself trigger any recovery action; that is governed by the service's configured failure policy. |
| **7031** | Service Control Manager | Error | Similar to 7034 but fires when the Service Control Manager is **executing a configured recovery action** in response to the unexpected termination. In this case it records that after the 4th crash, SCM will attempt to restart the service after a 60,000 ms (60-second) delay. This is the SCM's last automated recovery attempt before it gives up. |
| **7023** | Service Control Manager | Error | Records that a service **terminated with a specific Windows error code**. This is the most diagnostic event — it tells us *why* the service failed, not just that it did. "The specified module could not be found" (Win32 error `ERROR_MOD_NOT_FOUND`) means a DLL or binary that the service depends on at startup is missing or inaccessible on disk. |
| **7038** | Service Control Manager | Error | Records a **service account logon failure**. The SCM was unable to authenticate the service's configured account (`NT AUTHORITY\SYSTEM`) due to a logon type restriction. Under normal conditions, the built-in SYSTEM account always has the right to log on as a service; this event firing indicates a Group Policy or local security policy change has explicitly removed that right. |

---

## 2. Sequence of Events — Plain English Reconstruction

| Time | Event ID | What Happened |
|------|----------|---------------|
| **10:01:14** | 7034 (×1) | The Print Spooler service crashed for the **1st time**. SCM noted the unexpected termination and automatically restarted it per the service's default recovery policy. |
| **10:01:45** | 7034 (×2) | **~31 seconds later**, the restarted Spooler crashed again — 2nd crash. SCM restarted it again. The 31-second gap is the service failing almost immediately after each restart attempt. |
| **10:02:16** | 7034 (×3) | **~31 seconds later**, the 3rd crash. Same pattern — consistent, rapid failure on every startup attempt indicates a deterministic fault, not a transient one. SCM restarted it again. |
| **10:02:47** | 7031 (×4) | **~31 seconds later**, the 4th crash. SCM exhausted its immediate restart policy and escalated to its final recovery action: wait 60 seconds, then make one last restart attempt. |
| **10:03:49** | 7023 | After the 60-second wait, SCM restarted the Spooler. This time it recorded **why** it failed: `The specified module could not be found`. A DLL or driver binary the Spooler depends on is missing from disk. The service never finished starting. |
| **10:03:50** | 7038 | **One second later**, SCM also recorded a logon failure — `NT AUTHORITY\SYSTEM` was denied the right to log on as a service. A security policy change has revoked SYSTEM's `Log on as a service` privilege, adding a second independent barrier to recovery. |

---

## 3. Most Likely Cause — Analysis with Evidence

### Primary Root Cause
A **required printer driver DLL is missing or corrupted**, preventing the Print Spooler from loading on every startup attempt.

### Secondary Compounding Cause
A **Group Policy or Local Security Policy change has removed `NT AUTHORITY\SYSTEM` from the "Log on as a service" privilege**, meaning even if the missing DLL were restored, the service would still be blocked from starting.

### Supporting Evidence

| Evidence | Interpretation |
|----------|----------------|
| Four consecutive rapid crashes (~31-second intervals, Event ID 7034/7031) | The Spooler fails almost immediately on every restart — not a random or load-related fault. This is a **deterministic failure** triggered by a persistent condition, not a transient state. |
| Event ID 7023 — "The specified module could not be found" | The critical diagnostic event. The Print Spooler hosts printer driver DLLs from `%SystemRoot%\System32\spool\drivers\`. A missing or deleted driver DLL causes the Spooler process to fail during its initialisation phase before it can enter a running state. |
| Event ID 7038 — SYSTEM logon failure | `NT AUTHORITY\SYSTEM` is a built-in OS account; it **never** requires explicit logon permission under normal conditions. Its logon being denied can only be caused by a deliberate (and incorrect) Group Policy or `secpol.msc` change that added a `Deny log on as a service` entry or removed SYSTEM from `Log on as a service`. This points to a recent security hardening or GPO change that was applied incorrectly. |
| 7038 fires one second after 7023 | The two failures occur in the same recovery attempt — the service hit the missing module fault AND the logon denial simultaneously. This means two separate configuration problems converged, making recovery impossible without manual intervention. |

### Timeline of Likely System Changes (Preceding the Incident)

The crash loop almost certainly follows one or more of these actions in the hours/days before 10:01:

- Uninstallation of a network printer or printer driver that removed a shared DLL still referenced by the Spooler.
- A security scan or EDR remediation tool quarantining or deleting a DLL it flagged as suspicious (a known false-positive vector for printer drivers).
- Application of a new GPO or security baseline that inadvertently modified the "Log on as a service" User Rights Assignment.
- A Windows Update that partially updated printer driver components, leaving a version mismatch.

---

## 4. Five Why (5-Why) Root Cause Analysis

**Problem Statement:** The Print Spooler service entered an unrecoverable crash loop on 2024-03-15, cycling through four automatic restart attempts before halting, leaving the organisation with no print capability.

---

### Why 1 — Why did the Print Spooler service repeatedly crash?
**Answer:** The Service Control Manager logged four consecutive unexpected terminations (Event ID 7034/7031) within approximately 93 seconds. Each restart attempt ended in immediate failure, confirming the Spooler could not complete its startup sequence under the current system configuration.

---

### Why 2 — Why did the Print Spooler fail to complete its startup sequence?
**Answer:** Event ID 7023 records the explicit failure reason: `The specified module could not be found`. During startup, the Print Spooler enumerates and loads registered printer driver DLLs from the spool driver store (`%SystemRoot%\System32\spool\drivers\`). One or more of these DLLs were absent from their expected path, causing the process to terminate with `ERROR_MOD_NOT_FOUND` before it could enter a running state.

---

### Why 3 — Why was the required printer driver DLL missing from the system?
**Answer:** A recent change to the system removed or relocated the DLL without updating or cleaning the printer driver registry references. Most likely causes in order of probability: (1) a printer driver was partially uninstalled, leaving orphaned registry entries pointing to now-deleted files; (2) an EDR/antivirus tool quarantined the DLL as a false positive; (3) a Windows Update replaced a driver component without completing the transaction cleanly. In each case, the Spooler's driver registry keys still reference a file that no longer exists on disk.

---

### Why 4 — Why was the removal of the DLL not detected and corrected before the Spooler entered a crash loop?
**Answer:** No automated post-change validation was in place to verify Print Spooler service health after the change that removed the DLL. The change (driver uninstall, security scan, or update) completed without error from its own perspective, but left the system in an inconsistent state. Without a service health check or integrity scan of the spool driver store following the change, the broken state persisted silently until the Spooler was next restarted.

---

### Why 5 — Why was there no post-change validation of the Print Spooler service or its dependencies?
**Answer:** **Change management and deployment processes do not include a dependency integrity check for the Print Spooler or its driver store** as part of the standard post-change verification steps. Driver uninstallation, security remediation actions, and Windows Updates are applied without a checklist that confirms critical services remain operational and their dependent modules are intact. Additionally, the simultaneous Group Policy change that revoked `NT AUTHORITY\SYSTEM`'s logon right (Event ID 7038) indicates that security hardening changes are being applied to production systems without testing against service account dependencies — a gap in the change management and GPO testing processes.

---

## 5. Root Cause Statement

> The Print Spooler service entered an unrecoverable crash loop because a printer driver DLL referenced in the registry was no longer present on disk (Event ID 7023 — `ERROR_MOD_NOT_FOUND`), causing the service to fail during every startup attempt. This was compounded by a Group Policy misconfiguration that simultaneously revoked `NT AUTHORITY\SYSTEM`'s right to log on as a service (Event ID 7038), creating a second independent failure mode. Both conditions are the result of system changes — a driver removal/update and a security policy change — being applied to the production environment without post-change service health validation or GPO dependency testing.

---

## 6. Immediate Actions (Fix)

| Priority | Action | Owner |
|----------|--------|-------|
| P1 — Immediate | Identify the missing DLL by examining the Spooler's driver registry keys: `HKLM\SYSTEM\CurrentControlSet\Control\Print\Environments\`. Cross-reference each `Driver File` and `Data File` value against files present on disk. | Analyst |
| P1 — Immediate | If the DLL was quarantined by AV/EDR, restore it from quarantine and add a path exclusion for the spool driver store (`%SystemRoot%\System32\spool\drivers\`). If uninstalled, reinstall the relevant printer driver cleanly. | Analyst |
| P1 — Immediate | Restore `NT AUTHORITY\SYSTEM` to the **Log on as a service** (`SeServiceLogonRight`) User Rights Assignment via `secpol.msc` or Group Policy. Check `Computer Configuration → Windows Settings → Security Settings → Local Policies → User Rights Assignment`. | Analyst / GPO Admin |
| P1 — Immediate | After correcting both issues, start the Print Spooler service and verify it reaches **Running** state. Test print from an affected workstation. | Analyst |
| P2 — Short term | Run `sfc /scannow` to check for wider system file integrity issues that may have contributed to the missing module. | Analyst |

---

## 7. Long-Term Preventative Actions

| Action | Rationale |
|--------|-----------|
| Add a Print Spooler service health check (and driver store integrity scan) to the post-change verification checklist for any printer driver installation, removal, or update. | Catches broken driver store state immediately after the change, before the next Spooler restart. |
| Configure a GPO or Intune compliance policy to alert when the Print Spooler service is in a non-running state for more than 5 minutes. | Enables proactive detection of crash loops before users raise tickets. |
| Enforce an AV/EDR exclusion policy for the Windows spool driver store paths (`%SystemRoot%\System32\spool\drivers\`). Document and communicate this to the security team. | Prevents security tools from quarantining legitimate driver DLLs and causing identical incidents. |
| Establish a mandatory GPO change testing cycle in a representative test OU before production deployment, with explicit validation of service account logon rights for SYSTEM, LOCAL SERVICE, and NETWORK SERVICE. | Prevents security hardening changes from inadvertently breaking built-in service accounts. |
| Maintain a documented baseline of Print Spooler dependencies (driver DLLs and their expected paths) for each standard printer model in the estate. | Provides a reference for rapid triage of future `ERROR_MOD_NOT_FOUND` incidents. |

---

## 8. Evidence Summary

| Item | Value |
|------|-------|
| Affected Service | Print Spooler (Spooler) |
| Total Crash Count | 4 unexpected terminations + 1 fatal startup failure |
| Crash Loop Duration | 10:01:14 – 10:03:50 (~2 min 36 sec) |
| Primary Failure Reason | ERROR_MOD_NOT_FOUND — missing printer driver DLL (Event 7023) |
| Secondary Failure Reason | NT AUTHORITY\SYSTEM denied Log on as a service (Event 7038) |
| Recovery Attempted | Yes — SCM auto-restarted 3 times immediately, then once after 60-second delay |
| Recovery Outcome | Failed — service remained down after all recovery attempts |
| Probable Change Trigger | Printer driver removal, EDR quarantine, or Windows Update + GPO hardening change |

---

*Document prepared by DWP Analyst | 2026-08-06*
