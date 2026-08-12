# DWP Guide - Add a Windows App to Intune App Catalog (Pre-Rollout)

## Purpose
Use this guide to add a Windows application to Intune correctly before any phased rollout begins.

Worked example used throughout:
- App: FinBridge Connect v3.1
- Package type: Windows LOB app packaged as .intunewin
- Install command: FinBridgeConnect_Setup.exe /silent
- Uninstall command: FinBridgeConnect_Setup.exe /uninstall /silent
- Detection method: Registry key
- Detection value: HKLM\\SOFTWARE\\FinBridge\\Connect\\Version = 3.1

## Important UI note (read first)
Intune portal labels and menu positions can change by tenant version and portal updates.
- Whenever this guide shows a label/path, verify it live in your own tenant before proceeding.
- If a label is different, use the closest equivalent under Apps, Windows, Endpoint, or Devices areas.

---

## Step-by-Step Procedure

### 1. Prepare prerequisites before opening Intune
1. Confirm you have one working .intunewin package for the target app.
2. Confirm silent install and uninstall commands have been tested on a non-production Windows 11 test VM.
3. Confirm detection rule values are exact and stable.
4. Confirm a pilot Azure AD group exists (for example: DWP-App-Pilot-FinBridgeConnect).

For this example, verify these inputs:
- .intunewin package file is ready.
- Install command: FinBridgeConnect_Setup.exe /silent
- Uninstall command: FinBridgeConnect_Setup.exe /uninstall /silent
- Detection registry: HKLM\\SOFTWARE\\FinBridge\\Connect
- Value name: Version
- Expected value: 3.1

### 2. Navigate to app creation in Intune
1. Sign in to Microsoft Intune admin center.
2. In the left-hand navigation panel, click **Apps**.
3. Under Apps, click **All Apps**.
4. In the All Apps toolbar, click **+ Create**.
5. A **Select app type** panel opens on the right. In the **Platform** dropdown, select **Windows**.
6. A second dropdown appears — select the app type that matches your package (see step 3).

Verified path (confirmed against current portal UI):
- Intune admin center > Apps > All Apps > + Create > Select app type panel > Platform: Windows

### 3. Choose the correct app type
1. In Select app type, choose based on source:
- Windows app (Win32) for .intunewin package files.
- Microsoft Store app (new) for apps delivered directly from Microsoft Store integration.
- Web link for URL shortcuts to web-based applications.
2. For FinBridge Connect v3.1, select Windows app (Win32).

Note:
- Some tenants may show wording as Windows app (Win32), Line-of-business app, or Win32 app depending on portal updates. Verify the option that supports .intunewin upload.

### 4. Upload the package and start configuration
1. Upload the FinBridge Connect .intunewin file.
2. Wait for Intune to parse metadata.
3. Continue to app configuration tabs.

### 5. Complete App information (required)
1. Enter Name: FinBridge Connect v3.1
2. Enter Description: FinBridge secure connectivity client version 3.1 for managed Windows devices.
3. Enter Publisher: FinBridge
4. Enter Version: 3.1
5. Optionally add category, icon, and information URL for catalog clarity.

Minimum required fields for DWP standard:
- Name
- Description
- Publisher
- Version

### 6. Complete Program settings (required)
1. Install command:
- FinBridgeConnect_Setup.exe /silent
2. Uninstall command:
- FinBridgeConnect_Setup.exe /uninstall /silent
3. Install behavior (context):
- Select System for device-wide installs requiring admin privileges.
- Select User only if app is per-user and does not require elevation.
4. For this example, use System context.

Why System context for this app:
- Registry detection is under HKLM (machine hive), indicating machine-level installation.

### 7. Configure Requirements (required)
1. OS architecture:
- Select x64 (and x86 only if explicitly supported).
2. Minimum OS version:
- Set minimum supported Windows 10/11 baseline per DWP policy.
- Recommended for this environment: Windows 11 baseline aligned with current managed build policy.

Example setting:
- Architecture: x64
- Minimum OS: Windows 11 22H2 or tenant-equivalent baseline option

UI warning:
- OS version dropdown labels may vary (for example build-based options vs release names). Verify equivalent setting in your tenant.

### 8. Configure Detection rules (required)
Detection tells Intune how to decide whether install succeeded.

Common options:
1. Registry key/value detection
2. MSI product code detection
3. File/folder path detection

