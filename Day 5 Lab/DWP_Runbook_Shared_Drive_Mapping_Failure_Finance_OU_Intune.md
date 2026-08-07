# Prompt
---
You are a DWP engineer writing a runbook for colleagues who will follow it cold, under pressure. Convert this RCA into a runbook with below sections:

prerequisites: what the engineer needs before starting (access rights, tools, which system etc)
Procedure: numbered steps, one action per step, expected result after each step
Verification: how to confirm the fix worked before closing
Rollback: what to do if the procedure makes thing worse - be specific not generic
Notes: edge cases, warnings, related incidents
rules:

Every step must be a single and concrete action
No step should require the engineer to guess what to do
the rollback section must be immediately actionable
Flag any step that requires elevated permissions
RCA: @file:DWP_RCA_Shared_Drive_Access_Failure_Finance_OU_Resolved_2026-08-07.md

save this as a file under day 5 Lab folder

# DWP Runbook: Shared Drive Mapping Failure – Finance OU (Intune Script Context Mismatch)

| Field | Detail |
|---|---|
| **Title** | Shared Drive Mapping Failure – Finance OU (Intune Script Context Mismatch) |
| **Runbook ID** | RB-DRIVE-INTUNE-001 |
| **Version** | 1.0 |
| **Date** | 07/08/2026 |
| **Author** | DWP Engineer |
| **Reviewed By** | Self |
| **Status** | Draft |
| **Change** | Initial version created from RCA: Shared Drive Access Failure – Finance OU (2026-08-07) |
| **Based on RCA** | Shared Drive Access Failure – Finance OU (Resolved 2026-08-07) |

---

## Prerequisites

Work through each checklist below. Do **not** begin the procedure until every box can be ticked.

---

### A – Access Rights

- [ ] You have an Intune Administrator or Global Administrator role in Microsoft Entra ID (formerly Azure AD). Confirm by opening `https://endpoint.microsoft.com` — if the **Devices** menu is visible and clickable, you have sufficient access.
- [ ] You have **read access to the Intune Management Extension logs** on an affected endpoint. This requires either RDP access to the machine or physical access with a local admin account.
- [ ] You can **RDP or physically access** at least one affected Finance endpoint (hostname format: `DESKTOP-FB0xx`) using a local admin or domain admin account.
- [ ] A **change record is raised and approved** in the ITSM tool for modifying and redeploying an Intune PowerShell script to the Finance device scope. Note the change reference here: `CR# _______________`

---

### B – Tools — Confirm Each Opens Successfully Before Starting

- [ ] **Microsoft Intune Admin Center** — open a browser and go to `https://endpoint.microsoft.com`. Sign in with your admin account. The home dashboard must load without an "Access Denied" or "Insufficient permissions" error.
- [ ] **PowerShell ISE or VS Code** — you will need to edit a `.ps1` script file. On a management machine press `Win + R` → type `powershell_ise` → press **Enter**. It must open without errors. Alternatively open VS Code if installed.
- [ ] **Event Viewer on an affected endpoint** — press `Win + R` → type `eventvwr.msc` → press **Enter**. The console must open without an "access denied" error.
- [ ] **File Explorer on an affected endpoint** — press `Win + E`. Confirm you can navigate to `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\` and that the file `IntuneManagementExtension.log` is present.
- [ ] **PowerShell (Elevated) on an affected endpoint** — press `Win + X` → select **Windows PowerShell (Admin)** or **Terminal (Admin)**. The title bar must show **Administrator**.

---

### C – Mandatory Information to Collect Before Starting

Ask the reporting user, infrastructure team, or check the change record and fill in each field below. The "Used in" column tells you exactly which step needs that value — do not guess.

| # | Information needed | How to get it | Used in |
|---|---|---|---|
| 1 | **Affected machine hostname(s)** | Ask the user: *"What is your computer name?"* They find it at: **Start → Settings (cog) → System → About → Device name**. Format: `DESKTOP-FB0xx` | Steps 1, 3, 4, 11 |
| 2 | **Finance shared drive UNC path** | Should be `\\finbridge-fs01\Finance` — confirm with the **File Server / Storage team** before assuming | Steps 1, 2, 4, 9 |
| 3 | **Drive letter that should be mapped** | Should be `S:` — confirm with the **Finance team lead** or the original change record | Steps 4, 9 |
| 4 | **Intune script name** | Open `https://endpoint.microsoft.com` → **Devices → Scripts and remediations → Platform scripts** and look for the Finance drive-mapping script. Should be `Map-FinBridgeDrives.ps1` | Steps 1, 2, 6, 9 |
| 5 | **Intune device group for Finance scope** | Ask the **Intune / AD team** for the group assigned to Finance devices (e.g. `GRP-Finance-Devices`) | Step 10 |
| 6 | **Time the fault first occurred** | Ask the reporting user: *"What time did you first notice you could not access the S: drive?"* — you will use this to identify the right log entries | Steps 1, 2, 3 |

