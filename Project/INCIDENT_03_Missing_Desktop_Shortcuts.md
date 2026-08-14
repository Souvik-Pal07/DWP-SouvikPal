# INCIDENT 03: Missing Desktop Shortcuts - Configuration & User Experience
**FinBridge Legal Department | Floor 6 | Incident ID: CFG-2026-0814-003**

---

## INCIDENT BREAKDOWN

### Issue Statement
At least one user on Floor 6 reports that desktop shortcuts have disappeared. Previously accessible shortcuts to frequently-used applications or files are no longer visible on the desktop.

### Why This Is a Separate Incident
- **Incident Category:** User Experience & Configuration (not data access, not system availability)
- **Isolation Rationale:** Users CAN still log in and work; they simply have lost quick access to desktop shortcuts. This is independent of login performance issues (INCIDENT 02) and Copilot data access (INCIDENT 01). A user could have this issue even with a fully operational login.
- **Business Impact:** Moderate degradation; users are inconvenienced but productive. Shortcuts can be recreated manually or restored from backup.
- **Root Cause Domain:** Windows 11 user profile migration, desktop.ini corruption, OneDrive Known Folder Move, Group Policy Desktop redirection, or accidental user action
- **Containment Scope:** User-level configuration restoration, not system-wide remediation

---

## PRIORITY ASSESSMENT

### Severity: **MEDIUM** 🟡
- **Business Impact:** Moderate — users are inconvenienced but still productive
- **User Count:** 1 confirmed, unknown if others affected
- **Urgency:** Low-to-Moderate — can be worked around by manual navigation or shortcut recreation
- **Workaround Available:** YES — users can recreate shortcuts or use Start menu / File Explorer

### Priority Ranking Among Floor 6 Issues
**RANK 3 OF 3** — Ranked below both security incident (INCIDENT 01) and availability incident (INCIDENT 02). This is a comfort/convenience issue, not a blocking issue.

**Rationale:** Security breach must be contained immediately. System access must be restored immediately. Missing shortcuts are an annoyance; users can navigate using File Explorer or Start menu while this is being resolved.

---

## FACTS VS ASSUMPTIONS VS UNKNOWNS

### VERIFIED FACTS
- ✅ At least one user reports missing desktop shortcuts
- ✅ User is on Floor 6 (Legal department)
- ✅ Floor 6 was recently migrated to Windows 11
- ✅ Floor 6 users were recently enrolled in Intune
- ✅ New document management application was deployed Friday
- ✅ The user's device is currently operational (able to access incident report channel)

### ASSUMPTIONS (HIGH RISK - MUST VERIFY)
- ⚠️ **Assumption:** Shortcuts were deleted or moved, not hidden
  - *Counter-reality:* Shortcuts could be hidden by View settings (View → Hidden files) or by desktop.ini corruption
  - *Verification:* Check desktop.ini file; verify Show/Hide Files setting in File Explorer

- ⚠️ **Assumption:** This is specific to this user's profile
  - *Counter-reality:* Could be floor-wide issue affecting all users, but only one has reported it
  - *Verification:* Spot-check 3-5 other Floor 6 users' desktops

- ⚠️ **Assumption:** Shortcuts were accidentally deleted by user
  - *Counter-reality:* Could be automatically removed by Intune policy, profile migration script, or Group Policy
  - *Verification:* Check Intune policy for "Desktop Icon" settings; check Group Policy restrictions; check migration logs

- ⚠️ **Assumption:** This is related to Windows 11 migration
  - *Counter-reality:* Could be unrelated to migration and caused by user action, app uninstall, or update
  - *Verification:* Ask user: "When did you notice the shortcuts were missing?" (This morning? Yesterday? Last week?)

- ⚠️ **Assumption:** Shortcuts are needed for work
  - *Counter-reality:* Shortcuts might be convenience items that user can work without (applications in Start menu, documents in OneDrive)
  - *Verification:* Ask user: "Which shortcuts are missing?" "Do you need them to do your job?"

### UNKNOWNS (CRITICAL GAPS)
- ❓ **How many shortcuts are missing?** (All? Most? A specific subset?)
- ❓ **Which applications/files do the shortcuts point to?** (Microsoft Office? Custom apps? Document folders?)
- ❓ **When were the shortcuts last seen?** (Friday end of day? This morning before login attempt?)
- ❓ **Are other desktop items missing?** (Folder icons? Recycle Bin? Taskbar items?)
- ❓ **Is this affecting other Floor 6 users or just this user?** (Isolated or widespread?)
- ❓ **Does the user have a backup or recovery point?** (System Restore enabled? OneDrive backup?)
- ❓ **What is the exact Windows 11 build and user profile state?** (Fresh profile? Migrated profile?)
- ❓ **Is the new document management app using desktop integration?** (Does app installation remove existing shortcuts?)
- ❓ **Did the user install or update anything Friday/weekend?** (App install, Windows Update?)

---

