# Prompt
---
You are a DWP analyst, reviewing an RDP connection failure incident. Below are System and Security Event Viewer log entries captured during a period when a user was unable to connect through Remote Desktop and the account was later locked out. For each Event ID explain what it records. Then reconstruct the sequence of events in plain English, and give the most likely cause of the RDP connection failure with evidence from the events. Finally create a detailed RCA document with 5 why analysis and store it under Day 3 Lab folder.

Log Name: System
Source: TermDD
Event ID: 56 Level: Error Date: 2024-03-15 14:01:02
Description: The Terminal Server security layer detected an
error in the protocol stream and has disconnected the client.
Client IP: 10.10.5.44

Log Name: System
Source: RemoteDesktopServices-RdpCoreTS
Event ID: 140 Level: Warning Date: 2024-03-15 14:01:02
Description: A connection from the client computer with an IP
address of 10.10.5.44 failed because the user name or password
is not correct.

Log Name: Security
Event ID: 4625 Level: Audit Failure Date: 2024-03-15 14:01:04
Account: FINBRIDGE\bwalker
Failure reason: Unknown username or bad password
Logon type: 10 (RemoteInteractive) Source IP: 10.10.5.44

Log Name: Security
Event ID: 4625 Level: Audit Failure Date: 2024-03-15 14:03:18
Account: FINBRIDGE\bwalker
Failure reason: Unknown username or bad password
Logon type: 10 (RemoteInteractive) Source IP: 10.10.5.44

Log Name: Security
Event ID: 4625 Level: Audit Failure Date: 2024-03-15 14:05:33
Account: FINBRIDGE\bwalker
Failure reason: Unknown username or bad password
Logon type: 10 (RemoteInteractive) Source IP: 10.10.5.44

Log Name: Security
Event ID: 4740 Level: Audit Failure Date: 2024-03-15 14:05:34
Account: FINBRIDGE\bwalker
Caller computer: 10.10.5.44
Description: A user account was locked out

Log Name: System
Source: RemoteDesktopServices-RdpCoreTS
Event ID: 131 Level: Info Date: 2024-03-15 14:22:07
Description: Server accepted a new TCP connection from client
10.10.5.44:52341.

Log Name: Security
Event ID: 4624 Level: Audit Success Date: 2024-03-15 14:22:09
Account: FINBRIDGE\bwalker
Logon type: 10 (RemoteInteractive) Source IP: 10.10.5.44

# Root Cause Analysis — RDP Connection Failure and Account Lockout
**Incident Date:** 2024-03-15  
**Affected Account:** FINBRIDGE\bwalker  
**Source Client IP:** 10.10.5.44  
**Analyst:** DWP Analyst  
**Document Created:** 2026-08-06  
**Severity:** Medium — User unable to connect via Remote Desktop; account locked out for ~17 minutes  
**Status:** Root Cause Identified — Resolved same day

---

## 1. Event ID Reference — What Each Event Records

| Event ID | Source | Log | Level | Purpose |
|----------|--------|-----|-------|---------|
| **56** | TermDD | System | Error | Records a low-level Terminal Server protocol error that forced a client disconnection. TermDD operates at the RDP transport layer; this event fires when the security layer (typically Network Level Authentication) cannot complete a handshake — usually because submitted credentials were rejected before a session was fully negotiated. Logs the client IP address. |
| **140** | RemoteDesktopServices-RdpCoreTS | System | Warning | Logged by the RDP Core Transport Session component. Records that an RDP connection attempt from a specific client IP **failed due to incorrect username or password**. This is the RDP-layer authentication failure record, sitting one level above the raw protocol (TermDD) and one level below the domain security audit (Security log). |
| **4625** | Security | Security | Audit Failure | The Windows Security audit record of a **failed logon attempt**. Captures the target account name, the failure reason, the logon type, and the source IP. Logon Type **10 (RemoteInteractive)** confirms these are RDP logon attempts. Three occurrences of this event for `FINBRIDGE\bwalker` from `10.10.5.44` represent three distinct, failed credential submissions. |
| **4740** | Security | Security | Audit Failure | Records that a **user account was locked out** by the domain Account Lockout Policy. Fires the moment the failed logon count reaches the configured threshold. Captures the locked account name and the caller computer (the machine from which the triggering attempt originated). Once locked, all further logon attempts will fail regardless of whether the correct password is supplied. |
| **131** | RemoteDesktopServices-RdpCoreTS | System | Info | Records that the RDP server **accepted a new inbound TCP connection** from a client. This is the earliest stage of an RDP session — the TCP handshake has completed but authentication has not yet begun. Its presence confirms a fresh connection attempt was made after the lockout period. |
| **4624** | Security | Security | Audit Success | The Windows Security audit record of a **successful logon**. Logon Type **10 (RemoteInteractive)** confirms the session was established via RDP. Its presence here — for the same account and IP, 17 minutes after lockout — confirms the account was unlocked and the correct credentials were subsequently used. |

---

## 2. Sequence of Events — Plain English Reconstruction

