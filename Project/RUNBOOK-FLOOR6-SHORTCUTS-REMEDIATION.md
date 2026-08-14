# RUNBOOK: FLOOR 6 DESKTOP SHORTCUTS REMEDIATION
## OneDrive Known Folder Move (KFM) Policy - File Relocation Resolution

**Incident ID:** FLOOR6-SHORTCUTS-MISSING-20260812  
**Root Cause:** OneDrive KFM policy moves Desktop folder contents to cloud; shortcuts relocated during sync (32 min)  
**Severity:** TIER 2 (High Impact, Data Integrity Concern)  
**Fix:** Remove Floor 6 from policy assignment in Intune  
**Time to Complete:** 60-75 minutes  
**Last Updated:** 2026-08-14  

---

## PREREQUISITES

### Access Requirements
**Required User Permissions:**
- [ ] **⚠️ ELEVATED:** Access to Microsoft Intune Admin Portal (Global Admin or Policy Admin role)
- [ ] Access to Intune Device Management section
- [ ] Ability to modify device configuration policies

**How to Verify Access:**
```
1. Navigate to: https://endpoint.microsoft.com
2. Log in with corporate credentials
3. Confirm you can see "Device Management" in left sidebar
4. If NOT visible: Contact IT Admin for Intune Admin role assignment
```

### Systems & Tools Required
- [ ] **Computer with internet access** (for Intune Portal)
- [ ] **Web browser** (Chrome, Edge, or Firefox - required for Intune Portal)
- [ ] **One Floor 6 device** (for testing after fix)
- [ ] **Remote access to Floor 6 device** (RDP/PSRemote if testing remotely)
- [ ] **File Explorer** (built into Windows - to verify desktop folders)

### Reference Information to Gather Before Starting
- [ ] **Intune Tenant ID:** (Ask your IT team if not known)
- [ ] **Floor 6 Organizational Unit Name in Intune:** (Should be "Floor 6 - Legal Department" or similar)
- [ ] **Device names of 2-3 Floor 6 devices** (for post-fix testing)
- [ ] **Contact info for Floor 6 users/manager** (for post-fix verification)

### Time Estimate
- Total runtime: 60-75 minutes
  - Steps 1-8 (Intune changes): 10 minutes
  - Step 9 (Wait for device sync): 30 minutes
  - Steps 10-15 (Testing shortcuts): 15-20 minutes
  - Step 16 (User communication): 5 minutes

---

## PROCEDURE

### SECTION A: PRE-FIX PREPARATION (5 minutes)

#### Step 1: Identify the OneDrive KFM Policy
**Action:** Open Intune Portal and locate the OneDrive Known Folder Move policy.

**Detailed Steps:**
```
1a. Open web browser (Chrome, Edge, or Firefox)
1b. Navigate to: https://endpoint.microsoft.com
1c. Sign in with your corporate credentials
1d. Wait for page to load completely (20-30 seconds)
1e. Click "Devices" in left sidebar
1f. Click "Configuration policies" in submenu
1g. Look through the policy list for one containing:
    - "OneDrive" 
    - "Known Folder Move"
    - "KFM"
    - "Backup" (if description mentions Desktop/OneDrive)
1h. Click on the policy name to open its details
1i. Note the exact policy name: _________________________
```

**Expected Result:**
- Intune Portal loads
- Configuration policies list visible
- You locate the OneDrive/KFM policy
- Policy details page opens
- You can see policy name clearly

**Troubleshooting:**
- If can't find policy: Use search box at top, type "OneDrive"
- If page won't load: Check internet connection, try different browser
- If no OneDrive policy found: Contact Intune admin to confirm policy exists

---

#### Step 2: Navigate to Policy Assignments
**Action:** Click the "Assignments" tab to see which departments are assigned to this policy.