- [ ] All six rows above are filled in before proceeding.

---

## Procedure

### Phase 1 – Confirm the Fault

**Step 1.** Open the Intune Management Extension log on an affected endpoint.
> On the affected endpoint press `Win + E` to open File Explorer.
> Click once in the **address bar** at the top of the window (the bar showing the current folder path — it will highlight in blue when clicked).
> The path text becomes editable. Type exactly the following and press **Enter**:
> `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs`
> The folder opens. Double-click the file `IntuneManagementExtension.log` to open it in Notepad.

> ⚠️ This log file can be very large. Do **not** scroll manually. Use the steps below to search.

> In Notepad, press `Ctrl + End` to jump to the bottom of the file (most recent entries first).
> Press `Ctrl + F` → in the **Find what** box type: `Map-FinBridgeDrives` → click **Find Next**.

*Expected result: Notepad jumps to a block of entries referencing `Map-FinBridgeDrives.ps1`. Check the timestamp on those lines against the fault time from Prerequisites Section C row 6 — they must match. You should see all four of these phrases within a few lines of each other:*
- `Script context is SYSTEM account`
- `Network path not accessible`
- `exit code 1`
- `No retry configured`

> If you cannot find `Map-FinBridgeDrives` in the log, the script may have a different name — check Prerequisites Section C row 4 and search for that name instead.

---

**Step 2.** Confirm the exact line that shows the script ran as SYSTEM and note the timestamp.
> With the log still open and your search result visible, look at the line that reads `Script context is SYSTEM account`.
> Write down the timestamp at the start of that line (format will be `[date time]`): `_________________`
> You will use this timestamp in Step 3 to confirm the Event Viewer entry matches.

*Expected result: The timestamp falls within the fault window the user reported. If the timestamp is from a previous day or much earlier than the reported fault, scroll down in Notepad and press `Ctrl + F` again to find a more recent occurrence — there may be multiple failed runs.*

---

**Step 3.** Check Event Viewer on the affected endpoint for the drive assignment failure event.
> Press `Win + R` → type `eventvwr.msc` → press **Enter**.
> In the **left pane**, expand **Windows Logs** (click the arrow next to it) → click **System** underneath it.
> Wait for the log to load in the centre pane — this may take 10–15 seconds on a busy machine.
> In the **right Actions pane** (far right column), click **Filter Current Log**.
> A dialog box opens. Click inside the field labelled **\<All Event IDs\>** (it shows `<All Event IDs>` as placeholder text), clear any existing text, and type: `98`
> Click **OK**.

*Expected result: The centre pane now shows only Event ID 98 entries. Look for the entry whose timestamp matches the timestamp you noted in Step 2 (within 1–2 seconds). Double-click that entry to open its details. The **General** tab description must contain: "File system could not map drive letter S:, drive letter not assigned".*

> If no Event 98 entries appear at all, the drive assignment failure was not logged here. Continue to Step 4 — the PowerShell check will still confirm whether S: is missing.

---

**Step 4.** Confirm drive S: is not currently mapped on the affected endpoint.
> On the affected endpoint, press `Win + X` → select **Windows PowerShell (Admin)** (or **Terminal (Admin)** on Windows 11). The title bar must show **Administrator**.
> Run:
```powershell
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Root
```

*Expected result: A table of drives appears. Drive `S` does **not** appear in the `Name` column. If you do not see S:, the fault is confirmed. If S: is listed with `Root` showing `\\finbridge-fs01\Finance`, the drive may have been re-mapped since the fault — note this, proceed to Step 5, and then proceed to Phase 2 to fix the underlying script context issue so it does not recur.*

---

**Step 5.** Rule out a Group Policy failure as a contributing cause before proceeding.
> In the Event Viewer window (still open from Step 3), in the **left pane** expand **Applications and Services Logs** → expand **Microsoft** → expand **Windows** → expand **GroupPolicy** → click **Operational** underneath it.
> In the **right Actions pane**, click **Filter Current Log**.
> Clear the Event ID field and type: `1500` → click **OK**.
> Look for an entry timestamped at or after the last machine startup (around the same time as Step 2–3 entries).

