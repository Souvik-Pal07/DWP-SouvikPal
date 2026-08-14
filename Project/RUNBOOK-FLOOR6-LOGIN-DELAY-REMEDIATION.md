# RUNBOOK: FLOOR 6 LOGIN DELAY REMEDIATION
## OneDrive Known Folder Move (KFM) Policy - Scope Removal

**Incident ID:** FLOOR6-LOGIN-DELAY-20260812  
**Root Cause:** OneDrive KFM policy deployed to Floor 6 syncs 2.3 GB Desktop folder at login (32 min)  
**Severity:** TIER 2 (High Impact)  
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
- [ ] **One Floor 6 device** (for testing after fix - can be virtual or physical)
- [ ] **Remote access to Floor 6 device** (RDP/PSRemote if testing from remote location)
- [ ] **Access to Event Viewer logs** (on Floor 6 test device - built into Windows)

### Reference Information to Gather Before Starting
- [ ] **Intune Tenant ID:** (Ask your IT team if not known)
- [ ] **Floor 6 Organizational Unit Name in Intune:** (Should be "Floor 6 - Legal Department" or similar)
- [ ] **Device names of 2-3 Floor 6 devices** (for post-fix testing)
- [ ] **List of Floor 6 users/manager contact info** (for post-fix verification)

### Time Estimate
- Total runtime: 60-75 minutes
  - Steps 1-8 (Intune changes): 10 minutes
  - Step 9 (Wait for device sync): 30 minutes
  - Steps 10-14 (Testing): 15-20 minutes
  - Step 15 (Communication): 5 minutes

---

## PROCEDURE

### SECTION A: PRE-FIX PREPARATION (5 minutes)

#### Step 1: Identify the Policy Name and Assignment
**Action:** Open Intune Portal and navigate to Configuration Policies to locate the exact policy and Floor 6 assignment.

**Detailed Steps:**
```
1a. Open web browser (Chrome, Edge, or Firefox)
1b. Navigate to: https://endpoint.microsoft.com
1c. Sign in with your corporate credentials
1d. Wait for page to load completely (may take 20-30 seconds)
1e. Look for left sidebar menu; click on "Devices" (or "Device Management")
1f. In submenu, click on "Configuration policies"
    OR "Compliance" > "Policies" (depending on Intune version)
1g. You should see a list of policies displayed
1h. Look for policy containing "OneDrive" or "Known Folder Move"
    - Policy name may vary: could be "OneDrive KFM", "Backup", etc.
    - If unsure, hover over policy descriptions to see details
1i. Once found, click on the policy name to open its details
1j. Note the exact policy name for your records
```

**Expected Result:**
- Intune Portal loads successfully
- You can see "Configuration policies" list
- You identify a policy related to OneDrive/KFM
- Policy details page opens showing policy settings
- You can see policy name clearly displayed at top

**Troubleshooting:**
- If can't find policy: Search for "OneDrive" in the search box at top of policies list
- If search bar unavailable: Try reloading page (F5)
- If Intune portal won't load: Check internet connection, try different browser

---

#### Step 2: Locate the Floor 6 Assignment
**Action:** Click on the "Assignments" tab within the policy to see which departments/groups are assigned.

**Detailed Steps:**
```
2a. On the policy details page, look for tabs across the top
2b. Find and click the tab labeled "Assignments"
    - Tabs are usually located under the policy name
    - Other tabs might say "Settings", "Scope tags", "Overview"
2c. You should now see a list of assignments
2d. Look for an entry containing "Floor 6" or "Legal Department"
    - Exact name may vary (could be "Floor 6 - Legal" or "Legal Department")
2e. Confirm this is Floor 6 and NOT other floors
2f. Note the exact assignment name for reference
```

**Expected Result:**
- Assignments tab is now active (showing content)
- You can see a list of groups/departments assigned to this policy
- You clearly identify "Floor 6" or "Legal Department" in the list
- You can see additional assignment details (if policy is active, status shows "Assigned")

**Troubleshooting:**
- If no Assignments tab visible: Try refreshing page (F5)
- If Assignments tab empty: Policy may not be assigned yet (unexpected - verify you have correct policy)
- If only one assignment shown: Confirm it's Floor 6 before proceeding

---

