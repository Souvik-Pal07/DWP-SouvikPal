# DWP End-User Communication Pack - User Login Incident (Three Audiences)

Date: 2026-08-07
Source: Incident analysis and RCA for FINBRIDGE\\cthompson

## Audience 1 - Non-technical executive
Your access and data are safe. Today, one user (cthompson) could not sign in from about 08:40. Repeated incorrect sign-in attempts, including from a second saved sign-in source, caused a temporary account lock. We stopped the repeat attempts, re-enabled the account at 09:08, and refreshed saved sign-in details. Sign-in succeeded at 09:09 from the usual work computer, and no further issues were reported. You do not need to do anything.

## Audience 2 - Affected end-user team (non-technical)
This morning, one teammate (cthompson) could not sign in from about 08:40 because repeated wrong-password attempts, including from another saved sign-in source, temporarily locked the account. We stopped the repeat attempts, re-enabled the account at 09:08, refreshed saved sign-in details, and confirmed successful sign-in at 09:09 from the usual work computer, with no further issues reported. If you see the same issue, stop retrying and contact the DWP Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Incident facts (kept aligned with user comms):
- Affected principal: FINBRIDGE\\cthompson only.
- Symptom start: ~08:40, unable to sign in.
- Root cause: repeated invalid credential submissions (including a second saved sign-in source) triggered temporary account lockout.
- Action taken: contained repeated attempts, account re-enabled at 09:08, stale saved sign-in details remediated.
- Config/detail context: normal successful sign-in path is user session on DESKTOP-FB022; secondary saved credential source contributed to retries.
- Verification: successful sign-in at 09:09 from DESKTOP-FB022; user confirmed no remaining issues.
- Preventive action needed: enforce lockout triage runbook to identify and clear all saved credential sources quickly, and instruct users to stop repeated retries and call Service Desk on first lockout symptoms.