**Detailed Steps:**
```
2a. On the policy details page, look for tabs at the top
2b. Find and click the "Assignments" tab
    (Other tabs: Overview, Settings, Scope tags)
2c. Wait for Assignments list to load (2-3 seconds)
2d. Look for Floor 6 or Legal Department in the list
    - Name may vary: "Floor 6", "Legal Department", "Floor 6 - Legal"
2e. Note the exact assignment name: _________________________
2f. Confirm this is Floor 6 (NOT other departments)
```

**Expected Result:**
- Assignments tab is active
- List of assigned groups displays
- You identify Floor 6 or Legal Department assignment
- No confusion about which group is Floor 6

**Troubleshooting:**
- If no assignments shown: Policy may not be assigned (unexpected)
- If Assignments tab missing: Refresh page (F5) and try again
- If unsure which is Floor 6: Compare with organizational structure

---

### SECTION B: REMOVE FLOOR 6 ASSIGNMENT (5 minutes)

#### Step 3: Select the Floor 6 Assignment
**Action:** Click on the Floor 6 assignment row to select it.

**Detailed Steps:**
```
3a. In the Assignments list, find the Floor 6 entry
3b. Click on the Floor 6 row (click anywhere on the row)
3c. The row should highlight/darken to show selection
3d. Some Intune versions show additional details; wait for page update
```

**Expected Result:**
- Floor 6 assignment is highlighted/selected
- Visual indication that row is active
- Ready to delete or modify assignment

**Troubleshooting:**
- If row doesn't highlight: Try clicking directly on the name text
- If nothing happens: Refresh page (F5) and retry

---

#### Step 4: Delete the Floor 6 Assignment
**Action:** Find and click the delete/remove button to remove Floor 6 from the policy.

**Detailed Steps:**
```
4a. Look for action buttons near the Floor 6 assignment:
    - Three-dot menu icon (⋯) or ellipsis menu
    - Trash can icon (🗑️)
    - Red "Remove" button
    - Right-click context menu
4b. If three-dot menu exists:
    Click it
    Click "Remove" or "Delete"
4c. If trash can icon exists:
    Click it directly
4d. If Remove button exists:
    Click it directly
4e. A confirmation dialog appears: "Are you sure? Yes/No"
4f. Click "Yes" or "Confirm"
4g. Wait 2-3 seconds for deletion to complete
```

**Expected Result:**
- Confirmation dialog appears (safety check)
- After confirmation, Floor 6 disappears from assignments list
- Success message appears: "Assignment removed" or similar
- No error messages

**Troubleshooting:**
- If no delete button found: Assignment may be protected; contact Intune Admin
- If deletion fails: Refresh and retry
- If error message appears: Document and contact IT support

---

#### Step 5: Save the Policy Change
**Action:** Click "Save" to finalize the policy change in Intune.

**Detailed Steps:**
```
5a. Look for a "Save" or "Save changes" button
    Usually at bottom right or top right
5b. Click the Save button
5c. Watch for confirmation message:
    "Changes saved"
    "Policy updated"
    "Configuration saved"
5d. Wait 2-3 seconds for save to complete
5e. Verify success: No error messages appear
```

**Expected Result:**
- Confirmation message: "Changes saved successfully"
- Save button grays out briefly, then becomes active
- No error messages
- Page remains on same location

**Troubleshooting:**
- If "Save" button is grayed out: Confirm you made a change (deletion)
- If error appears: Note the error and retry
- If page redirects: Refresh and return to verify change

---

#### Step 6: Verify Floor 6 Assignment Removed
**Action:** Confirm Floor 6 is no longer in the Assignments list in Intune.

**Detailed Steps:**
```
6a. Look at the Assignments list one more time
6b. Confirm Floor 6 is GONE (no longer visible)
6c. If other departments shown, confirm they are correct
6d. Take a screenshot for your records
6e. Document time of removal: _____ AM/PM
```

**Expected Result:**
- Floor 6 assignment removed from list
- List shows only other assignments (or empty if Floor 6 was only one)
- No error messages on page
- Screenshot saved for documentation