### SECTION B: REMOVE FLOOR 6 FROM POLICY (5 minutes)

#### Step 3: Select the Floor 6 Assignment
**Action:** Click on the Floor 6 assignment entry to select it.

**Detailed Steps:**
```
3a. In the Assignments list, find the Floor 6 entry
3b. Click on the Floor 6 assignment row (the entire row, not just the name)
3c. The row should highlight/darken to show it's selected
3d. You may see additional details appear (depending on Intune version)
```

**Expected Result:**
- Floor 6 assignment is highlighted/selected
- Visual indication that this row is now active
- You can proceed to delete or remove this assignment

**Troubleshooting:**
- If assignment not selectable: Try clicking on different part of the row
- If nothing highlights: Refresh page and try again

---

#### Step 4: Delete or Remove the Assignment
**Action:** Find the delete/remove button and click it to remove Floor 6 from the policy.

**Detailed Steps:**
```
4a. Look for a menu button or action buttons near the Floor 6 assignment
    Options may include:
    - Three-dot menu icon (⋯) 
    - Trash can icon (🗑️)
    - Red "Remove" or "Delete" button
    - Right-click context menu on the assignment
4b. If three-dot menu: Click it and select "Remove" or "Delete"
4c. If trash can icon: Click it directly
4d. If Remove button: Click it directly
4e. A confirmation dialog should appear asking "Are you sure?"
4f. Click "Yes", "Confirm", or "Delete" in the dialog
```

**Expected Result:**
- A confirmation dialog appears (safety check before deletion)
- After confirmation, Floor 6 assignment disappears from the list
- Assignment list is now empty or shows only other departments (if any)
- You see a success message: "Assignment removed successfully" or similar

**Troubleshooting:**
- If no delete button found: Assignment may be protected; contact Intune Admin
- If deletion fails: Refresh page and retry
- If error message: Document error text and contact IT support

---

#### Step 5: Save Changes to Intune
**Action:** Click the "Save" button to finalize the policy change in Intune.

**Detailed Steps:**
```
5a. Look for a "Save" or "Save changes" button
    Usually located at:
    - Bottom right of the page
    - Top right of the page
    - Near the assignment details
5b. Click the Save button
5c. Watch for a confirmation message:
    - "Changes saved" 
    - "Policy updated"
    - "Configuration saved"
    - A green checkmark may appear
5d. Wait 2-3 seconds for the system to process the save
```

**Expected Result:**
- You see a confirmation message: "Changes saved successfully"
- The button grays out briefly, then becomes active again
- No error messages appear
- You remain on the same page (not redirected)

**Troubleshooting:**
- If "Save" button disabled/grayed out: Confirm you made a change (deletion)
- If error appears: Note the error message and retry
- If page redirects: Refresh and return to Assignments tab to verify change

---

#### Step 6: Verify Change Saved in Portal
**Action:** Confirm the Floor 6 assignment is no longer shown in Intune Portal.

**Detailed Steps:**
```
6a. Look at the Assignments list one more time
6b. Confirm Floor 6 assignment is GONE (not visible in list)
6c. If other departments remain, confirm they are correct (Floor 3, Floor 5, etc.)
6d. Take a screenshot for your records (proof of change)
6e. Document the time you made this change: _______________ (write it down)
```

**Expected Result:**
- Floor 6 assignment removed from list
- List shows only other assignments (or empty if Floor 6 was only one)
- No error messages on page
- Portal is ready for next step

**Troubleshooting:**
- If Floor 6 still shown: Refresh page (F5); if still present, retry Step 4
- If unsure: Close browser tab and reopen Intune Portal to verify

---

### SECTION C: WAIT FOR DEVICE SYNC (30 minutes)

#### Step 7: Document Change Time and Wait Period
**Action:** Record when the change was made, then wait for Floor 6 devices to sync with Intune (15-30 minutes).

**Detailed Steps:**
```
7a. Check the current time: _____ AM/PM
7b. Write down: Policy removed from Intune at: _____ AM/PM (write actual time)
7c. Devices take 15-30 minutes to download the policy change from Intune cloud
7d. During this time:
    - Do NOT restart Floor 6 devices yet
    - Do NOT inform users yet
    - Use this time to prepare for testing
7e. Set a timer or reminder for 30 minutes from now
7f. When timer goes off, proceed to Step 8
```

