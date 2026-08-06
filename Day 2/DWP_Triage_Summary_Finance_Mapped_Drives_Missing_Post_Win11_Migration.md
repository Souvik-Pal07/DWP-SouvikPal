Summary
After Win11 migration, a Finance user reports mapped drives S: and P: are missing each morning and must be remapped manually. A logon script exists but appears not to run reliably post-upgrade (to confirm).

Impact
User experiences recurring daily loss of access to mapped network drives, causing repeated manual remediation and potential delay to Finance file access/work at start of day.

Known facts
- User is in Finance.
- Issue started after Win11 migration.
- Mapped drives affected: S: and P:.
- Drives are missing every morning.
- User can restore access by remapping manually.
- A logon script exists.
- Logon script reliability post-upgrade is in question (to confirm).

Missing info to gather
- Affected scope: single user vs multiple Finance users (to confirm).
- Device details: hostname, Win11 build/version, and migration date (to confirm).
- Whether issue occurs on every sign-in/reboot or only first logon of day (to confirm).
- How drives are mapped: logon script, Group Policy Preferences, or other method (to confirm).
- Script location/path and execution context (user/computer), plus access permissions (to confirm).
- Evidence of script execution at logon: Event Viewer logs and gpresult output (to confirm).
- Network/VPN state at logon and whether drives reconnect after network is fully up (to confirm).

Likely category
Windows 11 post-migration issue - Drive mapping / Logon script / Group Policy processing (to confirm).

First diagnostic step
On the affected user/device, verify logon script processing at sign-in by collecting gpresult and checking relevant logon/Group Policy events; confirm whether the script is assigned correctly and actually executes during morning logon (to confirm).