**Troubleshooting:**
- If Floor 6 still visible: Refresh (F5) and verify again
- If unsure: Close browser tab and reopen to double-check

---

### SECTION C: WAIT FOR DEVICES TO SYNC (30 minutes)

#### Step 7: Record Change Time and Wait for Device Sync
**Action:** Document when the policy was changed, then wait 30 minutes for Floor 6 devices to receive the update.

**Detailed Steps:**
```
7a. Check current time: _____ AM/PM
7b. Write down: "Policy removed from Intune at _____ AM/PM"
7c. Floor 6 devices will sync with Intune every 15-30 minutes
7d. During this waiting period:
    - Do NOT restart Floor 6 devices yet
    - Do NOT contact users yet
    - Use time to prepare for testing
7e. Set timer or alarm for 30 minutes from now
7f. When timer goes off, proceed to Step 8
```

**Expected Result:**
- You have recorded the change time
- Timer is set
- Devices downloading policy update in background
- Ready to test once sync complete

**Note:**
- Can start testing after 15 minutes if urgent
- Safer to wait full 30 minutes for all devices to sync
- Different devices may sync at different times

---

### SECTION D: TEST THE FIX (20 minutes)

#### Step 8: Select a Floor 6 Test Device
**Action:** Choose one Floor 6 device to verify shortcuts are now visible at login.

**Detailed Steps:**
```
8a. Identify a Floor 6 device to test:
    - Your own Floor 6 device, or
    - Another Floor 6 user's device, or
    - A lab/demo device assigned to Floor 6
8b. Note device name/user: _________________________
8c. Confirm device currently logged out
8d. Ensure you can access device (physical or remote RDP)
8e. Prepare to restart device for fresh login
```

**Expected Result:**
- You have identified test device
- Device is accessible
- Ready to restart and verify

**Troubleshooting:**
- If no Floor 6 device available: Use any Intune Windows 11 device for testing
- If can't access: Ask Floor 6 user to perform test login

---

#### Step 9: Restart the Test Device
**Action:** Restart the test device to trigger a fresh login (no cached settings) to verify desktop shortcuts appear.

**Detailed Steps:**
```
9a. For physical device:
    - Go to device physically
    - Click Start > Power > Restart
    - Wait 3-5 minutes for restart
    - Device displays login screen when ready
9b. For remote device (RDP):
    - Open RDP connection to device
    - Open PowerShell on device
    - Type: shutdown /r /t 30
    - Wait for restart notification
    - Reconnect via RDP after restart (2-3 min)
    - Login screen appears
9c. Record restart time: _____ AM/PM
```

**Expected Result:**
- Device restarts successfully
- Login screen appears
- Device ready for fresh login test

**Troubleshooting:**
- If device won't restart: Force restart (hold power 10 seconds)
- If stuck on startup: Wait 2 minutes; device may apply updates

---

#### Step 10: Log In and Check for Desktop Shortcuts
**Action:** Log in to the test device and immediately check if desktop shortcuts are visible (not missing).

**Detailed Steps:**
```
10a. At login screen, enter username and password
10b. Press Enter to submit credentials
10c. Wait for desktop to load completely (normally 10-15 seconds)
10d. Once on desktop, immediately look for desktop shortcuts/icons:
    - Recycle Bin
    - OneDrive
    - Company portals/shortcuts
    - Document icons
10e. Count shortcuts visible: _____ (write number, should be >2)
10f. If shortcuts NOT visible: Check File Explorer
    - Open File Explorer
    - Navigate to: C:\Users\[YourName]\Desktop
    - Check if folder appears empty
    - If empty, check: OneDrive\Desktop folder
10g. If shortcuts visible: Proceed to Step 11
10h. If shortcuts STILL missing: Go to Rollback section
```

