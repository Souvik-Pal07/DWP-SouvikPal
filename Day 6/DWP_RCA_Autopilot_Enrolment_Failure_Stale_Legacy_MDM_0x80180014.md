# DWP RCA - Autopilot Enrolment Failure (0x80180014)

## Incident Summary
- Device: DESKTOP-FB099
- User: FINBRIDGE\\rthomas
- Date of failure: 2024-03-15 09:18
- Enrolment type: Autopilot
- Enrolment state: Failed
- Primary error: 0x80180014
- Secondary policy error: 0x80070005 (Access denied)

## Confirmed Root Cause
Autopilot enrolment failed because the device already had an existing legacy manual MDM enrolment record (from 2023-11-04). The pre-existing enrolment created a management conflict that blocked Autopilot enrolment completion.

Evidence used:
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment
- ProfilesApplied: 0 of 4
- AzureADJoined: Yes
- Intune and Autopilot licensing: Yes
- Network endpoints: reachable, no proxy

## Remediation Runbook (Exact Steps)

### Phase 1 - Admin-side cleanup in Intune and Entra
1. [Admin Center only] Identify the correct device objects before deletion.
   - Intune Admin Center path: Devices > All devices.
   - Locate entries by serial number, device name, and last check-in for the affected device.
   - Record the Intune Managed Device ID and Azure AD Device ID for audit notes.

2. [Admin Center only] Remove stale Intune managed device record(s).
   - Intune Admin Center path: Devices > All devices > select stale legacy-managed record > Delete.
   - If duplicate records exist for the same hardware, remove stale/inactive legacy records and keep only the object expected for fresh Autopilot flow.

3. [Admin Center only] Remove stale Entra device object only if duplicate/conflicting.
   - Entra Admin Center path: Identity > Devices > All devices.
   - Find duplicate or stale object tied to the old manual enrolment and delete only the stale object.
   - Do not delete an active production object unless confirmed stale.

4. [Admin Center only] Validate Autopilot device registration is intact.
   - Intune Admin Center path: Devices > Windows > Windows enrollment > Devices (Windows Autopilot).
   - Confirm the hardware hash entry exists and is assigned to the intended Autopilot profile (FinBridge-Autopilot-Standard).

### Phase 2 - Device-side cleanup (required)
5. [Device access required: physical or remote admin session] Disconnect old workplace/MDM account.
   - On device: Settings > Accounts > Access work or school.
   - Select legacy work account connection and choose Disconnect.
   - If policy blocks UI disconnect, proceed with command-line unenrolment method below.

6. [Device access required: physical or remote admin session] Remove stale local MDM enrolment artifacts.
   - Remove legacy MDM certificates from Local Computer certificate store where tied to old MDM channel.
   - Remove old EnterpriseMgmt scheduled tasks associated with the stale enrolment GUID.
   - Remove stale enrolment registry keys associated with old MDM GUIDs.
   - Use the approved enterprise cleanup procedure/script for this action to avoid removing active system components.

7. [Device access required: physical] Reboot device.
   - Required to clear enrollment channel state and scheduled task residue.

8. [Device access required: physical] Reset to OOBE for clean Autopilot rerun.
   - Preferred: Autopilot Reset or Fresh Start per DWP standard.
   - Ensure device returns to Out-of-Box Experience and internet connectivity is available.

### Phase 3 - Re-enrol via Autopilot
9. [Device access required: physical] Start Autopilot sign-in flow.
   - User signs in with corporate credentials.
   - Device should receive assigned Autopilot profile and begin MDM enrolment.

10. [Admin Center only] Monitor enrolment and policy application.
   - Intune path: Devices > Enroll devices > Enrollment program tokens > monitor status (or tenant enrollment monitoring view used by DWP).
   - Device path in Intune: Devices > All devices > select device > Device compliance and Device configuration.

## Correct Order of Operations (Mandatory Sequence)
1. Confirm stale legacy enrolment evidence.
2. Delete stale Intune managed device object(s).
3. Delete stale Entra device object only if duplicate/conflicting.
4. Confirm Autopilot registration and profile assignment still valid.
5. Perform device-side unenrolment and artifact cleanup.
6. Reboot device.
7. Return device to OOBE.
8. Rerun Autopilot enrolment.
9. Validate enrolment and policy completion in Intune.

## Verification Checks After Remediation

### Success criteria (must all be true)
- EnrollmentState becomes Succeeded.
- No recurrence of 0x80180014 during enrolment.
- MDMEnrolled reflects current Autopilot/Intune enrolment (not legacy manual source).
- Policy application shows profiles applied successfully (expected 4 of 4 for this case).
- No blocking policy apply access denied error for baseline profile.

### Where to verify
- [Admin Center only] Intune Admin Center:
  - Devices > All devices > selected device:
    - Overview: Managed by MDM = Microsoft Intune
    - Compliance: evaluation successful
    - Device configuration: targeted profiles show Succeeded
- [Device access required: physical or remote]
  - Settings > Accounts > Access work or school shows active corporate MDM connection
  - dsregcmd /status confirms AzureAdJoined = YES and expected tenant association

## Preventive Action for Fleet Recurrence

### Preventive control to implement
Implement a pre-Autopilot eligibility gate for migration waves that detects and remediates legacy MDM enrolments before devices enter Autopilot.

### Recommended implementation
1. [Admin Center only] Build dynamic device collection/report for candidates where historical enrolment source indicates legacy/manual MDM.
2. [Admin Center only] Run a pre-flight cleanup campaign:
   - Remove stale Intune/Entra duplicates before scheduling Autopilot reset.
3. [Device access required: remote script deployment] Push a standard legacy-MDM cleanup script to flagged devices before reset.
4. [Admin Center only] Add a go/no-go checkpoint in rollout process:
   - Device cannot move to Autopilot wave until stale enrolment checks pass.
5. [Admin Center only] Track KPI per wave:
   - Count of devices blocked by existing enrolment
   - Time to remediate stale enrolment
   - Repeat incident rate after preventive gate

## Final Resolution Statement
This incident is resolved by removing stale legacy MDM enrolment state in both tenant records and local device artifacts, then re-running Autopilot from clean OOBE. Licensing and network were healthy and not causal in this case.