*Expected result: Event ID 1500 appears with Source = **Group Policy**, Level = **Information**. Double-click it — the **General** tab must read "The Group Policy settings for the computer were processed successfully". This confirms Group Policy is not the cause and the issue is isolated to the Intune drive-mapping script.*

> ❌ If Event 1500 is **absent** and you see Event IDs 1058, 1030, or 1129 instead, Group Policy is also failing. **Stop here.** Follow Runbook **RB-GP-DHCP-DNS-001** first, then return to this runbook once GP is resolved.

---

### Phase 2 – Fix the Intune Script Configuration

> ⚠️ **Elevated permissions required for all steps in Phase 2 (Intune Administrator role).** If the Intune portal shows "You don't have permission to view this page" at any point, stop and request the Intune Administrator role from your IT manager before continuing.

---

**Step 6.** Open the Intune Admin Center and navigate to the Finance drive-mapping script.
> Open your browser (Edge or Chrome). Go to: `https://endpoint.microsoft.com`
> Sign in with your admin account credentials.
> In the **left navigation bar** (the dark bar on the far left of the page), click **Devices**.
> A submenu expands under **Devices**. Click **Scripts and remediations**.
> At the top of the **Scripts and remediations** page, click the **Platform scripts** tab.
> A list of scripts appears. In the **search box** in the top-right of the list, type: `Map-FinBridgeDrives`
> Click the script name **Map-FinBridgeDrives.ps1** in the results.

*Expected result: The script's **Overview** page opens. You can see tabs or a left-side menu with options including **Properties**, **Device status**, and **User status**.*

> If you cannot find **Scripts and remediations** in the Devices submenu, look for **Scripts** directly — the label varies slightly between Intune tenants. The same Platform scripts list will be inside it.

---

**Step 7.** Open the script properties to inspect the current run context setting.
> On the script Overview page, in the **left-side menu** under the script name, click **Properties**.
> The Properties page loads showing three sections: **Basics**, **Script settings**, and **Assignments**.
> Scroll down past **Basics** to the **Script settings** section.
> Find the row labelled **Run this script using the logged on credentials**.

*Expected result: The value next to that label currently shows **No**. This is the misconfiguration — it means the script runs as the SYSTEM account instead of the logged-on user, which is why it cannot access the Finance UNC path. You will change this in Step 8.*

> If the value already shows **Yes**, the context setting has already been corrected by someone else. Continue to Step 9 to check whether the script file itself also has retry logic, then proceed to Phase 3.

---

**Step 8.** Edit the script and change the run context to USER.
> On the Properties page, click the **Edit** button at the top of the page (above the Basics section).
> The page changes to an edit wizard with steps shown at the top: **Basics → Script settings → Assignments → Review + save**.
> You are on the **Basics** step. Click **Next** at the bottom to move to **Script settings**.
> On the **Script settings** step, find the row **Run this script using the logged on credentials**.
> Click the toggle or dropdown for that row and change it from **No** to **Yes**.
> Do **not** click Next or Save yet — continue to Step 9 on the same edit wizard page.

*Expected result: The **Run this script using the logged on credentials** toggle or dropdown now shows **Yes**. The page is still in edit mode.*

---

**Step 9.** Download the current script file, update it with retry logic, and re-upload it.
> Still on the **Script settings** step of the edit wizard, look for the row labelled **Script location** or **Script file**.
> Next to the current file name (`Map-FinBridgeDrives.ps1`), click the **three-dot menu (⋯)** or the **download** icon to save the original file to your machine (save it to your Desktop or Downloads folder with the name `Map-FinBridgeDrives_ORIGINAL.ps1` so you have a backup).

> Now open PowerShell ISE to create the updated script:
> Press `Win + R` → type `powershell_ise` → press **Enter**.
> In PowerShell ISE, click **File → New** to open a blank script pane.
> Copy and paste the entire block below into the blank pane:

```powershell
# Map-FinBridgeDrives.ps1 – USER context with retry logic
$driveLetter = "S"
$uncPath     = "\\finbridge-fs01\Finance"
$maxRetries  = 3
$retryDelay  = 15  # seconds between attempts

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    if (Test-Path $uncPath) {
        if (-not (Get-PSDrive -Name $driveLetter -ErrorAction SilentlyContinue)) {
            New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $uncPath -Persist -Scope Global
            Write-Host "Drive $driveLetter`: mapped successfully on attempt $attempt."
        } else {
            Write-Host "Drive $driveLetter`: already mapped."
        }
        break
    } else {
        Write-Warning "Attempt $attempt of $maxRetries`: UNC path $uncPath not reachable. Waiting $retryDelay seconds."
        Start-Sleep -Seconds $retryDelay
    }
}

