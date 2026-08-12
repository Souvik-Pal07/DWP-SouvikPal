# DWP Runbook — Autopilot Enrolment Failure (0x80180014)
## Legacy MDM Conflict Resolution

---

## Version History

| Field | Detail |
|---|---|
| **Title** | DWP Runbook — Autopilot Enrolment Failure (0x80180014) Legacy MDM Conflict Resolution |
| **Runbook ID** | RB-AUTOPILOT-001 |
| **Version** | 1.0 |
| **Date** | 07/08/2026 |
| **Author** | Souvik Pal |
| **Reviewed by** | Self |
| **Status** | Draft |
| **Change** | Initial version from RCA |
| **Applies to** | Any Windows device failing Autopilot enrolment with error 0x80180014 |

---

---

## Prerequisites

Tick every box before opening a portal or touching the device. Do not start the procedure if any item is unchecked.

### Access — confirm your roles before starting

- [ ] **Intune Admin Center access** — ⚠️ Elevated permission required
  - Role needed: `Intune Administrator` OR `Cloud Device Administrator`
  - How to verify: Sign in to [https://intune.microsoft.com](https://intune.microsoft.com). If you can see **Devices > All devices**, your access is sufficient. If you receive an access denied message, stop and contact your line manager to request the role before proceeding.

- [ ] **Entra Admin Center access** — ⚠️ Elevated permission required
  - Role needed: `Cloud Device Administrator` OR `Global Administrator`
  - How to verify: Sign in to [https://entra.microsoft.com](https://entra.microsoft.com). Navigate to **Identity > Devices > All devices**. If the list loads, access is confirmed. If blocked, stop and raise an access request.

- [ ] **Local administrator access on the device** — ⚠️ Elevated permission required on the device
  - Required for steps 11–15.
  - How to verify: On the device, open a command prompt. Run: `whoami /groups` and confirm `BUILTIN\Administrators` is listed. If not, arrange admin credentials or remote admin session via the DWP approved remote tool before continuing.

### Tools — confirm you have these before starting

- [ ] **MDM diagnostic export file from the failing device**
  - File is typically named `MDMDiagReport.html` or exported as a `.cab` archive containing `MDMDiagReport.xml`.
  - How to collect if not already provided: On the failing device, open a command prompt as administrator and run: `mdmdiagnosticstool.exe -out C:\MDMLogs`
  - Output folder: `C:\MDMLogs\` — share this folder or zip its contents and attach to the ticket before calling the engineer.
  - Log sections to confirm present: `EnrollmentStatus`, `DeviceInfo`, `PolicyManager`, `ComplianceEngine`, `NetworkCheck`, `Licensing`.

- [ ] **Approved enterprise cleanup script package**
  - Package name: supplied by Endpoint Engineering — do not substitute with any other script.
  - Where to obtain: raise a request to Endpoint Engineering via the internal tools request channel, referencing this runbook ID: `RB-AUTOPILOT-001`.
  - Do not begin device-side steps (Section C) without this package in hand.

- [ ] **DWP approved remote admin tool** (if physical access to the device is not possible)
  - Required for steps 11–12 if the device is remote.
  - Confirm the remote session is established and you have admin rights on the device before starting Section C.

### Mandatory information — collect from the ticket or the end user before starting

- [ ] **Device name** (e.g. `DESKTOP-FB099`) — visible on the ticket, on the device label, or by running `hostname` in a command prompt on the device.
- [ ] **Device serial number** — visible on the device label (underside of laptop or rear of desktop), or run `wmic bios get serialnumber` in a command prompt on the device.
- [ ] **Assigned user's full UPN** (e.g. `rthomas@finbridge.gov.uk`) — from the ticket; needed to match Intune and Entra records and to complete the Autopilot sign-in at step 15.
- [ ] **Date and approximate time the Autopilot failure occurred** — from the ticket or the user; used to distinguish the stale legacy record from the current attempt record in Intune.
- [ ] **Confirmation from the user that they have not already attempted to disconnect any work or school accounts themselves** — if the user has already disconnected accounts, note this before starting; it may affect what you find in step 11.

---

## Procedure

Complete all steps in the order shown. Do not jump ahead. **Section A (confirm fault) and Section B (admin-plane cleanup) must both be fully complete before you touch the device in Section C.**

---

### Section A — Confirm the fault before touching anything

**Step 1.** Open the MDM diagnostic export file collected in the prerequisites.
- If the export is a `.cab` file: extract it, then open `MDMDiagReport.xml` in a text editor (Notepad is fine).
- If the export is an `.html` file: open it in a browser (Edge or Chrome).
- Search the file (Ctrl+F) for the text `EnrollmentStatus`.
- Expected result: You find the section and can read the fields within it.

**Step 2.** Within the `EnrollmentStatus` section, read the `ErrorCode` and `ErrorDescription` fields.
- Expected result: `ErrorCode: 0x80180014` and `ErrorDescription: The device is already enrolled in MDM` are both present.
- ⛔ If `ErrorCode` is anything other than `0x80180014`, stop immediately. This runbook does not apply. Raise the ticket with Endpoint Engineering, stating the actual error code found.

**Step 3.** Search the same file (Ctrl+F) for `EnrolmentSource` within the `DeviceInfo` section.
- Expected result: You see `EnrolmentSource: Legacy (manual MDM enrolment)` with a date shown alongside it that is earlier than today's date and earlier than the Autopilot attempt date on the ticket.
- ⛔ If EnrolmentSource is not `Legacy` or `manual`, stop. The conflict has a different origin. Raise with Endpoint Engineering.

**Step 4.** Search the file (Ctrl+F) for `AzureADJoined` in the `DeviceInfo` section.
- Expected result: `AzureADJoined: Yes`.
- ⛔ If `AzureADJoined: No`, Azure AD join is broken and must be resolved separately first. Do not continue this runbook until join state is confirmed healthy.

**Step 5.** Search the file (Ctrl+F) for `NetworkCheck`. Read the result for each of the following endpoints listed in that section:
  - `login.microsoftonline.com`
  - `enrollment.manage.microsoft.com`
  - `enterpriseregistration.windows.net`
- Expected result: All three show `OK` and `ProxyDetected: No`.
- ⛔ If any endpoint shows a failure, network connectivity is a separate fault. Resolve it before continuing.

**Step 6.** Search the file (Ctrl+F) for `Licensing`. Read the `M365LicenseFound`, `IntuneP1License`, and `AutopilotLicense` fields.
- Expected result: All three show `Yes`.
- ⛔ If any licence is missing, raise with the licensing team. Do not continue until licensing is confirmed.

> All six steps in Section A must pass before moving to Section B. Log your findings in the ticket before continuing.

---

### Section B — Admin-plane cleanup in Intune and Entra — ⚠️ Elevated permission required

**Step 7.** Open a browser and go to: `https://intune.microsoft.com`. Sign in with your DWP admin account.
- In the left-hand navigation panel, click **Devices**.
- In the Devices menu, click **All devices**.
- Expected result: A list of managed devices loads. You can see a search bar at the top of the list.

**Step 8.** In the search bar at the top of the All devices list, type the **device name** (e.g. `DESKTOP-FB099`). Press Enter.
- Expected result: One or more device records appear matching that name.
- If no results appear, clear the search and try again using the **serial number** instead (click the **Filter** button, select **Serial number** as the filter field, and enter the serial number).

**Step 9.** Review the results. For each record shown, click on the device name to open it and note the following fields on the device overview page:
  - **Last check-in** — shown on the overview pane on the right
  - **Enrolment date** — shown in the device properties
  - **Management type** — should say `MDM` for all records
- The **stale record** is the one whose last check-in date is old (matching the legacy enrolment period, e.g. around 2023-11-04) and whose enrolment date predates the current Autopilot attempt.
- The **current record** (if a separate one exists) will have a last check-in matching today or the date of the failed Autopilot attempt.
- Expected result: You can clearly identify which record is stale and which (if any) is the current attempt.
- ⛔ If you cannot tell which record is stale, do not delete either. Take a screenshot of both records and raise with Endpoint Engineering before proceeding.

**Step 10.** Click on the stale device record to open it. At the top of the device detail page, click the **Delete** button (it appears in the toolbar above the device properties). A confirmation dialog will appear — click **Delete** again to confirm. — ⚠️ Elevated permission required
- Expected result: The page refreshes and the stale device record no longer appears in the All devices list when you search again.
- If a second stale record exists (confirmed in step 9), repeat this step for that record only.

**Step 11.** Still in Intune Admin Center, navigate to: **Devices > Windows > Windows enrollment** (in the left panel, under Windows, look for the **Windows enrollment** sub-menu). Click **Devices** under the Windows Autopilot heading.
- In the search bar on the Autopilot devices page, enter the device **serial number**.
- Expected result: One entry appears showing the device serial number, with a hardware hash value present and a deployment profile name shown in the **Profile** column.
- ⛔ If no entry appears, or if the Profile column shows `Unassigned` or is blank, do not continue. Raise with Endpoint Engineering to re-register the hardware hash before proceeding.

**Step 12.** Open a new browser tab and go to: `https://entra.microsoft.com`. Sign in with your DWP admin account.
- In the left-hand navigation panel, expand **Identity**, then click **Devices**, then click **All devices**.
- In the search bar at the top, type the device name (e.g. `DESKTOP-FB099`) and press Enter.
- Expected result: One or more Entra device objects appear.

**Step 13.** Review the Entra device objects returned. For each one, click the device name and check:
  - **Registered** date (shown in the device overview)
  - **Join type** (should be `Azure AD joined`)
  - **Activity** — last sign-in date
- The stale duplicate object will have a **Registered** date matching the old legacy enrolment period (around 2023-11-04) and a low or no recent activity date.
- Expected result: You can identify a stale duplicate object separate from the current valid one.
- If only one object exists and it appears current (registered date matches the current Autopilot attempt period), **do not delete it** — skip to step 14.

**Step 14.** If a stale duplicate Entra device object was identified in step 13: click on it to open it. At the top of the device detail page, click **Delete**. Confirm the deletion in the dialog. — ⚠️ Elevated permission required
- Expected result: The stale Entra object is removed. Only the current valid object remains when you search again.
- Record the deleted object's **Object ID** (copy it from the browser URL or the properties page before deleting) and paste it into the ticket as evidence.

> Section B is now complete. Before continuing, add a note to the ticket confirming: stale Intune record deleted (record name + deletion timestamp), Autopilot registration confirmed valid (profile name), and Entra duplicate deleted if applicable (Object ID).

---

### Section C — Device-side cleanup — ⚠️ Physical or remote admin access required

**Step 15.** On the device (physically in front of it, or via the DWP approved remote admin tool with admin rights confirmed), click **Start**, then click the **Settings** gear icon (or press `Windows key + I`).
- In the Settings window, click **Accounts** in the left panel.
- In the Accounts menu, click **Access work or school**.
- Expected result: You see the Access work or school page showing any connected accounts or MDM connections.

**Step 16.** On the Access work or school page, look for the legacy MDM connection. It will appear as a tile or link labelled with the old organisation name or domain (e.g. a legacy DWP domain, or labelled `Connected to [old domain] MDM`). It will be separate from (or instead of) the current corporate account tile.
- Click on the legacy connection tile to expand it.
- Click **Disconnect**.
- A confirmation dialog will appear — click **Yes** to confirm.
- Expected result: The legacy connection tile disappears from the Access work or school page.
- ⛔ If only one connection is shown and it says `Connected to [current DWP tenant]`, do not disconnect it. Stop and raise with Endpoint Engineering — the legacy connection may have already been removed or may be hidden.

**Step 17.** Open a command prompt as administrator on the device (right-click **Start > Windows Terminal (Admin)** or search for `cmd`, right-click, and select **Run as administrator**). — ⚠️ Elevated permission required
- Run the approved enterprise cleanup script package by typing the full path to the script provided by Endpoint Engineering and pressing Enter. Example: `C:\DWP\Scripts\MDMCleanup\Run-MDMCleanup.ps1` (use the exact path given to you — do not guess).
- Expected result: The script runs, displays a summary of what was removed (MDM certificates, EnterpriseMgmt scheduled tasks, stale enrolment registry GUID entries), and exits with a success message or a message confirming no artefacts were found.
- ⛔ Do not manually delete registry keys, certificates, or scheduled tasks without the script. If the script fails to run, stop and contact Endpoint Engineering.
- Log file: the script writes its output log to `C:\DWP\Logs\MDMCleanup_<date>.log`. Copy the log path and attach it to the ticket.

**Step 18.** Click **Start > Power > Restart** to reboot the device.
- Expected result: The device restarts and returns to the Windows sign-in screen (or enters OOBE if it was already in that state).

**Step 19.** Perform an Autopilot Reset on the device to return it to OOBE. — ⚠️ Elevated permission required
- Path: **Settings > System > Recovery** (Windows 11). Under **Reset this PC**, click **Reset PC**. Select **Remove everything**. Select **Cloud download** or **Local reinstall** per DWP standard. Confirm and proceed.
- Alternatively, if directed by DWP standard, trigger Autopilot Reset remotely from Intune Admin Center: **Devices > All devices > [device] > Autopilot Reset**.
- Expected result: The device wipes user state and reboots to the Autopilot OOBE sign-in screen (the screen shows the DWP or Microsoft logo with a sign-in prompt).
- ⛔ If the device does not reach the OOBE screen and instead boots to a recovery or error screen, treat this as rollback scenario R3 immediately — do not attempt a second reset.

**Step 20.** At the OOBE screen, enter the assigned user's UPN (e.g. `rthomas@finbridge.gov.uk`) and their password when prompted.
- Follow the on-screen Autopilot prompts. Do not click away or cancel at any point.
- Expected result: The screen shows progress messages such as *Setting up your device for work* and *Applying your organisation's policies*. The enrolment phase passes without displaying error 0x80180014.

**Step 21.** Wait for Autopilot to complete fully without interrupting it. Do not close the lid, disconnect power, or navigate away from the setup screens.
- Expected result: The device reaches the Windows desktop. The user's profile is loaded. The taskbar and Start menu are visible. The DWP baseline configuration (wallpaper, mandatory apps, or other policy-driven settings) is applied.

---

## Verification

All four checks must pass before you close the ticket or return the device to the user. Work through them in order.

---

**V1 — Confirm enrolment succeeded in Intune**

1. Open a browser and go to: `https://intune.microsoft.com`. Sign in with your DWP admin account.
2. In the left-hand panel, click **Devices**, then click **All devices**.
3. In the search bar, type the device name (e.g. `DESKTOP-FB099`) and press Enter.
4. Click the device name in the results to open its detail page.
5. On the device overview pane (right-hand side), locate the **Enrollment state** field.
- ✅ Pass: `Enrollment state: Succeeded` and the **Last check-in** timestamp is within the last 30 minutes.
- ❌ Fail: `Enrollment state: Failed` or device not found — do not close the ticket. Return to step 8 of the procedure and re-check admin-plane cleanup. Raise with Endpoint Engineering if the state has not changed.

---

**V2 — Confirm all configuration profiles applied in Intune**

1. Still on the device detail page from V1 (at `https://intune.microsoft.com > Devices > All devices > [device name]`).
2. In the left-hand menu of the device detail page, click **Device configuration**.
3. The page lists each configuration profile assigned to the device. Review the **State** column for every profile in the list.
- ✅ Pass: Every profile shows `Succeeded` in the State column. No profile shows `Error`, `Failed`, or `Conflict`.
- ❌ Fail: Any profile shows `Error` or `Failed` — click on that profile name to expand it and note the exact error code shown. If the error code is `0x80070005` (Access denied), enrolment is still not fully complete. Do not close the ticket. Raise with Endpoint Engineering and include the profile name and error code.
- Log to attach to ticket: on the device, navigate to `C:\Windows\System32\winevt\Logs\` and attach `Microsoft-Windows-DeviceManagement-Enterprise-Diagnostics-Provider%4Admin.evtx` to the ticket for Endpoint Engineering review.

---

**V3 — Confirm Azure AD join state on the device**

1. On the device, right-click **Start** and select **Windows Terminal (Admin)**, or search for `cmd`, right-click it, and select **Run as administrator**.
2. At the command prompt, type exactly: `dsregcmd /status` and press Enter.
3. In the output, scroll to the **Device State** section and locate the `AzureAdJoined` line.
- ✅ Pass: `AzureAdJoined : YES` and the `TenantName` line shows the expected DWP tenant name.
- ❌ Fail: `AzureAdJoined : NO` — the Azure AD join has broken during the procedure. Do not close the ticket. Do not rejoin manually. Immediately go to rollback scenario R5.
- Log to save: in the same command prompt window, run `dsregcmd /status > C:\MDMLogs\dsregcmd_output.txt` to save the full output, then attach `C:\MDMLogs\dsregcmd_output.txt` to the ticket.

---

**V4 — Confirm no legacy MDM connection remains on the device**

1. On the device, press `Windows key + I` to open **Settings**.
2. Click **Accounts** in the left panel.
3. Click **Access work or school**.
4. Review all connection tiles shown on the page.
- ✅ Pass: Exactly one connection tile is shown, labelled with the current DWP tenant name or the user's UPN (e.g. `rthomas@finbridge.gov.uk`). No second or legacy connection tile is present.
- ❌ Fail: A legacy connection tile is still visible — return to step 16 of the procedure and repeat the disconnect, then repeat step 17 (cleanup script). Retest V4 before closing.

---

## Rollback

> These scenarios are designed to be executed in under 3 minutes. Read the scenario that matches your situation, follow the numbered actions exactly, and stop. Do not attempt anything beyond what is written here without Endpoint Engineering on the call.

---

**R1 — You deleted the wrong Intune device record (deleted the current managed object instead of the stale one)**

Do this now, in this order:
1. Open `https://intune.microsoft.com`. Go to **Devices > All devices**. Search for the device name. Confirm the record is gone.
2. Do NOT click Create, Import, or attempt to rebuild the record.
3. Open the ticket. Add a note with: device name, serial number, and the exact time you deleted the record (check your browser history if unsure — the deletion confirmation page timestamp).
4. Call or message Endpoint Engineering immediately. Read them the note you just added. Use the words: *"Wrong Intune record deleted, need restore and Autopilot re-registration."*
5. Put the device aside. Do not reboot it, reset it, or attempt OOBE. Do not return it to the user.
6. Update the ticket status to **On Hold — Pending Endpoint Engineering**.

---

**R2 — You deleted the wrong Entra device object (deleted the current valid object instead of the stale one)**

Do this now, in this order:
1. Open your browser **History** (Ctrl+H in Edge/Chrome). Find the Entra device detail page you had open before deletion. Copy the URL — it contains the Object ID (a string of characters after `/devices/` in the URL, e.g. `a1b2c3d4-...`). Paste this into the ticket immediately.
2. Open `https://entra.microsoft.com`. Go to **Identity > Devices > All devices**. Search for the device name. Confirm the object is gone.
3. Do NOT attempt to create a new device object manually.
4. Add a note to the ticket with: device name, the Object ID you copied, and the deletion timestamp.
5. Call or message Endpoint Engineering immediately. Read them the note. Use the words: *"Wrong Entra device object deleted, Object ID is [paste ID], need restore and Autopilot re-registration."*
6. Put the device aside. Do not reboot, reset, or attempt OOBE. Do not return it to the user.
7. Update the ticket status to **On Hold — Pending Endpoint Engineering**.

---

**R3 — Autopilot Reset (step 19) failed or the device is stuck at a recovery or error screen**

Do this now, in this order:
1. On the device screen, read and photograph (with your phone) the exact error message or error code displayed.
2. Do NOT press reset again, attempt another Fresh Start, or power-cycle more than once.
3. Open the ticket. Add a note with: the exact error text or code from the screen, the current physical state of the device (e.g. *stuck at blue recovery screen*, *black screen after reset*).
4. Call or message Endpoint Engineering immediately. Use the words: *"Device bricked during Autopilot Reset, error is [paste text], marking as physically unavailable."*
5. Attach a sticky note to the device: **DO NOT USE — Awaiting Endpoint Engineering — [your name] — [date/time]**.
6. Do not return the device to the user under any circumstances.
7. Update the ticket status to **P1 — Endpoint Engineering Required**.

---

**R4 — Autopilot enrolment at step 20 failed again with error 0x80180014**

Do this now, in this order:
1. Do not trigger another OOBE or reset. Leave the device at the error screen.
2. Open `https://intune.microsoft.com`. Go to **Devices > All devices**. Search for the device. Check whether a new stale record appeared (a second entry with a failed or old check-in timestamp alongside the current attempt record).
3. Open `https://entra.microsoft.com`. Go to **Identity > Devices > All devices**. Search for the device. Check whether a duplicate Entra object re-appeared.
4. Collect the MDM diagnostic export again from the device: open an admin command prompt and run `mdmdiagnosticstool.exe -out C:\MDMLogs`. Zip the folder `C:\MDMLogs\` and attach it to the ticket.
5. Add a note to the ticket: *"0x80180014 recurred after full procedure. New MDM diagnostic attached. Intune and Entra screenshots attached. Awaiting Endpoint Engineering."*
6. Contact Endpoint Engineering. Do not rerun any cleanup steps independently.
7. Update the ticket status to **On Hold — Pending Endpoint Engineering**.

---

**R5 — Verification check V3 shows AzureAdJoined = NO after the procedure**

Do this now, in this order:
1. On the device, open an admin command prompt and run: `dsregcmd /status > C:\MDMLogs\dsregcmd_rollback.txt`
2. Zip `C:\MDMLogs\` and attach the zip to the ticket.
3. Open `https://entra.microsoft.com`. Go to **Identity > Devices > All devices**. Search for the device. Take a screenshot of what is shown (present or missing) and attach it to the ticket.
4. Add a note to the ticket: *"AzureAdJoined = NO confirmed at V3 post-procedure. dsregcmd output and Entra screenshot attached. Do not close."*
5. Do NOT attempt to manually re-join the device to Azure AD.
6. Contact Endpoint Engineering immediately. Use the words: *"Azure AD join broken post-Autopilot procedure, need re-join assessment."*
7. Do not return the device to the user. Update ticket status to **On Hold — Pending Endpoint Engineering**.

---

## Notes

**Edge cases**

- **Two stale Intune records exist:** Delete both stale records in step 6, but confirm each against serial number and last check-in before deleting. If uncertain which is stale, stop and raise with Endpoint Engineering.
- **No stale Entra object found (step 9):** This is expected in some cases where the legacy enrolment did not create a duplicate Entra object. Skip step 9 and continue — do not search further or force a deletion.
- **Cleanup script reports no artefacts found (step 12):** This is acceptable if admin-plane cleanup was complete. Continue to step 13. Do not re-run the script.
- **Device does not reach OOBE after Autopilot Reset (step 14):** Treat as R3 above immediately.

**Warnings**

- Partial cleanup (admin-plane only, or device-plane only) will not resolve the issue and will cause 0x80180014 to recur on the next Autopilot attempt. Both layers must be fully cleared before OOBE rerun.
- Do not return the device to the user after OOBE reset until V1–V4 all pass. An incomplete enrolment leaves the device unmanaged and non-compliant.
- The approved enterprise cleanup script must be used for step 12. Ad-hoc manual registry or certificate edits outside that script are not supported and may create additional faults.

**Related incidents and records**

- Known Error Record: DWP_Known_Error_Autopilot_Enrolment_Failure_0x80180014.md
- Source RCA: DWP_RCA_Detailed_Autopilot_Failure_0x80180014_5Why.md
- Reference incident: DESKTOP-FB099 / FINBRIDGE\rthomas — 2024-03-15

**Fleet prevention note**

This runbook is reactive. If your team is running an Autopilot rollout wave, a pre-wave eligibility gate should be in place to detect and clear legacy enrolment state before devices enter the wave. If that gate is not yet implemented, contact Endpoint Engineering before the next wave starts.
