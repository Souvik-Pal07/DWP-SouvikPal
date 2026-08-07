# DWP Cause Analysis - Group Policy Failure (Finance OU)

Date: 2026-08-07  
Analyst: DWP Engineer  
Incident Type: Group Policy processing failure at startup  
Affected Scope: 3 of 4 Finance OU machines

## Incident Summary
During startup on affected endpoints, domain controller discovery and SYSVOL access failed before Group Policy processing. The unaffected comparison endpoint in the same OU resolved this successfully because it had the correct DNS server. The strongest evidence indicates an incorrect DNS server assignment from DHCP after migration.

## Event ID Meanings (What Each Event Recorded)

### Event 7036 (Service Control Manager)
- Recorded that a Windows service changed state.
- In this case: Network Location Awareness (NLA) entered Running state.
- Significance: Networking stack initialization had begun; this does not confirm domain connectivity.

### Event 5719 (Netlogon, Error)
- Recorded failure to establish a secure channel to the domain.
- In this case: no domain controller was reachable for FINBRIDGE; DNS lookup for FINBRIDGE-DC01 had no response.
- Significance: Domain authentication path unavailable at that moment.

### Event 1058 (GroupPolicy, Error)
- Recorded failure to read a Group Policy file from SYSVOL.
- In this case: could not access \\FINBRIDGE-DC01\sysvol\finbridge.local\Policies\{GUID}\gpt.ini; error 0x3 (path not found).
- Significance: Client could not reach policy files over domain path, consistent with DC/DNS reachability failure.

### Event 1030 (GroupPolicy, Warning)
- Recorded that the client could not query the list of GPOs.
- In this case: error 0x546.
- Significance: GPO enumeration failed upstream, typically when domain path/DC lookup fails.

### Event 1129 (GroupPolicy, Error)
- Recorded that Group Policy could not be applied because no network connectivity to a domain controller was available.
- Significance: Explicit confirmation from GP engine that DC connectivity was unavailable.

### Event 1014 (DNS Client Events, Warning)
- Recorded DNS resolution timeout.
- In this case: FINBRIDGE-DC01.finbridge.local lookup timed out; configured DNS servers did not respond.
- Significance: Name resolution failure directly explains inability to locate/reach DC and SYSVOL.

### Event 50036 (DHCP Client, Information)
- Recorded lease details received from DHCP, including assigned DNS servers.
- In this case (affected host): DNS assigned as 10.10.3.250 (old/decommissioned DNS).
- Significance: Strong causal indicator. Client was configured with wrong DNS via DHCP.

### Event 1500 (GroupPolicy, Information) - comparison host
- Recorded successful Group Policy processing.
- In this case on unaffected FB029: DNS was 10.10.0.10 (correct new DNS), GP succeeded.
- Significance: Control comparison supports DNS assignment as key differentiator.

## Reconstructed Sequence of Events (Plain English)
1. At startup, NLA entered running state (07:40:02), meaning basic network initialization started.
2. Seconds later, the machine failed to establish Netlogon secure channel because it could not find a domain controller (07:40:08).
3. Group Policy immediately failed to read gpt.ini from SYSVOL (07:40:09 and 07:40:11), then failed to enumerate GPOs (07:40:10).
4. Group Policy logged explicit no-DC-connectivity failure (07:40:12).
5. DNS client then logged timeouts for FINBRIDGE-DC01 name resolution (07:41:05).
6. DHCP lease details showed the endpoint had been assigned DNS 10.10.3.250 (07:42:18), an old DNS server that had been decommissioned.
7. Group Policy retried later and failed again with no DC connectivity (07:44:01).
8. In contrast, FB029 in the same OU got DNS 10.10.0.10 and processed GP successfully at startup.

## Most Likely Cause of Policy Failure
Incorrect DNS server assignment from DHCP scope for the affected subnet/segment after migration.

## Evidence for Most Likely Cause
- Netlogon 5719: no DC available and DNS query for DC returned no response.
- DNS 1014: DC FQDN resolution timed out; configured DNS servers did not respond.
- DHCP 50036 on affected host: assigned old/decommissioned DNS (10.10.3.250).
- Repeated GroupPolicy 1058/1030/1129: consistent downstream failures from inability to locate/reach DC/SYSVOL.
- Control comparison (FB029): correct DNS (10.10.0.10) + Event 1500 success in same OU and same startup window behavior.
- DHCP server comparison note: affected Floor 3 devices received decommissioned local DNS, while manually corrected host received central DNS and was unaffected.

## Technical Conclusion
The Group Policy failures were not caused by a bad GPO object itself. They were connectivity-by-name failures caused by stale DNS settings delivered by DHCP after migration. Without valid DNS, clients could not resolve the domain controller, could not access SYSVOL, and therefore could not process GPOs.

