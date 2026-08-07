# DWP Known-Error Record - Shared Drive Access Failure (Finance OU)

Symptom: Finance users on affected OU=Finance devices cannot access mapped shared drives because drive letter S: is not assigned during sign-in. Users experience missing Finance share mapping.

Cause: The verified root cause is a context mismatch introduced by migration: drive mapping changed from GPO USER-context script to Intune SYSTEM-context script, and the script was not updated for SYSTEM-context behavior. At execution time, `\\finbridge-fs01\Finance` was not accessible from SYSTEM context, the script failed with exit code 1 ("Network name cannot be found"), and no retry was configured.

Scope: All Finance users (approximately 45) on OU=Finance devices (DESKTOP-FB*) were affected after the overnight migration. The issue was not limited to a single endpoint.

Workaround: Restore service immediately by running drive mapping in USER sign-in context and re-executing mapping on affected devices. Refresh/sync affected clients and perform a user sign-out/sign-in so S: can be assigned.

Permanent fix: Keep the mapping solution deployed in USER context for Finance sign-in sessions, with dependency checks and retry logic in the script. Maintain the corrected Intune deployment/configuration to Finance scope so first-attempt path inaccessibility does not leave S: unassigned.

How to spot it: Identify this pattern in logs: ScriptRunner shows `Map-FinBridgeDrives.ps1` executing in SYSTEM context, warning that `\\finbridge-fs01\Finance` is not accessible, then error exit code 1 with "Network name cannot be found," followed by "No retry configured." In System logs, GroupPolicy Event 1500 is successful while Ntfs Event 98 reports drive letter S: not assigned.
