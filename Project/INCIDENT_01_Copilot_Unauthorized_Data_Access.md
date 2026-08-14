# INCIDENT 01: Copilot Unauthorized Data Access - Security Critical
**FinBridge Legal Department | Floor 6 | Incident ID: SEC-2026-0814-001**

---

## INCIDENT BREAKDOWN

### Issue Statement
A paralegal reports that Microsoft Copilot displayed a confidential client matter to which the user has no documented access rights. This represents a potential data confidentiality breach affecting privileged legal information.

### Why This Is a Separate Incident
- **Incident Category:** Security & Data Exposure (not system availability)
- **Isolation Rationale:** This is independent of login/performance issues. A user CAN experience Copilot data exposure even with working login and shortcuts. Conversely, login issues do not automatically cause data exposure.
- **Regulatory Implication:** Legal data exposure triggers compliance obligations (attorney-client privilege, regulatory reporting, client notification protocols)
- **Root Cause Domain:** Depends on data permissions, Copilot grounding data, Graph API access, and Microsoft 365 backend, not Windows 11 or Intune device configuration

---

## PRIORITY ASSESSMENT

### Severity: **CRITICAL** 🔴
- **Security Risk:** Extreme — potential unauthorized access to privileged legal information
- **Business Impact:** Existential — reputational damage, regulatory liability, client notification required
- **Affected Users:** 1 confirmed (paralegal), unknown if others affected
- **Containment Timeline:** Immediate action required within minutes, not hours

### Priority Ranking Among Floor 6 Issues
**RANK 1 OF 3** — Security exposure supersedes availability issues. Login issues affect productivity; data breaches affect regulatory compliance and reputation.

---

## FACTS VS ASSUMPTIONS VS UNKNOWNS

### VERIFIED FACTS
- ✅ Paralegal reports Copilot displayed confidential client matter
- ✅ Paralegal states she has "no documented access" to this matter
- ✅ Copilot was accessed on Floor 6 on or around 09:14 Monday morning
- ✅ Floor 6 users were recently migrated to Windows 11
- ✅ Floor 6 users were recently enrolled in Intune
- ✅ Copilot deployment is active on Floor 6

### ASSUMPTIONS (HIGH RISK - MUST VERIFY)
- ⚠️ **Assumption:** User has truly never accessed this client matter
  - *Counter-reality:* User may have accessed file previously and forgotten, or may have been granted access via delegation/shared mailbox she's unaware of
  - *Verification:* Check Azure AD audit logs for file access history

- ⚠️ **Assumption:** Copilot is displaying data it retrieved from backend
  - *Counter-reality:* Could be hallucination or cached data from previous user's session on shared device
  - *Verification:* Correlate Copilot query timestamp with actual Microsoft 365 data access logs

- ⚠️ **Assumption:** This is unique to this user
  - *Counter-reality:* Other users may experience similar exposure but haven't reported it yet
  - *Verification:* Conduct rapid audit of Copilot query patterns across Floor 6

- ⚠️ **Assumption:** Intune/Windows 11 migration caused the exposure
  - *Counter-reality:* Copilot data access is M365/Azure backend configuration issue, not device-level
  - *Verification:* Check if non-Windows 11 users can replicate the issue (Mac, iPad, web)

### UNKNOWNS (CRITICAL GAPS)
- ❓ **What data did Copilot display?** Full document? Snippet? Metadata only?
- ❓ **How was the client matter accessed?** Via Copilot search? Chat? Suggested content?
- ❓ **Can the exposure be replicated?** Is it consistent or a one-time anomaly?
- ❓ **Which Copilot service?** Copilot Pro, Copilot for Microsoft 365, Copilot in Teams, embedded in another app?
- ❓ **What is the user's actual permission level?** Is she in delegated mailboxes? Team channels? Project sites?
- ❓ **How many users have been similarly exposed?** Is this widespread or isolated?
- ❓ **Was there a Copilot data source misconfiguration?** Post-migration permission sync failure?
- ❓ **Is there evidence of cache poisoning or session bleed?** Could previous user's session data leak?

---

## FIRST 30-MINUTE TRIAGE PLAN

### **Minute 0-2: Incident Receipt & Severity Gate**
**Actions:**
1. Record incident timestamp: 09:14 Monday
2. Assign incident ID: SEC-2026-0814-001
3. Establish incident bridge with reporter (paralegal) and IT Ops Lead
4. **Decision Gate:** Is this a confirmed data exposure or user perception error?
   - If confirmed → proceed with full containment
   - If unconfirmed → still treat as CRITICAL until proven otherwise (legal/compliance principle: assume breach until ruled out)

