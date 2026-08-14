# ROOT CAUSE ANALYSIS: INCIDENT #3
## Floor 6 Copilot Unauthorized Data Access - SECURITY INCIDENT

**Incident ID:** FLOOR6-COPILOT-UNAUTHORIZED-20260812  
**Date:** 2026-08-14  
**Status:** SECURITY INVESTIGATION REQUIRED - ESCALATED  
**Severity:** TIER 1 CRITICAL (Security Incident - Unauthorized Access to Confidential Data)  
**Affected Users:** At least 1 user (paralegal); scope unknown  
**Scope:** Potential data breach; legal documents accessed by unauthorized party  

---

## CRITICAL SECURITY NOTE

**This incident is NOT a normal support ticket.**

This is a potential **security incident involving unauthorized access to confidential legal documents**. This requires:
- Immediate security team escalation
- Potential legal/compliance notification
- Investigation into data exposure
- Chain of custody documentation
- Forensic evidence preservation

Do NOT dismiss as "system error" or "user confusion." Treat as potential breach.

---

## FINDINGS

### Main Issue
A paralegal on Floor 6 reports that Copilot (Microsoft AI assistant) displayed a client legal matter that the user believes she never had access to and should not have been able to see.

### User Report
- Time: Monday morning (~9:00 AM)
- User: Paralegal on Floor 6
- Report: "Copilot pulled up a client matter I don't have access to"
- Concern: Confidentiality breach; unauthorized access to privileged legal information

### Initial Observations
- User interacted with Copilot during login recovery attempts (after slow login issues)
- Copilot may have accessed user profile, files, or organization data
- Unknown if Copilot accessed data intentionally, through misconfiguration, or via user error
- Unknown scope: Is this limited to one user or wider access issue?

---

## SUPPORTING EVIDENCE

✅ **Evidence 1: Copilot Access to User Files Possible**
- Copilot integrated into Windows 11
- Copilot can search user files, email, documents (if permissions granted)
- Intune can grant Copilot permissions to access organizational data
- No explicit evidence yet, but technical capability exists

✅ **Evidence 2: User Interaction with Copilot During Login Issues**
- Paralegal attempted login during slow login period (8:00-8:45 AM)
- Frustrated by login delay, possibly contacted Copilot for help ("why is login slow?")
- Copilot may have accessed user profile/files during this interaction
- Timing coincides with policy application and Desktop folder movement

✅ **Evidence 3: Legal Documents Exist on Floor 6 Systems**
- Floor 6 is Legal Department
- Legal documents and client matters are routine
- Desktop folder sync moved legal-related files to OneDrive
- Documents accessible through Copilot search if permissions misconfigured

✅ **Evidence 4: Windows 11 Copilot Integration by Default**
- Windows 11 includes Copilot integration
- Intune devices may have Copilot enabled without explicit user opt-in
- Copilot can access files based on user permissions
- User may not be aware Copilot has access to their data

---

## CONTRADICTING EVIDENCE (NOT SUFFICIENT TO RULE OUT)

❌ **Cannot Rule Out (Insufficient Evidence):**
- No confirmation yet if user actually saw confidential information (versus perceived threat)
- No data export logs showing unauthorized data access
- No Copilot logs available yet to verify what data was accessed
- No confirmation if issue is system-wide or user-specific
- No indication if this is a permission misconfiguration or intentional data access

**IMPORTANT:** Absence of evidence does not mean this didn't happen. Requires investigation.

---

## CONFIDENCE LEVEL

### INSUFFICIENT EVIDENCE - INVESTIGATION REQUIRED

**Current State:** 
- User report received: Yes
- Potential severity: High (confidential legal data)
- Technical possibility: Yes (Copilot can access files)
- Confirmed unauthorized access: No (not yet verified)
- Scope of exposure: Unknown

**Confidence Level:** UNCONFIRMED - Requires Security Investigation

**Why Investigation Required:**
1. User concern involves confidential legal documents (attorney-client privilege)
2. Potential unauthorized access to privileged information
3. Potential data breach or exposure
4. Compliance/regulatory implications (legal documents may be regulated)
5. Unknown if issue affects other users or just this one

---

## ROOT CAUSE STATEMENT

### CONDITION
A Floor 6 paralegal reports that Copilot displayed a client legal matter the user believes she does not have authorization to access. The user is concerned this represents unauthorized access to confidential information.

