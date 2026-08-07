# DWP Incident Communication Pack - Finance OU Group Policy Failure

Date: 2026-08-07  
Incident Status: Resolved at 09:09 AM

## Audience 1 - Non-Technical Executive
Your access and data are safe. Earlier today, 3 of 4 Finance computers received an outdated network address source after the migration, so startup sign-in setup did not complete on those devices. We corrected the central network settings, refreshed the affected computers, and confirmed recovery at 09:09 AM with a successful user sign-in and no further issues reported. No action is needed unless this reappears; if it does, contact Service Desk.

## Audience 2 - Affected End-User Team (10 people, non-technical)
Hi team, today 3 of 4 Finance computers got an outdated network address source after the migration, which stopped startup sign-in setup from completing on those devices. We fixed the central network settings, refreshed the affected computers, and confirmed recovery at 09:09 AM with successful user login and no further issues reported. If you see the same issue, restart once and contact Service Desk immediately, and mention "Finance startup sign-in issue after migration" for faster routing.

## Audience 3 - Engineer-to-Engineer Internal Note
Summary:
- Scope: 3 of 4 Finance OU endpoints affected during startup window.
- Resolved: 09:09 AM.
- Validation: User login verified on host post-fix; no issues reported.

Root cause:
- DHCP scope Option 006 on affected Floor 3/Finance subnet delivered stale DNS (10.10.3.250, decommissioned) after migration, instead of current DNS (10.10.0.10).
- Result: DC FQDN resolution failure, Netlogon secure channel failure, SYSVOL path access failure, and downstream GP processing failures.

Supporting evidence:
- Affected host timeline:
  - 7036 (07:40:02): NLA running.
  - 5719 (07:40:08): Netlogon secure channel failed; no DC available; DNS query no response.
  - 1058 (07:40:09, 07:40:11): SYSVOL gpt.ini read failure (0x3).
  - 1030 (07:40:10): GPO list query failure (0x546).
  - 1129 (07:40:12, 07:44:01): GP failed due to no DC connectivity.
  - 1014 (07:41:05): DNS timeout for FINBRIDGE-DC01.finbridge.local.
  - 50036 (07:42:18): DHCP lease assigned old DNS 10.10.3.250.
- Control host FB029 (same OU, unaffected):
  - 50036 assigned correct DNS 10.10.0.10.
  - 1500 (07:40:11): GP processed successfully.
- DHCP comparison corroboration: affected devices got decommissioned local DNS; manually preconfigured host with central DNS remained unaffected.

Exact action taken:
1. Updated DHCP scope Option 006 to current DNS (10.10.0.10 and approved set) for affected subnet(s).
2. Removed decommissioned DNS entries from scope.
3. Forced client lease refresh on affected endpoints.
4. Cleared DNS resolver cache and re-triggered domain discovery/policy processing.
5. Ran GP refresh and validated success/no repeat 1058/1030/1129 pattern.
6. Performed user validation login; confirmed normal operation at 09:09 AM.

Verification performed:
- Technical: Correct DNS assignment present on corrected clients; DC name resolution and policy processing succeeded.
- Functional: User login to host succeeded; no further issues reported.

Preventive action required:
1. Add migration hard gate: DHCP DNS scope validation must complete before DNS decommission.
2. Audit all active scopes for stale/decommissioned DNS entries (especially Option 006).
3. Standardize post-change smoke tests per subnet: lease, DC FQDN lookup, SYSVOL access, GP update.
4. Track manual DNS overrides so pilot/control hosts do not mask scope-level defects.
5. Update service desk runbook with event-correlation pattern (5719/1014/1058/1030/1129 + 50036).
