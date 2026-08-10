# DWP L2/L3 Knowledge Base: Group Policy Failure - Finance OU (DHCP DNS Misconfiguration)

| Field | Detail |
|---|---|
| **Version** | v 1.0 |
| **Date** | 07/08/2026 |
| **Status** | Draft |
| **Audience** | DWP L2/L3 Engineer |

---

## Background
At startup and sign-in, domain-joined endpoints must resolve domain controller names via DNS to reach SYSVOL and process Group Policy. If DHCP supplies stale DNS server IPs, domain controller discovery fails, Group Policy cannot read `gpt.ini`, and users see login/startup reliability issues.

Why it matters:
- Group Policy controls security baseline, login scripts, drive mapping, and endpoint posture.
- DNS/DC reachability failures can cascade into authentication and business app access issues.

---

## Symptom
What users report:
- Repeated sign-in problems after reboot.
- "Domain not available" or delayed startup/login.
- Intermittent inability to access domain resources.

What engineer observes:
- System errors around startup: Event IDs `5719`, `1129`, `1058`, `1030`.
- DNS timeout Event ID `1014` for DC FQDN.
- DHCP assignment Event ID `50036` shows decommissioned DNS IP.
- Repeated GP failure pattern in GroupPolicy Operational log.

---

## Root Cause
DHCP scope Option `006` on the affected Finance subnet continued to hand out a decommissioned DNS server IP, so endpoints could not resolve/reach a domain controller at startup.

Evidence chain confirming root cause:
- `50036` (DHCP Client): stale DNS assigned (for example `10.10.3.250`).
- `1014` (DNS Client): DC FQDN lookup timeout.
- `5719` (Netlogon): no logon servers / secure channel failure.
- `1058` + `1030` (GroupPolicy): cannot read/query GPO/SYSVOL.
- `1129` (GroupPolicy): no DC connectivity.
- Comparison endpoint on same OU/subnet path with correct DNS shows GP success (`1500`) and no failure chain.

---

## Detection
Complete all steps before remediation.

### Step 1 - Confirm Netlogon/DC discovery failure
Log location:
- `Event Viewer > Windows Logs > System`

Action:
- Open `eventvwr.msc`.
- Filter Current Log, field `<All Event IDs>` = `5719`.

Fields to validate:
- `Source` = `NETLOGON`
- `Level` = `Error`
- `General` includes no available logon servers / DC discovery failure.

Expected detection result:
- `5719` present in fault window.

### Step 2 - Confirm DNS timeout to DC FQDN
Log location:
- `Event Viewer > Applications and Services Logs > Microsoft > Windows > DNS Client Events > Operational`

Action:
- Filter Current Log, field `<All Event IDs>` = `1014`.

Fields to validate:
- `Source` = `Microsoft-Windows-DNS-Client`
- `Level` = `Warning`
- `General` includes timeout resolving `<DC-FQDN>` (example `FINBRIDGE-DC01.finbridge.local`).

Expected detection result:
- `1014` present around same timestamp as `5719`.

### Step 3 - Confirm DHCP handed out stale DNS
Log location:
- `Event Viewer > Applications and Services Logs > Microsoft > Windows > Dhcp-Client > Operational`

Action:
- Filter Current Log, field `<All Event IDs>` = `50036`.

Fields to validate:
- `Source` = `Microsoft-Windows-DHCP-Client`
- `General` includes assigned DNS list containing decommissioned IP (example `10.10.3.250`).

Expected detection result:
- `50036` confirms stale DNS assignment.

### Step 4 - Confirm Group Policy failure pattern
Log location:
- `Event Viewer > Applications and Services Logs > Microsoft > Windows > GroupPolicy > Operational`

Action:
- Filter Current Log, field `<All Event IDs>` = `1058,1030,1129`.

Fields to validate:
- `1058` references SYSVOL `\\<DC>\sysvol\...\gpt.ini` and error code.
- `1030` indicates GPO query/list failure.
- `1129` indicates no DC connectivity.

Expected detection result:
- All three IDs appear in same startup sequence.

### Step 5 - NIC DNS state check
Log location:
- Local elevated PowerShell output

Action:
- Run `Get-DnsClientServerAddress -AddressFamily IPv4`.

Fields to validate:
- `InterfaceAlias` for active adapter.
- `ServerAddresses` includes stale DNS IP.

Expected detection result:
- Active adapter uses stale DNS.

### Step 6 - Comparison check (affected vs control endpoint)
Comparison scope:
- Affected host example: `DESKTOP-FB031`
- Control host example: `DESKTOP-FB029` (same OU, unaffected)

Compare exact evidence:
- Affected `50036` DNS value = stale/decommissioned IP.
- Control `50036` DNS value = approved current DNS (example `10.10.0.10`).
- Affected has `5719/1014/1058/1030/1129`; control has GP success `1500` and no matching failure chain.

Decision gate:
- Proceed to resolution only when affected vs control delta confirms DNS assignment as distinguishing variable.

