# INCIDENT RESPONSE RUNBOOK: FLOOR 6 COPILOT UNAUTHORIZED ACCESS
## Security Incident - First Responder Procedures

**Incident ID:** FLOOR6-COPILOT-UNAUTHORIZED-20260812  
**Incident Type:** SECURITY - Potential Unauthorized Access to Confidential Data  
**Severity:** TIER 1 CRITICAL  
**Response Time:** IMMEDIATE (First action within 5 minutes)  
**Last Updated:** 2026-08-14  

---

## ⚠️ CRITICAL NOTICE

**This is NOT a normal technical issue.**

**This is a potential data breach involving confidential legal documents.**

**You are not fixing this issue. You are:**
1. Escalating to security team
2. Preserving evidence
3. Preventing further exposure
4. Documenting everything

**DO NOT attempt to resolve this yourself. DO NOT troubleshoot. DO escalate immediately.**

---

## PREREQUISITES

### Who Can Execute This Procedure
- [ ] Any IT staff member who receives security incident report
- [ ] Help Desk engineer
- [ ] IT Operations team member
- [ ] Desktop support engineer
- You do NOT need special security clearance to START this procedure (you need it to CONTINUE investigation, but first responder just escalates)

### Access & Authorization Required
- [ ] Access to phone (to call security team)
- [ ] Access to email (to send escalation message)
- [ ] Access to incident management system (to file ticket)
- [ ] Authority to PRESERVE evidence (do not restart devices)
- [ ] Authority to NOTIFY management of security incident
- [ ] ⚠️ **NO special permissions needed to escalate.** Escalation is EVERYONE's responsibility.

### Systems & Tools Required
- [ ] Phone with direct access to security team
- [ ] Email account (corporate)
- [ ] Incident management system (Jira, ServiceNow, or similar)
- [ ] Browser (to document findings)
- [ ] Pen and paper (to take notes during investigation)

### Information to Gather BEFORE Starting (If Available)
- [ ] Date/time of report
- [ ] User name reporting issue
- [ ] What exact document/data was seen
- [ ] How user accessed it (Copilot query? Email? Search?)
- [ ] User's job role/access level
- [ ] Whether other users reported similar issues

### Key Contact Information
**Security Team Lead:** [Name/Number]  
**IT Operations Manager:** [Name/Number]  
**Compliance Officer:** [Name/Number]  
**Legal Department:** [Name/Number]  

**Document these before an incident occurs.**

---

## PROCEDURE

### SECTION A: INITIAL RESPONSE (5 MINUTES)

#### Step 1: Recognize This is a Security Incident
**Action:** Identify that report involves unauthorized/suspicious data access and classify as security incident.

**Recognition Criteria - IF ANY OF THESE TRUE, THIS IS A SECURITY INCIDENT:**
```
☐ User reports accessing confidential/sensitive data they shouldn't see
☐ Unexpected data appeared in search results or Copilot
☐ Files accessible that shouldn't be accessible
☐ User concerned about "data breach" or "unauthorized access"
☐ Involves legal documents, financial data, health information, or other regulated data
☐ User says "I don't have access to this" but data appeared anyway
☐ Data exposure involves privacy-protected information
☐ Multiple users report same type of unauthorized access
```

**If ANY above true:**
```
THIS IS A SECURITY INCIDENT.
Proceed with FULL escalation immediately.
Do NOT treat as normal support ticket.
Do NOT try to "fix" it yourself.
```

**Expected Result:**
- You recognize this as security incident (not normal tech support)
- You understand this requires escalation (not local troubleshooting)
- You're ready to execute emergency escalation

---

#### Step 2: Do NOT Modify Anything
**Action:** Immediately STOP any troubleshooting. Preserve all evidence.

**DO NOT DO THESE THINGS:**
```
❌ Do NOT restart the user's device
❌ Do NOT clear browser history
❌ Do NOT delete files or logs
❌ Do NOT reset passwords
❌ Do NOT modify permissions
❌ Do NOT uninstall applications
❌ Do NOT move device offline
❌ Do NOT restore from backup
❌ Do NOT ask user to "clear things"
❌ Do NOT touch Copilot settings
❌ Do NOT access OneDrive/email on device
```

**DO DO THESE THINGS:**
```
✓ Leave device in current state
✓ Keep device powered on (if possible)
✓ Keep user logged in (if possible)
✓ Preserve all logs and files
✓ Document current state (screenshots OK if non-invasive)
✓ Keep chain of custody (who touched what, when)
```