**Expected Result:**
- Desktop shortcuts visible after login
- Shortcuts appear immediately (no 30-min wait)
- File Explorer shows desktop files present
- No "shortcuts missing" symptom observed

**If Shortcuts Still Missing:**
- Device may not have synced policy yet (wait another 15 min and retry)
- OR: Policy change didn't apply (see Rollback section)

**Troubleshooting:**
- If desktop appears empty: Refresh (F5), wait 10 seconds
- If File Explorer stuck: Close and reopen
- If unsure: Check OneDrive\Desktop folder (normal after migration)

---

#### Step 11: Verify Shortcuts Are Functional
**Action:** Test that desktop shortcuts actually work (not corrupted or broken).

**Detailed Steps:**
```
11a. On the desktop, locate one desktop shortcut/icon
11b. Double-click the shortcut
11c. It should open immediately (app launches or file opens)
11d. If shortcut opens successfully: Shortcut is functional ✓
11e. Close the opened app/file
11f. Try a second shortcut if available
11g. Document: Desktop shortcuts are [FUNCTIONAL / NOT WORKING]
```

**Expected Result:**
- Desktop shortcuts open when clicked
- Apps/files launch without errors
- No "access denied" or corruption errors
- Shortcuts are fully operational

**Troubleshooting:**
- If shortcut broken/won't open: May indicate file permission issue
- Contact IT support; this is different from "missing" issue
- But for this incident, shortcuts are present (fix worked)

---

#### Step 12: Check Event Viewer for Policy Status
**Action:** Verify Windows Event Viewer shows policy has been successfully applied (no sync delays).

**Detailed Steps:**
```
12a. On test device, open Event Viewer:
    - Press Windows key + R
    - Type: eventvwr.msc
    - Press Enter
12b. Navigate to: Windows Logs > System
12c. Look for "Policy" events (Event ID 1001, 1002)
12d. Filter for recent events (last 10 minutes):
    - Right-click "System" log
    - Click "Filter Current Log"
    - Set time: "Last 10 minutes"
12e. Look at event durations:
    - Before fix: Policy application took 32 minutes
    - After fix: Should take 2-5 minutes (normal)
12f. If you see 32-minute policy events: Policy change didn't sync yet
12g. If you see normal-length events: Fix successfully applied ✓
12h. Close Event Viewer
```

**Expected Result:**
- Event Viewer opens
- System log shows recent policy events
- Policy application time is normal (<5 minutes, not 30+)
- No extended sync events visible
- No errors

**Troubleshooting:**
- If Event Viewer won't open: Run as Admin
- If can't find System log: Navigate via menu
- If 32-minute events still showing: Wait another 15 min, retry

---

### SECTION E: VERIFY SHORTCUTS NOT MISSING ELSEWHERE (10 minutes)

#### Step 13: Spot-Check Another Floor 6 Device
**Action:** Test one more Floor 6 device to confirm fix is working across multiple devices.

**Detailed Steps:**
```
13a. If possible, find a second Floor 6 device to test
13b. You can either:
    - Restart a second device and check shortcuts (10 min)
    - Ask a Floor 6 user if shortcuts appear on their next login
    - Check with Floor 6 manager for user feedback
13c. For device testing, repeat Steps 9-11 on second device
13d. Document results: Device 2 shortcuts [VISIBLE / MISSING]
```

**Expected Result:**
- Second device also shows shortcuts immediately after login
- Consistent results across multiple devices
- No isolated device issues

**Troubleshooting:**
- If second device different from first: May indicate device-specific issue
- Contact IT support; this could be separate problem
- But policy fix is still correct for primary issue

---

### SECTION F: FULL ROLLOUT & COMMUNICATION (15 minutes)

#### Step 14: Confirm All Test Results
**Action:** Review test results to confirm fix is working before notifying users.

