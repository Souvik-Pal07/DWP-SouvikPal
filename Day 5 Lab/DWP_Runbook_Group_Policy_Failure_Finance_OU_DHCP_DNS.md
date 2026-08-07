# Prompt
---
You are a DWP engineer writing a runbook for colleagues who will follow it cold, under pressure. Convert this RCA into a runbook with below sections:

prerequisites: what the engineer needs before starting (access rights, tools, which system etc)
Procedure: numbered steps, one action per step, expected result after each step
Verification: how to confirm the fix worked before closing
Rollback: what to do if the procedure makes thing worse - be specific not generic
Notes: edge cases, warnings, related incidents
rules:

Every step must be a single and concrete action
No step should require the engineer to guess what to do
the rollback section must be immediately actionable
Flag any step that requires elevated permissions
RCA: @file:DWP_RCA_Group_Policy_Failure_Finance_OU_Resolved_2026-08-07.md

save this as a file under day 5 Lab folder

# DWP Runbook: Group Policy Failure – Finance OU (DHCP DNS Misconfiguration)

| Field | Detail |
|---|---|
| **Title** | Group Policy Failure – Finance OU (DHCP DNS Misconfiguration) |
| **Runbook ID** | RB-GP-DHCP-DNS-001 |
| **Version** | 1.0 |
| **Date** | 07/08/2026 |
| **Author** | Souvik Pal |
| **Reviewed By** | Self |
| **Status** | Draft |
| **Change** | Initial version created from RCA: Finance OU Group Policy Startup Failure (2026-08-07) |
| **Based on RCA** | Finance OU Group Policy Startup Failure |

---

## Prerequisites

Work through each checklist below. Do **not** begin the procedure until every box can be ticked.

---

### A – Access Rights

- [ ] You have been granted **DHCP Administrators** group membership (or Domain Admin) on the DHCP server for the affected subnet — confirm with your line manager or AD team before proceeding.
- [ ] You can **RDP or physically access** the affected endpoint(s) using a local admin or domain admin account.
- [ ] You have **read access to DNS Manager** on the domain controller (open `dnsmgmt.msc` on the DC — if it loads scopes without an error, you have sufficient access).
- [ ] A **change record is raised and approved** in the ITSM tool for modifying DHCP scope options in production. Note the change reference here: `CR# _______________`

---

### B – Tools — Confirm Each Opens Successfully Before Starting

- [ ] **Event Viewer** — on the affected endpoint press `Win + R`, type `eventvwr.msc`, press Enter. Console must open without an "access denied" error.
- [ ] **DHCP Management Console** — on the DHCP server press `Win + R`, type `dhcpmgmt.msc`, press Enter. Your server must appear in the left pane under **IPv4**.
- [ ] **DNS Manager** — on the DHCP/DC server press `Win + R`, type `dnsmgmt.msc`, press Enter. Forward Lookup Zones must be visible.
- [ ] **PowerShell (Elevated)** — on the affected endpoint press `Win + X`, select **Windows PowerShell (Admin)** or **Terminal (Admin)**. The title bar must show **Administrator**.
- [ ] **Group Policy Management Console** — on a management machine press `Win + R`, type `gpmc.msc`, press Enter. The domain and OUs must be visible in the left pane.

---

### C – Mandatory Information to Collect from the End User and Team BEFORE Starting

Ask the reporting user or the infrastructure team and fill in these values. You will need them at specific steps — do not guess.

- [ ] **Affected machine hostname(s):** `_______________________________________`
  *(Ask the user: "What is the full computer name?" — they can find it at Settings > System > About > Device name)*
- [ ] **Affected subnet / floor:** `_______________________________________`
  *(e.g. Floor 3 Finance segment — confirm with the network team if unsure)*
- [ ] **DHCP server name:** `_______________________________________`
  *(Ask the infrastructure team — e.g. `DHCP-SVR01`)*
- [ ] **DHCP scope ID for the affected subnet:** `_______________________________________`
  *(e.g. `10.10.3.0` — the network team can provide this)*
- [ ] **Decommissioned DNS IP to remove:** `_______________________________________`
  *(e.g. `10.10.3.250` — confirm with the DNS/network team)*
- [ ] **Correct replacement DNS IP(s):** `_______________________________________`
  *(e.g. `10.10.0.10` — must be confirmed by the network team, do not assume)*
- [ ] **Domain FQDN:** `_______________________________________`
  *(e.g. `finbridge.local` — ask the user or check AD)*
- [ ] **Domain Controller FQDN:** `_______________________________________`
  *(e.g. `FINBRIDGE-DC01.finbridge.local` — check in DNS Manager or ask the AD team)*