### CAUSE - UNKNOWN (INVESTIGATION REQUIRED)

**Possible causes (not yet confirmed):**

**Scenario A: Copilot Permission Misconfiguration**
- Intune policy or Copilot configuration grants Copilot access to all user files
- User queries Copilot about login delay or other issue
- Copilot searches user files/email and finds client matter (which technically exists in user's accessible file share)
- User sees document they should not have direct access to
- Root cause: Overly permissive Copilot permissions in Intune

**Scenario B: OneDrive KFM Sync Exposed Files**
- OneDrive Desktop folder sync moved files containing client information to OneDrive
- Copilot indexes OneDrive contents
- User queries Copilot
- Copilot returns results including client documents
- Root cause: Combination of (1) file sync + (2) Copilot indexing + (3) permission misconfiguration

**Scenario C: Shared File Access Issues**
- Floor 6 devices access shared network drives containing legal documents
- User has access to these shares (job requirement)
- Copilot searches shared drives (if configured to do so)
- Copilot finds documents user has permission to see but shouldn't be querying
- Root cause: Copilot accessing shared resources inappropriately

**Scenario D: User Confusion / Misunderstanding**
- User saw document they DO have access to, but don't remember accessing
- User misunderstands Copilot capability as "unauthorized"
- User perception: Copilot accessed confidential information
- Actual situation: Document access was authorized, user forgot
- Root cause: User misunderstanding (lower severity)

**Scenario E: Actual Breach or Intentional Data Exposure**
- Unknown threat actor used Copilot to access confidential information
- Copilot used as vector for unauthorized access
- Documents intentionally exposed
- Root cause: Security vulnerability or policy bypass
- This scenario would represent genuine data breach

### IMPACT - POTENTIALLY SEVERE

**If Scenarios A-C confirmed (misconfiguration):**
- Copilot has unauthorized access to confidential documents
- Other users may be affected
- Legal/compliance risk (attorney-client privilege breach)
- Regulatory notification may be required
- Client notification may be necessary

**If Scenario D confirmed (misunderstanding):**
- No actual breach or policy violation
- User education sufficient
- No regulatory concern
- Low impact

**If Scenario E confirmed (breach):**
- Severe security incident
- Data exposure confirmed
- Forensic investigation required
- Regulatory/legal notification required
- Law enforcement possible

### EVIDENCE - INSUFFICIENT FOR CONFIRMATION

| Source | Evidence | Status | Details |
|--------|----------|--------|---------|
| User Report | Paralegal saw client matter in Copilot | Reported | Unverified - need to confirm what was shown |
| User Permissions | User's formal job access rights | Not checked | Need to verify if user has authorized access to document |
| Copilot Logs | What Copilot actually accessed | Not available | Need to retrieve Copilot activity logs |
| Intune Policy | Copilot permission configuration | Not checked | Need to review permission scope |
| OneDrive Logs | What files were synced where | Partial | Desktop sync confirmed, scope unknown |
| File Access Logs | Who accessed what files when | Not collected | Need to pull file server access logs |
| Data Exposure | Any data exfiltration | Not verified | Need to check for unauthorized transfers |

---

## IMMEDIATE SECURITY ACTIONS REQUIRED

### Action 1: Escalate to Security Team (IMMEDIATE - Next 5 Minutes)
```
Contact: [Security Team Lead]
Method: Phone call (do not email - security risk)
Message: "Potential unauthorized access to confidential legal documents 
         by Copilot on Floor 6. Requires immediate investigation. 
         Incident ID: FLOOR6-COPILOT-UNAUTHORIZED-20260812"
```

### Action 2: Preserve Evidence (IMMEDIATE - Next 15 Minutes)
- DO NOT restart affected user's device
- DO NOT clear browser history or files
- DO NOT modify OneDrive or file permissions
- Preserve Copilot logs/cache on device
- Document exact date/time of user report
- Get written statement from user: what did Copilot show? When? How?

### Action 3: Identify Scope (IMMEDIATE - Next 30 Minutes)
- Ask: Did any other Floor 6 users experience similar issues?
- Ask: Is this isolated to one user or wider problem?
- Check: Intune policy logs for Copilot permission scope
- Check: OneDrive sync logs for what files moved where
- Preliminary: Does this affect other departments?

### Action 4: Contain Potential Damage (IMMEDIATE - Next 60 Minutes)
- If Copilot permissions misconfigured: Remove Copilot access to sensitive folders
- If files inappropriately exposed: Check audit logs for viewing/sharing
- If breach confirmed: Follow data breach response plan
- Do NOT disable Copilot company-wide without security approval

### Action 5: Compliance/Legal Notification (WITHIN 2 HOURS)
- Contact: Compliance Officer / Legal Department
- Brief: Potential unauthorized access to privileged legal documents
- Question: Notification requirements under privacy/regulatory law?
- Question: Client notification required?
- This decision is NOT IT's; it's Compliance/Legal's

---

## INVESTIGATION PROTOCOL

### Phase 1: Verification (0-1 Hour)
**Goal:** Confirm unauthorized access actually occurred

**Steps:**
1. Interview user: What exactly did Copilot show? Document word-for-word
2. Pull Copilot logs: What search was performed? What results returned?
3. Review file: Verify file exists and contains what user claims
4. Check user permissions: Does user have authorized access to this file? (Likely yes, file on shared drive)
5. Determine difference: What the user CAN access (authorization) vs. what user SHOULD be querying (policy)

**Outcome:** Confirmed or ruled out

### Phase 2: Scope Analysis (1-4 Hours)
**Goal:** Determine if this is isolated incident or system-wide issue

**Steps:**
1. Check Floor 6 Copilot logs: Other users, similar patterns?
2. Check organization-wide Copilot logs: All departments, similar issues?
3. Review Intune Copilot policy: What's the configured permission scope?
4. Check OneDrive sync: What files were moved where?
5. Pull file access logs: Who accessed what, when?

**Outcome:** Isolated vs. widespread issue

### Phase 3: Root Cause Determination (4-8 Hours)
**Goal:** Determine why unauthorized access occurred

**Steps:**
1. Policy review: Is Copilot policy configuration appropriate?
2. Permission audit: Are file permissions correct?
3. Log analysis: Is Copilot behaving as configured?
4. Threat assessment: Was this intentional exposure or misconfiguration?
5. Compliance check: Any policy violations or regulatory issues?

**Outcome:** Identified root cause from scenarios A-E above

### Phase 4: Remediation (As needed, ongoing)
**Goal:** Fix underlying cause and prevent recurrence

**Steps:**
1. If misconfiguration: Correct Copilot permissions
2. If permission issue: Review and fix file access controls
3. If breach: Follow incident response plan
4. If user error: Provide education
5. Communication: Inform affected parties per legal/compliance guidance

**Outcome:** Issue resolved, preventive measures implemented

---

## CRITICAL QUESTIONS FOR INVESTIGATION

1. **What exactly did Copilot show?**
   - Document name? Client name? Matter details?
   - Was it a summary or full document?
   - User could see it clearly, or partial view?

2. **How did Copilot access this?**
   - User queried Copilot directly? (What was the query?)
   - Copilot provided unprompted? (Why would it do that?)
   - Through which interface? (Copilot app? Windows sidebar? Outlook?)

3. **Should this user have access to this document?**
   - Is this file on a shared drive user has access to? (Likely yes for legal staff)
   - Is the user authorized to work on this matter?
   - Is this a file access permission issue or a Copilot behavior issue?

4. **Could the user access this file normally (without Copilot)?**
   - Can user navigate to file through file explorer?
   - Can user open file through normal means?
   - If yes, is it a Copilot-specific issue or user access issue?

5. **What permission does Copilot have?**
   - Can Copilot search all user files? (Check Intune policy)
   - Can Copilot search shared drives? (Check Intune policy)
   - Can Copilot search email/OneDrive? (Check Intune policy)
   - Was this permission scope reviewed and approved?

---

## REGULATORY / COMPLIANCE CONSIDERATIONS

**If This is a Confirmed Breach:**
- Attorney-client privilege may be compromised
- Client confidentiality obligations may be violated
- Regulatory notification may be required (GDPR, HIPAA, state laws)
- Internal notification obligations (client, firm leadership, regulators)
- Legal hold implications (preserve all evidence)
- Incident reporting to cyber insurance

**Who Decides:** Not IT Operations
- Decision: Compliance Officer, Legal Department, Privacy Officer
- IT provides: Facts, evidence, technical details
- Legal/Compliance provides: Regulatory interpretation, notification requirements

---

## COMMUNICATION - SECURITY INCIDENT PROTOCOL

### DO NOT send this message to users yet - wait for security investigation
### This is for internal security/management communication only

**To: Security Team, Compliance Officer, IT Management**

**Subject: SECURITY INCIDENT - Potential Unauthorized Access to Confidential Legal Documents**

---

At approximately 9:00 AM Monday 2026-08-12, a Floor 6 paralegal reported that Copilot displayed a client legal matter the user stated she does not have authorization to access.

This report requires immediate security investigation to determine:
1. Whether unauthorized access actually occurred
2. Scope of potential exposure (one user or department-wide)
3. Root cause (permission misconfiguration vs. breach vs. user confusion)
4. Regulatory/compliance notification requirements

**Incident Details:**
- Affected User: Floor 6 paralegal (confidential, named in follow-up)
- Affected Data: Legal document / client matter (confidential, type not disclosed in this summary)
- Discovery Time: Monday 2026-08-12 approximately 9:00 AM
- Report Time: Monday 2026-08-12 approximately 9:14 AM
- Access Vector: Copilot (Microsoft AI assistant on Windows 11)
- Current Status: Reported, not yet verified

**Immediate Steps Taken:**
- Escalated to security team
- Evidence being preserved (device not restarted, logs not cleared)
- User being interviewed
- Preliminary scope analysis initiated

**Requested Actions:**
- Security team: Initiate investigation per protocol
- Compliance: Determine notification requirements
- Legal: Review for attorney-client privilege implications
- IT: Preserve all logs and evidence

**Do not dismiss this as user error or normal support issue. Treat as potential security incident until investigation concludes otherwise.**

---

## DOCUMENT CONTROL

| Item | Value |
|------|-------|
| **Incident ID** | FLOOR6-COPILOT-UNAUTHORIZED-20260812 |
| **RCA Document** | INCIDENT-03-COPILOT-SECURITY-RCA.md |
| **Date Created** | 2026-08-14 |
| **Status** | UNDER INVESTIGATION |
| **Classification** | CONFIDENTIAL - SECURITY |
| **Author** | DWP Service Desk |
| **Escalation** | Security Team, Compliance Officer, Legal Department |
| **Related Incidents** | INCIDENT-01-LOGIN-DELAY (may have triggered user's Copilot interaction), INCIDENT-02-SHORTCUTS-MISSING (may relate to file sync/access) |

---

## INCIDENT RESPONSE WORKFLOW

```
DISCOVERY (9:14 AM Monday)
│
├─ Received report from user
├─ Classified as potential security incident
└─ Escalation initiated

ESCALATION (9:15 AM - 9:30 AM)
│
├─ Contact security team (phone)
├─ Preserve evidence (device not restarted)
├─ Document user statement (written)
└─ Notify management of incident

INVESTIGATION (9:30 AM - End of Day)
│
├─ Security team takes lead
├─ Verify unauthorized access occurred (or not)
├─ Determine scope (isolated vs. widespread)
├─ Identify root cause
└─ Document all findings

COMPLIANCE REVIEW (Concurrent)
│
├─ Legal department reviews for privilege implications
├─ Compliance reviews for notification requirements
├─ Privacy officer assesses exposure
└─ Determine client/regulator notification needs

REMEDIATION (As Needed)
│
├─ If misconfiguration: Fix Copilot permissions
├─ If breach: Follow incident response plan
├─ If user error: Provide education
└─ Implement preventive measures

COMMUNICATION (Per Legal/Compliance)
│
├─ Internal: Brief affected parties
├─ External: Notify client (if required by law)
├─ Regulatory: File reports (if required by law)
└─ Documentation: Close incident with findings

CLOSURE
│
└─ Update incident record with final outcome
```

---

## SEPARATE FROM OTHER INCIDENTS

**This security incident is UNRELATED to:**
- INCIDENT #1 (Login Delay) - Timing coincidental; different root cause
- INCIDENT #2 (Shortcuts Missing) - File management issue; unrelated to Copilot access

**Recommend:** Investigate separately with different teams
- Incidents #1 & #2: IT Operations (resolved)
- Incident #3: Security Team (escalated, ongoing investigation)

---

**END OF RCA: INCIDENT #3 - COPILOT UNAUTHORIZED ACCESS (SECURITY INCIDENT)**

**STATUS: ESCALATED TO SECURITY TEAM - INVESTIGATION REQUIRED**

*This RCA is a security-classified document. Do not distribute outside of Security, Legal, Compliance, and authorized management.*
