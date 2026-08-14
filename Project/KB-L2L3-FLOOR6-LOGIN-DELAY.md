# Knowledge Base - L2/L3
## Floor 6 Login Delay After Windows 11 Migration

**Version:** v1.0  
**Date:** 07/08/2026  
**Status:** Draft

## Background
Floor 6 devices are Windows 11, Intune-managed, and were assigned a OneDrive Known Folder Move (KFM) policy. KFM redirects the Desktop folder to OneDrive and triggers a first-login sync of roughly 2.3 GB of desktop content. That sync blocks the sign-in flow until it completes, which is why the issue is floor-specific and first-login-specific.

## Symptom
The engineer sees the device stuck at login for 30+ minutes. The user reports that login used to take seconds, but now the first login after Monday morning is very slow. In some cases the user may also report that desktop items appeared late or that shortcuts were missing until sign-in finished.

## Root Cause
Specific technical cause:
- Floor 6 was assigned to the OneDrive Known Folder Move (KFM) policy in Intune.
- The policy redirected the user Desktop folder to OneDrive on first login after the Friday deployment.
- The first post-deployment login triggered a large OneDrive sync of roughly 2.3 GB of Desktop content.
- Windows held the sign-in session open until the OneDrive sync completed, creating the 30+ minute login delay.

Evidence that confirms it:
- Intune portal shows the OneDrive KFM policy assigned to Floor 6 and the device in In Evaluation during processing.
- Event Viewer shows System log policy application start/end events (Event ID 1001 and 1002) spanning about 32 minutes.
- OneDrive logs under C:\Users\[user]\AppData\Local\Microsoft\OneDrive\logs\ show KFM Policy Applied and Desktop sync activity in the same time window.
- Control floors without the KFM assignment do not show the same login delay.

## Detection
Target: confirm the issue in under 5 minutes before changing anything.

### 1) Confirm the policy assignment in Intune
Portal path:
- https://endpoint.microsoft.com > Devices > Configuration policies > OneDrive KFM policy > Assignments

What to look for:
- Floor 6 or Legal Department is listed as Assigned.
- Device status shows In Evaluation during the affected login window.

### 2) Confirm the login delay on the affected device
Local check:
- Ask the user what time sign-in started and how long the delay lasted.
- Note whether the delay happens only on the first login after the policy rollout.

### 3) Check Event Viewer on the affected device
Log locations:
- Windows Logs > System

Commands or GUI filter:
```powershell
$start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='System'; Id=1001,1002; StartTime=$start} |
	Where-Object { $_.ProviderName -eq 'Desktop Window Manager' -or $_.ProviderName -eq 'Microsoft-Windows-GroupPolicy' } |
	Select-Object TimeCreated, Id, ProviderName, Message
```

What to look for:
- Event ID 1001 and 1002 in the affected time window.
- A span of about 32 minutes between start and end.

### 4) Check OneDrive logs
Log location:
- C:\Users\[user]\AppData\Local\Microsoft\OneDrive\logs\

What to look for:
- Messages containing KFM Policy Applied.
- Desktop sync activity starting at login and finishing later in the same window.
- A sync size close to 2.3 GB.

### 5) Compare with a control floor
Control check:
- Review a Floor 3 or Floor 5 device that does not have the KFM assignment.

Pass criteria:
- Affected Floor 6 device shows the KFM assignment plus the 1001/1002 window and OneDrive sync.
- Control floor device does not show the same long delay.

## Resolution
Use this sequence to remove the cause and verify the fix.

### A) Remove the Floor 6 assignment
Portal path:
- https://endpoint.microsoft.com > Devices > Configuration policies > OneDrive KFM policy > Assignments

Action:
- Remove the Floor 6 or Legal Department assignment from the policy.
- Click Save.

Expected result:
- Floor 6 no longer appears in the assignment list.
- Intune saves the policy change successfully.

### B) Wait for the policy change to reach devices
Action:
- Wait 15-30 minutes for Intune to sync the updated policy.

Expected result:
- Floor 6 devices receive the updated assignment state.

### C) Test one Floor 6 pilot device
Action:
- Restart one Floor 6 device and sign in again.

Expected result:
- Login completes in about 7-15 seconds.
- The desktop becomes responsive immediately after sign-in.

### D) Confirm the long sync block is gone
Action:
- Recheck Event Viewer and OneDrive logs on the pilot device.

Expected result:
- Event Viewer no longer shows the 32-minute 1001/1002 policy window.
- OneDrive no longer shows the first-login KFM sync block for the affected login.

## Verification
1. Pilot login is under 15 seconds.
2. Event Viewer no longer shows a 32-minute policy application window.
3. OneDrive logs no longer show the first-login KFM sync block.
4. Help Desk stops receiving slow-login calls from Floor 6 within 24-48 hours.

## Rollback
If login is still slow after the removal, re-add Floor 6 to the KFM policy assignment in Intune, save, and wait for the device to resync. If the wrong policy was removed, re-add the removed group immediately. If the pilot device worsens after the change, stop rollout and escalate to Intune administration for a policy review.

## Preventive
Pre-sync large Desktop folders before KFM deployment, pilot new policy changes on one floor before full rollout, and publish a user notice before enabling folder redirection. Add a baseline login-time check to deployment validation so a first-login sync delay is caught before broad release.

## Related
Related to [KB-L2L3-FLOOR6-SHORTCUTS-MISSING.md](KB-L2L3-FLOOR6-SHORTCUTS-MISSING.md) and the RCA [INCIDENT-01-LOGIN-DELAY-RCA.md](INCIDENT-01-LOGIN-DELAY-RCA.md).