**Owner:** Incident Commander
**Output:** Incident ticket opened, severity level locked as CRITICAL

---

### **Minute 2-5: Data Collection from Affected User**
**Actions:**
1. Contact paralegal directly via phone (bypass email/Teams to avoid accidental data transmission)
2. **Critical questions:**
   - "Can you describe exactly what you saw Copilot display?"
   - "Which client name, project code, or matter ID did you recognize?"
   - "What was your query or interaction that triggered this?"
   - "Did you copy, screenshot, or share the content?"
   - "Is this client matter something you work on, or completely unknown to you?"
3. Request user to **STOP using Copilot immediately** and provide reason: "We need to preserve the exact state of your session for investigation"
4. Document user's exact words in incident log (avoid paraphrasing; quote verbatim)

**Owner:** Incident Commander
**Output:** Detailed account of user experience, confirmation of severity, user containment (stopped using Copilot)

---

### **Minute 5-10: Forensic Data Preservation**
**Actions:**
1. **Preserve Copilot session data:**
   - Request IT Ops to immediately capture browser history/cache from user's machine (Microsoft Edge local storage, Copilot interaction logs)
   - Enable enhanced auditing on user's M365 account before any cleanup
   - Check Microsoft 365 audit logs for Copilot-initiated data access in the past 24 hours

2. **Preserve user permissions baseline:**
   - Export current SharePoint/OneDrive permission matrix for affected user
   - Export Teams channel membership for user
   - Export shared mailbox access list for user
   - Export project site access for user
   - Timestamp all exports with preservation notice

3. **Communicate with Legal/Compliance:**
   - Notify Legal Department head immediately (verbal + email)
   - Alert Compliance Officer: potential data breach discovery
   - **Do NOT delay for formal breach notification process yet; this is discovery phase**

**Owner:** Security/Forensics Team + Compliance Officer
**Output:** Forensic data locked, audit trails enabled, legal notification sent

---

### **Minute 10-18: Parallel Investigation Streams**

**Stream A: Verify the Exposure (IT Security)**
1. Log into M365 Admin Center as Security Admin
2. Check **Microsoft 365 Audit Log:**
   - Search for user's Copilot interactions (look for "Bing" or "Copilot" event types)
   - Filter for timestamp around 09:14 and preceding 2 hours
   - Identify what data was accessed via Graph API by Copilot
3. Check **Microsoft 365 Defender > Actions & Submissions:**
   - Look for any anomalous permission changes post-migration
4. Cross-reference audit results with user's documented permission matrix
   - **If audit shows user HAS access:** Hypothesis is permission inheritance or delegation, not a breach
   - **If audit shows user LACKS access but data was returned:** Hypothesis is Copilot service misconfiguration or Graph API permission issue

**Stream B: Check for Windows 11/Intune Misconfiguration (System Engineer)**
1. Review Intune compliance policies for Floor 6 users
2. Check if any Intune policy grants elevated permissions (e.g., local admin rights that could enable permission bypass)
3. Verify Windows 11 login session doesn't have cross-session data bleed risk
4. Check OneDrive Known Folder Move (KFM) policies — did migration cause unintended profile/cache mixing?

**Stream C: Copilot Service Configuration Audit (Microsoft 365 Admin)**
1. Check Copilot for Microsoft 365 settings in M365 Admin Center:
   - Verify data sources are correctly scoped
   - Confirm topic-based access controls (if available) align with user roles
   - Check if there were any config changes in past 72 hours (post-deployment window)
2. Review Copilot audit logs (if available in tenant):
   - Look for queries from this user
   - Identify what backend services were queried
3. If Copilot in Teams: Check team/channel ownership and guest access rules

**Stream D: New Application Deployment Risk (Application Team)**
1. Get details on the document management app deployed Friday
2. Does the app have Copilot integration or API hooks?
3. Did deployment include SSO/federated identity configuration that could affect Copilot data grounding?
4. Check app logs for Friday deployment to see if there were permission or credential issues

**Owners:** Parallel teams (Security, System Engineer, M365 Admin, App Team)
**Output:** Four concurrent investigations to rule in/out root cause within 8 minutes

---

### **Minute 18-25: Rapid Triage Analysis & Decision Point**