| Time | Event(s) | What Happened |
|------|----------|---------------|
| **14:01:02** | 56, 140 | User `bwalker` initiated an RDP connection from `10.10.5.44`. The credentials submitted were rejected during Network Level Authentication. The RDP security layer (TermDD) forcibly disconnected the client and RdpCoreTS logged the credential failure. |
| **14:01:04** | 4625 (×1) | The domain security audit recorded the **1st failed logon** for `FINBRIDGE\bwalker` — incorrect username or password, Logon Type 10 (RDP). Failed logon counter: **1 of 3**. |
| **14:03:18** | 4625 (×2) | ~2 minutes 14 seconds later, `bwalker` tried again from the same IP. Credentials rejected again. Failed logon counter: **2 of 3**. |
| **14:05:33** | 4625 (×3) | ~2 minutes 15 seconds later, a **3rd attempt**, same result. Failed logon counter: **3 of 3** — the Account Lockout Policy threshold has been reached. |
| **14:05:34** | 4740 | **One second later**, the Account Lockout Policy triggered and `FINBRIDGE\bwalker` was **locked out**. All further logon attempts — even with the correct password — will now fail until the account is manually unlocked or the observation window expires. |
| **14:22:07** | 131 | Approximately **17 minutes after lockout**, the RDP server accepted a new TCP connection from `10.10.5.44`. The account has been unlocked (either by an administrator or by the auto-unlock timer expiring). |
| **14:22:09** | 4624 | **Two seconds later**, the logon succeeded. `FINBRIDGE\bwalker` authenticated successfully via RDP (Logon Type 10). Session established. |

---

## 3. Most Likely Cause — Analysis with Evidence

### Conclusion
The user `bwalker` was **attempting to log on with a password that no longer matched their Active Directory account** — most likely because their password had recently changed (password expiry rotation, forced reset by IT, or a user-initiated change from another device) and their RDP client was using **saved or cached credentials** that had not been updated.

### Supporting Evidence

| Evidence | Interpretation |
|----------|----------------|
| Three failed logons spaced ~2 minutes apart (Event 4625 ×3) | The attempts are deliberate, manual retries — not an automated brute-force attack. The spacing indicates a real user typing credentials and retrying. They are consistently wrong, suggesting the user genuinely believes they are entering the correct password. |
| Failure reason: "Unknown username or bad password" (Events 140, 4625) | The username is recognised (4740 correctly identifies `FINBRIDGE\bwalker`), so the account exists. The failure is therefore specifically a **wrong password**, not a mistyped username or a disabled account. |
| Lockout triggered after exactly 3 attempts (Event 4740 at 14:05:34) | The Account Lockout Threshold is configured at **3 invalid attempts**. The lockout fired one second after the 3rd failure — no grace period. |
| Caller computer is the same IP (10.10.5.44) throughout | All failures and the eventual success come from the same machine. This is a single legitimate user struggling with credentials, not an attacker pivoting. |
| Successful logon 17 minutes later from the same IP (Events 131, 4624) | The same user connected successfully with the same account after the lockout cleared. They did not change device or account — they either had the account unlocked by helpdesk and retrieved/reset their password, or the correct password was found (e.g., in a password manager). This confirms the prior failures were credential-related, not a network or RDP configuration fault. |

### Alternative Causes Considered and Dismissed

| Alternative | Reason Dismissed |
|-------------|-----------------|
| Brute-force / credential-stuffing attack | Attempts are spaced ~2 min apart — automated attacks fire at machine speed. Single source IP matches the user's known workstation. Successful login by the same account after unlocking confirms legitimate user. |
| RDP service or network fault | Event 140 explicitly records "user name or password is not correct" — not a transport failure. A network fault would produce Event 56 without a corresponding 4625 in the Security log. The eventual successful connection from the same IP on the same day eliminates a persistent network fault. |
| Account disabled or not permitted to RDP | A disabled account would produce Failure Reason "Account currently disabled" in Event 4625, not "Unknown username or bad password." A missing RDP permission would produce a different logon failure code. |

---

## 4. Five Why (5-Why) Root Cause Analysis

**Problem Statement:** `FINBRIDGE\bwalker` was unable to establish an RDP session and was locked out of their account for approximately 17 minutes on 2024-03-15, disrupting remote access to the system.

---

### Why 1 — Why was bwalker unable to connect via RDP?
**Answer:** Authentication failed on three consecutive attempts (Event ID 4625 ×3, Logon Type 10), which triggered the Account Lockout Policy and locked the account (Event ID 4740). Once locked, no further connections were possible regardless of credentials.

---

### Why 2 — Why did authentication fail three times?
**Answer:** The password submitted during each RDP attempt did not match the password currently stored in Active Directory for `FINBRIDGE\bwalker`. Event ID 140 and the 4625 failure reason "Unknown username or bad password" confirm the credentials were incorrect on every attempt. The username itself was valid, isolating the fault to the password.

---

### Why 3 — Why was bwalker submitting an incorrect password?
**Answer:** The user was using a password that had become **stale** — it was previously correct but no longer matched the AD account. The most probable mechanism is that the RDP client on `10.10.5.44` had **saved credentials** stored from a previous successful session. When the account password changed (via forced expiry rotation, an admin reset, or a user-initiated change on a different device or session), the saved credentials in the RDP client were not updated and continued to submit the old password automatically.

