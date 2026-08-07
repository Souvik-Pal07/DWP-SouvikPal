# DWP Ranked Cause Analysis - User Login Failure (cthompson)

Date: 2026-08-07  
Analyst: DWP Engineer  
Status: Hypothesis only (no single cause confirmed)

## Scope Facts Used
- Symptom: User `cthompson` not able to login
- Impact: Single user only
- Since: ~08:40 this morning
- Change: Nil reported

## Ranked Likely Causes (Most Probable First)

### 1) Account lockout from repeated bad authentication attempts
Why this fits scope facts:
- A lockout can start suddenly at a specific time (~08:40).
- It commonly affects only one user.
- It does not require a declared change by the user.

Fastest single check:
- Check AD/Azure AD sign-in and lockout events for `cthompson` around 08:40 to confirm lockout state and reason (bad password attempts vs policy trigger).

### 2) Password expired or forced password reset requirement
Why this fits scope facts:
- Password expiry/forced reset can begin abruptly at first login after threshold is reached.
- It is user-specific and consistent with one-user impact.
- Users often report this as "cannot login" with no perceived change.

Fastest single check:
- Query the account password status (expired / must-change-at-next-logon) in identity admin console for `cthompson`.

### 3) Conditional Access / MFA challenge failure for this user session
Why this fits scope facts:
- MFA device/app issues can block only one user while others continue normally.
- Failure can start at a specific time due to token expiry or mobile app/authenticator issue.
- No endpoint change is required for this to occur.

Fastest single check:
- Review the latest sign-in log result for `cthompson` and inspect the explicit failure reason (MFA denied, MFA timeout, CA block).

### 4) Account disabled/restricted or sign-in blocked at identity layer
Why this fits scope facts:
- A single-user login failure strongly matches user-object state issues.
- Can appear suddenly if automated risk controls or admin action occurred (even if not known to reporter).
- No local machine change is necessary.

Fastest single check:
- Verify `cthompson` account enabled/sign-in-allowed status in AD/Azure AD user properties.

### 5) Wrong credential entry context (cached old password, keyboard layout, username format)
Why this fits scope facts:
- User-only impact is consistent with credential entry/cached credential mismatch.
- Sudden onset can occur after recent password change elsewhere or login screen context change.
- Reported "no change" does not rule out unnoticed input-context issues.

Fastest single check:
- Have user perform one controlled login attempt using known-good username format and password on a second endpoint (or web sign-in page) while observing exact error text.

## Notes
- Ranking is based strictly on scope facts and typical enterprise login-failure patterns.
- No single cause is concluded yet; checks above are intended to quickly confirm/eliminate each hypothesis.

## Evidence Assessment Against Each Hypothesis (Incident Window 08:44-09:12)

### 1) Account lockout from repeated bad authentication attempts
Judgement: **Supports**

Why:
- Repeated bad-password failures are recorded immediately before lockout.
- The lockout event is explicitly present for the affected account.

Determining evidence:
- **Event 4776 at 08:44:01**: `0xC000006A` (wrong password).
- **Event 4625 at 08:44:03, 08:44:28, 08:44:55**: unknown user name or bad password.
- **Event 4740 at 08:44:56**: account locked out.
- **Event 4625 at 08:45:10**: failure reason account locked out.

### 2) Password expired or forced password reset requirement
Judgement: **Contradicts**

Why:
- Logged failures indicate wrong password and subsequent lockout, not password-expired or must-change flow.

Determining evidence:
- **Event 4776 at 08:44:01**: `0xC000006A` (wrong password).
- **Event 4625 at 08:44:03, 08:44:28, 08:44:55**: bad password pattern before lockout.
- **Event 4740 at 08:44:56**: lockout follows repeated bad credentials.

### 3) Conditional Access / MFA challenge failure for this user session
Judgement: **Contradicts**

Why:
- The recorded failures in this window are credential failures and lockout, not MFA/CA denial indicators.

Determining evidence:
- **Event 4776 at 08:44:01**: wrong password.
- **Event 4625 at 08:45:10**: account locked out after prior bad-password attempts.
- **Event 4771 at 08:45:44, 08:46:01, 08:46:33**: Kerberos pre-auth failed with `0x18` (wrong password).

### 4) Account disabled/restricted or sign-in blocked at identity layer
Judgement: **Contradicts**