## FIRST 30-MINUTE TRIAGE PLAN

### **Minute 0-2: Incident Receipt & Scope Confirmation**
**Actions:**
1. Record incident timestamp: 09:14 (reported along with other Floor 6 issues)
2. Assign incident ID: CFG-2026-0814-003
3. **Determine priority relative to other Floor 6 incidents:**
   - Is user blocked from working? (YES = higher priority; NO = lower priority)
   - Can user continue work using alternative navigation? (YES = lower priority; NO = higher priority)
   - Are many shortcuts missing or just a few? (Many = higher priority; Few = lower priority)
4. **Triage Decision:**
   - If user is blocked and widespread: Escalate to MEDIUM-HIGH
   - If user is not blocked and isolated: Keep at MEDIUM-LOW, defer to Phase 2 if other incidents are critical

**Owner:** Incident Commander
**Output:** Incident ticket created; triage decision made; resource allocation adjusted

---

### **Minute 2-5: User Interview & Symptoms Gathering**
**Actions:**
1. Contact the affected user directly (phone or Teams chat)
2. **Information gathering questions:**
   - "Can you describe which shortcuts are missing?" (List them or screenshot desktop)
   - "When did you last see these shortcuts?" (Friday EOD? This morning?)
   - "Are ALL your desktop shortcuts gone, or just some?" (Distinguish complete loss vs. partial)
   - "Do you have anything else on your desktop?" (Folder icons? Recycle Bin icon?)
   - "Can you see your files in File Explorer or OneDrive?" (Verify file access still works)
   - "Did you install any software this weekend?" (Could app install have removed shortcuts?)
   - "Did you delete anything from your desktop recently?" (Accidental delete?)
   - "Did your computer restart this weekend?" (Could trigger profile rebuild)

3. **Request visual evidence:**
   - Screenshot of current desktop
   - Screenshot of File Explorer → Desktop folder (to verify files are actually missing)

4. **Assess work impact:**
   - "Can you still do your job without these shortcuts?" (YES = low priority; NO = higher priority)
   - "What alternative would help?" (Recreate shortcuts? Point to Start menu? OneDrive access?)

**Owner:** IT Support / Incident Commander
**Output:** Detailed symptoms, timeline, work impact assessment

---

### **Minute 5-8: Rapid Desktop Investigation (On User's Device)**
**Actions:**
1. **Have user open File Explorer and navigate to desktop location:**
   - Path: `C:\Users\[username]\Desktop`
   - **Observation:** Are the shortcut files (.lnk files) actually present?
     - If files present but not visible on desktop → Hidden file issue
     - If files missing from folder → Files were deleted or moved

2. **Check desktop settings visibility:**
   - Right-click desktop → View → "Show desktop icons" (is it unchecked?)
   - If unchecked: Enable it
   - Right-click desktop → View → "Show hidden files" (are hidden shortcuts present?)

3. **Check desktop.ini corruption:**
   - Open File Explorer → Tools → Options → View
   - Check: "Show hidden files, folders, and drives" option
   - If desktop.ini exists but is corrupted, rebuild it:
     - Delete `C:\Users\[username]\Desktop\desktop.ini` (backup first)
     - Restart File Explorer (Ctrl+Shift+Esc → File Explorer → Restart)

4. **Check for Group Policy Desktop restrictions:**
   - Have user run: `gpresult /h report.html` and open report
   - Look for any Group Policy restrictions on desktop or shell
   - If restricted, this is likely a policy issue

5. **Check OneDrive desktop folder redirect:**
   - If OneDrive Known Folder Move (KFM) is enabled, desktop folder might be syncing
   - Open File Explorer → This PC → Desktop (on C: drive)
   - Compare with OneDrive → Desktop (in cloud)
   - Are they the same? Or is desktop folder being synced somewhere else?

**Owner:** IT Support (remote screen share with user)
**Output:** Root cause hypothesis (files deleted vs. hidden vs. redirected vs. policy-blocked)

---

### **Minute 8-15: Parallel Investigation Streams**

**Stream A: Intune Policy Audit (Intune Administrator)**
1. Log into Intune admin center
2. Find affected user's device in device list
3. **Check device policies:**
   - Are there any Group Policy Objects (GPOs) or mobile device management (MDM) policies that restrict desktop icons?
   - Look for policies containing "DesktopIcon", "Shell", "Explorer", or "Startup"
4. **Check for Kiosk Mode or Restricted Shell:**
   - If device is in Kiosk Mode → desktop icons would be hidden
   - If Restricted Shell policy is applied → desktop customization would be blocked
5. **Check policy application history:**
   - When were these policies deployed?
   - Was there a policy change in past 72 hours that could have removed shortcuts?

**Stream B: Windows 11 Migration Log Review (System Engineer)**
1. Locate user's device migration records
2. **Check migration details:**
   - Was user's profile migrated from Windows 10 to Windows 11? (New profile vs. migrated?)
   - Did migration preserve desktop shortcuts? (Depends on migration method used)
   - Were there any errors during profile migration?