For FinBridge Connect v3.1, configure registry detection:
1. Rule type: Registry
2. Key path: HKEY_LOCAL_MACHINE\\SOFTWARE\\FinBridge\\Connect
3. Value name: Version
4. Detection method: String comparison equals
5. Expected value: 3.1
6. Associated with 32-bit app on 64-bit clients: set according to actual installer behavior (enable only if app writes under WOW6432Node or 32-bit path behavior applies)

Engineer check:
- If uncertain, validate with local registry on a known-good installed test device before saving.

### 9. Configure Return codes (required)
Return codes map installer exit codes to success/failure/retry behavior.

Use Intune defaults unless vendor documentation requires changes, then confirm these are present:
- 0 = Success
- 3010 = Soft reboot (success with restart required)
- 1641 = Hard reboot (success, restart initiated)

Treat unknown non-zero codes as failure unless vendor explicitly defines them as success/retry.

DWP action:
1. Keep default success/reboot mappings.
2. Add vendor-specific custom mappings only when tested and approved.

### 10. Review and create the app
1. Review all tabs carefully.
2. Confirm package, commands, requirements, detection, return codes.
3. Select Create.
4. Wait for app object creation and content processing to finish.

### 11. Assign the app correctly (pilot first)
Assignment types:
1. Required:
- Intune automatically installs app on targeted devices/users.
2. Available for enrolled devices:
- App is shown in Company Portal; user can choose to install.
3. Uninstall:
- Intune removes app from targeted devices/users.

Pilot-first rule for DWP:
1. Do not target full fleet initially.
2. Assign first to a small test group (for example 10 to 50 devices).
3. Validate install success/failure patterns before broader deployment.

Why pilot first:
- Prevents large-scale outage or mass install failure across 10,000 devices.
- Surfaces command, detection, dependency, and reboot behavior issues safely.

### 12. Create pilot assignment for worked example
1. Open app: FinBridge Connect v3.1.
2. Go to Assignments.
3. Add group under Required (pilot group only).
4. Save assignments.

Example target:
- Group: DWP-App-Pilot-FinBridgeConnect
- Assignment type: Required

### 13. Verify app appears correctly in catalog
1. Go to Apps > All apps.
2. Search for FinBridge Connect v3.1.
3. Confirm:
- Name and publisher are correct.
- Platform/type is Win32 (or tenant-equivalent label for .intunewin apps).
- Assignment is present.

### 14. Verify install status on assigned test device
1. Open app > Device install status (label may vary, verify live).
2. Filter for pilot device.
3. Confirm status and timestamp.
4. On the device, optionally verify locally:
- App present in Programs/features view
- Registry value exists: HKLM\\SOFTWARE\\FinBridge\\Connect\\Version = 3.1

### 15. Interpret status values correctly
1. Installed:
- App install succeeded and detection rule matched expected state.
2. Failed:
- Installer returned failure or detection rule did not match expected post-install state.
- Investigate command syntax, context, dependencies, and detection settings.
3. Not applicable:
- Device does not meet requirements (OS/architecture/scope) or assignment targeting does not apply.

### 16. Gate before phased rollout
Do not begin phased rollout until all conditions are true in pilot:
1. High success rate across pilot devices.
2. No unexplained Failed states.
3. Detection rule accuracy confirmed.
4. Reboot/user impact validated.
5. Support desk briefed with known issues and rollback path.

### 17. Move from pilot to phased rollout
1. Expand assignment from pilot to Wave 1 group only.
2. Monitor for at least one business cycle.
3. Progress wave-by-wave after acceptance criteria are met.
4. Keep Uninstall assignment plan ready for rapid rollback.

---

## Quick Configuration Summary (FinBridge Connect v3.1)
- App type: Windows app (Win32) using .intunewin
- Install command: FinBridgeConnect_Setup.exe /silent
- Uninstall command: FinBridgeConnect_Setup.exe /uninstall /silent
- Install behavior: System
- Requirements: x64, Windows baseline per DWP policy
- Detection: Registry value HKLM\\SOFTWARE\\FinBridge\\Connect\\Version equals 3.1
- Initial assignment: Required to pilot group only

---

## Common Mistakes to Avoid
1. Assigning directly to all managed devices before pilot validation.
2. Using incorrect install context (User instead of System for machine installs).
3. Weak detection rule that can pass when app is partially installed.
4. Custom return code mapping without vendor evidence.
5. Ignoring tenant UI label differences and following old screenshots blindly.

---

## Final Engineer Checklist
1. Correct app type selected for source format.
2. Required metadata completed.
3. Install/uninstall commands tested and entered exactly.
4. Requirements aligned to target fleet.
5. Detection and return codes validated.
6. Assigned to pilot group first.
7. Status reviewed to Installed on pilot devices before phased rollout approval.