**Expected Result:**
- You have recorded the change time
- Timer set for 30 minutes
- Ready to move to testing phase

**Note:** 
- If urgent: Can proceed to testing after 15 minutes (devices sync in 15-30 min cycle)
- If no urgency: Wait full 30 minutes to ensure all devices synced
- Staggered logins: Some devices may sync faster, others slower

---

### SECTION D: TEST THE FIX (20 minutes)

#### Step 8: Select a Pilot Device for Testing
**Action:** Choose one Floor 6 device to test the login fix before rolling out to all users.

**Detailed Steps:**
```
8a. Identify a Floor 6 device to test
    Options:
    - Your own device if you're on Floor 6
    - Visit a floor 6 user and ask to test their device
    - Use a test device assigned to Floor 6
    - Use a lab/demo device if available
8b. Note the device name/user for reference
8c. Confirm device is currently logged out (or log out current user)
8d. Make sure you have access to this device (physical or remote)
    - If remote: Have RDP/PSRemote connection ready
    - If physical: Have device physically available
8e. Prepare to restart this device for clean login test
```

**Expected Result:**
- You have identified one Floor 6 device
- Device is accessible (physical or remote)
- You're ready to restart and test

**Troubleshooting:**
- If no Floor 6 device available: Test on any Intune-managed Windows 11 device if possible
- If can't access device: Ask Floor 6 user to perform test login; document results

---

#### Step 9: Restart the Pilot Device
**Action:** Restart the Floor 6 device to trigger a fresh login (no cached credentials) to verify the fix.

**Detailed Steps:**
```
9a. If physical device:
    - Go to device physically
    - Click Start menu > Power > Restart
    - Wait for device to shutdown and restart (~3-5 minutes)
    - Device will display login screen after restart
9b. If remote device (RDP):
    - Open RDP connection to device
    - Once logged in, open PowerShell
    - Type: shutdown /r /t 30
    - This schedules restart in 30 seconds
    - Wait for disconnect/restart notification
    - Reconnect via RDP after restart (2-3 minutes)
    - Device login screen should appear
9c. Start timer: note the exact time restart begins
    Time restart started: _____ AM/PM
```

**Expected Result:**
- Device restarts successfully
- After restart, login screen appears
- Device ready for login timing test

**Troubleshooting:**
- If device won't restart: Force restart (hold power button 10 seconds)
- If stuck on startup screen: Wait 2 minutes; devices may apply updates after restart

---

#### Step 10: Perform Timed Login Test
**Action:** Log in to the pilot device and measure how long login takes (should be 7-10 seconds, not 30+ minutes).

**Detailed Steps:**
```
10a. When login screen appears, start a timer (use phone, computer clock, or stopwatch app)
10b. Enter username and password
10c. Press Enter to submit credentials
10d. Start timing NOW from the moment credentials submitted
10e. Watch the screen; typical login progression:
    - First: "Logging in..." message
    - Then: Desktop starts loading
    - Then: Taskbar appears
    - Then: Icons populate taskbar
10f. Stop timing when:
    - Desktop is fully visible AND
    - Taskbar icons are responsive AND
    - You can move the mouse smoothly (not frozen)
10g. Record login time: _____ seconds (write actual time)
10h. Do NOT proceed further; just log out and wait for verification
```

**Expected Result:**
- Login completes in 7-15 seconds (normal speed, NOT 30+ minutes)
- Desktop appears responsive after login
- No frozen screen or hung login process
- Taskbar icons functional

**If Login Still Slow (30+ minutes):**
- Device may not have received policy change yet (wait another 15 min and retry)
- OR: Policy change didn't apply successfully (see Rollback section)

**Troubleshooting:**
- If login hangs/frozen: Wait 2 minutes before force-restarting
- If login takes 2-3 minutes: This is acceptable (Windows 11 normal behavior post-migration)
- If login takes 30+ minutes: Problem NOT fixed; skip verification, go to Rollback section

---

#### Step 11: Verify Desktop Shortcuts Are Present
**Action:** After login, check that desktop shortcuts are visible (not missing).

