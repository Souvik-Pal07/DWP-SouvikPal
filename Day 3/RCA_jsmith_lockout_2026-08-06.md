# RCA: User Lockout Incident - jsmith

## Incident Summary
- **Incident Type:** User account lockout
- **User:** `jsmith`
- **Review Window:** 30 minutes (08:02:14 to 08:23:44)
- **Primary Endpoint:** `DESKTOP-FB001`
- **Business Impact:** User unable to sign in/unlock workstation until service desk intervention
- **Current Status:** Resolved after account re-enabled and successful interactive logon

## Event ID Explanation

### Event ID 4625 - Failed Logon (Audit Failure)
Records a failed authentication attempt.
- In this incident it appears in two forms:
  - **Bad password/credential mismatch** ("Unknown username or bad password")
  - **Attempt while account already locked** ("Account locked out")
- Includes source host and logon type, which helps identify where/how failures occurred.

### Event ID 4740 - Account Locked Out
Records that an account has been locked due to lockout policy (typically failed-attempt threshold reached).
- "Called from" indicates the host that triggered lockout (`DESKTOP-FB001`).

### Event ID 4722 - Account Enabled (Audit Success)
Records that an administrator enabled a user account.
- Here it was performed by `FINBRIDGE\helpdesk-admin`.

### Event ID 4624 - Successful Logon (Audit Success)
Records successful authentication.
- `Logon Type 2` indicates successful interactive/console sign-in.

## Evidence Table

| Time     | Event ID | Result        | Account | Source/Actor                | Logon Type | Key Detail |
|----------|----------|---------------|---------|-----------------------------|------------|------------|
| 08:02:14 | 4625     | Audit Failure | jsmith  | DESKTOP-FB001              | 2          | Unknown username or bad password |
| 08:04:22 | 4625     | Audit Failure | jsmith  | DESKTOP-FB001              | 2          | Unknown username or bad password |
| 08:06:01 | 4740     | Lockout       | jsmith  | Called from DESKTOP-FB001  | N/A        | Account locked out |
| 08:07:45 | 4625     | Audit Failure | jsmith  | DESKTOP-FB001              | 7          | Account locked out (unlock attempt) |
| 08:22:10 | 4722     | Audit Success | jsmith  | FINBRIDGE\helpdesk-admin   | N/A        | Account enabled |
| 08:23:44 | 4624     | Audit Success | jsmith  | DESKTOP-FB001              | 2          | Successful logon |

## Reconstructed Sequence (Plain English)
1. At **08:02:14**, `jsmith` attempted to log in locally on `DESKTOP-FB001` and entered incorrect credentials.
2. At **08:04:22**, a second local interactive attempt also failed due to bad credentials.
3. At **08:06:01**, account lockout policy was triggered, and `jsmith` was locked out. The lockout was generated from `DESKTOP-FB001`.
4. At **08:07:45**, an unlock attempt was made but failed because the account was already locked.
5. At **08:22:10**, service desk/admin (`FINBRIDGE\helpdesk-admin`) enabled the account.
6. At **08:23:44**, `jsmith` successfully logged in interactively.

## Most Likely Cause of Lockout
**Repeated incorrect password entry on the user’s own endpoint (`DESKTOP-FB001`) caused the account to hit lockout threshold.**

### Supporting Evidence
- Two consecutive **4625** failures with reason **"Unknown username or bad password"** (08:02:14 and 08:04:22).
- Immediate **4740** lockout event afterward (08:06:01), explicitly **called from DESKTOP-FB001**.
- Post-lockout **4625** with reason **"Account locked out"** during an unlock attempt (08:07:45), confirming the account state.
- Recovery sequence: **4722** admin enable followed by **4624** successful logon.

## Root Cause Statement
The lockout occurred because multiple failed interactive sign-in attempts from `DESKTOP-FB001` exceeded configured account lockout threshold for user `jsmith`.

## 5 Whys Analysis
1. **Why was `jsmith` locked out?**
   - Because account lockout policy was triggered after repeated failed authentication attempts.
2. **Why were there repeated failed attempts?**
   - The credentials entered during interactive logon were invalid (bad password).
3. **Why was an invalid password used multiple times?**
   - User likely retried the same incorrect/stale password before verifying/resetting credentials.
4. **Why did retries continue until lockout?**
   - No immediate interruption/escalation after initial failures; user continued manual attempts.
5. **Why did incident duration extend to ~21 minutes after lockout?**
   - Account recovery required service desk intervention to re-enable account (administrative dependency).

## Contributing Factors
- User-side credential entry errors.
- Lockout threshold reached quickly.
- Manual recovery path (helpdesk action) increased meantime-to-recovery.

## Corrective Actions (Immediate)
- Reinforce user guidance: after 1-2 failures, stop retries and verify password/reset path.
- Update helpdesk runbook with rapid lockout triage steps (confirm source host, logon type, and failure reasons).
- Ensure support coverage for fast unlock/enable response during business hours.

## Preventive Actions (Medium Term)
- Add SIEM alert rule:
  - Trigger when same user has >=2 Event 4625 from same host within 5 minutes.
- Review lockout policy and user messaging balance (security vs usability).
- Improve self-service password reset/unlock adoption to reduce dependency on manual admin action.
- Monitor endpoints generating clustered 4625 events for proactive outreach.

## Validation of Resolution
- Administrative remediation event recorded: **4722** at 08:22:10.
- Successful user authentication recorded: **4624** at 08:23:44.
- No further failures provided in reviewed window after successful sign-in.

## Final Incident Disposition
- **Classification:** Credential-related account lockout
- **Primary Trigger:** Repeated bad password attempts from local interactive session
- **Resolved By:** Helpdesk-admin account enable + successful user sign-in
- **RCA Complete:** Yes
