# DWP - macOS JAMF Compliance Baseline
## Security Baseline Translation
Author: DWP Engineer  
Date: 2026-08-14  
Scope: macOS Design Team Fleet (25 JAMF-managed devices)

---

## Important Verification Discipline (same practice as Day 6 Intune labs)

JAMF Pro UI labels, payload names, and menu paths can change between versions and can also differ by tenant capabilities.

Do not trust exact label text in this document without validating in your own JAMF instance.

Any entry marked with "VERIFY IN JAMF" means you must confirm all of the following before production rollout:

1. The payload category name in your JAMF UI
2. The exact setting label under that payload
3. The resulting behavior on a test Mac using local command verification

---

## Baseline Objective

Translate the following security baseline into enforceable JAMF configuration profile settings:

1. FileVault disk encryption enabled
2. Gatekeeper enabled (identified developers only)
3. Minimum macOS version set to current stable minus one point release (N-1)
4. Firewall enabled
5. Login password required after sleep or screen saver
6. Automatic security updates enabled

---

## Requirement 1 - FileVault Disk Encryption Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Disk Encryption payload (or Security and Privacy grouping in some JAMF versions). VERIFY IN JAMF. |
| Value | Enable FileVault. Escrow personal recovery key to JAMF. If available, enforce institutional key and restrict deferral to limited prompts (for example 1 to 3). |
| Typical JAMF UI path | Computers -> Configuration Profiles -> New -> Payloads -> Disk Encryption. VERIFY IN JAMF. |

Effect:  
Ensures the startup volume is encrypted at rest and recovery keys are centrally available for support, incident response, and break-glass recovery.

False-positive risk:
- Device inventory record has not refreshed after encryption starts.
- Device reports "Encryption in progress" and is incorrectly treated as failed.
- Recovery key escrow delay after first sign-in or post-upgrade token changes.
- Laptops offline for extended periods appear non-compliant due to stale state.

Recommendation:  
Track three states separately in reporting: Encrypting, Encrypted with escrow confirmed, and Failed. Do not collapse "Encrypting" into "Failed" during first enforcement week.

---

## Requirement 2 - Gatekeeper Must Be Enabled (Identified Developers Only)

| Field | Detail |
|---|---|
| Payload type | Security and Privacy payload, Gatekeeper section. VERIFY IN JAMF. |
| Value | Allow apps from App Store and identified developers only (or equivalent text in your UI). |
| Typical JAMF UI path | Computers -> Configuration Profiles -> New -> Payloads -> Security and Privacy -> Gatekeeper. VERIFY IN JAMF. |

Effect:  
Prevents execution of unsigned or untrusted applications while still allowing signed and notarized developer software required by design teams.

False-positive risk:
- Internal utilities and scripts may be unsigned and blocked even when business-approved.
- Some plug-ins or helper binaries spawn from paths that trigger quarantine/translocation checks.
- Manual local overrides by admin users may temporarily diverge before profile re-assertion.

Recommendation:  
Use a documented exception path (approved notarization, packaging, or controlled allowlist deployment) instead of disabling Gatekeeper for productivity issues.

---

## Requirement 3 - Minimum macOS Version Must Be N-1

| Field | Detail |
|---|---|
| Payload type | Combination control: Software Update payload plus Smart Group compliance logic. Not a single universal toggle in all JAMF versions. VERIFY IN JAMF. |
| Value | Enforce update behavior so devices stay within current stable or one point release behind. Backstop with Smart Group criteria for OS version threshold. |
| Typical JAMF UI path | Computers -> Configuration Profiles -> New -> Payloads -> Software Update, and Computers -> Smart Computer Groups for version criteria. VERIFY IN JAMF. |

Effect:  
Prevents long-tail patch drift and keeps endpoints within a supportable vulnerability window.

False-positive risk:
- Apple release publication and JAMF catalog synchronization timing mismatch.
- Pilot rings intentionally deferred for compatibility testing appear non-compliant too early.
- Devices mid-upgrade or awaiting restart are incorrectly counted as outdated.

Recommendation:  
Publish the N-1 threshold only after pilot ring validation, and maintain a monthly review task to move version criteria forward in line with release cadence.

---

## Requirement 4 - Firewall Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Security and Privacy payload, Firewall section. VERIFY IN JAMF. |
| Value | Set macOS application firewall to On. If aligned with policy, also enable stealth mode and allow signed system software. |
| Typical JAMF UI path | Computers -> Configuration Profiles -> New -> Payloads -> Security and Privacy -> Firewall. VERIFY IN JAMF. |

Effect:  
Reduces inbound attack surface by enforcing host firewall controls for unsolicited incoming connections.