**Detailed Steps:**
```
11a. On the logged-in desktop, look at the desktop area
11b. You should see desktop shortcuts/icons:
    - Typical: Recycle Bin, OneDrive, Company shortcuts, etc.
    - Count the shortcuts visible (at least 2-3 should be present)
11c. Try double-clicking one desktop icon
    - Icon should open (shortcut functional)
11d. Open File Explorer and navigate to:
    C:\Users\[YourUsername]\Desktop
11e. In File Explorer, you should see desktop files/shortcuts listed
11f. If missing: Check OneDrive folder:
    OneDrive\Desktop
    (Desktop folder should now be linked to OneDrive)
11g. Document: Desktop shortcuts are [PRESENT / MISSING]
```

**Expected Result:**
- Desktop shortcuts visible (or linked to OneDrive, which is normal)
- Shortcuts are functional (can open them)
- File Explorer shows desktop files
- No "access denied" or corruption errors

**Troubleshooting:**
- If shortcuts missing: They may be in OneDrive\Desktop (expected after KFM policy)
- If File Explorer shows error: Refresh (F5) or restart device

---

#### Step 12: Check Event Viewer for Successful Policy Application
**Action:** Verify Windows Event Viewer logs show policy successfully removed (no more sync events).

**Detailed Steps:**
```
12a. On the test device, open Event Viewer:
    - Press Windows key + R
    - Type: eventvwr.msc
    - Press Enter
12b. In Event Viewer, navigate to:
    Windows Logs > System
12c. Look for events with "Policy" in the event name
12d. Filter by time: Only show events from last 5 minutes (when restart happened)
    - Right-click on "System" log
    - Click "Filter Current Log"
    - Set "Time: Last 5 minutes"
12e. Look for Events:
    - Event ID 1001, 1002 (Policy Application events)
    - Recent events should be minimal (no 32-minute sync like before)
12f. Close Event Viewer
```

**Expected Result:**
- Event Viewer opens successfully
- System log shows recent events (from restart)
- Events are brief (1-2 minute policy application, not 30+)
- No errors or warnings related to policy
- No OneDrive sync blocking events

**Troubleshooting:**
- If Event Viewer won't open: Try running as Admin (right-click eventvwr.msc, Run as administrator)
- If can't find System log: Navigate via menu: Event Viewer (Local) > Windows Logs > System

---

### SECTION E: FULL ROLLOUT & VERIFICATION (15 minutes)

#### Step 13: Confirm Test Results Meet Success Criteria
**Action:** Review the test results to confirm the fix is working before rolling out to all Floor 6 users.

**Detailed Steps:**
```
13a. Answer these questions about your test:
    Q1: Did login complete in <15 seconds? 
        Answer: YES / NO
    Q2: Were desktop shortcuts present?
        Answer: YES / NO / PRESENT IN ONEDRIVE (all acceptable)
    Q3: Did desktop respond normally (no frozen screen)?
        Answer: YES / NO
    Q4: Did Event Viewer show normal policy events (not 30-min sync)?
        Answer: YES / NO
13b. If YES to ALL questions: Fix is successful, proceed to Step 14
13c. If NO to ANY question: Problem not fully resolved
    - Go to Rollback section (Step 16)
    - Contact IT Support
```

**Expected Result:**
- Test results confirm login is fast (7-15 seconds)
- Shortcuts accessible (either on desktop or in OneDrive)
- No system-level errors
- Fix verified and ready for organization rollout

---

#### Step 14: Notify IT Ops and Floor 6 Leadership
**Action:** Send brief communication to inform stakeholders that fix has been tested and is safe to deploy organization-wide.

**Detailed Steps:**
```
14a. Send email to:
    - IT Operations Lead
    - Floor 6 Department Manager
    - Help Desk Supervisor
14b. Email subject: "Floor 6 Login Fix - Tested and Ready"
14c. Email body (sample):
    "Floor 6 login issue has been resolved. Testing completed on [device name].
     Login time: [X] seconds (normal). 
     Desktop shortcuts accessible.
     Ready for full rollout to Floor 6.
     Users should see fast login on their next logon.
     Help Desk: Expect reduced login-related calls.
     Contact me if issues persist."
14d. Include this runbook link for reference
14e. Send email and retain copy for incident documentation
```

**Expected Result:**
- Stakeholders informed that fix is tested and working
- Clear communication about expected results
- Documentation preserved for future reference

