# Knowledge Base - L2/L3
## Floor 6 Desktop Shortcuts Missing After Login

**Version:** v1.0  
**Date:** 07/08/2026  
**Status:** Draft

## Background
The Floor 6 devices use OneDrive Known Folder Move (KFM) under Intune. KFM redirects the Desktop folder into OneDrive so the local desktop becomes a cloud-backed location. During the first sync after the Friday policy deployment, desktop items move from the local profile into OneDrive Desktop.

## Symptom
The engineer hears that the desktop looks empty after sign-in. The user says their shortcuts disappeared when they logged in and came back later, or that the desktop looked blank while login was still finishing. The issue affects Floor 6 only and happens during the same login window as the slow-login complaint.

## Root Cause
Specific technical cause:
- Floor 6 was assigned to the OneDrive Known Folder Move (KFM) policy.
- KFM redirected the Desktop folder from the local profile path to OneDrive\Desktop.
- The first login after deployment triggered a sync of roughly 2.3 GB of desktop content, including shortcuts.
- During the sync window, the local desktop looked empty because the items were mid-transfer rather than deleted.

Evidence that confirms it:
- OneDrive logs show Desktop sync activity with the reason KFM Policy Applied.
- The logged Desktop folder size is about 2.3 GB and the item count is 847 files/shortcuts.
- The shortcuts reappear when sync completes, which rules out deletion.
- Event Viewer on the affected device shows the same policy application timing as the slow-login incident.
- Control floors without the KFM assignment do not show the same missing-shortcuts pattern.

## Detection
Target: confirm relocation, not deletion.

### 1) Confirm the policy assignment in Intune
Portal path:
- https://endpoint.microsoft.com > Devices > Configuration policies > OneDrive KFM policy > Assignments

What to look for:
- Floor 6 or Legal Department is assigned to the policy.

### 2) Check OneDrive logs on the affected device
Log location:
- C:\Users\[user]\AppData\Local\Microsoft\OneDrive\logs\

What to look for:
- KFM Policy Applied entries.
- Desktop sync start and finish during the affected login.
- Sync size around 2.3 GB.
- Item count around 847 files/shortcuts.

### 3) Compare the local desktop and OneDrive-backed desktop path
File paths:
- C:\Users\[user]\Desktop
- OneDrive\Desktop

What to look for:
- The local Desktop looks empty or incomplete during sync.
- The same items appear in OneDrive\Desktop after sync completes.

### 4) Check Event Viewer for matching policy timing
Log location:
- Windows Logs > System

Command or GUI check:
```powershell
$start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='System'; Id=1001,1002; StartTime=$start} |
	Where-Object { $_.ProviderName -eq 'Desktop Window Manager' -or $_.ProviderName -eq 'Microsoft-Windows-GroupPolicy' } |
	Select-Object TimeCreated, Id, ProviderName, Message
```

What to look for:
- Event ID 1001 and 1002 during the same window as the missing-shortcuts complaint.

### 5) Validate the control floor
Control check:
- A Floor 3 or Floor 5 device without the KFM assignment should not show the same empty-desktop pattern.

Pass criteria:
- The affected device shows KFM sync activity and the files appear in OneDrive\Desktop.
- The shortcuts are missing only while sync is in progress, not after completion.

## Resolution
Use this sequence to stop the relocation and verify the desktop comes back normally.

### A) Remove Floor 6 from the KFM policy
Portal path:
- https://endpoint.microsoft.com > Devices > Configuration policies > OneDrive KFM policy > Assignments

Action:
- Remove the Floor 6 or Legal Department assignment.
- Click Save.

Expected result:
- The Floor 6 group is no longer assigned.
- Intune saves the change successfully.

### B) Wait for the policy update
Action:
- Wait 15-30 minutes for the device to receive the new assignment state.

Expected result:
- Devices stop receiving the Desktop relocation behavior on the next sync cycle.

### C) Restart one Floor 6 pilot device
Action:
- Restart one affected device and sign in again.

Expected result:
- The desktop loads normally and the shortcuts are visible.

### D) Verify the file location
Action:
- Open File Explorer and check C:\Users\[user]\Desktop and OneDrive\Desktop.

Expected result:
- The shortcuts are present and accessible.
- If the desktop still points to OneDrive\Desktop, the files should be visible there rather than deleted.

## Verification
1. Desktop shortcuts appear on the first login after policy removal.
2. Shortcuts open normally when double-clicked.
3. OneDrive\Desktop contains the files if the desktop is still cloud-backed.
4. Event Viewer no longer shows 32-minute sync behavior.
5. Help Desk ticket volume for missing shortcuts drops off within 24-48 hours.

## Rollback
If shortcuts are still missing after removal, re-add Floor 6 to the KFM policy in Intune and save the change. If the wrong group or policy was removed, restore that assignment immediately. If the pilot device shows corrupted files or new access errors, stop the rollout and escalate to Intune administration and file services.

## Preventive
Pre-sync large desktop folders before KFM enablement, send a user notice before deployment, and pilot the change on a single floor before wider rollout. Add a desktop-content size check to deployment planning so large desktops are handled before policy activation.

## Related
Related to [KB-L2L3-FLOOR6-LOGIN-DELAY.md](KB-L2L3-FLOOR6-LOGIN-DELAY.md), [KB-L1-SHORTCUTS-MISSING-ARTICLE.md](KB-L1-SHORTCUTS-MISSING-ARTICLE.md), and [INCIDENT-02-SHORTCUTS-MISSING-RCA.md](INCIDENT-02-SHORTCUTS-MISSING-RCA.md).