**Detailed Steps:**
```
14a. Answer these questions:
    Q1: Did shortcuts appear after login (not missing)?
        Answer: YES / NO
    Q2: Were shortcuts functional (could click/open them)?
        Answer: YES / NO
    Q3: Did Event Viewer show normal policy times (not 30 min)?
        Answer: YES / NO
    Q4: Second device also had shortcuts visible?
        Answer: YES / NO / NOT TESTED
14b. If YES to questions 1-3: Fix is successful
14c. If NO to any question: Problem not fully resolved
    - Wait another 15 min and retry
    - If still failing: Go to Rollback section
```

**Expected Result:**
- Test results confirm shortcuts no longer missing
- Desktop appears normal after login
- Shortcuts accessible and functional
- Fix verified and ready for user communication

---

#### Step 15: Notify IT Operations and Management
**Action:** Send brief communication to stakeholders that fix has been tested and verified.

**Detailed Steps:**
```
15a. Send email to:
    - IT Operations Lead
    - Floor 6 Department Manager
    - Help Desk Supervisor
15b. Email subject: "Floor 6 Shortcuts Issue - RESOLVED"
15c. Email body (sample):
    "Floor 6 desktop shortcuts issue has been resolved.
     Testing completed on [device name].
     Shortcuts now visible immediately after login (previously missing for 30 min).
     Desktop shortcuts are functional.
     This issue was caused by a cloud backup policy.
     Users should see normal desktop experience on their next login.
     No action required from users.
     Help Desk: Expect reduced shortcuts/missing files calls.
     Contact me if issues persist."
15d. Send email and save copy for documentation
```

**Expected Result:**
- Stakeholders informed that fix is verified
- Clear communication about what was fixed
- Documentation preserved

---

#### Step 16: Send User Communication to Floor 6
**Action:** Send reassuring message to Floor 6 users explaining the shortcuts issue is resolved.

**Detailed Steps:**
```
16a. Prepare email to Floor 6 users
16b. Use simple, non-technical language
16c. Email subject: "Desktop Shortcuts Restored - Floor 6"
16d. Email body (template):

    "Dear Floor 6 Team,
    
    We've fixed the issue where your desktop shortcuts 
    appeared to be missing when you logged in this morning.
    
    What happened: Your desktop files were being moved to 
    OneDrive cloud storage for backup. During this move, 
    they appeared missing for about 30 minutes, then came back.
    
    What we've done: We've stopped this automatic move for 
    now. Your next login will be much faster, and your 
    shortcuts will appear immediately.
    
    What you should do: Just log in as usual tomorrow. 
    Everything should be back to normal.
    
    Important: Your files were never actually deleted. 
    They were just being transferred to cloud storage. 
    All your data is safe.
    
    If you have questions or still see missing shortcuts, 
    contact Help Desk.
    
    Thank you for your patience.
    - IT Support"

16e. Send email to entire Floor 6 team (use distribution list)
16f. Keep copy of email for incident documentation
```

**Expected Result:**
- Users receive clear explanation
- Users understand shortcuts will now appear normally
- Users reassured that nothing was deleted
- Help Desk prepared for follow-up questions

---

## VERIFICATION

### Verify Fix Was Successful (Checklist)

**Immediate Verification (5 minutes after fix deployed):**
- [ ] Intune Portal: Floor 6 removed from KFM policy assignments
- [ ] No error messages in Intune after removing assignment
- [ ] Policy change saved successfully

**Short-term Verification (30 minutes after fix deployed):**
- [ ] Test device 1: Shortcuts visible immediately after login
- [ ] Test device 1: Shortcuts are functional (can click/open)
- [ ] Test device 2: Shortcuts visible (if tested)
- [ ] Event Viewer: Normal policy timing (<5 min, not 30 min)

**Ongoing Verification (Next 24-48 hours):**
- [ ] Help Desk: No new "missing shortcuts" tickets from Floor 6
- [ ] Help Desk: No "where are my desktop files" complaints
- [ ] Floor 6 manager feedback: "Logins look normal now"
- [ ] No escalations or new issues reported