---

### SECTION F: COMMUNICATE WITH USERS (5 minutes)

#### Step 15: Send User Communication to Floor 6
**Action:** Send a brief, reassuring message to Floor 6 users explaining the issue is fixed.

**Detailed Steps:**
```
15a. Prepare email to Floor 6 users (via department distribution list)
15b. Use simple, non-technical language (see template below)
15c. Email subject: "Login Speed Restored - Floor 6"
15d. Email body (template):

    "Dear Floor 6 Team,
    
    We identified and fixed the slow login issue from this morning.
    
    What happened: A cloud backup setting rolled out Friday that was 
    syncing files when you logged in. This caused the 30-minute delays.
    
    What we did: We've removed that setting for your group. Your next 
    login will be back to normal speed (about 10 seconds).
    
    What you should do: Just log in as usual. It should be fast.
    
    If you still experience slow login tomorrow morning, restart your 
    computer once and it should fix it. Contact Help Desk if issues 
    continue.
    
    Thank you for your patience.
    - IT Support"

15e. Send email to entire Floor 6 team
15f. Keep a copy of the email for documentation
```

**Expected Result:**
- Users receive clear explanation
- Users understand issue is resolved
- Users know what to expect (fast login next time)
- Help Desk prepared for any remaining calls

---

## VERIFICATION

### Verify Fix Was Successful (Checklist)

**Immediate Verification (5 minutes after fix deployed):**
- [ ] Intune Portal shows Floor 6 removed from KFM policy assignment
- [ ] No error messages in Intune after removing assignment
- [ ] Policy change saved successfully

**Short-term Verification (30 minutes after fix deployed):**
- [ ] Test device restarts successfully
- [ ] Test device login completes in <15 seconds (down from 30+ min)
- [ ] Desktop shortcuts present and functional on test device
- [ ] Event Viewer shows no extended policy sync events

**Ongoing Verification (Next 24-48 hours):**
- [ ] Help Desk reports: No new "slow login" tickets from Floor 6
- [ ] Help Desk reports: No "missing shortcuts" tickets from Floor 6
- [ ] Follow up with Floor 6 manager: "Are logins back to normal speed?"
- [ ] No escalations or critical issues reported

### Success Criteria

**Fix is SUCCESSFUL if:**
- ✅ Pilot device login: 7-15 seconds (not 30+ minutes)
- ✅ Desktop shortcuts: Visible and functional
- ✅ Event Viewer: No 32-minute policy sync events
- ✅ No help desk calls about slow login after 24 hours
- ✅ Floor 6 users report normal login experience

**Fix is UNSUCCESSFUL if:**
- ❌ Pilot device login still 30+ minutes
- ❌ Desktop shortcuts still missing after login
- ❌ Event Viewer shows continued sync delays
- ❌ Help desk receives more slow-login tickets from Floor 6
- ❌ Error messages in Intune after policy change

If unsuccessful: Go to **ROLLBACK** section immediately.

---

## ROLLBACK

**Use this section ONLY if the fix makes the situation worse or doesn't resolve the issue.**

### Rollback Scenario 1: Fix Didn't Work (Still Slow Login)

**Action:** Re-enable the KFM policy for Floor 6

**Steps:**
```
1. Go to Intune Portal: https://endpoint.microsoft.com
2. Navigate to: Devices > Configuration policies
3. Find: "OneDrive Known Folder Move" policy
4. Click on policy name to open details
5. Click: "Assignments" tab
6. Look for button: "Add groups" or "Edit assignments" or "Create assignment"
7. Click that button
8. Select: "Floor 6 - Legal Department" (or whatever the group name is)
9. Under "Assignment type": Select "Assigned"
10. Click: "Save"
11. Wait 30 minutes for devices to sync
12. Device logins will slow again (but at least predictable)
13. Contact IT infrastructure team to resolve root cause properly
```

**Expected Result:**
- Floor 6 re-added to policy assignments
- Devices sync policy change within 30 minutes
- First login after re-assignment will sync again (expected)
- System back to original state

**Next Steps After Rollback:**
- Contact IT management
- Schedule meeting with Intune admin + Help Desk
- Implement proper fix: Pre-sync Desktop folders BEFORE applying policy
- OR: Apply policy with user communication before first login
- Document lessons learned

