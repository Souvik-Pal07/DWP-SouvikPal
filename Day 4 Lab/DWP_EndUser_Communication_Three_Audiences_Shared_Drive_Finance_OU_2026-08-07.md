# DWP Incident Communication Pack - Shared Drive Access Failure (Finance OU)

Date: 2026-08-07  
Incident Status: Resolved at 09:09 AM

## Audience 1 - Non-Technical Executive
Your access and data are safe. After an overnight change, about 45 Finance users on Finance computers did not get drive S because the new sign-in step ran as the computer, could not reach the Finance shared folder, failed once, and had no retry, while other sign-in policy steps worked. We changed it to run in user sign-in, added checks and retry, redeployed, and confirmed recovery at 09:09 AM. No action unless it returns; contact Service Desk.

## Audience 2 - Affected End-User Team (10 people, non-technical)
Hi team, after the overnight change, about 45 Finance users on Finance computers did not get drive S because the new sign-in step ran as the computer, could not reach the Finance shared folder, failed once, and had no retry, while other sign-in policy steps worked. We changed mapping to run in user sign-in, added checks and retry, redeployed, and confirmed recovery at 09:09 AM with successful login and no issues reported. If this returns, contact Service Desk.

## Audience 3 - Engineer-to-Engineer Internal Note
Scope/facts:
- Impacted population: All Finance users (~45) on OU=Finance devices (DESKTOP-FB*), post overnight migration.
- Symptom: Shared drive mapping failure; S: not assigned.
- Parallel signal: Group Policy processing succeeded.

Root cause:
- Migration moved mapping from GPO logon script (USER context) to Intune PowerShell script (SYSTEM context).
- Script execution in SYSTEM context could not access \\finbridge-fs01\Finance at sign-in, failed once, and had no retry path.

Evidence set used:
- 08:00:01 ScriptRunner Info: Executing Map-FinBridgeDrives.ps1.
- 08:00:02 ScriptRunner Info: Script context SYSTEM account.
- 08:00:03 ScriptRunner Warning: \\finbridge-fs01\Finance not accessible from SYSTEM context at execution time.
- 08:00:03 ScriptRunner Error: Exit code 1, Network name cannot be found.
- 08:00:04 ScriptRunner Info: No retry configured.
- 08:00:06 GroupPolicy Event 1500: GP processed successfully.
- 08:00:07 Ntfs Event 98: Drive letter S: not assigned.

Exact action taken:
- Changed mapping execution to USER sign-in context.
- Added execution-time checks and retry logic.
- Redeployed corrected mapping configuration/script to Finance scope.
- Triggered refresh/sync and re-execution on affected devices.

Verification:
- Technical: Corrected mapping behavior observed and S: assignment restored.
- User: Login to host verified and no issues reported.
- Incident closure time: 09:09 AM.

Preventive action needed:
- Enforce migration gate for USER vs SYSTEM compatibility before cutover.
- Require retry plus dependency checks for sign-in-time mappings.
- Keep post-change smoke tests mandatory: context check, share reachability, drive assignment, relogin persistence.