**Why This Matters:**
- Evidence can be altered/destroyed
- Forensic investigation requires original state
- Legal proceedings require chain of custody
- Data breach response requires preserved logs

**Expected Result:**
- No modifications made to device
- Device in original state for forensic analysis
- Ready for security team handoff

---

#### Step 3: Document the Report
**Action:** Write down exactly what the user reported. Use their exact words.

**Detailed Steps:**
```
3a. Get with user (phone, Teams, or in person)
3b. Ask: "Tell me exactly what you saw. Use specific names/details."
3c. Write down word-for-word what user says (use quotes)
3d. Document date and time of report
3e. Document date and time of incident (when user saw the data)
3f. Document how user accessed it (Copilot search? Direct access? Email?)
3g. Document what data was shown (document name? Client name? Specifics?)
3h. Save this documentation (attach to incident ticket)
3i. Do NOT discuss with other users yet (prevents rumors/panic)
```

**Example Documentation:**
```
INCIDENT REPORT - Security
Date/Time Reported: Monday 2026-08-12, 9:14 AM
User: [Name], Floor 6 Paralegal
What Happened (User's Exact Words):
"I was having trouble logging in this morning. I opened Copilot to ask 
about the slow login. When I typed my question, Copilot showed me 
search results that included a client matter for [Client Name]. I know 
I don't have access to that matter and was never assigned to it. 
I'm concerned Copilot pulled a confidential document I'm not supposed 
to see."

Date/Time of Incident: Monday 2026-08-12, ~8:30 AM (during login issues)
How Accessed: Copilot search (Copilot sidebar on Windows 11)
Data Seen: Legal document re: [Client Matter] - user states unauthorized
User's Access Level: Paralegal, Floor 6, not assigned to this matter
```

**Expected Result:**
- Exact user report documented
- Dates/times recorded
- Specific data identified
- Clear chain of events recorded
- Ready for security team investigation

---

### SECTION B: EMERGENCY ESCALATION (5 MINUTES)

#### Step 4: Contact Security Team Immediately (PHONE CALL - NOT EMAIL)
**Action:** Call security team lead directly. Do NOT send email. Use phone.

**Detailed Steps:**
```
4a. Locate security team contact number (from prerequisites)
4b. Call immediately (this is URGENT)
4c. When security team answers, say:
    "I'm reporting a security incident. Potential unauthorized access 
     to confidential data by Copilot on Floor 6.
     Incident ID: FLOOR6-COPILOT-UNAUTHORIZED-20260812
     User: [Name]
     Time of Report: [Time]
     I have documentation ready.
     What are your next steps?"
4d. Do NOT speculate about cause or severity
4e. Stick to facts (what user reported, what data seen)
4f. Have your documentation ready to read if asked
4g. Follow security team's instructions
4h. Ask: "Should device remain powered on? Any immediate actions needed?"
4i. Document what security team says
4j. Document name of security team person you spoke with
4k. Document time of call
```

