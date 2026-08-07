Symptom : User FINBRIDGE\cthompson could not sign in to the host from about 08:40. Login attempts returned bad-password and locked-account outcomes during the incident window.

Cause : The verified root cause was repeated invalid credential submissions for FINBRIDGE\cthompson that triggered temporary account lockout. A contributing factor was continued wrong-password Kerberos pre-auth attempts from a second source (10.10.8.112).

Scope : This incident affected one user only: FINBRIDGE\cthompson. Observed systems/sources in evidence were DESKTOP-FB022 and source IP 10.10.8.112.

Workaround : Stop repeated sign-in retries, then correct account state and perform a controlled sign-in validation. In this incident, the account was enabled at 09:08 and successful interactive sign-in was confirmed at 09:09 from DESKTOP-FB022.

Permanent fix: Remediate stale saved sign-in details that were driving repeated bad credentials, including the secondary credential source, and keep lockout triage in place to clear all saved credential sources quickly. Incident resolution completed with successful sign-in verification and no further issues reported.

How to spot it: Look for Security Event 4776 with error 0xC000006A (wrong password), repeated Security Event 4625 failures including "Unknown user name or bad password" and "Account locked out," Security Event 4740 (account locked out), and Security Event 4771 with failure code 0x18 (wrong password). Recovery confirmation signals are Security Event 4722 (account enabled) followed by Security Event 4624 (successful interactive logon).