if (-not (Get-PSDrive -Name $driveLetter -ErrorAction SilentlyContinue)) {
    Write-Error "Drive $driveLetter`: could not be mapped after $maxRetries attempts. UNC path: $uncPath"
    exit 1
}
```

> Click **File → Save As**. Save the file to your Desktop as `Map-FinBridgeDrives.ps1`.
> Close PowerShell ISE.

> Back in the Intune portal edit wizard (still on the **Script settings** step):
> Click **Remove** next to the current script file to remove the old version.
> Click **Select file** → navigate to your Desktop → select `Map-FinBridgeDrives.ps1` → click **Open**.

*Expected result: The new file name `Map-FinBridgeDrives.ps1` appears in the script file field. Confirm the file size looks correct (it should be a few KB). Click **Next** at the bottom of the page to advance to the **Assignments** step.*

---

**Step 10.** Confirm the assignment scope and save the changes.
> On the **Assignments** step of the wizard, check the **Included groups** list.
> Confirm the Finance device group from Prerequisites Section C row 5 (e.g. `GRP-Finance-Devices`) is listed. Do **not** add or remove any groups unless explicitly stated in your change record.
> Click **Next** at the bottom to advance to the **Review + save** step.
> On the **Review + save** page, check the following two values before saving:
> - **Run this script using the logged on credentials** = **Yes**
> - **Script file** = `Map-FinBridgeDrives.ps1` (the file you just uploaded)
> Click **Save**.

*Expected result: A green confirmation banner appears at the top of the page: "Script saved successfully" or similar. You are returned to the Platform scripts list. The **Map-FinBridgeDrives.ps1** row shows a **Modified** timestamp within the last few minutes.*

---

### Phase 3 – Trigger Client Sync and Re-execution

**Step 11.** Send a sync command to the affected endpoint from the Intune portal.
> In the Intune Admin Center (`https://endpoint.microsoft.com`), in the **left navigation bar**, click **Devices**.
> In the submenu, click **All devices**.
> In the **search box** at the top of the device list, type the affected machine hostname from Prerequisites Section C row 1 (e.g. `DESKTOP-FB041`) → press **Enter**.
> Click the device name in the results to open its device page.
> At the top of the device page, click the **Sync** button in the action bar (it shows a circular arrow icon).
> A confirmation dialog appears: "Are you sure you want to sync this device?" → click **Yes**.

*Expected result: A notification banner appears at the top of the portal: "Sync request sent" or similar. The sync and script re-execution will complete within 5–10 minutes.*

> Repeat this step for each additional affected device from Prerequisites Section C row 1.

---

**Step 12.** Alternatively, if you have direct access to the endpoint and need faster results, trigger the sync from the device itself.
> On the affected endpoint, press `Win + I` to open **Settings**.
> Click **Accounts** in the left menu.
> Click **Access work or school** in the Accounts submenu.
> Click on the connected work or school account entry (it shows your organisation name underneath it).
> An expanded panel appears with an **Info** button — click **Info**.
> On the Account info page that opens, scroll down to find the **Sync** button under the heading **Device sync status**.
> Click **Sync**.

*Expected result: A progress spinner appears briefly next to the Sync button and a timestamp updates to show "Last attempted sync: [current time]". Intune will re-check and re-run pending scripts within a few minutes.*

---

**Step 13.** After 10 minutes, confirm in the Intune Management Extension log that the script ran again — and that this time it succeeded.
> On the affected endpoint, press `Win + E` → click the address bar → type `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs` → press **Enter**.
> Right-click `IntuneManagementExtension.log` → select **Open with** → select **Notepad**.
> In Notepad, press `Ctrl + End` to jump to the very bottom of the file (newest entries).
> The new run entries will be at the bottom. Look for a block of lines with a timestamp **after** the time you triggered the sync in Step 11 or 12.
> In that new block, press `Ctrl + F` → search for `Map-FinBridgeDrives` → click **Find Next** and keep clicking until you reach the most recent occurrence.

*Expected result: The most recent block for `Map-FinBridgeDrives.ps1` contains:*
- `Script context is` — this line must **not** say `SYSTEM account`. If it still says SYSTEM, return to Step 8 and re-confirm the toggle was saved as **Yes**.
- `Drive S: mapped successfully on attempt` — confirms the new script ran and mapped the drive.
- No `exit code 1` line in this block.