**Expected Result:**
- Security team contacted by phone
- Incident reported with key details
- Security team acknowledges receipt
- Initial instructions received from security (preserve device, don't touch files, etc.)
- Phone conversation documented

**Troubleshooting:**
- If security team not available: Try backup number, leave voicemail saying "URGENT SECURITY INCIDENT"
- If voicemail: Say "URGENT SECURITY INCIDENT - Unauthorized data access - Floor 6 - Copilot - Call me back immediately"
- Then send follow-up email (see Step 5)

---

#### Step 5: Send Formal Escalation Email
**Action:** Send written escalation message to security team, compliance officer, and management.

**Detailed Steps:**
```
5a. Send email to these recipients (if available in your org):
    - Security Team Lead
    - Compliance Officer
    - IT Operations Manager
    - Legal Department (Attention: [Name])

5b. Email subject line:
    "URGENT: SECURITY INCIDENT - Unauthorized Copilot Access to 
     Confidential Data - Floor 6 - INCIDENT-03-COPILOT-UNAUTHORIZED-20260812"

5c. Email body (copy template below):
```

**Email Template:**

```
SECURITY INCIDENT NOTIFICATION

INCIDENT ID: FLOOR6-COPILOT-UNAUTHORIZED-20260812
SEVERITY: TIER 1 CRITICAL
REPORTED BY: [Your Name]
DATE/TIME REPORTED: [Date/Time]
INCIDENT DISCOVERY TIME: [When user first noticed]

INCIDENT SUMMARY:
A Floor 6 user reported that Microsoft Copilot displayed a client 
legal matter the user states she does not have authorization to access. 
This incident involves potential unauthorized access to confidential 
legal documents and requires immediate security investigation.

AFFECTED USER:
[User Name], Floor 6 Paralegal
User's assigned matters: [If known]
User's access level: [Standard user / admin / other]

DATA POTENTIALLY EXPOSED:
Legal document / client matter: [Document Name or Client Name]
Classification: Confidential
Sensitivity: Attorney-client privileged (potentially)
Regulatory implication: [GDPR / HIPAA / State law / Other, if applicable]

HOW INCIDENT WAS DISCOVERED:
User was querying Copilot about login delay when Copilot search 
results included the confidential matter. User recognized she should 
not have access and reported to IT.

IMMEDIATE ACTIONS TAKEN:
✓ Incident classified as SECURITY INCIDENT (not normal support)
✓ User device preserved (no changes made)
✓ Evidence documented (exact user statement recorded)
✓ Security team notified by phone at [Time]
✓ Formal escalation initiated

EVIDENCE PRESERVED:
- User device: [Device name] - Not restarted, in original state
- Copilot logs: Not cleared, in original state
- User statement: Documented verbatim
- Timeline: Recorded
- No modifications made to preserve forensic integrity

INVESTIGATION REQUIRED:
1. Verify unauthorized access actually occurred
2. Determine if Copilot permissions misconfigured
3. Determine scope (one user or wider issue)
4. Check for other similar incidents
5. Assess data exposure/breach implications
6. Determine regulatory notification requirements

NEXT STEPS:
Awaiting security team direction for investigation protocol.
Please advise on:
- Evidence collection procedures
- Chain of custody requirements
- Forensic acquisition needs
- Compliance notification decision
- Client notification decision (if applicable)

CONTACTS:
Reported by: [Your Name] [Your Number]
Device user: [User Name] [User Number]
IT Manager: [Manager Name] [Manager Number]

This email contains sensitive security information. 
Distribute only to authorized recipients.
```

**Steps to Send:**
```
5d. Open email client
5e. Create new email with template above
5f. Add recipient addresses
5g. Change [bracketed] items to actual information
5h. Send email
5i. Do NOT send copy to general help desk or user community
5j. Document that escalation email was sent (save copy in ticket)
```

**Expected Result:**
- Formal escalation email sent to decision-makers
- Email contains complete incident information
- Security team has written record of incident
- Chain of custody documented
- Compliance/legal notified of potential breach

---

### SECTION C: EVIDENCE PRESERVATION (10 MINUTES)

#### Step 6: Preserve User Device
**Action:** Ensure the device remains in original state for forensic investigation.

**Detailed Steps:**
```
6a. Contact user: "Please keep your device powered on and logged in 
    while security team investigates."
6b. Device requirements:
    - Power: ON (do not restart)
    - User account: LOGGED IN (do not log off)
    - Files: DO NOT DELETE OR MODIFY
    - Browser: DO NOT CLEAR HISTORY
    - Copilot: DO NOT CLEAR CACHE OR LOGS
6c. If user must restart (emergency, battery dying):
    - Contact security team FIRST for permission
    - Get explicit approval before restarting
6d. If user logs off accidentally:
    - DO NOT log back in
    - Contact security team
    - Wait for forensic team
6e. Physically secure device:
    - If shared device: Change password so only user/IT can access
    - If personal device: Keep with user or in secure location
    - Prevent other users from accessing device
6f. Document device location and access control
```

**Chain of Custody Form:**
```
DEVICE CHAIN OF CUSTODY

Device: [Name/Serial Number]
User: [Name]
Date Seized: [Date]
Time Seized: [Time]
Seized By: [Your Name]

Current Status: 
☐ Powered On, User Logged In
☐ Powered Off (not recommended)
☐ In Secure Storage
☐ With User (supervised)

Last Person with Device: [Name]
Time Handed Over: [Time]
Location: [Where is device right now?]
Password Changed: ☐ Yes ☐ No
Access Restricted To: [Only user / Only IT / Only security]

Signature: ________________  Date: ___________
```

**Expected Result:**
- Device remains in original state
- No modifications made to files/logs
- Device secure and access controlled
- Chain of custody documented
- Ready for forensic team analysis

---

#### Step 7: Collect System Logs and Metadata
**Action:** Document what can be gathered WITHOUT modifying system (screenshots, metadata only).

**Detailed Steps:**
```
7a. Screenshot current screen (if safe to do):
    - Press Print Screen or Shift+PrintScreen
    - Save as: "Device_State_[Date]_[Time].png"
    - Shows current Copilot state, user account, visible data
    - Do NOT open new windows or navigate to new content
7b. Document device information (NOT opening anything new):
    - Device name
    - Operating system version
    - Intune enrollment status
    - User account name
    - OneDrive status (if visible)
7c. Note Copilot interface:
    - Is Copilot still showing the reported results?
    - What search terms are visible?
    - Can you see what was searched? (Do not clear history)
7d. Document file locations:
    - Is reported document visible in File Explorer?
    - Where is OneDrive located?
    - What is synced state? (Do not open/modify)
7e. Do NOT:
    - Open Event Viewer (can alter logs)
    - Run PowerShell commands (can alter system state)
    - Access file properties in detail (can change access times)
    - Restart device or restart applications
7f. Save all screenshots and documentation
7g. Attach to incident ticket
```

**Expected Result:**
- Current state documented visually (screenshots)
- Device information recorded
- Evidence preserved for forensic analysis
- No system modifications made
- Documentation ready for security team

---

### SECTION D: INVESTIGATION TRIAGE (15 MINUTES)

#### Step 8: Interview User (Fact Gathering Only)
**Action:** Ask investigative questions to gather facts. Do NOT reassure or make promises about outcome.

**Key Questions to Ask:**

**Question 1: What Exactly Did Copilot Show?**
```
Ask user: "Describe exactly what you saw in Copilot. 
Use specific details if you remember."

Listen for:
- Document name or file path
- Client name or matter name
- Specific content shown (summary vs. full document)
- Screenshots or document details
- When did you first see this
- What were you searching for when this appeared

Record: Word-for-word response
```

**Question 2: How Did You Access Copilot?**
```
Ask: "How did you open Copilot? What did you type or ask?"

Listen for:
- Copilot button on taskbar?
- Windows+C keyboard shortcut?
- Copilot in sidebar?
- Search box query?
- Teams Copilot?
- What were your search terms / question?

Record: Exact search terms if remembered
```

**Question 3: Is This Your First Time Seeing This?**
```
Ask: "When was the first time you saw this document?
Have you seen this in Copilot before?
Is this the only time this happened?"

Listen for:
- Single incident or recurring
- Other similar experiences
- Pattern or one-off occurrence

Record: Frequency and timing
```

**Question 4: Do You Normally Have Access?**
```
Ask: "In your job, do you normally have access to this matter?
Are you assigned to work on this client?
Have you opened this document before?"

Listen for:
- User's actual access level vs. what appeared
- Job responsibilities
- Whether access was authorized or not

Record: User's understanding of their own access
```

**Question 5: What Happened Next?**
```
Ask: "After you saw this in Copilot, what did you do?
Did you click on it? Did you open the document?
Did you read the full content?
Did you forward it anywhere?"

Listen for:
- Extent of data exposure
- Any further access/sharing
- User's response to incident

Record: What actions user took after discovery
```

**Expected Result:**
- Factual information gathered
- Investigative questions answered
- User timeline established
- Data specifics documented
- Ready for security team's detailed investigation

**DO NOT:**
- Make promises about resolution timeline
- Blame Copilot or Microsoft (investigation not complete)
- Minimize concern ("Don't worry, probably just a glitch")
- Discuss with other staff members
- Reassure them it's not a breach (investigation not complete)

---

#### Step 9: Check for Similar Incidents
**Action:** Search incident system for other Copilot/unauthorized access reports.

**Detailed Steps:**
```
9a. Open incident management system (Jira, ServiceNow, etc.)
9b. Search for tickets containing keywords:
    - "Copilot"
    - "Unauthorized access"
    - "Confidential"
    - "Data access"
    - "Floor 6" (if specific to Floor 6 policy)
9c. Filter by date:
    - Last 7 days (to catch recent issues)
9d. For each similar ticket found:
    - Note ticket number
    - Note description
    - Note user name
    - Note date reported
    - Note if same symptom (data appeared unexpectedly)
9e. Link all related tickets together
9f. Document findings: "Found X similar tickets"
9g. If many related tickets: Indicates wider issue (not isolated incident)
9h. Include summary in escalation: "X similar reports found; appears 
    to be pattern not isolated incident"
```

**Expected Result:**
- Incident system searched
- Similar tickets identified (if any)
- Pattern analysis available
- Scope of issue clearer
- Information for security team

---

#### Step 10: Check Intune Copilot Policy Configuration
**Action:** Review Copilot permissions in Intune to see what scope is configured.

**Detailed Steps:**
```
10a. Open Intune Portal: https://endpoint.microsoft.com
10b. Navigate to: Devices > Configuration Policies
10c. Search for policies containing:
    - "Copilot"
    - "AI"
    - "Search"
    - "Data access"
10d. For each policy found:
    - Click policy name
    - Review "Settings" or "Configuration" section
    - Look for permission scope:
      "Copilot can search:" [All files / Company files only / User files / 
                              Email / OneDrive / etc.]
    - Note what is configured
    - Check who policy is assigned to (Floor 6? Everyone? Specific users?)
10e. Do NOT change any settings
10f. Document findings:
    "Intune Copilot Policy Review:
     Policy Name: [Name]
     Configured Permissions: [List of permissions]
     Assignment Scope: [Who assigned]
     Assessment: [Does this explain unauthorized access?]"
```

**Expected Result:**
- Intune policy configuration reviewed
- Copilot permissions documented
- Assignment scope documented
- Information available for investigation
- No changes made (preserve evidence)

**Do NOT:**
- Modify any policy settings
- Change permissions
- Disable Copilot company-wide
- Make assumptions about cause

---

#### Step 11: Preliminary Risk Assessment
**Action:** Document your preliminary assessment of incident severity and exposure.

**Assessment Questions:**
```
Risk Question 1: How Sensitive is the Data?
☐ Highly sensitive (legal documents, attorney-client privileged)
☐ Sensitive (confidential client information)
☐ Moderately sensitive (internal documents)
☐ Not particularly sensitive

Risk Question 2: How Many Users Might Be Affected?
☐ Just this one user
☐ All Floor 6 users (50)
☐ All organization users (company-wide)
☐ Unknown scope

Risk Question 3: Was Data Actually Exported/Shared?
☐ User saw data but did not access further
☐ User opened document
☐ User forwarded/shared document
☐ Unknown

Risk Question 4: How Long Was Data Exposed?
☐ Minutes (just when discovered)
☐ Hours (since this morning)
☐ Days (longer issue)
☐ Unknown

Risk Question 5: What is Client Impact?
☐ None (internal data only)
☐ Potential breach of client confidentiality
☐ Likely breach (data definitely shared with unauthorized party)
☐ Unknown
```

**Preliminary Assessment:**
```
Based on investigation to date, my preliminary assessment:

Severity: [HIGH / MEDIUM / LOW]
Reason: [Explain your reasoning]

Scope: [ISOLATED / WIDESPREAD / UNKNOWN]
Reason: [Explain your reasoning]

Exposure Risk: [HIGH / MEDIUM / LOW]
Reason: [Explain your reasoning]

Regulatory Risk: [ATTORNEY-CLIENT PRIVILEGE / GDPR / HIPAA / OTHER / LOW]
Reason: [Explain your reasoning]

Recommended Action: [INVESTIGATION / CONTAINMENT / FORENSIC ANALYSIS / 
                     POLICY CHANGE / NOTIFICATION / OTHER]

Next Step: [Wait for security team / [Other]]
```

**Expected Result:**
- Preliminary risk assessment documented
- Severity and scope estimated
- Information ready for security team decision-making
- Clear hand-off information for investigation phase

---

### SECTION E: DOCUMENTATION & HANDOFF (5 MINUTES)

#### Step 12: Create Incident Ticket
**Action:** Formally document incident in incident management system for tracking and escalation.

**Detailed Steps:**
```
12a. Open incident management system
12b. Create new ticket with:
    - Incident ID: FLOOR6-COPILOT-UNAUTHORIZED-20260812
    - Title: "Security Incident - Unauthorized Copilot Access to 
             Confidential Legal Document - Floor 6"
    - Priority: CRITICAL (highest priority)
    - Category: SECURITY INCIDENT
    - Assigned To: [Security Team Lead]
    - Status: ESCALATED - INVESTIGATION REQUIRED
12c. Add description (copy from escalation email)
12d. Attach documentation:
    - User statement (verbatim)
    - Screenshots
    - Device information
    - Intune policy configuration
    - Preliminary assessment
    - Chain of custody documentation
12e. Add timeline:
    - [Time]: Incident reported to IT
    - [Time]: Security team contacted by phone
    - [Time]: Escalation email sent
    - [Time]: Device preserved
    - [Time]: User interviewed
    - [Time]: Incident ticket created
12f. Set tag: SECURITY / CONFIDENTIAL / POTENTIAL-BREACH
12g. Save ticket
12h. Document ticket number: ___________
```

**Expected Result:**
- Incident formally documented in system
- Escalated to security team
- All evidence attached
- Clear audit trail
- Ready for investigation team to take over

---

#### Step 13: Notify Management
**Action:** Inform IT management and Floor 6 leadership of incident status (factual, no speculation).

**Detailed Steps:**
```
13a. Send message to:
    - IT Operations Manager
    - IT Director
    - Floor 6 Manager (optional, per security guidance)
    - Service Delivery Manager
13b. Message content (factual only):
    "An IT security incident has been reported and escalated to the 
     security team. A Floor 6 user reported unauthorized access to 
     confidential data through Copilot. Incident ID: [ID]. Security 
     team is conducting investigation. No action required from IT 
     operations at this time. Will provide updates as available."
13c. Do NOT speculate about cause or severity
13d. Do NOT discuss with users yet
13e. Do NOT send updates to general staff
13f. Emphasis: Investigation ongoing; no conclusions yet
```

**Expected Result:**
- Management informed of incident
- Clear escalation path established
- No premature communication to users
- Ready for security team investigation

---

### SECTION F: ONGOING INCIDENT MANAGEMENT

#### Step 14: Hand Off to Security Team
**Action:** Transition investigation from first responder (you) to security team.

**Detailed Steps:**
```
14a. Schedule call with security team lead:
    "I've completed initial response and documentation. 
    Ready to brief you on findings and hand over for investigation."
14b. During handoff call, provide:
    - Complete incident summary
    - User interview findings
    - Device preservation status
    - Evidence collected
    - Incident ticket number
    - Any preliminary findings
14c. Ask security team:
    - "What happens next?"
    - "Do you need anything from IT?"
    - "Should we disable Copilot company-wide?"
    - "Should we notify other users?"
    - "When will investigation conclude?"
14d. Get written confirmation from security team:
    - "I am taking the lead on investigation"
    - "Your responsibilities are [X, Y, Z]"
    - "We will update you on [timeline]"
14e. Document security team's instructions
14f. Update incident ticket with handoff confirmation
```

**Expected Result:**
- Security team takes ownership of investigation
- First responder role complete
- Clear next steps established
- Incident tracked and monitored
- You're released from active incident management (unless asked for follow-up)

---

#### Step 15: Await Investigation Results
**Action:** Monitor incident ticket for updates. Do NOT attempt own investigation.

**Detailed Steps:**
```
15a. Check incident ticket daily for updates
15b. If security team requests additional information:
    - Respond immediately
    - Provide whatever they request
15c. Do NOT attempt to investigate further without security approval
15d. Do NOT access user device without security direction
15e. Do NOT make assumptions about cause
15f. If more similar reports come in:
    - File new ticket immediately
    - Link to master incident (FLOOR6-COPILOT-UNAUTHORIZED-20260812)
    - Escalate same as Step 4-5
15g. When investigation concludes:
    - Security team will communicate findings
    - Will recommend remediation (policy changes, etc.)
    - Will notify affected parties per legal/compliance guidance
15h. Your job: Support remediation implementation if needed
```

**Expected Result:**
- Incident monitored
- Additional issues escalated immediately
- Investigation progressing through security team
- First responder available if needed

---

## VERIFICATION

### Did First Responder Actions Succeed?

**Verification Checklist (Must all be YES):**

**Escalation Verification:**
- [ ] Security team contacted by PHONE (not email first)
- [ ] Security team acknowledged incident receipt
- [ ] Formal escalation email sent to security/compliance/legal
- [ ] Incident ticket created and assigned to security
- [ ] Management notified of incident

**Evidence Preservation Verification:**
- [ ] User device remains powered ON and unmodified
- [ ] No restarts performed
- [ ] No files deleted or modified
- [ ] No system changes made
- [ ] Chain of custody documented
- [ ] Screenshots/documentation saved

**Investigation Initiation Verification:**
- [ ] User interviewed and statement documented
- [ ] Intune policy configuration reviewed
- [ ] Similar incidents searched for
- [ ] Preliminary assessment completed
- [ ] Security team has all necessary information

**Documentation Verification:**
- [ ] Incident ticket filed with all attachments
- [ ] Escalation email sent and archived
- [ ] User statement preserved
- [ ] Timeline documented
- [ ] Device information documented
- [ ] Preliminary risk assessment completed

---

### Success Criteria

**First Responder's Job is COMPLETE when:**
- ✅ Security team has taken ownership
- ✅ All evidence preserved (device untouched)
- ✅ Incident formally documented
- ✅ No further unauthorized access occurring
- ✅ Security team has timeline and investigation plan

**First Responder's Job is INCOMPLETE if:**
- ❌ Security team never acknowledged receipt
- ❌ Device modified or restarted
- ❌ Investigation being delayed
- ❌ Multiple similar incidents not linked
- ❌ Management not informed of incident

If incomplete: Escalate to IT Operations Manager immediately.

---

## ROLLBACK

**IMPORTANT: You CANNOT "rollback" a security incident like a technical fix.**

A data breach, once confirmed, cannot be undone. However, you can manage CONTAINMENT and INVESTIGATION:

### If Investigation Finds Widespread Issue

**Scenario 1: Copilot Access Misconfigured Company-Wide**

**Action:** Work with security team to contain exposure

```
Security Team (Not You) Will:
1. Disable Copilot access to sensitive data
2. Review permission configurations
3. Audit who accessed what and when
4. Notify affected users/clients per compliance guidance

You (First Responder) Will:
1. Implement Intune policy changes directed by security
2. Verify policy deployed across organization
3. Monitor for policy application success
4. Document when containment complete
```

**Steps to Contain (Directed by Security Team):**
```
1. Open Intune Portal: https://endpoint.microsoft.com
2. Navigate to: Devices > Configuration Policies
3. Find Copilot policy
4. Reduce permission scope:
   FROM: "Can search all files, email, OneDrive"
   TO: "Can search user files only" (or disable entirely)
5. Save changes
6. Wait 30 minutes for devices to sync
7. Verify Copilot behavior changed on test device
8. Document containment action in incident ticket
```

---

### If Investigation Finds Data Was Exfiltrated

**Scenario 2: Confidential Data Forwarded/Downloaded by Unauthorized Party**

**Action:** Escalate immediately (This is beyond first responder scope)

```
Contact:
- Legal Department (breach notification, client notification)
- Compliance Officer (regulatory requirements)
- Law Enforcement (if criminal activity suspected)
- Insurance (cyber incident insurance, breach response coverage)

Your Role:
- Do NOT attempt to remediate
- Do NOT delete evidence
- Provide all logs and documentation to investigation team
- Follow legal team's direction on client/regulator notification
```

---

### If Investigation Finds User Error (Scenario D)

**Scenario 3: Data User Actually Had Access To**

**Action:** Educate and document

```
If Investigation Finds:
"User has authorized access to document; 
Copilot behavior is as designed; 
No breach occurred; 
User misunderstood Copilot capability"

Then:
1. Provide user training on Copilot permissions
2. Document outcome in incident ticket
3. Close incident (no further action)
4. Lessons learned: Inform users what Copilot can/cannot access
5. Consider communication about Copilot behavior expectations
```

---

### Emergency Containment (If You See Further Exposure)

**If More Users Report Same Issue While Waiting for Investigation:**

**Action:** File new incident tickets and escalate same as Step 4-5

```
1. File new ticket immediately (do not wait for first investigation)
2. Link to master incident: FLOOR6-COPILOT-UNAUTHORIZED-20260812
3. Contact security team again: "Pattern emerging; multiple reports"
4. Subject: URGENT UPDATE - MULTIPLE COPILOT UNAUTHORIZED ACCESS REPORTS"
5. Recommend immediate Copilot policy restriction
6. Ask: "Should we disable Copilot while investigating?"
```

---

## NOTES

### Critical Reminders

⚠️ **This is NOT a Technical Fix**
- Cannot be "fixed" by restarting, reinstalling, or troubleshooting
- Requires investigation to determine what happened
- Requires security/legal/compliance decision on response
- Your job is to escalate and preserve evidence

⚠️ **Preserve Chain of Custody**
- Evidence will be used in forensic investigation
- May be needed for legal proceeding or regulatory investigation
- Every touch must be documented
- Original state must be maintained

⚠️ **Confidentiality is Critical**
- Do NOT discuss with general help desk staff
- Do NOT email sensitive details to non-security personnel
- Do NOT tell users prematurely (decision is legal team's)
- Information is security-classified

⚠️ **Do NOT Make Promises to User**
- Do not promise "this won't happen again"
- Do not promise timeline for resolution
- Do not assure data isn't leaked (investigation not complete)
- Say: "Security team is investigating and will update us"

⚠️ **Do NOT Modify or Disable Copilot Without Security Direction**
- Modification could destroy evidence
- Could indicate tampering with system
- Could affect investigation timeline
- Wait for security team decision

---

### Related Incidents (Different Root Causes)

**INCIDENT #1 - Login Delay** 
- Different issue (performance, not security)
- Different root cause (OneDrive KFM policy)
- Different resolution (remove policy)
- May have triggered Copilot query (user frustrated), but separate issue

**INCIDENT #2 - Shortcuts Missing**
- Different issue (file location, not security)
- Different root cause (OneDrive sync)
- Different resolution (remove policy)
- Not related to Copilot access issue

**Why Separate:** Incidents #1 & #2 are technical issues that get fixed. Incident #3 is security issue that gets investigated.

---

### Legal Hold Notice

**If Incident Confirms Data Breach:**

A "legal hold" may be issued requiring:
- All evidence preserved indefinitely
- Device not recovered or reused
- Logs retained for investigation
- Access audited and documented
- May prevent device from being used/returned

**You should be aware:** This device may not be returned to user immediately. Investigation and legal proceedings could take weeks or months.

---

### Regulatory Notification (Legal/Compliance Decision)

**Do NOT decide whether to notify regulators, clients, or affected parties.**

That decision is made by:
- Legal Department (attorney-client privilege implications)
- Compliance Officer (regulatory requirements - GDPR, state laws, etc.)
- Privacy Officer (data protection obligations)
- Insurance carrier (may be required for claims)
- Executive leadership (reputation/disclosure timing)

**Your job:** Provide facts; let decision-makers decide.

---

### What Happens After Investigation

**Possible Outcomes:**

**Outcome A: No Unauthorized Access Found**
- Investigation concludes no breach occurred
- User misunderstood data access
- Copilot behaved as configured
- Incident closed
- No regulatory notification needed

**Outcome B: Copilot Misconfigured**
- Investigation finds permission misconfiguration
- Copilot had excessive access to sensitive files
- Configuration changed to restrict access
- Audit performed to see who accessed what
- Incident closed with remediation
- May require client notification (if data accessed)

**Outcome C: Confirmed Breach**
- Investigation confirms unauthorized access
- Data exposure verified
- Legal/compliance team decides on notifications
- Law enforcement may be involved
- Forensic investigation may continue
- Incident remains open during legal proceedings

---

### Documentation Records to Keep

**Preserve all documentation from this incident:**
- [ ] Original incident report (user's exact words)
- [ ] Date/time report received
- [ ] Screenshots of device state
- [ ] Intune policy configurations (screenshots)
- [ ] Incident ticket number and all updates
- [ ] Phone call log (time, person contacted)
- [ ] Escalation email (sent and received copies)
- [ ] Chain of custody documentation
- [ ] User interview notes
- [ ] Preliminary assessment
- [ ] Security team handoff notes

**These records:**
- Support investigation
- Provide audit trail
- Document your response quality
- May be used in legal proceedings
- Should be retained per organization's retention policy

---

## SIGN-OFF

**First Responder Response Completed By:**
- Name: _______________________
- Date: _______________________
- Time Started: _____  Time Completed: _____

**Incident Escalation Status:**
- Security team contacted: ☐ YES  ☐ NO  (Time: _____)
- Escalation email sent: ☐ YES  ☐ NO  (Time: _____)
- Incident ticket created: ☐ YES  ☐ NO  (Ticket: _____)
- Device preserved: ☐ YES  ☐ NO
- User interviewed: ☐ YES  ☐ NO
- Security team handoff confirmed: ☐ YES  ☐ NO

**Investigation Handed Off To:**
- Name: _______________________
- Title: _______________________
- Date/Time: _______________________

**Incident Status:**
- ☐ ESCALATED - Awaiting Security Team Investigation
- ☐ INVESTIGATION IN PROGRESS
- ☐ INVESTIGATION COMPLETE (Outcome: ______________)

---

**END OF INCIDENT RESPONSE RUNBOOK**

*This runbook is for first responders to recognize, escalate, and document security incidents. The goal is NOT to fix the issue yourself, but to ensure proper escalation and evidence preservation. Investigation, determination of regulatory response, and final remediation are security team's responsibility.*

*Security Team Contact: [Name/Number]*  
*Compliance Officer Contact: [Name/Number]*  
*Legal Department Contact: [Name/Number]*

*REMEMBER: When in doubt about a security incident, escalate immediately. Do not try to troubleshoot or "fix" it yourself.*