- [ ] **Time the fault first occurred (from the user):** `_______________________________________`
  *(You will use this to filter Event Viewer logs to the right window)*

---

## Procedure

### Phase 1 – Confirm the Fault

**Step 1.** Open Event Viewer on the affected endpoint.
> Press `Win + R` → type `eventvwr.msc` → press **Enter**.
> In the **left pane**, expand **Windows Logs** → click **System**.
> In the **right Actions pane**, click **Filter Current Log**.
> In the **\<All Event IDs\>** field, type `5719` → click **OK**.

*Expected result: One or more events appear with Source = **Netlogon**, Level = **Error**, with a description containing "There are currently no logon servers available" or "failed to find a domain controller". Note the timestamp — it should be at or after the startup time the user reported.*

> If no events for 5719, also filter for Event ID `1129` (Source: **GroupPolicy**, Level: **Error**). Either ID confirms DC connectivity failure.

---

**Step 2.** Still in Event Viewer on the affected endpoint, check the DHCP Client log for the DNS assignment.
> In the **left pane**, expand **Applications and Services Logs** → **Microsoft** → **Windows** → **Dhcp-Client** → click **Operational**.
> In the **right Actions pane**, click **Filter Current Log**.
> In the **\<All Event IDs\>** field, type `50036` → click **OK**.
> Double-click the most recent matching event to open its **Details**.

*Expected result: The event description shows a DNS server IP. If this IP matches the decommissioned server value you recorded in Prerequisites Section C (e.g. `10.10.3.250`), the fault is confirmed. Screenshot or note this IP before continuing.*

> If the Dhcp-Client Operational log is empty, right-click **Operational** in the left pane and select **Enable Log**, then ask the user to restart the endpoint and repeat this step.

---

**Step 3.** Confirm the bad DNS assignment is still live on the NIC.
> On the affected endpoint press `Win + X` → select **Windows PowerShell (Admin)** or **Terminal (Admin)**.
> Run:
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

*Expected result: The `ServerAddresses` column shows the decommissioned DNS IP (e.g. `10.10.3.250`) for the active network adapter (`Ethernet` or `Wi-Fi`). If the correct DNS IP already appears here, go back to Step 2 and re-check the DHCP event — the issue may be resolved or a different cause.*

---

**Step 4.** Confirm that DC name resolution is failing due to the bad DNS.
> In the same elevated PowerShell window, run (substitute the DC FQDN from Prerequisites Section C):
```powershell
nslookup FINBRIDGE-DC01.finbridge.local
```

*Expected result: The command times out or returns `DNS request timed out` or `Server: UnKnown` — confirming the currently assigned DNS server cannot resolve the DC hostname. If resolution succeeds, the DNS server may be partially working; continue to Phase 2 but note this deviation.*

---

**Step 5.** Check the Group Policy Operational log for the specific GP error codes.
> In Event Viewer, in the **left pane** expand **Applications and Services Logs** → **Microsoft** → **Windows** → **GroupPolicy** → click **Operational**.
> In the **right Actions pane**, click **Filter Current Log**.
> In the **\<All Event IDs\>** field, type `1058, 1030, 1129` → click **OK**.

*Expected result: You see events with those IDs timestamped around the same startup window as Step 1. Event 1058 will reference a SYSVOL path like `\\FINBRIDGE-DC01\sysvol\...\gpt.ini` and an error code `0x3` (file not found / DC unreachable). This confirms the scope of GP failure and gives you evidence for the change record.*

---

### Phase 2 – Fix the DHCP Scope (Requires Elevated Permissions)

> ⚠️ **Elevated permissions required for Steps 6–9.** You must have DHCP Administrators group rights on the DHCP server. If you are not sure, open `dhcpmgmt.msc` on the DHCP server — if you receive an "Access Denied" error, stop and request access via your infrastructure team before continuing.

---

**Step 6.** Log on to the DHCP server (hostname from Prerequisites Section C) and open the DHCP Management Console.
> Press `Win + R` → type `dhcpmgmt.msc` → press **Enter**.
> Alternatively: Open **Server Manager** → click **Tools** (top-right menu) → select **DHCP**.

*Expected result: The console opens. In the left pane you see your DHCP server name expanded under **DHCP**, with **IPv4** and **IPv6** nodes visible.*

---