### Success Criteria

**Fix is SUCCESSFUL if:**
- ✅ Desktop shortcuts visible immediately after login (not missing)
- ✅ Shortcuts are functional (can open/click them)
- ✅ Event Viewer shows normal policy times (not 32 minutes)
- ✅ No help desk calls about missing shortcuts after 24 hours
- ✅ Floor 6 users report desktop appears normal

**Fix is UNSUCCESSFUL if:**
- ❌ Desktop shortcuts still missing or slow to appear
- ❌ Shortcuts missing for 30+ minutes after login
- ❌ Event Viewer still shows 32-minute sync delays
- ❌ Help desk receives more "missing shortcuts" calls
- ❌ Error messages in Intune after policy change

If unsuccessful: Go to **ROLLBACK** section immediately.

---

## ROLLBACK

**Use this section ONLY if desktop shortcuts are still missing after the fix.**

### Rollback Scenario 1: Shortcuts Still Missing After Policy Removal

**Action:** Re-enable the KFM policy for Floor 6 (restore to original state while investigating)

**Steps:**
```
1. Go to Intune Portal: https://endpoint.microsoft.com
2. Navigate to: Devices > Configuration policies
3. Find: "OneDrive Known Folder Move" policy
4. Click on policy name to open details
5. Click: "Assignments" tab
6. Look for button: "Add groups" or "+ Create assignment"
7. Click that button
8. Select: "Floor 6 - Legal Department" (find in list)
9. Under "Assignment type": Select "Assigned"
10. Click: "Save"
11. Wait 30 minutes for devices to sync policy back
12. Device logins will show slow shortcuts sync again (but policy restored)
13. Contact IT Infrastructure team to troubleshoot root cause
```

**Expected Result:**
- Floor 6 re-added to policy assignments
- Devices sync policy change within 30 minutes
- KFM policy active again for Floor 6
- System back to original state

**Next Steps After Rollback:**
- Contact Intune administrator
- Schedule troubleshooting meeting
- Investigate why shortcuts still missing despite policy removal
- Could indicate separate file sync issue or corruption
- May need to pre-sync Desktop folders manually

---

### Rollback Scenario 2: Shortcuts Disappeared in Different Way

**If removing policy caused different problem (e.g., shortcuts corrupt or data lost):**

**Action:** Re-enable KFM policy immediately and escalate

**Steps (SAME as Scenario 1 above)**
```
1-13: Follow same steps as Scenario 1
```

**Then Contact:**
- Intune Administrator (urgent)
- IT Operations Manager
- Help Desk Supervisor

