# DWP Known-Error Record - Finance OU Group Policy Failure

Symptom: On affected Finance OU machines, startup sign-in setup and Group Policy processing failed, and users could not complete normal startup/login policy processing on those hosts. The issue presented during the incident window and was confirmed on 3 of 4 machines.

Cause: The verified root cause was DHCP scope Option 006 on the affected Floor 3/Finance subnet still assigning decommissioned DNS entries (including 10.10.3.250) after migration. This caused domain controller name-resolution failure, which then caused SYSVOL access and Group Policy processing failures.

Scope: Affected systems were 3 of 4 Finance OU endpoints on the impacted subnet segment. One comparison host in the same OU (FB029) was unaffected because it had correct DNS (10.10.0.10), and user impact was limited to affected-host users.

Workaround: Restore service by correcting DHCP Option 006 to current DNS, then renew client leases so affected hosts receive corrected DNS. Flush DNS cache and force Group Policy update to re-establish policy processing.

Permanent fix: Implement and keep the corrected DHCP DNS scope configuration on affected subnet(s), removing all decommissioned DNS entries. Enforce migration control so DHCP DNS validation is completed before DNS decommission and audit scopes for stale DNS references.

How to spot it: Look for this event pattern on affected clients: Netlogon 5719 (no DC available), DNS Client 1014 (FINBRIDGE-DC01.finbridge.local resolution timeout), GroupPolicy 1058 and 1030 (SYSVOL/GPO query failures), and GroupPolicy 1129 (no DC connectivity), along with DHCP Client 50036 showing old DNS assignment. Confirm contrast with healthy host behavior such as GroupPolicy 1500 success when correct DNS is assigned.