**Step 7.** Navigate to the scope for the affected subnet.
> In the **left pane**, expand your server name → expand **IPv4**.
> Look for the scope whose IP matches the affected subnet ID from Prerequisites Section C (e.g. `Scope [10.10.3.0] Finance Floor 3`).
> Click the arrow to expand it — you will see: **Address Pool**, **Address Leases**, **Reservations**, **Scope Options**, **Policies**.

*Expected result: The scope for the Finance/Floor 3 subnet is visible and expanded.*

> If you cannot find the scope, press `Win + R`, type `cmd`, run `ipconfig` on an affected endpoint to confirm its subnet, then match that subnet in the DHCP console.

---

**Step 8.** Open the DNS option for this scope.
> Right-click **Scope Options** (directly under the scope you just expanded) → select **Configure Options**.
> In the dialog that opens, scroll the **Available Options** list until you find **006 DNS Servers**.
> Tick the checkbox next to **006 DNS Servers** if it is not already ticked.
> In the **IP address** list at the bottom of the dialog, look for the decommissioned DNS IP (e.g. `10.10.3.250`).

*Expected result: The dialog is open, Option 006 is selected, and the decommissioned IP is visible in the IP address list at the bottom.*

---

**Step 9.** Remove the decommissioned DNS entry and add the correct one.
> In the **IP address** list, click `10.10.3.250` (or whichever decommissioned IP you recorded) to highlight it → click **Remove**.
> In the **IP address** text field (the blank entry box above the list), type the correct DNS IP from Prerequisites Section C (e.g. `10.10.0.10`) → click **Add**.
> Confirm the list now shows **only** the correct IP(s) → click **OK**.

*Expected result: The Scope Options dialog closes. Back in the DHCP console, double-click **Scope Options** in the left pane — the right pane should show **006 DNS Servers** with value `10.10.0.10` only. The decommissioned IP must not appear.*

---

**Step 10.** Verify the change was saved correctly using PowerShell on the DHCP server.
> Press `Win + X` on the DHCP server → select **Windows PowerShell (Admin)**.
> Run (substitute the scope ID from Prerequisites Section C):
```powershell
Get-DhcpServerv4OptionValue -ScopeId 10.10.3.0 -OptionId 6
```

*Expected result: The `Value` field in the output lists only the correct DNS IP(s) (e.g. `10.10.0.10`). If the decommissioned IP still appears, return to Step 8 — the change may not have saved.*

---

### Phase 3 – Refresh Affected Endpoints

**Step 11.** Warn the user that network connectivity will drop briefly, then release and renew the DHCP lease.
> On the affected endpoint, press `Win + X` → select **Windows PowerShell (Admin)**.
> Run:
```powershell
ipconfig /release
ipconfig /renew
```

*Expected result: After `/release` the adapter shows no IP. After `/renew` a new IP is assigned. No error messages. This step must be repeated on each affected endpoint.*

---

**Step 12.** Confirm the correct DNS IP has been assigned by the renewed lease.
> In the same elevated PowerShell window, run:
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

*Expected result: The `ServerAddresses` column for the active adapter (e.g. `Ethernet`) now shows **only** the correct DNS IP (e.g. `10.10.0.10`). If the old IP is still listed, the DHCP change in Step 9 may not have saved — go back and repeat Steps 8–10.*

---

**Step 13.** Flush the local DNS resolver cache.
> In the same elevated PowerShell window, run:
```powershell
ipconfig /flushdns
```

*Expected result: Output reads exactly: `Successfully flushed the DNS Resolver Cache.` If you see an error, ensure you are running PowerShell as Administrator.*

---

**Step 14.** Re-register DNS and force the endpoint to discover a domain controller.
> In the same elevated PowerShell window, run (substitute the domain FQDN from Prerequisites Section C):
```powershell
ipconfig /registerdns
nltest /dsgetdc:finbridge.local /force
```

*Expected result: `nltest` returns output containing `DC: \\FINBRIDGE-DC01`, `Address: \\10.x.x.x`, and `The command completed successfully`. If you still see `ERROR_NO_SUCH_DOMAIN` or a timeout, DNS is still not resolving correctly — return to Step 12 and verify the DNS IP before continuing.*

---

**Step 15.** Force a Group Policy refresh and watch the output.
> In the same elevated PowerShell window, run:
```powershell
gpupdate /force
```

*Expected result: The command prints progress and completes with both lines:*
```
Computer Policy update has completed successfully.
User Policy update has completed successfully.
```
*If either line reads "has completed with errors", proceed to the Verification section — Event Viewer will show which specific policy failed.*

---

## Verification

Complete every check in order. Do not mark the incident resolved until all six pass. Each check tells you exactly where to look and what a pass looks like.

---