3. **Check profile type:**
   - Is this a fresh Azure AD profile or a hybrid-synced profile?
   - If hybrid: were synced settings supposed to restore desktop shortcuts?
4. **Check migration backup:**
   - Is there a system image or recovery point from before Windows 11 migration?
   - Could shortcuts be recovered from backup?

**Stream C: User Profile Integrity Check (File System)**
1. Check desktop folder for `.lnk` files:
   - `Get-ChildItem "C:\Users\[username]\Desktop" -Filter "*.lnk"` (PowerShell)
   - If no .lnk files: shortcuts were deleted or moved
   - If .lnk files present: shortcuts are hidden or path issue
2. Check AppData for shortcut backups:
   - `C:\Users\[username]\AppData\Local\Microsoft\Windows` (Recent shortcuts)
   - `C:\Users\[username]\AppData\Roaming\Microsoft\Windows\Recent`
   - Could shortcuts be recovered from recent items?
3. Check Recycle Bin:
   - Are deleted shortcuts in Recycle Bin? (Can restore manually)
   - `Get-Item "$env:USERPROFILE\$Recycle.Bin" -Force` (PowerShell check)

**Stream D: Application Change Log (if new app deployed)**
1. Review document management app deployment details
2. **Check for desktop shortcuts in app installer:**
   - Did app installation include removing existing shortcuts?
   - Did app try to "clean" the desktop?
   - Check app installer logs: `C:\ProgramData\[app-name]\` or `C:\Users\[username]\AppData\Local\[app-name]\`
3. **Review app recent changes:**
   - Were any system shortcuts removed during app setup?
   - Does app have "Reset desktop" or "Clean desktop" feature?

**Owners:** Parallel teams (Intune Admin, System Engineer, File System, Application Owner)
**Output:** Four concurrent investigations; hypothesis narrowed

---

### **Minute 15-20: Rapid Triage Synthesis & Root Cause Hypothesis**

**Decision Matrix:**
| Root Cause Hypothesis | Evidence from Stream A | Evidence from Stream B | Evidence from Stream C | Evidence from Stream D | Likelihood |
|---|---|---|---|---|---|
| Intune policy restricts desktop | Desktop icon policy found? | N/A | Files missing? | N/A | HIGH/MED/LOW |
| Windows 11 migration lost shortcuts | N/A | Profile migration error? | Files not present in new profile? | N/A | MED/LOW |
| New app removed shortcuts | N/A | N/A | Files deleted recently? | App uninstall log shows removal? | MED/LOW |
| User accidentally deleted | N/A | N/A | Files in Recycle Bin? | N/A | MED/HIGH |
| OneDrive KFM redirected desktop | N/A | KFM policy enabled? | Desktop syncing to OneDrive? | N/A | MED |
| Desktop.ini corrupted | Hidden file setting? | N/A | desktop.ini file exists? | N/A | LOW/MED |
| Group Policy desktop restriction | GPO restricting desktop? | N/A | Files present but hidden? | N/A | LOW/MED |

**Root Cause Ranking (Most to Least Likely):**
1. **User accidentally deleted** (most common scenario)
2. **Intune policy restricts desktop icons** (explains multiple users if widespread)
3. **New app removed shortcuts during installation** (timing correlation with Friday deployment)
4. **OneDrive KFM redirected desktop folder** (explains both missing shortcuts and sync behavior)
5. **Windows 11 migration profile corruption** (explains if migration was incomplete)
6. **desktop.ini corruption or Group Policy restriction** (less common but possible)

**Owner:** Incident Commander + Investigation Lead
**Output:** Root cause hypothesis with >70% confidence

---

### **Minute 20-25: Targeted Quick-Fix Testing**

**Test 1: If User Accidentally Deleted (Highest Likelihood)**
- **Action:** Check Recycle Bin for .lnk files
  - `$recycle = Get-Item "$env:USERPROFILE\$Recycle.Bin" -Force -ErrorAction SilentlyContinue`
  - If shortcuts found: Restore from Recycle Bin
- **Timeline:** 2 minutes
- **Result:** If shortcuts recovered → Resolved; close incident with user education

**Test 2: If Intune Policy Restricts Desktop (If Test 1 Fails)**
- **Action:** Temporarily exempt user from desktop icon restriction policy
  - Create exemption group; add user
  - Apply policy exemption; user refreshes policies (`gpupdate /force`)
- **Timeline:** 3-5 minutes
- **Result:** If shortcuts reappear after policy exemption → Policy is root cause; proceed with remediation decision

**Test 3: If OneDrive KFM Redirected Desktop (If Test 1-2 Fail)**
- **Action:** Check if desktop folder is syncing to OneDrive
  - Compare `C:\Users\[username]\Desktop` with `C:\Users\[username]\OneDrive\Desktop`
  - If OneDrive Desktop has shortcuts but local doesn't → KFM is redirecting
- **Timeline:** 2 minutes
- **Result:** If detected → KFM is cause; shortcuts exist in OneDrive; can be re-synced locally

**Test 4: If New App Removed Shortcuts (If Test 1-3 Fail)**
- **Action:** Check app's installation log for shortcut removal
  - Review app installer MSI/EXE log for "RemoveFile" or "DeleteFile" entries
- **Timeline:** 3 minutes
- **Result:** If found → App is cause; can be uninstalled/reinstalled with fix

**Owner:** IT Support / System Engineer
**Output:** Root cause confirmed with high confidence; targeted fix ready

---

### **Minute 25-30: Resolution & Escalation**

**Resolution Path (Depending on Diagnosis):**

1. **If user accidentally deleted shortcuts:**
   - ✅ Restored from Recycle Bin or user recreation
   - User education: Recycle Bin recovery for future
   - Escalation: None (user-caused issue)

2. **If Intune policy restricted desktop:**
   - ⚠️ Requires policy change (exemption or removal)
   - Escalation: Policy review and approval required
   - Mitigation: Temporary exemption during policy review

3. **If OneDrive KFM redirected desktop:**
   - ⚠️ Requires KFM policy tuning (INCIDENT 02 related)
   - Escalation: Coordinate with INCIDENT 02 remediation
   - Mitigation: Restore shortcuts from OneDrive sync

4. **If new app caused removal:**
   - ⚠️ Requires app rollback or vendor fix
   - Escalation: Coordinate with app owner
   - Mitigation: Uninstall app; reapply after hotfix

5. **If root cause still unclear:**
   - Escalate to Phase 2 investigation
   - Implement workaround: Help user manually recreate shortcuts
   - Timeline for Phase 2: After INCIDENTS 01 & 02 are resolved

**Owner:** Incident Commander
**Output:** Remediation path clear; escalation determined; user notified of resolution time

---

## EVIDENCE REQUIRED

### TIER 1: MUST-HAVE EVIDENCE (Required to confirm root cause)

1. **Desktop File Listing**
   - Actual .lnk files present or absent: `Get-ChildItem "C:\Users\[username]\Desktop" -Filter "*.lnk"`
   - File count before vs. after migration
   - File timestamps (when were they created? When deleted?)

2. **Desktop.ini Integrity**
   - File exists: `Test-Path "C:\Users\[username]\Desktop\desktop.ini"`
   - File content (is it valid XML?)
   - Corruption indicators

3. **User Profile State**
   - Profile type: Azure AD, Hybrid, or Local?
   - Profile creation date vs. Windows 11 migration date
   - Profile size and sync status

4. **OneDrive Desktop Folder State**
   - Is desktop folder syncing to OneDrive? (Check KFM policy)
   - Which location has the shortcuts? (Local or OneDrive?)
   - File count comparison

5. **Intune Policy Assignment**
   - Which policies are deployed to user/device?
   - Any policies related to desktop icons or shell restrictions?
   - Policy application history and timestamps

6. **Recycle Bin Contents**
   - Are shortcut files in Recycle Bin?
   - File timestamps (when deleted?)
   - Original paths

### TIER 2: SUPPORTING EVIDENCE (Required for root cause confirmation)

7. **Windows 11 Migration Log**
   - Was this profile newly created or migrated?
   - Were shortcuts supposed to be preserved during migration?
   - Any migration errors or warnings?

8. **Document Management App Deployment Log**
   - Deployment timestamp and success/failure status
   - Installer actions (did it remove files?)
   - App configuration (does it modify desktop?)

9. **Group Policy Audit**
   - Are any Group Policy Objects restricting desktop customization?
   - When were GPOs applied?
   - Any conflicts with Intune policies?

10. **System Event Log**
    - Any errors related to profile loading or desktop initialization?
    - Event IDs: 1000 (profile load), 1502 (policy application)

---

## SYSTEMS AND LOGS TO CHECK

### PRIMARY SYSTEMS (Check First)

**1. User's Desktop (Direct Inspection)**
   - **Path:** `C:\Users\[username]\Desktop` (in File Explorer)
   - **Observation:** Are shortcut files visible? Count them. Screenshot.
   - **Expected output:** List of missing or present .lnk files

**2. Windows File Explorer - Desktop Folder View**
   - **Path:** Open File Explorer → Navigate to Desktop
   - **Check:** View → Show hidden files
   - **Look for:** Visible vs. hidden shortcut files
   - **Expected output:** Confirm files are hidden or truly deleted

**3. File System Command Line**
   - **Command:** `Get-ChildItem "C:\Users\[username]\Desktop" -Filter "*.lnk" | Select-Object Name, FullName, CreationTime, LastWriteTime`
   - **Purpose:** Get exact file list and timestamps
   - **Expected output:** Count of .lnk files or "No files found"

**4. Recycle Bin**
   - **Path:** File Explorer → Recycle Bin (or `$env:USERPROFILE\$Recycle.Bin`)
   - **Look for:** Shortcut files (.lnk)
   - **Expected output:** List of deleted shortcuts or empty Recycle Bin

**5. Intune Admin Center - Device Policy Review**
   - **Path:** https://endpoint.microsoft.com → Devices → Windows → All devices → [Device name]
   - **Check:** Device compliance status, policy assignments, policy application history
   - **Look for:** Any policies containing "Desktop", "Shell", "Icon", "Kiosk"
   - **Expected output:** List of policies applied to device

**6. Azure AD - User Profile Sync Status**
   - **Path:** https://entra.microsoft.com → Users → [User name]
   - **Check:** Profile type (Cloud-only, Hybrid, Directory synced)
   - **Expected output:** Profile creation date, sync status

### SECONDARY SYSTEMS (Check During Phase 2)

**7. Windows 11 Device - System Event Log**
   - **Path (local):** Event Viewer → Windows Logs → System
   - **Filter:** Event IDs 1000, 1002, 224 (profile/policy events)
   - **Timeline:** Filter by time around migration date
   - **Expected output:** Any profile loading errors or policy failures

**8. OneDrive Admin Center - Known Folder Move Status**
   - **Path:** https://[tenant]-admin.onedrive.com → Sync → KFM settings
   - **Check:** Is KFM enabled? Which folders are being redirected?
   - **Expected output:** KFM policy status for Floor 6 users

**9. Document Management App Installation Log**
   - **Path:** `C:\ProgramData\[AppName]\`, `C:\Users\[username]\AppData\Local\[AppName]\`
   - **Check:** Installer log for file deletion events
   - **Expected output:** Evidence of whether app removed shortcuts

**10. Windows 11 Migration Log**
    - **Path:** Usually in `C:\Windows\Logs\Migration\` or `C:\ProgramData\Migration\`
    - **Check:** Profile migration details, preserved vs. removed items
    - **Expected output:** Migration completion status and any warnings

---

## INVESTIGATION APPROACH

### PHASE 1: QUICK RESOLUTION (Minutes 0-30) ← **YOU ARE HERE**

**Objective:** Restore user's desktop shortcuts or provide clear remediation plan within 30 minutes

**Methodology:**
1. **User Interview** (2-5 min)
   - Understand what shortcuts are missing and work impact
   - Establish timeline of when shortcuts disappeared

2. **Rapid File System Check** (5-8 min)
   - Determine if .lnk files exist but are hidden OR actually deleted
   - Check Recycle Bin for deleted shortcuts
   - Identify if desktop.ini is corrupted

3. **Parallel Investigation** (8-15 min)
   - Check Intune policies for desktop restrictions
   - Review Windows 11 migration logs
   - Check for new app interference
   - Verify OneDrive desktop sync status

4. **Quick-Fix Testing** (20-25 min)
   - Test most likely root cause (user deletion → restore from Recycle Bin)
   - If not, test next hypothesis (policy restriction → exemption)
   - Continue until fix is found or Phase 2 is required

5. **Resolution & Escalation** (25-30 min)
   - If root cause confirmed → Implement fix
   - If root cause unclear → Escalate to Phase 2; provide temporary workaround

**Success Criteria for Phase 1:**
- ✅ Shortcuts restored to user's desktop, OR
- ✅ Clear remediation plan defined with owner and timeline

---

### PHASE 2: DEEPER INVESTIGATION (Post-30-Minute Window, Low Priority)

**Scope (if Phase 1 succeeds):**
- Verify fix does not affect other users
- Audit Floor 6 for similar issues (are others missing shortcuts too?)
- Implement preventive measures (backup policy, user education)
- Document lesson learned

**Scope (if Phase 1 does not find root cause):**
- Deeper forensic analysis of profile migration, Intune policies, application logs
- Engage Microsoft support if needed
- Profile-level rebuild or restore from backup
- Longer investigation timeline (4-8 hours after INCIDENTS 01 & 02 are resolved)

---

## RISK ASSESSMENT

### BUSINESS RISKS

**Risk 1: User Productivity Impact**
- **Likelihood:** LOW (shortcuts are convenience, not blocking)
- **Impact:** Low (users can navigate via Start menu or File Explorer)
- **Workaround:** Users can continue work; shortcuts are "nice to have"
- **Mitigation:** Prioritize lower than INCIDENTS 01 & 02; resolve after critical issues

**Risk 2: Widespread Issue Affecting Multiple Floor 6 Users**
- **Likelihood:** MEDIUM (if policy or migration issue, could affect all users)
- **Impact:** MODERATE (multiple users inconvenienced; reduces workflow efficiency)
- **Mitigation:** Audit all Floor 6 users during Phase 1; check if isolated to one user

**Risk 3: Indicator of Larger Profile/Configuration Problem**
- **Likelihood:** MEDIUM (could indicate profile corruption or policy misconfiguration)
- **Impact:** MODERATE (if profiles are corrupted, other issues could emerge)
- **Mitigation:** Use as diagnostic signal; if confirmed policy issue, audit other policy assignments

**Risk 4: Lost Productivity During Troubleshooting**
- **Likelihood:** LOW (investigation is minimal; user can continue work)
- **Impact:** LOW (user can work around missing shortcuts)
- **Mitigation:** Resolve in parallel with INCIDENTS 01 & 02; don't block critical issues

---

### TECHNICAL RISKS

**Risk 5: Policy Change Affects Other Users Unintentionally**
- **Likelihood:** LOW (policy exemption is targeted to one user)
- **Impact:** MODERATE (if policy change rolls out to others, unexpected side effects)
- **Mitigation:** Carefully scope exemptions to specific user only; test before rollout

**Risk 6: Accidental File Deletion During Troubleshooting**
- **Likelihood:** LOW (diagnostics are read-only until solution identified)
- **Impact:** MODERATE (if files are deleted during troubleshooting, they're gone)
- **Mitigation:** Backup user profile before making changes; verify Recycle Bin before deletion

**Risk 7: OneDrive Sync Complications**
- **Likelihood:** MEDIUM (if desktop.ini or KFM is involved)
- **Impact:** MODERATE (could create file sync conflicts or duplication)
- **Mitigation:** Coordinate with INCIDENT 02 remediation; ensure OneDrive sync strategy is clear

---

## IMMEDIATE CONTAINMENT ACTIONS

### TIER 1: EXECUTE IMMEDIATELY (Within 5 Minutes)

**Action 1.1: Assess User Work Impact**
- **How:** Contact user; ask if missing shortcuts are blocking work or just inconvenient
- **Why:** Determine actual urgency; prioritize resource allocation
- **Impact:** Sets investigation priority relative to INCIDENTS 01 & 02
- **Reversibility:** N/A (assessment only)
- **Owner:** Incident Commander
- **Output:** Impact assessment; resource priority set

**Action 1.2: Gather Visual Evidence**
- **How:** Request user screenshot of desktop and File Explorer → Desktop folder
- **Why:** Visual confirmation helps hypothesis formation; reduces back-and-forth
- **Impact:** Speeds diagnosis
- **Reversibility:** N/A (information gathering)
- **Owner:** IT Support
- **Output:** Screenshots for file review

**Action 1.3: Document Scope**
- **How:** Ask user: "Is this affecting just your desktop, or all Floor 6 users?"
- **Why:** Determine if isolated or widespread
- **Impact:** Affects investigation scope and remediation scale
- **Reversibility:** N/A (scoping)
- **Owner:** Incident Commander
- **Output:** Scope confirmation (isolated vs. widespread)

---

### TIER 2: EXECUTE WITHIN 10 MINUTES (Diagnostic Actions)

**Action 2.1: Check Recycle Bin for Deleted Shortcuts**
- **How:** User opens Recycle Bin; looks for .lnk files; checks timestamps
- **Why:** Quickest path to resolution if user accidentally deleted shortcuts
- **Impact:** If shortcuts found, can restore within 2 minutes
- **Reversibility:** N/A (restore from Recycle Bin is always safe)
- **Owner:** IT Support
- **Timeline:** 2 minutes
- **Success Indicator:** Shortcuts restored; user confirms work is unblocked

**Action 2.2: Check Hidden Files Setting**
- **How:** Right-click desktop → View → "Show hidden files" toggle
- **Why:** Shortcuts might be hidden by View setting
- **Impact:** If shortcuts are just hidden, enabling View restores access immediately
- **Reversibility:** Yes; can hide again if needed
- **Owner:** IT Support
- **Timeline:** 1 minute

**Action 2.3: Check Desktop.ini File**
- **How:** Open File Explorer; navigate to `C:\Users\[username]\Desktop`; check for desktop.ini file
- **Why:** Corrupted desktop.ini can cause shortcuts to not display
- **Impact:** If corrupted, delete and restart Explorer to rebuild
- **Reversibility:** Yes; desktop.ini will be recreated
- **Owner:** IT Support
- **Timeline:** 2 minutes

**Action 2.4: Run PowerShell File Listing Command**
- **How:** Execute `Get-ChildItem "C:\Users\[username]\Desktop" -Filter "*.lnk"`
- **Why:** Get authoritative count of shortcut files on disk
- **Impact:** Confirms whether files are actually missing or just display issue
- **Reversibility:** N/A (read-only command)
- **Owner:** System Engineer
- **Timeline:** 1 minute

---

### TIER 3: EXECUTE WITHIN 25 MINUTES (If Tier 1-2 Fails)

**Action 3.1: Query Intune Policy for Desktop Restrictions**
- **How:** Log into Intune Admin Center; find user's device; review policy assignments
- **Why:** Identify if policy is blocking desktop customization
- **Impact:** If found, policy exemption can restore access immediately
- **Reversibility:** Yes; exemption can be removed after testing
- **Owner:** Intune Administrator
- **Timeline:** 3-5 minutes
- **Next Step:** If policy found, create pilot exemption group and test

**Action 3.2: Check OneDrive Known Folder Move Status**
- **How:** Check if KFM policy is enabled; compare local vs. OneDrive Desktop folders
- **Why:** If desktop is syncing to OneDrive, files might be in cloud, not local
- **Impact:** If syncing to OneDrive, shortcuts can be re-synced locally
- **Reversibility:** Yes; can stop syncing if needed
- **Owner:** System Engineer
- **Timeline:** 3 minutes

**Action 3.3: Review Windows 11 Migration Log**
- **How:** Locate migration logs; search for "Desktop" or shortcut-related entries
- **Why:** Identify if migration intentionally removed shortcuts
- **Impact:** If migration removed them intentionally, need to understand policy
- **Reversibility:** Depends on policy; may require profile rebuild
- **Owner:** System Engineer
- **Timeline:** 5 minutes

**Action 3.4: Prepare Shortcut Recreation Plan**
- **How:** Document which shortcuts user needs; prepare to manually recreate if needed
- **Why:** If shortcuts truly deleted with no recovery, user can create new ones
- **Impact:** Restores user access within 10-15 minutes
- **Reversibility:** N/A (manual action)
- **Owner:** IT Support
- **Timeline:** 5-10 minutes to recreate 5-10 shortcuts

---

### TIER 4: ESCALATION ACTIONS (If Tier 1-3 Fails)

**Action 4.1: Escalate to Phase 2 Investigation**
- **How:** Document all Phase 1 findings; escalate to System Engineering for deeper analysis
- **Why:** Root cause remains unclear; requires deeper investigation
- **Impact:** Investigation continues; user provided with temporary workaround
- **Reversibility:** Investigation can continue in background while other incidents are resolved
- **Owner:** Incident Commander
- **Timeline:** Phase 2 investigation starts after INCIDENTS 01 & 02 are resolved

**Action 4.2: Provide Temporary Workaround for User**
- **How:** Help user access applications via Start menu or File Explorer until permanent fix is found
- **Why:** User can continue work while investigation continues
- **Impact:** Unblocks user; reduces urgency for Phase 2
- **Reversibility:** N/A (workaround is temporary; permanent fix still in development)
- **Owner:** IT Support
- **Timeline:** Immediate

---

## DECISION TREE

```
START: Desktop Shortcuts Missing Report (09:14)
│
├─────────────────────────────────────────────────────┐
│ DECISION 1: Is this blocking the user from working? │
│ (Can user continue work without these shortcuts?)    │
└─────────────────────────────────────────────────────┘
│
├─ YES: User is blocked; cannot work without shortcuts
│   └─ Priority: MEDIUM-HIGH; escalate investigation
│       └─ Allocate resources to resolve within 30 minutes
│
└─ NO: User can continue work via alternate navigation
    └─ Priority: MEDIUM-LOW; defer to Phase 2 if needed
        └─ Resolve in background; don't block critical incidents


