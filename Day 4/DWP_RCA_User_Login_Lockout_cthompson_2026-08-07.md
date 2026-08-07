# DWP Root Cause Analysis - User Login Failure (cthompson)

Date: 2026-08-07  
Prepared by: DWP Engineer  
Incident Type: User authentication failure / account lockout  
Status: Resolved

## 1) Executive Summary
At approximately 08:40, user FINBRIDGE\cthompson was unable to log in. Security logs show repeated bad-password attempts, followed by an account lockout. Additional Kerberos bad-password attempts continued from a second source IP, indicating a secondary stale credential source. Remediation steps were applied (contain retry sources, account state correction, credential cleanup, and controlled revalidation). Service was restored at 09:09, with successful interactive logon and no further issues reported.

## 2) Scope and Impact
- Affected user: FINBRIDGE\cthompson
- Affected devices/sources observed:
  - DESKTOP-FB022
  - Source IP 10.10.8.112
- Start time: ~08:40
- End time (verified): 09:09
- Business impact: Single user could not access workstation session during incident window.

## 3) Root Cause Statement
Primary cause:
- Repeated invalid credential submissions for FINBRIDGE\cthompson triggered account lockout.

Contributing cause:
- A secondary source (10.10.8.112) continued to submit wrong credentials (Kerberos pre-auth failures), increasing lockout persistence risk.

## 4) Supporting Evidence
Pre-lockout and lockout evidence:
- 08:44:01 - Security Event 4776 Audit Failure
  - Account: FINBRIDGE\cthompson
  - Error code: 0xC000006A (wrong password)
  - Source workstation: DESKTOP-FB022
- 08:44:03 - Security Event 4625 Audit Failure
  - Failure reason: Unknown user name or bad password
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022
- 08:44:28 - Security Event 4625 Audit Failure
  - Failure reason: Unknown user name or bad password
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022
- 08:44:55 - Security Event 4625 Audit Failure
  - Failure reason: Unknown user name or bad password
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022
- 08:44:56 - Security Event 4740 Audit Failure
  - Message: A user account was locked out
  - Account: FINBRIDGE\cthompson
  - Caller computer: DESKTOP-FB022
- 08:45:10 - Security Event 4625 Audit Failure
  - Failure reason: Account locked out
  - Logon type: 7 (Unlock attempt)
  - Source: DESKTOP-FB022

Secondary source evidence:
- 08:45:44 - Security Event 4771 Audit Failure
  - Kerberos pre-authentication failed
  - Failure code: 0x18 (wrong password)
  - Source IP: 10.10.8.112
- 08:46:01 - Security Event 4771 Audit Failure
  - Failure code: 0x18 (wrong password)
  - Source IP: 10.10.8.112
- 08:46:33 - Security Event 4771 Audit Failure
  - Failure code: 0x18 (wrong password)
  - Source IP: 10.10.8.112

Recovery evidence:
- 09:08:14 - Security Event 4722 Audit Success
  - Message: A user account was enabled
  - Account: FINBRIDGE\cthompson
  - Done by: FINBRIDGE\helpdesk-admin
- 09:09:01 - Security Event 4624 Audit Success
  - Message: An account was successfully logged on
  - Account: FINBRIDGE\cthompson
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022
- User validation:
  - 09:09 - User confirmed login to host successful and no ongoing issues.

## 5) Incident Timeline
- ~08:40: User reports unable to log in.
- 08:44:01: First observed credential validation failure (Event 4776, wrong password).
- 08:44:03-08:44:55: Repeated interactive bad-password attempts (Event 4625).
- 08:44:56: Account lockout recorded (Event 4740).
- 08:45:10: Post-lockout login attempt blocked (Event 4625, account locked out).
- 08:45:44-08:46:33: Continued wrong-password Kerberos pre-auth from second source 10.10.8.112 (Event 4771).
- 09:08:14: Account state corrected/enabled by helpdesk-admin (Event 4722).
- 09:09:01: Successful interactive logon from DESKTOP-FB022 (Event 4624).
- 09:09: Incident functionally resolved; user confirms no issues.

## 6) 5 Whys Analysis
1. Why could cthompson not log in?
- Because the account became locked and authentication attempts were being rejected.

2. Why was the account locked?
- Because multiple bad-password attempts were submitted in a short period from DESKTOP-FB022.

3. Why were bad passwords repeatedly submitted?
- Because one or more credential sources were using incorrect or stale credentials.

4. Why did lockout risk persist after initial failures?
- Because a second source (10.10.8.112) continued Kerberos pre-auth attempts with wrong password.

5. Why was this not prevented earlier?
- There was no immediate automated suppression/alert-driven containment of repeated bad-credential attempts across all credential sources for the user.

## 7) Resolution Actions Performed
- Stopped repeated sign-in attempts during remediation window.
- Corrected account state via helpdesk action (Event 4722 confirms account enabled).
- Applied credential remediation approach to remove stale credential usage patterns.
- Performed controlled login validation on user endpoint.
- Confirmed successful interactive logon (Event 4624 at 09:09:01).
- Obtained user confirmation of restored service and no residual symptoms.

## 8) Preventive Actions
Immediate (0-2 days):
- Identify and remediate the host/service mapped to 10.10.8.112 to remove stale credentials.
- Audit Credential Manager entries, scheduled tasks, and services using user credentials on affected endpoints.
- Add temporary monitoring rule for cthompson for Events 4740, 4771, 4776 to confirm no recurrence.

Short term (this week):
- Implement lockout triage checklist requiring source-IP correlation for every lockout case.
- Standardize post-password-change guidance for users (update VPN, mail, mobile, mapped drive credentials).
- Create helpdesk runbook for rapid lockout containment and structured credential source isolation.

Medium term (this month):
- Enable automated alerting when repeated 4771/4776 failures are detected from multiple sources for one account.
- Review use of user credentials in scheduled tasks/services and migrate to managed service identities where possible.
- Add dashboard view for lockout frequency, top source hosts, and repeat offenders.

## 9) Validation and Closure Criteria
Closure criteria met:
- Account state corrected (Event 4722 at 09:08:14).
- Successful interactive login recorded (Event 4624 at 09:09:01).
- User confirms successful access and no ongoing issue at 09:09.
- No immediate post-fix symptom recurrence reported.

## 10) Residual Risk
- If any unmanaged secondary endpoint still stores old credentials, lockout may recur.
- Continued monitoring and source eradication actions are required to reduce recurrence likelihood.