> If the log has not updated yet (no new block after your sync timestamp), wait another 5 minutes and refresh: close Notepad and re-open the log file.

---

## Verification

Complete every check in order. Do not mark the incident resolved until all five pass.

---

**Check 1 — Drive S: is now mapped on the endpoint**

> On the affected endpoint press `Win + X` → select **Windows PowerShell (Admin)**.
> Run:
```powershell
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Root
```

✅ **Pass:** Drive `S` appears in the output with Root showing `\\finbridge-fs01\Finance`.
❌ **Fail:** Drive `S` is absent. Check whether the Intune sync completed (go back to Step 13 and check the log again). If the log shows the script ran but S: is still missing, proceed to Check 2.

---

**Check 2 — The UNC path is reachable from the endpoint**

> In the same elevated PowerShell window, run:
```powershell
Test-Path "\\finbridge-fs01\Finance"
```

✅ **Pass:** Output returns `True`. The file server is reachable and the path exists.
❌ **Fail:** Output returns `False`. The file server is not reachable — this is a separate infrastructure issue. Do not close the incident. Escalate to the Storage/File Server team with the UNC path and the affected machine hostname. Do not proceed further until the path returns `True`.

---

**Check 3 — Drive S: persists after sign out and sign back in**

> Ask the affected user (or do this yourself on the test machine) to:
> Click **Start** → click their name/profile icon → select **Sign out**.
> Wait 30 seconds, then sign back in with their normal credentials.
> After login, press `Win + E` to open File Explorer.
> Check the **left pane** under **This PC** for drive **S: (Finance)** or equivalent label.

✅ **Pass:** Drive S: appears in File Explorer under **This PC** after a fresh login without any manual intervention.
❌ **Fail:** Drive S: is missing after relogin. Open the Intune Management Extension log (Step 13) and check whether the script ran at login time. If it ran but S: is absent, the `New-PSDrive -Persist` flag may not have taken effect — escalate to the Endpoint Engineering team.

---

**Check 4 — Intune log confirms USER context execution**

> On the affected endpoint, open `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` in Notepad.
> Press `Ctrl + F` → search for `Map-FinBridgeDrives` → locate the most recent run entry.

✅ **Pass:** The log entry for the most recent run does **not** contain `Script context is SYSTEM account`. The line `Drive S: mapped successfully` is present. Exit code is **0**, not 1.
❌ **Fail:** `Script context is SYSTEM account` still appears in the most recent run. The Intune portal change in Step 8 did not save correctly. Return to Step 7 and re-confirm the **Run this script using the logged on credentials** setting is **Yes**, then save again and repeat Steps 11–12.

---

**Check 5 — Affected user confirms access**

> Ask the affected user to open File Explorer and navigate to drive S:.
> Ask them to open a file they normally use from that drive.

✅ **Pass:** The user can browse S: and open their files without any error or permission prompt.
❌ **Fail:** The user sees "Access denied" when browsing S:. The drive is mapped but the user does not have the correct permissions to the share. This is a separate permissions issue — do not close the incident. Escalate to the File Server / Storage team with the username, UNC path, and the error message wording.

---

## Rollback

> ⚠️ **Target: complete all four steps within 3 minutes.** Read the entire section before starting.
> Trigger this section if: the Finance endpoint behaves worse after the script change (e.g. other drives disappear, login takes significantly longer, or new errors appear in the Intune log after your script was deployed).

---

**Rollback Step 1 — Revert the Intune script to the previous version (~90 seconds)**

> Open a browser → go to `https://endpoint.microsoft.com` → sign in.
> Click **Devices** in the left menu → click **Scripts and remediations** → click **Platform scripts**.
> Click **Map-FinBridgeDrives.ps1** → click **Properties** → click **Edit**.
> In the **Script settings** section, set **Run this script using the logged on credentials** back to **No**.
> Click **Remove** next to the uploaded script file.
> Upload the original script file you downloaded in Step 9 (the version before your edits, which should be in your Downloads folder — look for the file with an earlier timestamp).
> Click **Next** → **Next** → **Save**.

*The original SYSTEM-context script is restored. Affected machines will revert to the previous (broken) behaviour on next sync — but this stops any new problems your updated version may have introduced.*

---

**Rollback Step 2 — Force affected endpoints to pick up the reverted script (~45 seconds)**