---

### Rollback Scenario 2: Fix Caused New Problem

**If after removing policy, something worse happens (e.g., data sync issues, file access problems):**

**Action:** Re-enable KFM policy immediately

**Steps (SAME as Scenario 1 above)**
```
1-13: Follow same steps as Scenario 1
```

**Then Contact:**
- Intune Administrator (urgent)
- IT Operations Manager
- Information Security (if data access issues)

**Document:**
- Time issue occurred
- Exact error message or symptom
- Which devices affected
- Screenshot or error log

---

### Rollback Scenario 3: Accidental Deletion of Wrong Policy

**If you accidentally removed a different policy (not KFM):**

**Action:** Undo the change immediately

**Steps:**
```
1. Go back to Intune Portal: https://endpoint.microsoft.com
2. Go to: Devices > Configuration policies
3. Find the policy you mistakenly removed assignment from
4. Click: Assignments tab
5. Click: "Add groups"
6. Find the group that was mistakenly removed
7. Re-add the group
8. Save changes
9. Notify users: "The policy you removed has been restored"
```

**Prevention:**
- Verify policy name multiple times before removing
- Take screenshot of policy name before removing
- Ask second person to confirm correct policy before proceeding

---

### Emergency Contacts for Rollback Failures

**If rollback steps don't work:**

| Role | Contact | Notes |
|------|---------|-------|
| Intune Admin | [Your IT Team] | Has permission to force policy changes |
| IT Operations Lead | [Your Manager] | Escalation authority |
| Help Desk Supervisor | [Number] | Can field user complaints while troubleshooting |
| Incident Response | [Team] | For security-related issues |

**Message Template for Emergency Contact:**
```
Subject: URGENT - KFM Policy Rollback Failed - Incident ID: FLOOR6-LOGIN-DELAY-20260812

I removed Floor 6 from the OneDrive KFM policy in Intune to resolve slow login.
The fix worked on test device (login 10 sec, down from 30+ min).

Attempting rollback (re-add policy to Floor 6) but [describe problem].

Current status: [Describe symptom - logins still slow / devices not syncing / users complaining / etc.]

Devices affected: Floor 6 (50 users)

Immediate action needed: [Describe what you need IT to do]

This is Incident ID FLOOR6-LOGIN-DELAY-20260812 and is time-sensitive.
```

---

## NOTES

### Edge Cases & Special Situations

#### Edge Case 1: Device Doesn't Sync Policy Change Quickly
**Symptom:** After 30 minutes, test device still shows slow login
**Cause:** Policy sync cycle may be longer; Intune cached policy
**Solution:**
```
1. On test device, force immediate Intune sync:
   - Open Company Portal app
   - Click: "Settings" or "Account"
   - Click: "Sync" button
   - Wait for sync to complete (2-3 min)
2. Restart device
3. Test login again
4. If still slow: Escalate to Intune admin
```

#### Edge Case 2: Floor 6 Spans Multiple Organizational Units
**Situation:** Floor 6 users may be in multiple OUs (Finance-Floor6, Legal-Floor6, etc.)
**Action:**
```
1. Check if policy assignment shows multiple groups:
   - "Floor 6 - Finance"
   - "Floor 6 - Legal" 
   - "Floor 6 - Operations"
2. REMOVE ALL Floor 6 groups from the policy
3. Verify all Floor 6 groups removed before saving
4. Test with device from each sub-group if possible
```

#### Edge Case 3: Multiple Policies Assigned to Floor 6
**Situation:** Policy named "OneDrive" might not be the only KFM policy
**Action:**
```
1. Check all policy names carefully:
   - "OneDrive Known Folder Move"
   - "OneDrive Configuration"
   - "Desktop Backup"
   - "Cloud Sync Policy"
2. For each policy that redirects Desktop/Documents:
   Remove Floor 6 from assignment
3. Document which policies were removed
4. Test with multiple policies removed
```