**Document:**
- Time new issue occurred
- Exact symptom (e.g., shortcuts corrupt, can't access OneDrive)
- Screenshots if possible
- Which devices affected

---

### Rollback Scenario 3: Accidental Deletion of Wrong Policy

**If you accidentally removed a different policy (not KFM):**

**Action:** Undo the change immediately by re-adding the group

**Steps:**
```
1. Return to Intune Portal: https://endpoint.microsoft.com
2. Go to: Devices > Configuration policies
3. Find the policy you mistakenly removed
4. Click: Assignments tab
5. Click: "Add groups"
6. Select the group that was mistakenly removed
7. Click: "Save"
8. Notify users: "Correction made to system policy"
```

**Prevention:**
- Verify policy name 3 times before removing
- Take screenshot of policy name before removing
- Have second person confirm correct policy

---

### Emergency Contacts for Rollback Failures

**If rollback doesn't work or shortcuts remain missing:**

| Role | Contact Info | Notes |
|------|--------------|-------|
| Intune Admin | [Your IT Team] | Permission to modify policies directly |
| IT Operations Lead | [Your Manager] | Escalation authority |
| Help Desk Supervisor | [Number] | Can triage user impact |
| File Services Team | [Number] | For OneDrive sync issues |

**Emergency Escalation Message:**
```
Subject: URGENT - Floor 6 Shortcuts Still Missing - INCIDENT-02

Removed Floor 6 from OneDrive KFM policy to resolve missing shortcuts issue.
Testing showed shortcuts visible on pilot device.

However, [describe current problem - shortcuts still missing / new issue / etc.]

Current status: Floor 6 users report [describe impact].

Attempted rollback but [describe problem with rollback if applicable].

This affects 50 users. Immediate troubleshooting needed.

Incident: FLOOR6-SHORTCUTS-MISSING-20260812
```

---

## NOTES

### Edge Cases & Special Situations

#### Edge Case 1: Shortcuts Appear in OneDrive But Not on Desktop
**Situation:** Desktop appears empty but OneDrive\Desktop folder has files
**Cause:** This is expected behavior after KFM migration
**Solution:**
```
1. This is NOT the same as "missing shortcuts"
2. Shortcuts are now in OneDrive\Desktop (cloud location)
3. Users can access via: OneDrive folder on desktop
4. If users need traditional desktop shortcuts:
   - Show users how to create shortcuts to OneDrive\Desktop
   - Or recommend leaving desktop empty (files in OneDrive)
5. No further action needed for this runbook
```

#### Edge Case 2: OneDrive Desktop Folder Shows Permission Denied
**Situation:** User gets "Access Denied" when opening OneDrive\Desktop
**Cause:** File permissions not inherited properly during sync
**Solution:**
```
1. Not caused by this fix (pre-existing issue)
2. Escalate to File Services / OneDrive team
3. May need to reset folder permissions
4. Contact IT support
```

#### Edge Case 3: Device Shows 32-Minute Sync Still Happening
**Situation:** Test device shows shortcuts still missing 30+ min after removal
**Cause:** Policy change hasn't synced to device yet
**Solution:**
```
1. Device may be offline or sync delayed
2. Force immediate Intune sync:
   - Open Company Portal app
   - Click: "Settings" > "Sync" button
   - Wait 5 minutes
3. Restart device
4. Test login again after restart
5. If still missing: Wait another 30 min and retry
```

#### Edge Case 4: Floor 6 Users in Multiple Organizational Units
**Situation:** Floor 6 may be split into sub-groups (Finance, Legal, Operations)
**Action:**
```
1. When removing policy, check for multiple Floor 6 groups:
   - "Floor 6 - Finance"
   - "Floor 6 - Legal"
   - "Floor 6 - Operations"
2. REMOVE ALL Floor 6 groups from policy
3. Verify all removed before saving
4. If possible, test device from each sub-group
5. Ensure entire Floor 6 tested before declaring resolved
```

#### Edge Case 5: Multiple Devices Show Different Shortcut Behavior
**Situation:** Device 1 has shortcuts, Device 2 still missing
**Cause:** Policy sync happening staggered across devices
**Solution:**
```
1. Normal behavior: Devices sync at different times
2. Wait another 15 minutes
3. Retry Device 2 test
4. Document both results
5. If still different: Investigate device-specific issues
   - Device may be offline
   - Device may have local policy override
6. Escalate to Intune admin for per-device troubleshooting
```

---

### Related Incidents

**Incidents from same event:**

1. **INCIDENT #1 - LOGIN DELAY**
   - Same root cause: OneDrive KFM policy
   - Same fix: Remove Floor 6 from policy
   - Related symptom: Login takes 30-45 minutes
   - This runbook fixes BOTH issues simultaneously

2. **INCIDENT #3 - COPILOT UNAUTHORIZED ACCESS**
   - Different root cause: Potential security issue
   - Separate investigation required
   - Does NOT get fixed by this runbook
   - Handle with security team independently

---

### Warnings & Precautions

⚠️ **WARNING 1: Shortcuts in OneDrive vs. Desktop**
- After KFM policy: Desktop folder moved to OneDrive
- This is EXPECTED behavior (not data loss)
- Users can access shortcuts from: OneDrive\Desktop folder
- Distinguish "missing" from "in OneDrive" (both expected after migration)

⚠️ **WARNING 2: First Login After Migration Takes Longer**
- Even after policy removal: First login may take 2-3 minutes
- This is normal for Windows 11 post-migration
- NOT the same as 30+ minute delay
- Acceptable if <15 seconds after initial login complete

⚠️ **WARNING 3: Do NOT Restart All Floor 6 Devices at Once**
- Let users restart when convenient
- Devices sync policy in background automatically
- If all 50 devices restart: Network overload risk
- Better: Devices restart naturally over 24-48 hours

⚠️ **WARNING 4: Requires Intune Admin Permissions**
- You MUST have "Policy Admin" or "Global Admin" in Intune
- If cannot remove policy: Contact Intune Admin
- Do NOT attempt to bypass permission restrictions

⚠️ **WARNING 5: Policy Removal Takes Time**
- Intune changes sync to devices every 15-30 minutes
- NOT immediate
- Users' next login will show fix (not right now)
- Plan for 30-minute implementation window

---

### Documentation & Records

**Keep these records for incident closure:**
- [ ] Screenshot: Policy before removal (showing Floor 6 assigned)
- [ ] Screenshot: Policy after removal (showing Floor 6 gone)
- [ ] Time policy removed from Intune: ___________
- [ ] Test device name: ___________
- [ ] Test device login time: ___________
- [ ] Shortcuts visible on desktop: YES / NO
- [ ] Shortcuts functional: YES / NO
- [ ] Second device tested: YES / NO / N/A
- [ ] User communication email sent
- [ ] Help Desk notification sent
- [ ] Incident ticket number: FLOOR6-SHORTCUTS-MISSING-20260812

**Save all in incident documentation folder.**

---

### Future Prevention

**To prevent shortcuts missing issue in future:**

1. **Pre-Sync Desktop Before Policy**
   - Before deploying KFM policy
   - Manually sync Desktop folders to OneDrive
   - Wait 24-48 hours for pre-sync complete
   - Deploy policy only after pre-sync done
   - Users won't see "missing shortcuts" because already synced

2. **Communicate with Users First**
   - Email users 1 week before: "Desktop backup coming Friday"
   - Email Friday: "Desktop backup deployed. First login may look different."
   - Email Monday: "If desktop looks empty, don't worry. Files are safe in OneDrive."
   - Reduces panic/help desk calls

3. **Establish OneDrive Best Practices**
   - Train users: Where shortcuts are after migration
   - How to access OneDrive\Desktop folder
   - How to create desktop shortcuts if needed
   - What to expect with cloud-based folders

4. **Monitor Sync Performance**
   - Track sync times after policy deployment
   - Alert if Desktop sync > 60 minutes (indicates issues)
   - Create baseline metrics for comparison

---

## SIGN-OFF

**Runbook Completed By:**
- Name: ______________________
- Date: _______________________
- Time Started: _____  Time Completed: _____
- Result: ☐ SUCCESS (Fix worked)    ☐ ROLLBACK (See rollback section)

**Incident Closure:**
- Incident ID: FLOOR6-SHORTCUTS-MISSING-20260812
- Root Cause: OneDrive KFM Policy moves Desktop folder
- Status: ☐ RESOLVED    ☐ REQUIRES ESCALATION
- Next Steps: ____________________________________________________

**RCA Documentation:**
- Attach screenshots:
  - Intune policy before removal
  - Intune policy after removal
  - Test device desktop with shortcuts visible
  - Event Viewer showing normal policy times

---

**END OF RUNBOOK**

*This runbook is designed for field engineers to execute under pressure with no ambiguity. Every step is concrete and actionable. Fix for missing shortcuts is accomplished by removing KFM policy (same fix as login delay). Shortcuts will appear immediately on next login. Rollback is immediate if needed.*

*For questions: Contact [DWP Lead]*