---

### Why 4 — Why were the saved RDP credentials not updated when the password changed?
**Answer:** Windows Credential Manager and the built-in RDP client store credentials independently of Active Directory. When an AD password changes, **there is no automatic synchronisation** between the new password and any saved RDP credentials on client machines. Unless the user manually updates or deletes the saved credential entry, the RDP client will silently submit the old password on every connection attempt, failing without an obvious prompt that the stored value is wrong.

---

### Why 5 — Why was there no mechanism to prevent the stale credential from triggering a lockout?
**Answer:** Two process gaps allowed this to reach the point of lockout:
1. **No proactive user notification**: There is no automated reminder or desktop alert informing `bwalker` that their password had changed and that saved RDP credentials needed to be updated. Users are expected to manage this manually.
2. **Low lockout threshold with no smart lockout tolerance**: The Account Lockout Policy is set to lock after **3 failed attempts**, with no distinction between a trusted internal IP submitting stale cached credentials and a genuine external brute-force attempt. A single session of automatic credential retry from a saved but stale RDP entry is sufficient to trigger lockout, with no grace mechanism for known internal client IPs.

---

## 5. Root Cause Statement

> `FINBRIDGE\bwalker` was locked out of their RDP session because the RDP client on their workstation (`10.10.5.44`) was submitting **saved credentials that had become stale** following a password change in Active Directory. The password change was not reflected in the Windows Credential Manager saved entry on the client, causing three automatic or manual submission of the old password in rapid succession. This triggered the Account Lockout Policy (threshold: 3 attempts), blocking access for approximately 17 minutes until the account was unlocked and the user authenticated successfully with updated credentials. The incident was enabled by the absence of a proactive credential-update notification mechanism and a lockout policy with no tolerance for trusted internal sources submitting stale cached credentials.

---

## 6. Immediate Actions (Fix)

| Priority | Action | Owner |
|----------|--------|-------|
| P1 — Immediate | Unlock `FINBRIDGE\bwalker` in Active Directory Users and Computers (ADUC) or via `Unlock-ADAccount -Identity bwalker`. *(Completed — user connected successfully at 14:22:09.)* | Helpdesk / AD Admin |
| P1 — Immediate | Instruct the user to open **Windows Credential Manager** → Windows Credentials → locate the saved RDP entry for the target host → **Edit or Remove** the entry so the correct password is used on next connection. | Analyst / User |
| P2 — Short term | Verify whether the password change that caused the stale credential was an expected expiry rotation or an unplanned admin reset. If the latter, confirm with the user that the reset was intended and that they know their current password. | AD Admin |

---

## 7. Long-Term Preventative Actions

| Action | Rationale |
|--------|-----------|
| Deploy a **password expiry notification** via a login script, Entra ID (Azure AD) notification, or third-party tool (e.g., Netwrix, ManageEngine) that alerts users 14 and 7 days before their password expires and instructs them to update saved credentials. | Eliminates the "surprise stale credential" scenario by giving users advance notice to refresh all saved passwords proactively. |
| Create a helpdesk self-service knowledge base article: "How to update saved RDP credentials in Windows Credential Manager after a password change." | Reduces repeat helpdesk calls and empowers users to resolve the issue themselves before lockout occurs. |
| Review the **Account Lockout Policy** threshold. Consider raising from 3 to 5–10 attempts, or implementing **Microsoft Entra Smart Lockout** (for hybrid environments) which distinguishes known good IPs from unfamiliar sources. | Reduces the frequency of lockouts caused by a single session of stale-credential retries from a trusted internal workstation, while maintaining protection against external brute-force attacks. |
| Implement **Azure AD / Entra ID Conditional Access** or an on-premises equivalent to flag anomalous lockout patterns (multiple lockouts for the same account within a short window) and route them to the security team. | Distinguishes legitimate user credential issues from credential-stuffing attacks that present similarly in the logs. |
| Include "clear saved RDP credentials" as a step in the standard IT **password reset procedure** communicated to users. | Ensures the stale-credential vector is closed at the point of every admin-initiated password reset. |

---

## 8. Evidence Summary

| Item | Value |
|------|-------|
| Affected Account | FINBRIDGE\bwalker |
| Client Source IP | 10.10.5.44 |
| Failed Logon Count | 3 |
| Logon Type | 10 — RemoteInteractive (RDP) |
| Lockout Time | 2024-03-15 14:05:34 |
| Lockout Duration | ~17 minutes |
| Account Unlocked / Session Recovered | 2024-03-15 14:22:09 |
| Lockout Threshold (inferred) | 3 invalid attempts |
| Root Failure Reason | Stale saved RDP credentials — password changed in AD but not updated in Credential Manager |
| Attack Assessment | No evidence of malicious activity — single trusted internal IP, manual retry cadence, same account recovered post-unlock |

---

*Document prepared by DWP Analyst | 2026-08-06*