**Pause for synthesis:**
1. Compile findings from all four streams
2. Build decision matrix:
   - Is the exposure real or user misperception? → YES/NO
   - Is it Windows 11/Intune related? → YES/NO
   - Is it Copilot service misconfiguration? → YES/NO
   - Is it permissions inheritance issue (legitimate but unexpected)? → YES/NO
   - Is it related to new document management app? → YES/NO

3. **Determine immediate containment posture:**
   - **If REAL BREACH CONFIRMED:** Escalate to incident response, prepare breach notification
   - **If LEGITIMATE BUT UNEXPECTED ACCESS:** Audit all similar user permission chains, remediate
   - **If MISPERCEPTION:** Continue with normal investigation, document for lessons learned

4. Begin drafting executive summary for leadership

**Owner:** Incident Commander + Investigation Lead
**Output:** Root cause hypothesis, containment decision, executive summary draft

---

### **Minute 25-30: Escalation & Next Steps Definition**

**Actions:**
1. Update IT Ops Lead with preliminary findings and containment status
2. Define next phase investigation priorities (scope, depth, timeline)
3. Identify if external incident response firm needed (if breach confirmed)
4. Prepare to notify affected clients if required
5. Document lessons learned for preventive measures post-investigation

**Owner:** Incident Commander
**Output:** Status update to stakeholders, Phase 2 investigation plan

---

## EVIDENCE REQUIRED

### TIER 1: MUST-HAVE EVIDENCE (Required to confirm/deny breach)
1. **Copilot Audit Log Entry**
   - Timestamp of Copilot interaction
   - Query/prompt text from user
   - Data sources accessed
   - Client matter ID or name returned
   - User's permission level at time of query

2. **M365 Audit Log: Graph API Access**
   - Azure AD sign-in logs for user's session
   - Graph API calls initiated by Copilot service
   - Files/documents accessed via Graph
   - Timestamp correlation with user's Copilot query

3. **User Permission Matrix (Pre & Post Migration)**
   - SharePoint/OneDrive sites user has access to
   - Teams channels and their membership
   - Shared mailboxes on user's account
   - Delegated calendars or mailboxes
   - Project site access
   - **Critical:** Compare pre-migration vs post-migration to identify unintended additions

4. **Device Forensics**
   - Browser cache (Microsoft Edge)
   - Copilot interaction logs (local or browser-based)
   - Windows 11 session logs
   - User profile integrity check

### TIER 2: SUPPORTING EVIDENCE (Required for root cause confirmation)
5. **Intune Policy Audit**
   - All policies deployed to Floor 6 in past 2 weeks
   - Any policy changes related to permissions or app access
   - Compliance baseline for user's device

6. **Copilot Service Configuration**
   - Copilot for Microsoft 365 policy settings
   - Data source configuration (what data Copilot is authorized to access)
   - Role-based access control settings
   - Recent configuration changes (past 72 hours)

7. **Windows 11 Migration Log**
   - User profile migration script output
   - Permission inheritance changes during migration
   - OneDrive KFM synchronization status
   - Cache/temporary file handling during migration

8. **New Document Management App Logs**
   - Deployment manifest
   - SSO configuration
   - App-to-M365 API permissions granted
   - Any errors during Friday deployment
   - User's interaction logs with the app

### TIER 3: PATTERN EVIDENCE (Required for scope assessment)
9. **Floor-Wide Copilot Audit**
   - Query logs from all Floor 6 users (past 24 hours)
   - Identify similar anomalies
   - Pattern analysis: is this isolated or systematic?

10. **Other Users' Permission Matrices**
    - Spot-check 5-10 other Floor 6 users
    - Verify their permissions match expected role
    - Identify if mass permission grant occurred

---

## SYSTEMS AND LOGS TO CHECK

### PRIMARY SYSTEMS (Check First)

