# DWP Root Cause Analysis (RCA) - Group Policy Failure (Finance OU)

Date: 2026-08-07  
Analyst: DWP Engineer  
Incident ID: Finance OU Group Policy Startup Failure  
Status: Resolved  
Resolution Time: 09:09 AM  
User Validation: User successfully logged in to host after fix; no further issues reported.

## 1) Executive Summary
Three of four Finance OU machines failed Group Policy processing during startup because they could not resolve/reach a domain controller. Investigation showed affected machines received decommissioned DNS server entries via DHCP. The one unaffected comparison machine had correct DNS and processed Group Policy successfully. After DHCP DNS correction and client refresh/remediation steps, service recovered and was confirmed resolved at 09:09 AM.

## 2) Impact Assessment
- Affected scope: 3 of 4 endpoints in Finance OU (Floor 3 segment).
- User impact: Startup/login policy processing failures and domain-connected operations impacted on affected hosts.
- Business impact: Authentication/policy reliability degraded for Finance users on impacted endpoints.
- Non-affected control: 1 endpoint in same OU remained healthy due to correct DNS configuration.

## 3) Supporting Evidence

### 3.1 Affected Endpoint Evidence (DESKTOP-FB031)
- 07:40:02, Event 7036 (SCM): NLA entered running state (network stack startup).
- 07:40:08, Event 5719 (Netlogon, Error): Secure channel to FINBRIDGE failed; no DC available; DNS query for FINBRIDGE-DC01 had no response.
- 07:40:09, Event 1058 (GroupPolicy, Error): Could not read gpt.ini from \\FINBRIDGE-DC01\sysvol\finbridge.local\Policies\{3A1B2C4D-E5F6-7890-ABCD-EF1234567890}\gpt.ini, code 0x3.
- 07:40:10, Event 1030 (GroupPolicy, Warning): Could not query GPO list, code 0x546.
- 07:40:11, Event 1058 (GroupPolicy, Error): Repeated SYSVOL path access failure.
- 07:40:12, Event 1129 (GroupPolicy, Error): No network connectivity to a domain controller.
- 07:41:05, Event 1014 (DNS Client, Warning): Name resolution for FINBRIDGE-DC01.finbridge.local timed out; configured DNS did not respond.
- 07:42:18, Event 50036 (DHCP Client, Info): Lease assigned DNS 10.10.3.250 (old/decommissioned DNS).
- 07:44:01, Event 1129 (GroupPolicy, Error): Group Policy failed again, no DC connectivity.

### 3.2 Comparison Evidence (DESKTOP-FB029, same OU, unaffected)
- 07:40:05, Event 50036: DNS assigned 10.10.0.10 (correct new DNS).
- 07:40:11, Event 1500 (GroupPolicy, Info): Group Policy processed successfully.
- Distinguishing variable: Correct DNS assignment.

### 3.3 DHCP Server Comparison Notes
- FB055-FB057 received decommissioned DNS entries from scope (legacy/local DNS path).
- FB058 received correct central DNS (10.10.0.10) due to manual pre-configuration and remained unaffected.

## 4) Incident Timeline (End-to-End)
- 07:40:02: Network service initialization observed (7036).
- 07:40:08: Netlogon fails secure channel setup; DC discovery failure begins (5719).
- 07:40:09-07:40:12: Group Policy read/query/connectivity failures occur (1058, 1030, 1129).
- 07:41:05: DNS timeout confirms DC FQDN cannot be resolved via configured DNS (1014).
- 07:42:18: DHCP lease reveals stale DNS assignment to affected host (50036).
- 07:44:01: Group Policy retry fails again (1129), confirming persistent condition.
- During remediation window: DHCP scope DNS corrected and client-side refresh/validation steps executed.
- 09:09 AM: Incident confirmed resolved; user logged into host successfully; no issues reported.

## 5) Root Cause Statement
Primary root cause was DHCP scope misconfiguration on the affected subnet, which continued to hand out decommissioned DNS server addresses after migration. This prevented DC name resolution, resulting in inability to access SYSVOL and subsequent Group Policy processing failures.

## 6) 5 Whys Analysis
1. Why did Group Policy fail on affected hosts?
- Because clients could not contact a domain controller or access SYSVOL at startup.

2. Why could clients not contact a domain controller?
- Because DC hostname resolution failed and DNS queries timed out.

3. Why did DNS resolution fail?
- Because clients were assigned an old/decommissioned DNS server via DHCP.

4. Why were clients assigned old DNS values?
- Because DHCP scope Option 006 on the affected segment was not updated during/after migration wave.

5. Why was DHCP scope not updated before DNS decommission?
- Because migration change controls/checklists did not enforce a hard dependency gate between DNS retirement and DHCP scope validation across all affected subnets.

Root cause category:
- Process and configuration management gap during migration execution.

## 7) Corrective Actions Implemented (What Resolved the Incident)
1. Updated DHCP Option 006 for affected Floor 3/Finance subnet(s) to current DNS (10.10.0.10 and approved set).
2. Removed decommissioned DNS entries from active DHCP scope configuration.
3. Renewed DHCP leases on affected clients and verified corrected DNS assignment.
4. Flushed DNS cache and re-triggered domain discovery/policy processing.
5. Re-ran Group Policy update and validated successful processing with no repeat failures.
6. Verified user login success and normal behavior on host at 09:09 AM.

## 8) Preventive Actions (CAPA)
1. Migration control gate
- Introduce mandatory pre-decommission checkpoint: all DHCP scopes validated for updated DNS before DNS server retirement.
- Owner: Infrastructure Change Manager.
- Target: Before next migration wave.

2. DHCP scope audit automation
- Implement recurring audit/report to detect decommissioned DNS IPs in Option 006 across all scopes.
- Owner: Network Services Team.
- Target: Within 2 weeks.

3. Post-change smoke test standard
- Standardize test sequence per subnet: lease renewal, DC FQDN lookup, SYSVOL reachability, gpupdate result.
- Owner: EUC Operations.
- Target: Immediate adoption.

4. Exception handling for manually configured hosts
- Document and track endpoints with manual DNS overrides to avoid false confidence during rollout validation.
- Owner: Endpoint Engineering.
- Target: Within 1 week.

5. Knowledge base and runbook update
- Publish this failure pattern and rapid triage logic (5719/1014/1058/1030/1129 + 50036 correlation).
- Owner: Service Desk Enablement.
- Target: Within 1 week.

## 9) Verification of Effectiveness
- Short-term verification: No recurring GP/DC connectivity failures observed after fix window.
- User confirmation: Successful login at 09:09 AM and no issues reported.
- Technical confirmation: Correct DNS assignment on affected hosts and successful Group Policy processing events.

## 10) Residual Risk
- Risk remains if any un-audited scope still contains stale DNS values.
- Risk remains if future migrations skip DHCP/DNS dependency validation.

## 11) Closure Statement
Incident is closed as resolved. Evidence shows DNS misassignment from DHCP was the causal trigger for DC discovery failure and Group Policy processing breakdown. Corrective changes restored service, and post-fix user and technical validation confirm stable recovery.