## Recommended Corrective Actions
1. Update DHCP scope option 006 on Floor 3/Finance-related subnets to current DNS (10.10.0.10) and remove decommissioned DNS entries.
2. Force lease renewal on affected clients (`ipconfig /release` then `ipconfig /renew`) and verify DNS assignment.
3. Run `ipconfig /flushdns` and `gpupdate /force` after DNS correction.
4. Validate DC resolution (`nslookup FINBRIDGE-DC01.finbridge.local`) and SYSVOL accessibility.
5. Audit all migration-wave DHCP scopes for stale DNS references to prevent recurrence.

## Confidence
High.
The event chain is coherent and the unaffected comparison host provides a strong control that isolates DNS assignment as the key variable.

## Addendum - Updated Event Details, Surviving Hypothesis, and Resolution

### Updated Event Details (Evidence-Linked Interpretation)
- 07:40:02, Event 7036 (Service Control Manager): Network Location Awareness entered running state. This confirms network initialization began, but not that domain services were reachable.
- 07:40:08, Event 5719 (Netlogon, Error): Secure channel setup to FINBRIDGE failed because no domain controller was available; DNS query for FINBRIDGE-DC01 had no response.
- 07:40:09, Event 1058 (GroupPolicy, Error): Client failed to access gpt.ini under SYSVOL path \\FINBRIDGE-DC01\sysvol\finbridge.local\Policies\{3A1B2C4D-E5F6-7890-ABCD-EF1234567890}\gpt.ini with error 0x3.
- 07:40:10, Event 1030 (GroupPolicy, Warning): Client could not query the GPO list (error 0x546), consistent with upstream DC/path resolution failure.
- 07:40:11, Event 1058 (GroupPolicy, Error): Same SYSVOL read failure repeated, indicating issue persisted during retry.
- 07:40:12, Event 1129 (GroupPolicy, Error): Group Policy explicitly recorded no network connectivity to a domain controller.
- 07:41:05, Event 1014 (DNS Client Events, Warning): DNS resolution for FINBRIDGE-DC01.finbridge.local timed out; configured DNS servers did not respond.
- 07:42:18, Event 50036 (DHCP Client, Information): Affected host leased DNS server 10.10.3.250, which was the old/decommissioned DNS after migration.
- 07:44:01, Event 1129 (GroupPolicy, Error): Group Policy retried and failed again due to no DC connectivity.
- Comparison host FB029: Event 50036 assigned correct DNS 10.10.0.10, followed by Event 1500 (GroupPolicy success), creating a direct control contrast.

### Surviving Hypothesis (Post-Elimination)
The surviving hypothesis is: DHCP scope misconfiguration assigned decommissioned DNS server(s) to affected Finance OU clients, preventing DC name resolution and causing Group Policy processing failures.

Why this survives all evidence checks:
- Netlogon failure (5719) and DNS timeout (1014) both point to DC discovery failure by name.
- GroupPolicy failures (1058, 1030, 1129) are expected downstream symptoms when SYSVOL/DC cannot be resolved/reached.
- DHCP evidence (50036) shows affected hosts received old DNS values.
- Unaffected host FB029 received correct DNS and processed Group Policy successfully (1500).

### Detailed Resolution Steps (Operational Runbook)
1. Correct DHCP scope DNS configuration
- Update DHCP Option 006 on all affected Floor 3/Finance scopes to current DNS (10.10.0.10, plus approved secondary if applicable).
- Remove decommissioned DNS entries (including 10.10.3.250 and any retired local resolver addresses).
- Validate there is no overlapping policy/superscope/reservation reintroducing stale DNS.

2. Force clients to pull corrected network settings
- On each affected endpoint, renew lease to fetch updated DNS assignment.
- Verify adapter DNS now matches approved DNS list only.

3. Clear stale name-resolution and domain-discovery state
- Flush DNS cache on affected endpoints.
- Restart Netlogon service (or reboot endpoint during maintenance window) to re-run secure channel/DC discovery.

4. Validate DC resolution and SYSVOL access
- Confirm FINBRIDGE-DC01.finbridge.local resolves correctly from affected clients.
- Confirm \\FINBRIDGE-DC01\sysvol is reachable and policy path is accessible.

5. Re-run Group Policy and verify recovery
- Execute forced Group Policy update on corrected clients.
- Confirm successful GP processing event(s) and no new 1058/1030/1129 failures in the same validation window.

6. Confirm control parity across OU
- Compare previously affected hosts with FB029 baseline behavior.
- Ensure startup GP processing is now consistent across all four Finance OU machines.

7. Prevent recurrence in future migration waves
- Audit all active DHCP scopes for decommissioned DNS addresses.
- Add migration gate: DHCP DNS update must be verified before DNS server retirement.
- Add post-change smoke test: DHCP lease, DNS query to DC FQDN, SYSVOL access, and GP update on representative client.

8. Capture closure evidence for incident record
- Before/after DHCP Option 006 screenshots or exported configuration.
- Before/after client ipconfig DNS values for at least one previously affected host.
- Post-fix log evidence showing successful Group Policy processing and absence of repeat failures.