**1. Microsoft 365 Audit Log (Security & Compliance Center)**
   - **Path:** https://compliance.microsoft.com → Audit Log Search
   - **Search Filters:**
     - User principal name: [affected user's email]
     - Activities: "Search-UnifiedAuditLog" (Copilot searches if visible)
     - Date range: -24 hours from incident
     - Result options: Download CSV for detailed analysis
   - **What to look for:** Graph API calls, data access from Copilot service account

**2. Azure AD Audit Logs (Entra ID Admin Center)**
   - **Path:** https://entra.microsoft.com → Audit Logs
   - **Search Filters:**
     - User: [affected user]
     - Date range: -72 hours
     - Activity: "Add member" / "Remove member", permission changes
   - **What to look for:** Unintended permission grants around migration date

**3. Microsoft 365 Defender - Advanced Hunting**
   - **Path:** https://security.microsoft.com → Advanced Hunting
   - **Query focus:** IdentityInfo, IdentityLogonEvents, CloudAppEvents (Copilot activities)
   - **Purpose:** Detect if user's session was compromised or if permission escalation occurred

**4. SharePoint Admin Center - Site Permissions**
   - **Path:** https://[tenant]-admin.sharepoint.com → Sites → [specific site with client matter]
   - **Check:** User's permission level, inheritance chain
   - **Timeline:** View permission change history for past 72 hours

**5. Teams Admin Center - User Access**
   - **Path:** https://admin.teams.microsoft.com → Users → [affected user]
   - **Check:** Team membership, channel access, guest access status
   - **Focus:** Client matter-related teams and channels

**6. OneDrive Admin Center - Sharing Reports**
   - **Path:** https://[tenant]-admin.onedrive.com → Sharing → External sharing
   - **Check:** Has user been granted any shared libraries or folders containing client matters?

### SECONDARY SYSTEMS (Check During Phase 2)

**7. Intune Device Management (Endpoint Manager)**
   - **Path:** https://endpoint.microsoft.com → Devices → Windows → All devices
   - **Search:** Floor 6 user's device
   - **Check:** Compliance status, policy application, any permission-elevation policies
   - **Review:** Device configurations deployed in past 72 hours

**8. Windows 11 Event Viewer (on affected device)**
   - **Path:** Event Viewer → Windows Logs → Security
   - **Filter:** Event ID 4624 (logon), 4720 (user created), 4732 (group membership)
   - **Purpose:** Detect any privilege escalation or unauthorized account activity

**9. Microsoft Edge Browser History (on affected device)**
   - **Path:** C:\Users\[username]\AppData\Local\Microsoft\Edge\User Data\Default\History
   - **Check:** Copilot URL visits, M365 service access patterns
   - **Extract:** Using forensic tools (Nirsoft BrowsingHistoryView or similar)

**10. OneDrive Sync Log (on affected device)**
   - **Path:** C:\Users\[username]\AppData\Local\Microsoft\OneDrive\logs
   - **Check:** Which files were synced, when, and from which sources
   - **Purpose:** Detect if unexpected files were brought down to device

**11. Copilot Local Interaction Log (if available)**
   - **Path:** Edge → Settings → Privacy → Clear browsing data (history of cleared items)
   - **Purpose:** Recover Copilot query history before potential cleanup
   - **Alternative:** Use Microsoft 365 Defender device timeline for Copilot access

### TERTIARY SYSTEMS (Check if Phase 2 escalates)

**12. Microsoft 365 Governance Center (Data Lifecycle Management)**
   - Check if any data retention or compliance policy changes occurred around migration

**13. Entra ID Conditional Access Policies**
   - Verify if any new policies grant Copilot service elevated permissions

**14. Azure Blob Storage / Data Lake (if organization uses)**
   - If client matters stored externally, check access logs

---

## INVESTIGATION APPROACH

### PHASE 1: CONFIRMATION (Minutes 0-30) ← **YOU ARE HERE**

**Objective:** Determine if a real data breach occurred or if this is a false alarm

**Methodology:**
1. **Interview-Driven Discovery**
   - Direct user conversation to gather exact nature of exposure
   - Preserve user's exact narrative before memory fades
   - Identify triggering action (what prompted Copilot to display data)

2. **Forensic Timeline Construction**
   - Map all system events within 2-hour window before incident report
   - Correlate user's Copilot interaction with backend data access
   - Identify permission state at time of access

3. **Permission Baseline Comparison**
   - Extract user's current permissions across all M365 services
   - Identify any post-migration changes
   - Rule out legitimate access paths user is unaware of

4. **Copilot Service Configuration Review**
   - Check if Copilot is authorized to access the data source
   - Verify role-based controls are enforced
   - Identify if configuration drifted post-migration

**Success Criteria for Phase 1:**
- ✅ Determined if data access was unauthorized or legitimate
- ✅ Identified specific system(s) where access occurred
- ✅ Locked down evidence before potential cleanup
- ✅ Escalated to appropriate response team (incident response, legal, compliance)

---

### PHASE 2: ROOT CAUSE ANALYSIS (Post-30-Minute Window)

**If Phase 1 confirms breach:**
- Deep forensic analysis of all four investigation streams
- Determine if Windows 11 migration, Intune, or new app deployment is causative
- Identify if this is isolated or part of larger systemic issue
- Quantify exposure scope (how many users? how much data?)

**If Phase 1 determines access was legitimate:**
- User education (unexpected permission inheritance)
- Audit similar users for same pattern
- Review delegation/shared access policies
- Update data access awareness

---

## RISK ASSESSMENT

### SECURITY RISKS

**Risk 1: Unauthorized Data Access to Privileged Information**
- **Likelihood:** Medium-High (unconfirmed but user confidence suggests real)
- **Impact:** Extreme (attorney-client privilege violation, regulatory exposure)
- **Exploitability:** If real, Copilot design allowed unauthorized data return
- **Mitigation (Immediate):** Disable Copilot for affected user's department pending investigation

**Risk 2: Systemic Permission Misconfiguration Post-Migration**
- **Likelihood:** Medium (Windows 11/Intune migration is complex)
- **Impact:** High (multiple users could have unintended access)
- **Exploitability:** Malicious user could discover similar gaps
- **Mitigation (Immediate):** Audit Floor 6 permission changes; rollback any unintended grants

**Risk 3: New Document Management App as Attack Vector**
- **Likelihood:** Medium-Low (deployed Friday, timing proximity)
- **Impact:** High (app could expose data if misconfigured)
- **Exploitability:** App could have overpermissioned API access
- **Mitigation (Immediate):** Review app's M365 API permissions; consider disabling until verified

**Risk 4: Intune Policy Granting Elevated Device Permissions**
- **Likelihood:** Low (Intune policies typically restrict, not elevate)
- **Impact:** Medium (local admin rights could bypass file permission checks)
- **Exploitability:** User could access protected files if device-level permissions escalated
- **Mitigation (Immediate):** Audit Intune policies for Floor 6; verify no local admin grants

**Risk 5: Windows 11 Session Bleed or Cache Poisoning**
- **Likelihood:** Low (Windows 11 session isolation is mature)
- **Impact:** Medium (previous user's data could leak to current user)
- **Exploitability:** Shared device scenarios
- **Mitigation (Immediate):** Verify devices are single-user; check if device is kiosk/shared

**Risk 6: Regulatory/Compliance Exposure**
- **Likelihood:** High (if breach is confirmed)
- **Impact:** Extreme (legal industry faces harsh regulations: GDPR, state bar rules, professional liability)
- **Exploitability:** Clients could sue FinBridge for negligence; regulators could levy fines
- **Mitigation (Immediate):** Involve Legal and Compliance in investigation; prepare breach notification plan

**Risk 7: Reputational Damage**
- **Likelihood:** High (law firm data breach is immediately newsworthy)
- **Impact:** Extreme (client base could flee; firm reputation permanently damaged)
- **Exploitability:** Media attention could accelerate client churn
- **Mitigation (Immediate):** Prepare transparent communication plan; control narrative

---

## IMMEDIATE CONTAINMENT ACTIONS

### TIER 1: EXECUTE IMMEDIATELY (Within 5 Minutes)

**Action 1.1: Disable Affected User's Copilot Access**
- **How:** In Microsoft 365 Apps admin center, revoke Copilot for Microsoft 365 assignment for the affected paralegal
- **Why:** Prevents further accidental data exposure while investigation continues
- **Impact:** User loses Copilot functionality; minimal disruption compared to breach risk
- **Reversibility:** Can be re-enabled post-investigation
- **Owner:** Microsoft 365 Admin
- **Verification:** Confirm in Copilot settings that user no longer has access within 2 minutes

**Action 1.2: Preserve All Audit Data**
- **How:** Enable enhanced auditing on affected user's account and Copilot service account
- **Why:** Prevents automatic log rotation/cleanup before forensics complete
- **Impact:** None (audit-only, no user-facing change)
- **Reversibility:** Can be disabled after investigation
- **Owner:** Security Team
- **Verification:** Confirm audit settings in M365 Security & Compliance Center

**Action 1.3: Notify Legal/Compliance Leadership**
- **How:** Phone call to Legal Department head + Compliance Officer
- **Message:** "We've received a report of potential unauthorized data access in a legal matter. We're investigating and will provide full details within 2 hours. Please do not communicate externally until we brief you."
- **Why:** Legal/Compliance must begin breach notification assessment immediately
- **Impact:** Escalation; potential breach notification process activation
- **Reversibility:** None; notification has occurred
- **Owner:** Incident Commander
- **Documentation:** Send email summary to Legal/Compliance within 5 minutes

**Action 1.4: Place Affected User in Monitoring Status**
- **How:** Flag user's account in Azure AD for enhanced monitoring; set alert on any M365 data access
- **Why:** Detect if data exposure is ongoing or if malicious use is occurring
- **Impact:** User doesn't know about monitoring; normal operations continue
- **Reversibility:** Can be removed post-investigation
- **Owner:** Security Team
- **Tool:** Microsoft 365 Defender → Set alert on user's anomalous activities

---

### TIER 2: EXECUTE WITHIN 15 MINUTES

**Action 2.1: Audit Floor 6 Permissions for Similar Issues**
- **How:** Export SharePoint/OneDrive permissions for all Floor 6 users; run automated check against role-based expectations
- **Why:** Determine if this is isolated incident or systemic permission misconfiguration
- **Impact:** Identifies scope of potential exposure
- **Reversibility:** View-only; no changes made
- **Owner:** SharePoint Admin
- **Scope:** All 45 Floor 6 legal users

**Action 2.2: Disable or Restrict Copilot for Floor 6 Department (Pending Verification)**
- **How:** Temporarily remove Copilot assignment for all Floor 6 users OR restrict Copilot to specific approved data sources
- **Why:** Defense-in-depth; prevents widespread exposure if systemic issue confirmed
- **Impact:** 45 users lose Copilot; business disruption is significant but justified if breach is real
- **Reversibility:** Can be re-enabled after root cause fix
- **Owner:** Microsoft 365 Admin
- **Decision Trigger:** If Phase 1 audit (Action 2.1) finds multiple anomalies, execute immediately. If isolated, hold pending Phase 2 findings.

**Action 2.3: Isolate and Inspect New Document Management App**
- **How:** Review app's M365 API permissions in Azure AD app registration; check deployment logs for Friday
- **Why:** Determine if app granted overpermissioned access that enabled Copilot data leakage
- **Impact:** May require app rollback/remediation
- **Reversibility:** App can be re-deployed after fixes
- **Owner:** Application Owner + Security Team
- **Scope:** Check if app has access to SharePoint, OneDrive, Teams, or Graph Search APIs

**Action 2.4: Correlate Windows 11 Migration Events**
- **How:** Cross-reference Copilot data access timestamp with user's Windows 11 migration completion date/time
- **Why:** Determine if exposure is related to profile migration or Intune enrollment
- **Impact:** Narrows root cause hypothesis
- **Reversibility:** View-only; no changes made
- **Owner:** System Engineer
- **Timeline:** When did user's device migrate? When was Intune policy applied? Did Copilot access occur post-migration?

---

### TIER 3: EXECUTE WITHIN 30 MINUTES (Pending Phase 1 Findings)

**Action 3.1: Engage Incident Response Team (If Breach Confirmed)**
- **How:** Contact external incident response firm (if organization contracts one) with full forensic package
- **Why:** Complex breach investigation requires expert-level analysis; liability/legal considerations
- **Impact:** External costs, potential extended service disruption for investigation
- **Reversibility:** Investigation proceeds regardless; can be paused if false alarm
- **Owner:** Incident Commander
- **Trigger Condition:** Phase 1 confirms unauthorized access with high confidence

**Action 3.2: Prepare Client Notification List (If Breach Confirmed)**
- **How:** Identify all clients whose matters could have been exposed; categorize by sensitivity
- **Why:** Legal obligation to notify affected parties within state-specific timelines
- **Impact:** Major business/reputation impact; must be coordinated with Legal/Compliance/PR
- **Reversibility:** No; notification is legal requirement
- **Owner:** Compliance Officer + Legal Counsel
- **Scope:** Depends on which client matters were exposed (Phase 1 must determine this first)

**Action 3.3: Document All Changes for Audit Trail**
- **How:** Create detailed log of all containment actions taken, including timestamp, owner, justification, and reversibility
- **Why:** Litigation/regulatory investigations will require proof of appropriate response
- **Impact:** None (documentation only)
- **Reversibility:** None; audit trail is permanent
- **Owner:** Incident Commander
- **Format:** Incident ticket, include all action details in timeline

---

## DECISION TREE

```
START: Copilot Data Access Report Received (09:14)
│
├─────────────────────────────────────────────────────┐
│ DECISION 1: Is the user's narrative credible?      │
│ (Can she describe the data with specificity?)       │
└─────────────────────────────────────────────────────┘
│
├─ YES: User describes specific client matter, document title, or project code
│       └─ Proceed to DECISION 2
│
└─ NO: User is vague or confused; might be misunderstanding Copilot's response
       └─ Still escalate as CRITICAL (legal principle: assume breach until proven otherwise)
           └─ Proceed to DECISION 2 anyway


├─────────────────────────────────────────────────────┐
│ DECISION 2: Can the data access be verified in     │
│ M365 Audit Logs? (Graph API call from Copilot)     │
└─────────────────────────────────────────────────────┘
│
├─ YES: Audit log shows Copilot service accessed the client matter file
│       └─ This is CONFIRMED BREACH unless DECISION 3 negates it
│           └─ Proceed to DECISION 3
│
└─ NO: Audit log is silent; no Graph API call for this file from Copilot
       └─ Possible explanations: cached data, hallucination, or user misremembering
           └─ De-escalate to MEDIUM priority but keep incident open
               └─ Investigate cache poisoning and session bleed


├─────────────────────────────────────────────────────┐
│ DECISION 3: Did the user have legitimate access to │
│ this client matter? (Check permission matrix)       │
└─────────────────────────────────────────────────────┘
│
├─ YES: User is member of shared mailbox, Teams channel, or project site containing matter
│       └─ Access was AUTHORIZED but UNEXPECTED to user
│           └─ Not a breach; user education needed
│           └─ Escalate to MEDIUM: audit similar permission chains
│
└─ NO: User has no documented permission to this matter in any form
       └─ This is CONFIRMED UNAUTHORIZED ACCESS
           └─ Proceed to DECISION 4


├─────────────────────────────────────────────────────┐
│ DECISION 4: Is this a Windows 11/Intune/Migration  │
│ issue, or Copilot/M365 service configuration issue?│
└─────────────────────────────────────────────────────┘
│
├─ Device/Intune Issue (Windows 11 privilege escalation allowed bypass)
│   └─ Look for: Local admin rights in Intune policy, device permission cache issues
│       └─ Mitigation: Audit Intune policies; remediate device permissions
│       └─ Scope: Likely isolated to this device (Intune per-device policies)
│
├─ Copilot Service Issue (Copilot data source misconfigured)
│   └─ Look for: Copilot granted access to data it shouldn't access
│       └─ Mitigation: Restrict Copilot data sources; review Graph API permissions
│       └─ Scope: Likely affects all users with similar access patterns
│           └─ ESCALATE: Disable Copilot for Floor 6 pending review
│
└─ New App Deployment Issue (Document management app granted overpermissioned API access)
    └─ Look for: App has developer mode or testing permissions that expose data
        └─ Mitigation: Review app API permissions; disable app pending remediation
        └─ Scope: Anyone who used the new app Friday could be affected


├─────────────────────────────────────────────────────┐
│ DECISION 5: Is this isolated to one user or        │
│ systemic across Floor 6?                            │
└─────────────────────────────────────────────────────┘
│
├─ ISOLATED: Only this user affected
│   └─ Scope: 1 user, 1 client matter exposed (potentially)
│       └─ Response: Targeted remediation, user education
│       └─ Timeline: Investigation within 4 hours; notification by EOD
│
└─ SYSTEMIC: Multiple users could access each other's matters via Copilot
    └─ Scope: All 45 Floor 6 users potentially compromised
        └─ Response: FULL INCIDENT RESPONSE; prepare breach notification for all affected clients
        └─ Timeline: Investigation within 2 hours; client notification within 24 hours


├─────────────────────────────────────────────────────┐
│ DECISION 6: What is the regulatory/notification    │
│ requirement? (Legal/Compliance decision)            │
└─────────────────────────────────────────────────────┘
│
├─ Data includes Attorney-Client Privilege (ACP)
│   └─ Notification: Clients MUST be notified (attorney obligations supersede normal breach notification)
│       └─ Timeline: Immediately (within 24 hours)
│       └─ Impact: Existential to firm; potential engagement at risk
│
├─ Data includes Personal Identifiable Information (PII)
│   └─ Notification: Affected individuals + state AG + regulators per state law
│       └─ Timeline: 30-45 days (state-dependent)
│       └─ Impact: High; media attention likely
│
└─ Data is only business/non-sensitive
    └─ Notification: Internal notification only (unless contract terms require client notice)
        └─ Timeline: Flexible; can be included in regular incident summary
        └─ Impact: Medium; business continuity focus


├─────────────────────────────────────────────────────┐
│ DECISION 7: Should we disable Copilot             │
│ for Floor 6 immediately or wait for Phase 2 data? │
└─────────────────────────────────────────────────────┘
│
├─ CONFIRMED unauthorized access → DISABLE IMMEDIATELY (Tier 2, Action 2.2)
│   Rationale: Known active threat; defense-in-depth required
│
├─ LIKELY unauthorized access (high confidence) → RESTRICT TO APPROVED SOURCES
│   Rationale: Partially disable to limit exposure while investigation continues
│
└─ UNCERTAIN or ISOLATED → ENABLE ENHANCED MONITORING
    Rationale: Preserve functionality while detecting further issues
    └─ Escalate to disable if additional anomalies detected during Floor 6 audit


END: Send status to Incident Commander for Phase 2 planning
```

---

## EXECUTIVE UPDATE FOR LEADERSHIP

### FOR: FinBridge Partners & Senior Leadership  
### TIME: ~09:45 (approximately 30 minutes after initial report)  
### FROM: IT Security & Incident Management  
### CONFIDENTIALITY: Partners and Leadership Only  

---

### SITUATION SUMMARY (Non-Technical)

This morning at 09:14, a member of our Legal department reported that Microsoft Copilot may have displayed confidential client information that she should not have access to. This is a serious matter that we are treating as our highest priority.

**What we know:**
- One attorney reported seeing confidential client case details via Copilot
- We have NOT yet confirmed if this was an actual unauthorized access or if there's another explanation
- This incident is NOT related to the other issues reported this morning (login problems, missing shortcuts)

**What we're doing RIGHT NOW:**
- Our security team is actively investigating and gathering evidence
- We've taken immediate steps to preserve all relevant data and logs
- We've notified our Legal and Compliance teams
- We expect to have a clear answer within the next 60-90 minutes

---

### POTENTIAL BUSINESS IMPACT (Worst Case, Not Confirmed)

If this investigation confirms unauthorized access to client information:
- We have an **immediate legal obligation** to notify affected clients
- Our professional liability insurance will need to be engaged
- We may face regulatory reporting requirements depending on the scope
- Reputational impact could be significant in the legal community

**However:** We will not know the true scope for another hour. It's possible this is a misunderstanding or can be explained by legitimate access the attorney forgot about.

---

### WHAT WE'RE TELLING CLIENTS RIGHT NOW

**NOTHING.** We do not communicate with clients until we have confirmed facts. Right now we have a report, not yet confirmed facts. Once we know what actually happened, we'll immediately brief leadership and Legal on the client communication plan.

---

### TIMELINE & NEXT BRIEFING

- **09:45 (NOW):** Initial update to leadership
- **10:15:** Preliminary findings from forensic investigation
- **10:45 to 11:00:** Full briefing with root cause, scope, and containment actions
- **11:30:** Client communication plan (if required) or all-clear briefing

---

### IMMEDIATE LEADERSHIP DECISION REQUIRED

**Question for Partners:** If we confirm unauthorized access to a client matter, are you prepared to immediately notify that client and our insurance carrier? (Yes/No - requires executive-level sign-off for our immediate response)

**Answer needed by:** 10:00 AM

---

### KEY POINTS FOR EXTERNAL COMMUNICATION (DO NOT USE UNTIL AUTHORIZED)

- "We identified and immediately investigated a potential data access issue."
- "We have not confirmed any client data was compromised."
- "We are following all regulatory and professional obligations."
- "Client data security is our top priority and we are committed to full transparency."

*(This language will be refined once findings are confirmed)*

---

## PHASE 2: ROOT CAUSE ANALYSIS SCOPE (Post-Triage)

Once Phase 1 triage is complete, Phase 2 will determine:

1. **Was this caused by Windows 11 migration?** (Device profile corruption, permission inheritance)
2. **Was this caused by Intune enrollment?** (Device policy misconfiguration, elevated privileges)
3. **Was this caused by the new document management app?** (API permission overreach)
4. **Was this caused by Copilot service configuration?** (Data source scope misconfiguration)
5. **Is this isolated or systemic?** (Affects 1 user or all 45 Floor 6 users)
6. **What is the remediation path?** (Policy fix, app rollback, Copilot reconfiguration, user education)

---

## DOCUMENTATION & EVIDENCE CHAIN

**Incident Log ID:** SEC-2026-0814-001  
**Report Time:** 2026-08-14 09:14  
**Incident Commander:** [Assigned]  
**Status:** ACTIVE - Phase 1 Investigation In Progress  
**Next Review:** 2026-08-14 10:00  
**Escalation:** IT Security, Legal, Compliance, Executive Leadership

---

**END OF INCIDENT 01 ANALYSIS**