├─────────────────────────────────────────────────────┐
│ DECISION 2: Are shortcut files actually deleted     │
│ or just hidden from view?                           │
└─────────────────────────────────────────────────────┘
│
├─ Files deleted (not in C:\Users\[user]\Desktop folder)
│   └─ Check: Are they in Recycle Bin? (Action 2.1)
│       ├─ YES: Files in Recycle Bin
│       │  └─ RESOLVE: User restored from Recycle Bin
│       │      └─ Close incident; user education
│       │
│       └─ NO: Files not in Recycle Bin
│           └─ Proceed to DECISION 3
│
└─ Files not deleted (present but hidden)
    └─ Check: Hidden file setting, desktop.ini (Actions 2.2, 2.3)
        ├─ Hidden file setting issue → Enable "Show hidden files"
        │  └─ RESOLVE: Shortcuts become visible
        │
        └─ desktop.ini corrupted → Delete and rebuild
           └─ RESOLVE: Shortcuts display restored


├─────────────────────────────────────────────────────┐
│ DECISION 3: Is this a policy-driven removal or      │
│ accidental deletion?                                │
└─────────────────────────────────────────────────────┘
│
├─ Policy-driven (Intune or Group Policy removing desktop icons)
│   └─ Check: Intune policies for desktop restrictions (Action 3.1)
│       ├─ YES: Desktop restriction policy found
│       │  └─ Create exemption → Test → Remove restriction
│       │      └─ RESOLVE: Policy remediation
│       │
│       └─ NO: No obvious policy found
│           └─ Proceed to DECISION 4
│
├─ Accidental deletion (user or migration removed shortcuts)
│   └─ Check: Windows 11 migration logs (Action 3.3)
│       ├─ Migration intentionally removed → By design
│       │  └─ RESOLVE: User recreates shortcuts manually (Action 3.4)
│       │
│       └─ Migration error removed them → Unintended
│           └─ RESOLVE: Restore profile from backup or recreate
│
└─ Unknown origin
    └─ Proceed to DECISION 4