False-positive risk:
- VPN/endpoint agents using network extensions can create conflicting local indicators.
- Temporary local admin troubleshooting turns firewall off briefly and triggers stale alerts.
- Compliance checks reading cached values before profile re-application.

Recommendation:  
Validate with both JAMF inventory and local command output before opening incident tickets.

---

## Requirement 5 - Login Password Required After Sleep or Screen Saver

| Field | Detail |
|---|---|
| Payload type | Passcode payload or equivalent lock policy payload depending on JAMF version. VERIFY IN JAMF. |
| Value | Require password after sleep or screen saver with grace period set to immediately (zero delay). |
| Typical JAMF UI path | Computers -> Configuration Profiles -> New -> Payloads -> Passcode (or Restrictions/Security variant). VERIFY IN JAMF. |

Effect:  
Eliminates unattended workstation exposure by forcing authentication whenever the system wakes or unlocks.

False-positive risk:
- Profile installed at user level instead of device level can create inconsistent behavior.
- Fast user switching and token timing can delay observed enforcement.
- Test scripts checking preferences before MDM profile write completion.

Recommendation:  
Confirm effective state with local preference reads on the endpoint and not only dashboard status.

---

## Requirement 6 - Automatic Security Updates Must Be Enabled

| Field | Detail |
|---|---|
| Payload type | Software Update payload. VERIFY IN JAMF. |
| Value | Enable automatic checks and installation of security updates, system data files, and available critical updates according to what your JAMF UI exposes. |
| Typical JAMF UI path | Computers -> Configuration Profiles -> New -> Payloads -> Software Update. VERIFY IN JAMF. |

Effect:  
Reduces time-to-patch by removing dependence on user-initiated updates for security content.

False-positive risk:
- Device is on battery saver, low disk, or off-network when update orchestration occurs.
- Update installed but restart pending, causing temporary non-compliance.
- Inventory timestamp lag makes healthy devices appear stale.

Recommendation:  
Pair this control with restart communication and maintenance windows to avoid repeated pending-reboot exceptions.

---

## Enforcement Model for JAMF (Equivalent to Intune "Actions for Noncompliance")

JAMF configuration profiles enforce settings directly, but "grace period" behavior is typically implemented operationally through smart groups, scoping rings, and staged enforcement rather than a single native compliance timer.

### Recommended staged sequence for the 25-device Design fleet

| Stage | Scope | Timing | Action |
|---|---|---|---|
| 1 | Pilot ring (5 devices) | Days 0-7 | Deploy profiles in monitor mode with daily validation and no access control impact. |
| 2 | Broad ring (remaining 20 devices) | Days 8-14 | Deploy baseline profiles, maintain exception handling for known creative tooling gaps. |
| 3 | Enforcement hardening | Day 15 onward | Remove temporary exceptions, finalize dashboards and monthly evidence exports. |

### Operator note

If your environment integrates JAMF with identity conditional access tooling, map "non-compliant" smart groups to access policy actions only after pilot evidence is clean.

---

## Assignments and Scope Design

| Field | Value | Notes |
|---|---|---|
| Assign to | Selected Smart Groups | Avoid tenant-wide scope for first deployment cycle. |
| Include group | DWP-macOS-Design-Managed-25 | Primary target group for this baseline. |
| Exclude group | DWP-macOS-Design-Exceptions | Temporary exclusions for approved blockers (for example critical unsigned plugin). |

Conflict handling:  
If multiple profiles define overlapping security settings, macOS and JAMF payload precedence can produce unexpected outcomes. Keep a single authoritative baseline profile for each control domain to avoid policy collisions.

---

## Migration Risk Analysis - Highest False-Positive Threat

### Verdict: Requirement 1 (FileVault)

FileVault status is the most likely source of false-positive compliance noise during initial enforcement and OS upgrade windows.

Why this is highest risk:
- Encryption state has transitional phases (Encrypting, Deferred, Escrow pending) that are healthy but often misread as failed.
- SecureToken/bootstrap token dependencies can delay expected activation timing.
- Inventory refresh cadence can lag real endpoint state by hours.

### Typical false-positive timeline

| Time | What happens |
|---|---|
| T+0 | Profile deployed. User receives enablement prompt. |
| T+1h | Encryption starts successfully on endpoint. |
| T+1h | JAMF inventory still shows pre-change state. |
| T+2h to T+24h | Device appears non-compliant despite active encryption progression. |
| T+24h | Inventory refresh reconciles and device returns compliant state. |

### Control values to keep

Do not weaken FileVault requirements. Keep enforcement values strict and manage noise via staged rollout and reporting categories.