Why:
- Evidence shows an active account receiving authentication attempts, failing on wrong password, then being locked by policy. This does not match a pre-existing disabled/sign-in-blocked state as the primary issue in-window.

Determining evidence:
- **Event 4776 at 08:44:01**: credential validation attempt returns wrong password.
- **Event 4740 at 08:44:56**: account transitions into locked-out state after failures.

### 5) Wrong credential entry context (cached old password, keyboard layout, username format)
Judgement: **Supports**

Why:
- Multiple wrong-password events are recorded for the same user.
- Additional wrong-password Kerberos attempts originate from a different source IP, consistent with stale/incorrect credentials being retried from another endpoint or service.

Determining evidence:
- **Event 4776 at 08:44:01**: wrong password from `DESKTOP-FB022`.
- **Event 4625 at 08:44:03, 08:44:28, 08:44:55**: repeated interactive bad-password failures on `DESKTOP-FB022`.
- **Event 4771 at 08:45:44, 08:46:01, 08:46:33**: wrong-password Kerberos pre-auth from source IP `10.10.8.112` (different from `DESKTOP-FB022`).

## Interim Position
- Evidence has been applied against all ranked hypotheses.
- No single winner selected yet, per instruction.

## Final Surviving Hypothesis After Elimination

**Surviving hypothesis:** Wrong credential usage pattern leading to account lockout (user/device/service submitting incorrect or stale password repeatedly).

Why this is the survivor:
- Multiple bad-password events are present before lockout.
- Explicit lockout event is present.
- Additional wrong-password attempts continue from a second source IP after lockout, indicating another credential source may still be retrying stale credentials.

Primary supporting events:
- Event 4776 at 08:44:01 (`0xC000006A`, wrong password) from `DESKTOP-FB022`.
- Event 4625 at 08:44:03, 08:44:28, 08:44:55 (interactive bad password) from `DESKTOP-FB022`.
- Event 4740 at 08:44:56 (account locked out).
- Event 4625 at 08:45:10 (failure reason: account locked out).
- Event 4771 at 08:45:44, 08:46:01, 08:46:33 (`0x18`, wrong password) from `10.10.8.112`.

## Detailed Resolution Steps

1. Contain the lockout loop first
- Temporarily stop active sign-in retries from known endpoints.
- Ask user to stop attempts on `DESKTOP-FB022` until remediation is complete.
- Identify host at `10.10.8.112` and pause any active session/task using `cthompson` credentials.

2. Unlock account and force a controlled password reset
- Unlock `cthompson` in AD/Azure AD.
- Reset password to a temporary strong value.
- Enforce change at next sign-in if policy requires.

3. Perform one clean validation sign-in
- From a known-good endpoint, sign in once with the temporary password.
- Confirm success event (for example successful logon/sign-in event) and absence of immediate new 4625/4771 failures.

4. Remove stale credentials on user workstation (`DESKTOP-FB022`)
- Open Credential Manager and remove saved entries for domain, M365, Teams, Outlook, OneDrive, VPN, mapped drives, and legacy Windows Credentials tied to old password.
- Sign out of Office apps/Teams, then sign back in with new password.

5. Hunt and clear secondary credential source (`10.10.8.112`)
- Resolve IP to hostname and owner.
- Check for persisted credentials in:
	- Windows Credential Manager
	- Services running as `cthompson`
	- Scheduled tasks using `cthompson`
	- Mapped drives or scripts storing old credentials
	- Mobile mail profile or legacy device still using old password
- Update credentials or disable offending task/service until corrected.

6. Confirm lockout no longer reoccurs
- Monitor security logs for 30-60 minutes:
	- No new 4740 lockout events for `cthompson`
	- No new 4771 (`0x18`) or 4776 (`0xC000006A`) failures
- Require at least one successful user logon and normal app access.

7. User-facing recovery actions
- Instruct user to reboot once after credential cleanup.
- Re-authenticate Teams, Outlook, OneDrive, VPN, and mapped drives using updated password.

8. Closeout evidence to record
- Record exact unlock/reset time.
- Record identity of secondary source previously at `10.10.8.112` and remediation applied.
- Record post-fix verification events and user confirmation timestamp.

## Backout / Escalation Criteria
- If lockout returns after cleanup, escalate to IAM/AD engineering with:
	- Timeline of 4625/4771/4740 events
	- Source host mapping for `10.10.8.112`
	- List of cleared credential stores and tasks
	- Any non-interactive service accounts or legacy app dependencies discovered