├─────────────────────────────────────────────────────┐
│ DECISION 4: Is OneDrive Known Folder Move (KFM)    │
│ redirecting the desktop folder?                     │
└─────────────────────────────────────────────────────┘
│
├─ YES: KFM is enabled; desktop folder is syncing to OneDrive
│   └─ Shortcuts exist in OneDrive/Desktop, not local
│       └─ RESOLVE: Adjust KFM policy; re-sync desktop locally
│           └─ Coordinate with INCIDENT 02 remediation
│
└─ NO: KFM is not enabled or desktop is not syncing
    └─ Proceed to DECISION 5


├─────────────────────────────────────────────────────┐
│ DECISION 5: Did the new document management app     │
│ remove shortcuts during installation?               │
└─────────────────────────────────────────────────────┘
│
├─ YES: App installer log shows file removal
│   └─ RESOLVE: Uninstall app; reapply after vendor hotfix
│       └─ Coordinate with new app owner
│
└─ NO: App did not remove shortcuts
    └─ Proceed to DECISION 6


├─────────────────────────────────────────────────────┐
│ DECISION 6: Root Cause Confirmed or Escalate?      │
└─────────────────────────────────────────────────────┘
│
├─ CONFIRMED: Root cause found
│   └─ Apply targeted fix (from Decisions 1-5)
│       └─ Verify shortcuts restored or accessible
│           └─ Close incident
│
└─ UNKNOWN: Could not determine root cause
    └─ Escalate to Phase 2 investigation (Action 4.1)
        └─ Provide user workaround (Action 4.2)
            └─ Defer permanent fix until after INCIDENTS 01 & 02 are resolved