| Control | Value | Rationale |
|---|---|---|
| FileVault setting | Enabled with key escrow required | Preserves encryption assurance and recovery readiness. |
| Reporting logic | Separate Encrypting vs Failed | Avoids false incident volume from healthy transitions. |
| Rollout mode | Pilot then broad | Catches token/workflow edge cases before fleet-wide deployment. |

---

## What to Monitor in First 24 Hours After Deployment

1. Smart Group membership changes for each control-specific compliance group.
2. Devices showing FileVault deferred, escrow missing, or encryption stalled.
3. Restart-pending update backlog on automatic security updates.
4. Firewall enabled state drift after VPN/agent installs.

Action threshold:
If more than 10 percent of pilot devices show the same failure after local verification, pause broad rollout and remediate root cause first.

---

## Post-Assignment Validation - Device Check Procedure

### Where to validate in JAMF Pro

Primary path:
Computers -> Inventory -> Select Device -> Profiles, Security, and Operating System sections.

Policy-level view:
Computers -> Configuration Profiles -> Select Baseline Profile -> Scope and Logs.

Smart Group view:
Computers -> Smart Computer Groups -> Select Compliance Group -> View Members.

### Interpretation guide

| State | Meaning | Operator action |
|---|---|---|
| Compliant | Setting enforced and reflected in latest inventory. | No action required. |
| Pending | Profile delivered but endpoint state not yet reconciled. | Force inventory update, then re-check. |
| Non-compliant | Control failed after profile application. | Run endpoint command checks and remediate. |
| Not reporting | Device offline or inventory stale. | Verify check-in, network access, and MDM connectivity. |

---

## FileVault Non-Compliant But Actually Enabled - Three Common Causes

### Cause 1 - Inventory Lag

What happens:  
FileVault is active but JAMF inventory still reflects older state.

Fastest local check:
```bash
fdesetup status
```
Expected healthy output example: FileVault is On.

Resolution:  
Trigger inventory update and allow next reporting cycle.

---

### Cause 2 - Encryption in Progress

What happens:  
Drive conversion is underway and should not be treated as failed encryption.

Fastest local check:
```bash
diskutil apfs list
```
Confirm encryption progression on the startup volume.

Resolution:  
Maintain status as transitional until conversion completes.

---

### Cause 3 - Recovery Key Escrow Delay or Token Issue

What happens:  
Disk is encrypted, but escrow or token workflow has not completed, causing dashboard exceptions.

Fastest local checks:
```bash
fdesetup status
profiles status -type enrollment
```

Resolution:  
Validate SecureToken/bootstrap token prerequisites, rotate or re-escrow key if required, then re-run inventory.

---

## Known JAMF Label and Path Variability Flags

The following settings are known to vary by JAMF Pro version and tenant design. Validate before production deployment.

| Requirement | Flag | Notes |
|---|---|---|
| Requirement 1 - FileVault | VERIFY IN JAMF | May appear as dedicated Disk Encryption payload or under a broader Security grouping depending on version. |
| Requirement 2 - Gatekeeper | VERIFY IN JAMF | Wording can vary between "identified developers" and equivalent trusted developer phrasing. |
| Requirement 3 - Minimum OS N-1 | VERIFY IN JAMF | Usually requires combined Software Update plus Smart Group logic, not one direct compliance field. |
| Requirement 5 - Password after sleep | VERIFY IN JAMF | May sit under Passcode, Login Window, or Restrictions style payload names by release. |
| Requirement 6 - Auto security updates | VERIFY IN JAMF | Setting split can vary between config profiles and update policy workflows. |

Recommended action:
Validate all six controls in a test tenant or pilot scope and capture screenshots of exact UI paths as implementation evidence.

---

## Summary Table

| Req | Payload type | Value | Effect | False-positive risk |
|---|---|---|---|---|
| 1 | Disk Encryption / Security payload | FileVault On, escrow required | Encrypts disk and preserves recovery capability | Inventory lag, encryption-in-progress states |
| 2 | Security and Privacy (Gatekeeper) | App Store and identified developers | Blocks untrusted apps | Unsigned internal tools and helper binaries |
| 3 | Software Update + Smart Group | N-1 version threshold enforced | Keeps devices near current security level | Release timing and staged rollout mismatch |
| 4 | Security and Privacy (Firewall) | Firewall On | Reduces inbound attack surface | Agent/network extension interference |
| 5 | Passcode / lock payload | Password required immediately after sleep | Prevents unattended access | Scope mismatch and delayed profile writes |
| 6 | Software Update | Auto security updates enabled | Shortens patch exposure window | Restart pending and stale inventory |

---

Document prepared by DWP Engineering.  
Review cycle: Monthly (aligned to Apple security release cycle).  
Next review: 2026-09-11.
