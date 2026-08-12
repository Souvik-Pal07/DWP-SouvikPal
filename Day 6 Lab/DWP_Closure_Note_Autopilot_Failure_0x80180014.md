# DWP Closure Note — Autopilot Enrolment Failure (0x80180014)

- Device: DESKTOP-FB099 | User: FINBRIDGE\rthomas
- Incident date: 2024-03-15
- Closed: 2026-08-11

---

Resolved. Cause: Stale legacy manual MDM enrolment (established 2023-11-04) remained active on the device and in Intune, creating a management authority conflict that blocked Autopilot enrolment with error 0x80180014 and prevented all four baseline configuration profiles from applying. Action: Deleted stale legacy managed device record from Intune Admin Center and removed duplicate Entra device object; disconnected legacy work or school MDM connection on the device and cleaned residual local enrolment artefacts (MDM certs, EnterpriseMgmt tasks, stale registry GUID entries); rebooted, performed Autopilot Reset to return device to OOBE, and reran Autopilot enrolment flow — admin-plane cleanup completed before local cleanup, and local cleanup completed before OOBE rerun. Preventive: Implement an enforced pre-Autopilot legacy enrolment eligibility gate requiring all devices to pass a preflight check (legacy/manual enrolment indicators and duplicate stale records cleared) before entering any Autopilot rollout wave, and update the decommission-to-Autopilot runbook with a mandatory retire/remove legacy MDM step with evidence capture. User confirmed working.