END: Incident resolved or escalated to Phase 2
```

---

## EXECUTIVE UPDATE FOR LEADERSHIP

### FOR: FinBridge IT Operations  
### TIME: ~09:45 (approximately 30 minutes after initial report)  
### FROM: System Administration & Incident Management  
### CONFIDENTIALITY: Internal Leadership Only  
### NOTE: This incident is LOWEST PRIORITY of three Floor 6 issues; defer detailed response until INCIDENTS 01 & 02 are resolved

---

### SITUATION SUMMARY

At 09:14, one user on Floor 6 reported that desktop shortcuts have disappeared. This is a user experience issue, not a system availability or security issue.

**Status:** Investigating in parallel with higher-priority incidents (INCIDENTS 01 & 02). Low business impact; user can continue work via alternate navigation.

---

### PRELIMINARY FINDINGS

**Most Likely Causes (in order):**
1. User accidentally deleted shortcuts (most probable)
2. Intune policy restricting desktop customization
3. New document management app removed shortcuts during installation
4. OneDrive Known Folder Move (KFM) redirecting desktop folder
5. Windows 11 migration profile corruption

---

### BUSINESS IMPACT

- **Users Affected:** 1 confirmed, unclear if others
- **Work Blocked:** NO — user can navigate via Start menu or File Explorer
- **Workaround Available:** YES — user can continue work without shortcuts
- **Urgency:** LOW — resolve after INCIDENTS 01 & 02

---

### RESOLUTION TIMELINE

- **Most Likely (Accidental Deletion):** Restore from Recycle Bin → **5 minutes**
- **Moderate (Policy Issue):** Policy exemption and verification → **15 minutes**
- **Worst Case (Root Cause Unclear):** Defer to Phase 2; provide workaround → **Immediate workaround; permanent fix after critical incidents**

---

### RECOMMENDED ACTION

**Prioritize INCIDENTS 01 & 02.** This incident requires minimal resources and does not block productivity. Investigate in parallel at low resource allocation. Resolve after critical incidents are contained.

---

## PHASE 2: ROOT CAUSE ANALYSIS SCOPE (Post-30-Minute Window, Low Priority)

**Objective:** Determine permanent remediation for desktop shortcuts if Phase 1 investigation was unsuccessful

**Scope (if Phase 1 succeeds):**
- Audit Floor 6 to identify if others have similar issues
- Determine pattern (isolated vs. systemic)
- Implement preventive measures

**Scope (if Phase 1 does not find root cause):**
- Deeper forensic analysis of user profile, Intune policies, app deployment logs
- Profile-level rebuild or restore from backup
- Timeline: 4-8 hours after INCIDENTS 01 & 02 are resolved

---

## DOCUMENTATION & INCIDENT TRACKING

**Incident ID:** CFG-2026-0814-003  
**Report Time:** 2026-08-14 09:14  
**Incident Severity:** MEDIUM  
**Affected Users:** 1 (unknown if widespread)  
**Priority:** LOW (below INCIDENTS 01 & 02)  
**Status:** ACTIVE - Phase 1 Investigation (Low Resource Allocation)  
**Next Review:** After INCIDENTS 01 & 02 are resolved  
**Escalation:** System Administration (with low priority)  

---

**END OF INCIDENT 03 ANALYSIS**