### Step 7 - Record complete event set in incident notes
Record all relevant IDs:
- `7036` (SCM/NLA or Workstation service state transition)
- `5719` (Netlogon)
- `1014` (DNS Client)
- `50036` (DHCP Client)
- `1058`, `1030`, `1129` (GroupPolicy failures)
- `1500` (GroupPolicy success on control endpoint)

---

## Resolution
Use the steps below in order.

> Elevated permissions required for steps that modify DHCP scope and client NIC settings.

1. Open Azure portal path: `https://portal.azure.com > Virtual machines > <Infrastructure-Jump-VM> > Connect`.
Console path: from jump/admin workstation open `dhcpmgmt.msc`.
Expected result: DHCP MMC opens with target server visible under `IPv4`.

2. Azure portal path: `https://portal.azure.com > Virtual machines > <Infrastructure-Jump-VM> > Connect` (same session).
Console path: `DHCP > <ServerName> > IPv4 > <Affected Scope> > Scope Options > Configure Options`.
Expected result: Option `006 DNS Servers` is visible with current values.

3. Azure portal path: `https://portal.azure.com > Virtual machines > <Infrastructure-Jump-VM> > Connect`.
Console path: in Option `006`, remove decommissioned DNS IP and add approved DNS IP set.
Expected result: Only approved DNS IP(s) remain in Option `006` list.

4. Azure portal path: `https://portal.azure.com > Virtual machines > <Infrastructure-Jump-VM> > Connect`.
Console path: elevated PowerShell on DHCP server, run `Get-DhcpServerv4OptionValue -ScopeId <ScopeID> -OptionId 6`.
Expected result: Output `Value` contains only approved DNS IP(s).

5. Azure portal path: `https://portal.azure.com > Microsoft Entra ID > Devices > All devices > <AffectedDevice>`.
Console path: on each affected endpoint open elevated PowerShell and run `ipconfig /release` then `ipconfig /renew`.
Expected result: New lease acquired without errors.

6. Azure portal path: `https://portal.azure.com > Microsoft Entra ID > Devices > All devices > <AffectedDevice>`.
Console path: run `Get-DnsClientServerAddress -AddressFamily IPv4`.
Expected result: Active adapter `ServerAddresses` now shows only approved DNS IP(s).

7. Azure portal path: `https://portal.azure.com > Microsoft Entra ID > Devices > All devices > <AffectedDevice>`.
Console path: run `ipconfig /flushdns` then `ipconfig /registerdns` then `nltest /dsgetdc:<domain> /force`.
Expected result: DC discovery returns successful response and valid DC address.

8. Azure portal path: `https://portal.azure.com > Microsoft Entra ID > Devices > All devices > <AffectedDevice>`.
Console path: run `gpupdate /force`.
Expected result: both computer and user policy updates complete successfully.

---

## Verification
Close only when all checks pass:

1. `Get-DnsClientServerAddress -AddressFamily IPv4`
Pass: no stale DNS IP present.

2. `nslookup <DC-FQDN>`
Pass: resolves quickly with valid DC IP.

3. `nltest /dsgetdc:<domain>`
Pass: returns DC and `The command completed successfully`.

4. Event Viewer path:
`Applications and Services Logs > Microsoft > Windows > GroupPolicy > Operational`
Filter `<All Event IDs>` = `1500`.
Pass: Event `1500` appears after remediation window.

5. Event Viewer path:
`Windows Logs > System`
Filter `<All Event IDs>` = `5719`.
Pass: no new `5719` events after fix timestamp.

6. User validation
Pass: successful login and no repeat symptoms.

---

## Rollback
Execute immediately if condition worsens.

1. Azure portal path: `https://portal.azure.com > Virtual machines > <Infrastructure-Jump-VM> > Connect`.
Console path: `dhcpmgmt.msc > IPv4 > <Affected Scope> > Scope Options > Configure Options > 006 DNS Servers`.
Action: re-add previous DNS IP alongside new DNS temporarily.
Expected result: clients receive both DNS entries to restore partial resolution.

2. Azure portal path: `https://portal.azure.com > Microsoft Entra ID > Devices > All devices > <AffectedDevice>`.
Console path: endpoint elevated PowerShell `ipconfig /release`, `ipconfig /renew`.
Expected result: endpoint picks up rollback DNS list.

3. Azure portal path: `https://portal.azure.com > Microsoft Entra ID > Devices > All devices > <AffectedDevice>`.
Console path: temporary static NIC DNS if still failing:
`Set-DnsClientServerAddress -InterfaceAlias "<AdapterName>" -ServerAddresses ("<ApprovedDNS>","<OldDNS>")`
Expected result: immediate DNS resolution recovery for that endpoint.

4. Azure portal path: `https://portal.azure.com > Monitor > Alerts` (optional incident correlation) plus internal escalation channel.
Action: escalate to Network Services with scope ID, DNS values, event IDs `5719/1014/50036/1058/1030/1129`, and rollback actions already executed.
Expected result: ownership transfer with full evidence package.

---

## Preventive
Implement these concrete controls:

1. DHCP Option 006 compliance job
- Owner: DWP engineer | Timing: After deployment (daily) | Mode: Automated [REQUIRES: scheduled compliance job + ticket integration].
- Signal: nightly scan of all scopes for Option `006`; count scopes containing decommissioned DNS IPs.
- Pass/Fail: Pass = `0` non-compliant scopes; Fail = `>=1` non-compliant scope.
- If fail: auto-create incident, assign to Network Services queue, and block next migration wave.

2. Change gate: DNS decommission dependency
- Owner: Change manager | Timing: Before deployment | Mode: Manual [REQUIRES: CAB template field update].
- Signal: change record contains mandatory evidence field `All affected DHCP scopes validated for Option 006` plus attachment.
- Pass/Fail: Pass = field completed and attachment present; Fail = either missing.
- If fail: reject CAB approval; Automation note: enforce as required field in ITSM workflow.

3. Subnet smoke-test automation
- Owner: Release engineer | Timing: During deployment | Mode: Automated [REQUIRES: smoke-test pipeline].
- Signal: script returns per-subnet checks for lease renew, `nslookup`, `nltest`, `gpupdate`, and Event IDs `5719/1058/1030/1129`.
- Pass/Fail: Pass = all checks green and `0` matching failure events; Fail = any failed check or event hit.
- If fail: stop deployment progression and trigger rollback readiness review.

4. Control endpoint comparison requirement
- Owner: Service desk lead | Timing: After deployment | Mode: Manual [REQUIRES: closure checklist update].
- Signal: closure artifact includes affected vs control DNS values (`50036`) and event outcomes (`5719/1014/1058/1030/1129` vs `1500`).
- Pass/Fail: Pass = signed comparison artifact attached; Fail = missing or incomplete artifact.
- If fail: hold change closure and return to DWP engineer for evidence completion.

5. Central alerting rule
- Owner: DWP engineer | Timing: During deployment | Mode: Automated [REQUIRES: SIEM correlation rule].
- Signal: correlated `50036` (stale DNS IP) + `5719` on same subnet across hosts.
- Pass/Fail: Pass = fewer than 3 affected hosts in 30 minutes; Fail = 3 or more hosts in 30 minutes.
- If fail: auto-create high-priority incident and freeze rollout.

6. Pre-deployment test gate (smoke test before release)
- Owner: Release engineer | Timing: Before deployment | Mode: Automated [REQUIRES: pre-release test stage].
- Signal: test subnet run returns successful `nslookup`, `nltest /dsgetdc`, and no Event IDs `5719/1014/1058/1030/1129` in 15-minute window.
- Pass/Fail: Pass = all checks pass on test subnet; Fail = any failed probe or event hit.
- If fail: block release package from entering deployment stage.

7. In-flight monitoring during rollout window
- Owner: Service desk lead | Timing: During deployment | Mode: Manual+Automated [REQUIRES: alert dashboard].
- Signal: 30-minute dashboard view of `50036`, `5719`, and new GP failures per subnet.
- Pass/Fail: Pass = no upward trend and no threshold breach; Fail = sustained increase for two consecutive intervals.
- If fail: pause rollout and open bridge with DWP engineer + change manager.

8. Post-deployment validation before change closure
- Owner: Change manager | Timing: After deployment | Mode: Manual.
- Signal: 60-minute post-change sample of 3 endpoints shows correct DNS, successful `gpupdate`, and Event `1500` with no new `5719`.
- Pass/Fail: Pass = all sampled endpoints healthy; Fail = any endpoint shows failure chain.
- If fail: keep change open and revert affected subnet(s) to rollback plan.

9. Rollback trigger threshold
- Owner: Change manager | Timing: During deployment | Mode: Manual threshold trigger [REQUIRES: documented rollback threshold].
- Signal: threshold met if 3+ hosts in one subnet show `5719` + `50036` stale DNS within 30 minutes.
- Pass/Fail: Pass = threshold not met; Fail = threshold met.
- If fail: execute rollback section immediately and stop further scope changes.

10. Knowledge update control
- Owner: DWP engineer | Timing: After deployment | Mode: Manual [REQUIRES: KB review workflow].
- Signal: runbook + KB updated with confirmed event pattern (`50036/1014/5719/1058/1030/1129`) and command outputs used.
- Pass/Fail: Pass = updates published within 2 business days and linked in ticket; Fail = SLA missed.
- If fail: escalate to service desk lead and delay incident problem-closure signoff.

---

## Related
- RCA: `Day 4 Lab/DWP_RCA_Group_Policy_Failure_Finance_OU_Resolved_2026-08-07.md`
- Runbook: `Day 5 Lab/DWP_Runbook_Group_Policy_Failure_Finance_OU_DHCP_DNS.md`
- Related runbook (downstream symptom path): `Day 5 Lab/DWP_Runbook_Shared_Drive_Mapping_Failure_Finance_OU_Intune.md`
- L1 article (user-facing baseline): `Day 5 Lab/DWP_KB_Article_L1_Login_Issues_Finance_Computers.md`