> In the Intune Admin Center, click **Devices** → **All devices**.
> Search for the affected device hostname → click the device → click **Sync** → click **Yes**.
> Repeat for each affected device.

*The reverted script will execute on next Intune check-in (within 5–10 minutes).*

---

**Rollback Step 3 — If the user needs S: mapped immediately as a temporary fix (~20 seconds)**

> On the affected endpoint, press `Win + X` → select **Windows PowerShell (Admin)**.
> Run (substitute the UNC path and drive letter from Prerequisites Section C if different):
```powershell
New-PSDrive -Name "S" -PSProvider FileSystem -Root "\\finbridge-fs01\Finance" -Persist -Scope Global
```

✅ Drive S: is now mapped for this session. Warn the user it may not survive a restart — this is a temporary fix only until the Intune script issue is properly resolved.

---

**Rollback Step 4 — Escalate immediately (~10 seconds)**

> Stop all further changes. Contact the **Endpoint Engineering team** right now with the following information:

```
Escalation – Intune Script Rollback Required
Script name:         Map-FinBridgeDrives.ps1
Intune device group: [value from Prerequisites C]
Affected devices:    [value from Prerequisites C]
Drive letter:        S:
UNC path:            \\finbridge-fs01\Finance
Change made:         Run as logged-on user = Yes; retry logic added; script re-uploaded
Problem observed:    [describe what got worse]
Rollback taken:      Reverted to original script and re-synced devices
```

> ⚠️ Do **not** modify the script or its Intune assignment further until the Endpoint Engineering team confirms it is safe to proceed.

---

## Notes

### Edge Cases

- **Multiple Intune script versions:** If the Intune portal shows more than one version of `Map-FinBridgeDrives.ps1` or a similarly named script, check the **Assignment** tab on each one to confirm which is assigned to the Finance device group before editing anything.
- **Devices not yet synced:** Newly enrolled Finance devices may not have received the script at all. After deploying the fix, check the **Device status** tab on the script page in Intune — devices showing **Pending** or **Failed** have not yet received the corrected script; trigger a manual sync (Step 11) for each.
- **VPN-connected machines:** Devices connecting remotely via VPN may not be able to reach `\\finbridge-fs01\Finance` if split tunnelling is configured to exclude the file server subnet. Test `Test-Path "\\finbridge-fs01\Finance"` on any remote machine before assuming the script fix will work — a VPN routing issue must be resolved separately.
- **Cached credentials / locked sessions:** If a user has locked their screen rather than signing out, the USER-context script may not re-run until a full sign-out and sign-in. Always ask the user to fully sign out and sign back in to trigger the fix (Verification Check 3).
- **Drive letter conflict:** If drive letter S: is already in use by another mapped drive or device (e.g. a USB drive), `New-PSDrive` will fail silently. Run `Get-PSDrive -PSProvider FileSystem` to check for conflicts before re-mapping.

### Warnings

- Do **not** change the **Run this script using the logged on credentials** setting to **Yes** for scripts that genuinely require SYSTEM-level access (e.g. software installation, registry edits under `HKLM`). Only USER-context operations like drive mapping, desktop shortcuts, and per-user settings should use this setting.
- Editing a script that is deployed to a large device group (all Finance devices, ~45 machines) means any error in the new script will affect all of them simultaneously. Test on a single device first by temporarily changing the assignment scope to a test group, if time permits and the change record allows it.
- The `New-PSDrive -Persist` flag requires the script to run in USER context to persist across sessions. In SYSTEM context, `-Persist` has no effect — the drive will not appear for the logged-on user even if the command succeeds.

### Related Incidents and Knowledge Base References

| Reference | Description |
|---|---|
| RCA: Shared Drive Failure – Finance OU (2026-08-07) | Source RCA for this runbook |
| Runbook RB-GP-DHCP-DNS-001 | Group Policy failure runbook — check this first if Event 1500 is absent (Step 5) |
| Intune log path | `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\IntuneManagementExtension.log` |
| Key event IDs | Event 98 (Ntfs/System log) = drive letter not assigned; Event 1500 (GroupPolicy/Operational) = GP success |
| Key Intune log signals | `Script context is SYSTEM account` + `Network name cannot be found` + `exit code 1` + `No retry configured` = this failure pattern |
| CAPA: Script context gate | All future Intune script migrations must validate USER vs SYSTEM compatibility before production rollout |
| Post-change smoke test | Context confirmation → `Test-Path` UNC check → `Get-PSDrive` S: present → relogin persistence |
