# DWP Known Error Record — Autopilot Enrolment Failure (0x80180014)

## Document Control
- Knowledge Base ID: KE-AUTOPILOT-001
- Date recorded: 2026-08-11
- Source incident: DESKTOP-FB099 / FINBRIDGE\rthomas (2024-03-15)
- Source RCA: DWP Detailed RCA — Autopilot Enrolment Failure (0x80180014)

---

## Known Error Record

**Symptom**
The user is unable to complete Autopilot enrolment. The device fails at the enrolment stage and does not proceed to policy or compliance evaluation, leaving the device unmanaged and unconfigured.

**Cause**
A pre-existing legacy manual MDM enrolment (established 2023-11-04) remained active on the device, creating a management authority conflict. When Autopilot attempted enrolment, Windows MDM rejected it because the device was already enrolled, raising error 0x80180014 with the description "The device is already enrolled in MDM".

**Scope**
Any Windows device targeted for Autopilot enrolment that retains a stale or legacy manual MDM enrolment record in Intune, a duplicate device object in Entra ID, or residual local enrolment artefacts from a prior MDM management channel. Policy and compliance evaluation are also blocked as downstream consequences, meaning 0 of the expected configuration profiles will apply.

**Workaround**
Remove the stale legacy managed device record from Intune Admin Center (Devices > All devices) and any duplicate Entra device object, then on the device disconnect the old work or school MDM connection (Settings > Accounts > Access work or school) and clean residual local enrolment artefacts. Complete admin-plane cleanup before local cleanup, and do not rerun Autopilot until both layers are clear.

**Permanent Fix**
Implement an enforced pre-Autopilot eligibility gate that blocks a device from entering an Autopilot wave until legacy enrolment checks pass, and update the decommission-to-Autopilot runbook to include a mandatory retire/remove step for legacy MDM with evidence capture (before/after device IDs, timestamps, operator sign-off) before Autopilot assignment.

**How to Spot It**
Look for error code **0x80180014** in the EnrollmentStatus section of the MDM diagnostic export, accompanied by the description *"The device is already enrolled in MDM"* and an EnrolmentSource value of *Legacy (manual MDM enrolment)*. In the PolicyManager section, confirm the pattern of **ProfilesAttempted: 4 / ProfilesApplied: 0** with **LastError: 0x80070005 (Access denied)**, and a ComplianceEngine result of *"Could not evaluate — enrolment not complete"*.