**Check 1 — DNS assignment is correct on the NIC**

> On the affected endpoint press `Win + X` → select **Windows PowerShell (Admin)**. Title bar must show **Administrator**.
> Run:
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```
> In the output, find the row for your active adapter (labelled `Ethernet` or `Wi-Fi` in the `InterfaceAlias` column).

✅ **Pass:** The `ServerAddresses` column shows **only** the correct DNS IP (e.g. `10.10.0.10`). The decommissioned IP (e.g. `10.10.3.250`) does **not** appear anywhere in the output.
❌ **Fail:** The decommissioned IP is still listed. Return to Procedure Step 9 and confirm the DHCP scope change saved, then repeat Steps 11–12.

---

**Check 2 — DC hostname resolves correctly**

> In the same elevated PowerShell window, run (substitute the DC FQDN you recorded in Prerequisites Section C):
```powershell
nslookup FINBRIDGE-DC01.finbridge.local
```

✅ **Pass:** Output shows `Name: FINBRIDGE-DC01.finbridge.local` and a valid IP address (e.g. `10.10.0.x`). No timeout or `DNS request timed out` message.
❌ **Fail:** Output shows `DNS request timed out` or `Server: UnKnown`. DNS is still not resolving. Check 1 must have shown the wrong DNS IP — return to Procedure Step 9.

---

**Check 3 — Endpoint can locate a domain controller**

> In the same elevated PowerShell window, run (substitute your domain name from Prerequisites Section C):
```powershell
nltest /dsgetdc:finbridge.local
```

✅ **Pass:** Output contains a line starting `DC:` with a server name, a line starting `Address:` with an IP, and ends with `The command completed successfully`.
❌ **Fail:** Output shows `ERROR_NO_SUCH_DOMAIN` or a timeout. Netlogon cannot find a DC. Run `ipconfig /flushdns` again, wait 30 seconds, then retry this check once. If it fails again, escalate — there may be a wider DC reachability issue beyond DNS.

---

**Check 4 — Group Policy applies without errors**

> In the same elevated PowerShell window, run:
```powershell
gpupdate /force
```

✅ **Pass:** Both of these lines appear in the output:
```
Computer Policy update has completed successfully.
User Policy update has completed successfully.
```
❌ **Fail:** Either line reads `has completed with errors`. Proceed immediately to Check 5 to identify which policy failed.

---

**Check 5 — Group Policy Operational log confirms clean processing**

> On the affected endpoint press `Win + R` → type `eventvwr.msc` → press **Enter**.
> In the **left pane**, expand in order: **Applications and Services Logs** → **Microsoft** → **Windows** → **GroupPolicy** → click **Operational**.
> In the **right Actions pane**, click **Filter Current Log**.
> In the **\<All Event IDs\>** field, type `1500` → click **OK**.
> Check the timestamp on the top result — it must be **after** the time you ran `gpupdate /force` in Check 4.

✅ **Pass:** Event ID 1500 is present, Source = **Group Policy**, Level = **Information**, timestamped after your `gpupdate`. The description reads "The Group Policy settings for the computer were processed successfully".
❌ **Fail:** Only Event IDs 1058, 1030, or 1129 appear, or Event 1500 is missing. Note the exact error code in the 1058 description and escalate — there may be a SYSVOL replication issue separate from DNS.

> To also check for any residual DC connectivity errors, clear the filter and search for Event ID `5719` in **Windows Logs → System**. If 5719 appears **after** your fix steps, the DC is still unreachable.

---

**Check 6 — User can log in successfully**

> Ask the affected user to **log off** the endpoint (Start → click their account icon → Sign out).
> Ask them to log back in with their normal domain credentials.

✅ **Pass:** User logs in to the desktop without any Group Policy error dialogs, no "Domain not available" messages, and applications (Outlook, Teams) connect normally.
❌ **Fail:** User sees a Group Policy error on login. Open Event Viewer → **Windows Logs → System** → filter for Event ID `5719`. If it appears at the login timestamp, the DC connectivity issue has not fully resolved — do not close the incident; escalate to the Network Services Team.

---

## Rollback

> ⚠️ **Target: complete all four steps within 3 minutes.** Read the entire section once before starting. Do not skip steps.
> Trigger this section if: the endpoint loses all network connectivity after Phase 2 or Phase 3, or Group Policy failures worsen after your changes.

---

**Rollback Step 1 — Restore the old DNS in the DHCP scope (~60 seconds)**

> On the **DHCP server**, press `Win + R` → type `dhcpmgmt.msc` → press **Enter**.
> In the **left pane**: expand your server name → expand **IPv4** → expand the affected scope (e.g. `Scope [10.10.3.0]`) → right-click **Scope Options** → select **Configure Options**.
> In the dialog: scroll to **006 DNS Servers** → tick it if unticked → in the **IP address** field type `10.10.3.250` → click **Add** → click **OK**.

*Both the old IP (`10.10.3.250`) and new IP (`10.10.0.10`) are now in the scope. This restores partial DNS capability immediately.*

---

**Rollback Step 2 — Force affected endpoints to pick up the restored scope (~60 seconds)**

> On each affected endpoint, press `Win + X` → select **Windows PowerShell (Admin)**.
> Run these two commands one at a time:
```powershell
ipconfig /release
```
*(Wait for the prompt to return — the NIC will lose its IP briefly)*
```powershell
ipconfig /renew
```
*(Wait for the prompt to return — a new lease will be assigned)*

> Immediately confirm the DNS assignment:
```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```
✅ Both IPs (`10.10.3.250` and `10.10.0.10`) should now appear in `ServerAddresses` for the active adapter. If only one IP appears, run `ipconfig /renew` once more.

---

**Rollback Step 3 — If the endpoint still cannot reach the DC, force DNS directly on the NIC (~30 seconds)**

> This step bypasses DHCP entirely. Use it only if Steps 1–2 did not restore connectivity.
> In the same elevated PowerShell window, first find the exact adapter name:
```powershell
Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name
```
> Note the name shown (e.g. `Ethernet` or `Ethernet 2`). Then run (substitute the adapter name):
```powershell
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ("10.10.0.10","10.10.3.250")
```
> Flush the cache immediately:
```powershell
ipconfig /flushdns
```
✅ DNS is now set statically on the NIC. Test by running `nslookup FINBRIDGE-DC01.finbridge.local` — it must return an IP, not a timeout.

---

**Rollback Step 4 — Escalate immediately (~10 seconds)**

> Stop all further changes. Call or message the **Network Services Team** right now with this information copied from your Prerequisites Section C notes:

```
Escalation – DHCP/DNS Rollback Required
DHCP Server:      [value from Prerequisites C]  
Scope ID:         [value from Prerequisites C]  
Bad DNS IP:       [value from Prerequisites C]  
Correct DNS IP:   [value from Prerequisites C]  
Affected hosts:   [value from Prerequisites C]  
Event IDs seen:   5719, 1014, 1058, 1030, 1129  
Steps taken:      DHCP Option 006 modified; rollback attempted  
Current state:    Endpoints still cannot reach DC after rollback  
```

> ⚠️ Do **not** remove any DNS entry or modify any DHCP scope further until the Network Services Team confirms it is safe to do so.

---

## Notes

### Edge Cases

- **Manually configured endpoints:** Some hosts may have static DNS configured on the NIC and will not pick up DHCP Option 006 changes. Identify these using `Get-DnsClientServerAddress` and correct them manually using Rollback Step 3 syntax, pointing to the correct DNS only.
- **Multiple DHCP scopes:** If the subnet has both a scope-level and server-level Option 006, scope-level takes precedence. Check both levels in the DHCP console for stale entries.
- **VPN-connected machines:** Machines on VPN may not renew their lease from the internal DHCP server. These machines must be physically on the network or have DNS manually corrected.
- **Cached Kerberos tickets:** If a user reports authentication issues after DNS is fixed, run `klist purge` on the affected endpoint to clear cached Kerberos tickets, then retry login.

### Warnings

- Do not remove the decommissioned DNS from DHCP Option 006 until you have confirmed the replacement DNS (e.g. `10.10.0.10`) is responding correctly for all DC FQDNs in scope.
- Running `gpupdate /force` triggers immediate policy application. On machines with logon scripts or software deployment policies, this may trigger unexpected installs. Inform the user before running.
- `ipconfig /release` will briefly drop network connectivity on the endpoint. Warn the user before running.

### Related Incidents and Knowledge Base References

| Reference | Description |
|---|---|
| RCA: Finance OU GP Failure (2026-08-07) | Source RCA for this runbook |
| Event correlation pattern | 5719 + 1014 + 1058 + 1030 + 1129 together with DHCP Event 50036 pointing to stale DNS = this failure pattern |
| CAPA: DHCP scope audit | Network Services Team to implement recurring audit for decommissioned DNS in Option 006 across all scopes (target: within 2 weeks of 2026-08-07) |
| Post-change smoke test | Per subnet: lease renewal → DC FQDN lookup → SYSVOL reachability → `gpupdate` result |