#### Edge Case 4: User Refuses to Test on Their Device
**Situation:** Test user not available or won't restart device
**Options:**
```
Option 1: Use lab/demo device
- Find IT test device or laptop
- Add to Floor 6 assignment group (if possible)
- Use as test device instead

Option 2: Remote testing
- Ask test user for RDP access to their machine
- Perform test during their lunch or break
- Minimize business disruption

Option 3: Wait for after-hours testing
- Arrange with user to test after 5 PM
- Reduce impact on business operations
- Allow time to rollback if needed before next morning
```

---

### Related Incidents

**Other incidents from same event:**

1. **INCIDENT #2: Desktop Shortcuts Missing**
   - Same root cause: KFM policy
   - Same resolution: Remove policy
   - This runbook fixes both issues

2. **INCIDENT #3: Copilot Unauthorized Access**
   - Different root cause (potential security issue)
   - Requires separate security investigation
   - NOT fixed by this runbook
   - Handle independently with security team

---

### Warnings & Precautions

⚠️ **WARNING 1: Do NOT restart all Floor 6 devices at once**
- If all 50 devices restart simultaneously: Network overload
- Better: Devices sync in background naturally
- Users restart when convenient

⚠️ **WARNING 2: OneDrive data is NOT deleted**
- Policy removal keeps files in OneDrive
- Files remain safe and accessible
- Users can still access OneDrive\Desktop folder
- This is NOT data loss

⚠️ **WARNING 3: Do NOT remove wrong policy**
- Similar policy names might exist
- Verify "OneDrive" or "Known Folder Move" in description
- Ask second person to confirm before removing
- Take screenshots for documentation

⚠️ **WARNING 4: Requires Intune Admin permissions**
- You must have "Policy Admin" or "Global Admin" role in Intune
- If cannot access policy removal: Contact Intune Admin
- Do NOT attempt to bypass permission restrictions

⚠️ **WARNING 5: Policy removal takes time**
- Devices don't immediately download change
- Plan for 30-minute delay from fix to effect
- Users' next login will be normal (not immediate)
- Be prepared for 24-hour adjustment period

---

### Documentation & Records

**Keep these records:**
- [ ] Screenshot of policy assignment before removal
- [ ] Screenshot of policy after removal (confirming change)
- [ ] Time policy removed: ___________
- [ ] Time test completed: ___________
- [ ] Login time measurement from test: ___________
- [ ] Names of users/managers contacted: ___________
- [ ] User communication email sent (copy saved)
- [ ] Help Desk updated with notification
- [ ] Incident ticket number: FLOOR6-LOGIN-DELAY-20260812

**Save all in incident documentation folder for future reference.**

---

### Future Prevention

**To prevent this in the future:**

1. **Pilot Test Policy Deployments**
   - Deploy to 10% (1 floor) first
   - Monitor for 48 hours before full rollout
   - Measure login times; alert if >5 min increase

2. **Pre-Sync Large Folders**
   - Before deploying KFM policy
   - Manually sync >500 MB Desktop folders
   - Wait 24-48 hours for pre-sync to complete
   - Deploy policy only after pre-sync done

3. **Communicate Before Deployment**
   - Email users 1 week before: Policy coming Friday
   - Email users Friday: Policy deployed, first login may be slower
   - Email users Monday: If login slow, this is expected; will be normal by next login

4. **Establish Baseline Metrics**
   - Measure normal login time per floor (7-10 sec for Windows 11)
   - After major deployment, re-measure
   - Alert if >2× baseline
   - Track login time trends over time

---

## SIGN-OFF

**Runbook Completed By:**
- Name: ______________________
- Date: _______________________
- Time Started: _____  Time Completed: _____
- Result: ☐ SUCCESS (Fix worked)    ☐ ROLLBACK (See rollback section)

**Incident Closure:**
- Incident ID: FLOOR6-LOGIN-DELAY-20260812
- Root Cause: OneDrive KFM Policy Sync
- Status: ☐ RESOLVED    ☐ REQUIRES ESCALATION
- Next Steps: ____________________________________________________

**For RCA Documentation:**
- Attach screenshots of:
  - Intune policy assignment (before removal)
  - Intune policy assignment (after removal)
  - Test device login timing
  - Event Viewer logs (showing no sync)

---

**END OF RUNBOOK**

*This runbook is designed for field engineers with Intune access to execute cold under pressure. Every step is concrete and actionable. Rollback is immediate and specific. No guessing required.*

*For questions or corrections, contact: [DWP Lead]*
