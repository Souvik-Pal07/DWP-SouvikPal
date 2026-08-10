# DWP L2/L3 Knowledge Base: AVD Black Screen - POOL-FIN-01

| Field | Detail |
|---|---|
| **Version** | v 1.0 |
| **Date** | 07/08/2026 |
| **Status** | Draft |
| **Audience** | DWP L2/L3 Engineer |

---

## Background
`POOL-FIN-01` is an Azure Virtual Desktop host pool used by Finance users for daily workload access. During user sign-in, Desktop Window Manager (`dwm.exe`) must initialize correctly for the desktop session to render.

If display initialization fails on session hosts, users may connect but only see a persistent black screen. This creates business outage impact even when authentication and broker services are healthy.

---

## Symptom
What users report:
- Black screen after sign-in to AVD.
- Session opens but desktop never loads.
- Reconnect also shows black screen.

What engineer observes:
- Incidents concentrated on `POOL-FIN-01`.
- `POOL-FIN-02` users are not impacted (comparison baseline).
- On affected host: Application log Event ID `1000` (source `Application Error`) with `dwm.exe` faulting in `igdumd64.dll`.
- On affected host: System log Event ID `9009` (source `Desktop Window Manager`) shortly after Event `1000`.

---

## Root Cause
Specific technical cause:
- Display/rendering regression on `POOL-FIN-01` image path causing `dwm.exe` to crash in `igdumd64.dll` during session initialization.

Evidence that confirms it:
- Event `1000` in Application log with faulting application `dwm.exe` and faulting module `igdumd64.dll`.
- Event `9009` in System log from `Desktop Window Manager` following the crash window.
- Pattern present on affected `POOL-FIN-01` session hosts and absent on control pool `POOL-FIN-02` during equivalent login window.

---

## Detection
Target: complete diagnosis in under 3 minutes using command-first checks, then optional Event Viewer confirmation.

### 1) Identify one affected host and one control host
Azure portal path:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts`

Required outcome:
- Select `<AffectedHost>` from `POOL-FIN-01`.
- Select `<ControlHost>` from `POOL-FIN-02`.

### 2) Fast extraction on affected host (PowerShell)
Log locations checked by command:
- `Windows Logs > Application` (LogName `Application`)
- `Windows Logs > System` (LogName `System`)

Run on `<AffectedHost>` (local elevated PowerShell session):
```powershell
$start=(Get-Date).AddHours(-4)

$app1000 = Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$start} |
  Where-Object { $_.ProviderName -eq 'Application Error' -and $_.Message -match 'dwm\.exe' -and $_.Message -match 'igdumd64\.dll' } |
  Select-Object -First 5 TimeCreated, Id, ProviderName, Message

$sys9009 = Get-WinEvent -FilterHashtable @{LogName='System'; Id=9009; StartTime=$start} |
  Where-Object { $_.ProviderName -eq 'Desktop Window Manager' } |
  Select-Object -First 5 TimeCreated, Id, ProviderName, Message

$app1000
$sys9009
```

Fields to confirm:
- Event ID `1000`, Provider `Application Error`, Message contains `Faulting application name: dwm.exe` and `Faulting module name: igdumd64.dll`.
- Event ID `9009`, Provider `Desktop Window Manager`, timestamp same window as Event `1000`.

Detection pass criteria:
- Both `1000` and `9009` exist in same incident window on `<AffectedHost>`.

### 3) Healthy baseline check on control pool host (Event 9011)
Log location:
- `Windows Logs > System` (LogName `System`)

Run on `<ControlHost>` (local elevated PowerShell session):
```powershell
$start=(Get-Date).AddHours(-4)
Get-WinEvent -FilterHashtable @{LogName='System'; Id=9011; StartTime=$start} |
  Where-Object { $_.ProviderName -eq 'Desktop Window Manager' } |
  Select-Object -First 5 TimeCreated, Id, ProviderName, Message
```

Fields to confirm:
- Event ID `9011`, Provider `Desktop Window Manager` present during equivalent login window.

Healthy baseline result:
- `POOL-FIN-02` shows `9011` and does not show matching `1000` (`dwm.exe`/`igdumd64.dll`) + `9009` crash chain.

### 4) Azure CLI remote option (if direct host console is not available)
Azure path reference:
- `https://portal.azure.com > Virtual machines > <SessionHostVM>`

Run from admin workstation with Azure CLI:
```bash
az vm run-command invoke \
  --resource-group <RG_NAME> \
  --name <AffectedHostVM> \
  --command-id RunPowerShellScript \
  --scripts "$s=(Get-Date).AddHours(-4); Get-WinEvent -FilterHashtable @{LogName='Application';Id=1000;StartTime=$s} | ? {$_.ProviderName -eq 'Application Error' -and $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll'} | select -First 5 TimeCreated,Id,ProviderName,Message; Get-WinEvent -FilterHashtable @{LogName='System';Id=9009;StartTime=$s} | ? {$_.ProviderName -eq 'Desktop Window Manager'} | select -First 5 TimeCreated,Id,ProviderName,Message"
```

Control host command (`POOL-FIN-02` baseline):
```bash
az vm run-command invoke \
  --resource-group <RG_NAME> \
  --name <ControlHostVM> \
  --command-id RunPowerShellScript \
  --scripts "$s=(Get-Date).AddHours(-4); Get-WinEvent -FilterHashtable @{LogName='System';Id=9011;StartTime=$s} | ? {$_.ProviderName -eq 'Desktop Window Manager'} | select -First 5 TimeCreated,Id,ProviderName,Message"
```

### 5) Optional GUI confirmation (if command output is ambiguous)
Exact log locations and filter fields:
- `Event Viewer > Windows Logs > Application` -> `Filter Current Log` -> `<All Event IDs>` = `1000`, `Event sources` = `Application Error`.
- `Event Viewer > Windows Logs > System` -> `Filter Current Log` -> `<All Event IDs>` = `9009`, `Event sources` = `Desktop Window Manager`.
- Control host (`POOL-FIN-02`) `Event Viewer > Windows Logs > System` -> `<All Event IDs>` = `9011`, `Event sources` = `Desktop Window Manager`.

### 6) Detection decision gate
Confirm this incident only when all are true:
- Affected `POOL-FIN-01` host has Event `1000` (`dwm.exe` + `igdumd64.dll`) and Event `9009` in same time window.
- Control `POOL-FIN-02` host shows healthy baseline Event `9011` and no equivalent crash chain.
- User symptom (persistent black screen) aligns with event timestamps.

---

## Resolution
Use this sequence to complete containment and remediation in 5 to 10 minutes.

> Elevated permissions required for AVD host-pool settings and VM/image actions.

### A) Fast command setup (run once from admin workstation)
```powershell
Connect-AzAccount
Set-AzContext -Subscription "<SUBSCRIPTION_ID>"

$rg              = "<RESOURCE_GROUP>"
$hostPool        = "POOL-FIN-01"
$controlPool     = "POOL-FIN-02"
$affectedSession = "<AffectedHost>.domain.local"
$vmName          = "<AffectedHostVMName>"
```

### 1) Drain affected host immediately
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Properties > Allow new sessions`

Action:
- Set `Allow new sessions` to `No`, then click `Save`.

PowerShell equivalent:
```powershell
Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hostPool -Name $affectedSession -AllowNewSession:$false
```

Expected result:
- Host is in drain mode and no new user sessions are admitted.

### 2) Confirm continuity pool is healthy
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts > <ControlHost> > Overview`

Action:
- Confirm at least one control host is `Available` and `Allow new sessions = Yes`.

PowerShell equivalent:
```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $controlPool |
  Select-Object Name, Status, AllowNewSession
```

Expected result:
- `POOL-FIN-02` remains serviceable for user continuity.

### 3) Confirm crash signature once before image action
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Connect`

Action:
- Connect, then verify Event `1000` and `9009` on the host.

Azure CLI quick extraction equivalent:
```bash
az vm run-command invoke \
  --resource-group <RESOURCE_GROUP> \
  --name <AffectedHostVMName> \
  --command-id RunPowerShellScript \
  --scripts "$s=(Get-Date).AddHours(-2); Get-WinEvent -FilterHashtable @{LogName='Application';Id=1000;StartTime=$s} | ? {$_.ProviderName -eq 'Application Error' -and $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll'} | select -First 3 TimeCreated,Id,ProviderName,Message; Get-WinEvent -FilterHashtable @{LogName='System';Id=9009;StartTime=$s} | ? {$_.ProviderName -eq 'Desktop Window Manager'} | select -First 3 TimeCreated,Id,ProviderName,Message"
```

Expected result:
- Pre-change evidence is confirmed and captured.

### 4) Apply approved image remediation
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Virtual machine`
- Then one approved action only from change record:
  - `Operations > Restart`
  - or `Support + troubleshooting > Redeploy + reapply`
  - or image rollback path on VM/VMSS per approved deployment record.

Azure CLI quick actions:
```bash
az vm restart --resource-group <RESOURCE_GROUP> --name <AffectedHostVMName>
# If using VMSS host and approved reimage path:
# az vmss reimage --resource-group <RESOURCE_GROUP> --name <VMSS_NAME> --instance-ids <INSTANCE_ID>
```

Expected result:
- Host returns in corrected image/runtime state.

### 5) Re-enable host intake after remediation
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Properties > Allow new sessions`

Action:
- Set `Allow new sessions` to `Yes`, then click `Save`.

PowerShell equivalent:
```powershell
Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hostPool -Name $affectedSession -AllowNewSession:$true
```

Expected result:
- Host accepts new sessions and returns to production routing.

---

## Verification
Complete all checks before closure.

### 1) Verify host state and intake setting
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <RemediatedHost> > Overview`

Pass criteria:
- `Status = Available`
- `Allow new sessions = Yes`

PowerShell equivalent:
```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hostPool -Name $affectedSession |
  Select-Object Name, Status, AllowNewSession
```

### 2) Verify no new crash events after fix window
Exact log locations:
- `Event Viewer > Windows Logs > Application`
- `Event Viewer > Windows Logs > System`

PowerShell quick check (on remediated host):
```powershell
$verifyStart=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$verifyStart} |
  Where-Object { $_.ProviderName -eq 'Application Error' -and $_.Message -match 'dwm\.exe' -and $_.Message -match 'igdumd64\.dll' } |
  Select-Object TimeCreated,Id,ProviderName,Message

Get-WinEvent -FilterHashtable @{LogName='System'; Id=9009; StartTime=$verifyStart} |
  Where-Object { $_.ProviderName -eq 'Desktop Window Manager' } |
  Select-Object TimeCreated,Id,ProviderName,Message
```

Pass criteria:
- No new Event `1000` (`dwm.exe`/`igdumd64.dll`) in verification window.
- No new Event `9009` in verification window.

### 3) Verify healthy baseline still present on control pool
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts > <ControlHost> > Connect`

PowerShell quick check (control host):
```powershell
$verifyStart=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='System'; Id=9011; StartTime=$verifyStart} |
  Where-Object { $_.ProviderName -eq 'Desktop Window Manager' } |
  Select-Object -First 3 TimeCreated,Id,ProviderName,Message
```

Pass criteria:
- Event `9011` present on control host and no equivalent new crash chain.

### 4) Functional test
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <RemediatedHost> > Connect`

Pass criteria:
- Test login and reconnect complete without persistent black screen.
- Affected user confirms normal desktop load.

---

## Rollback
Execute immediately if remediation worsens impact.

### 1) Isolate unstable host again
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Properties > Allow new sessions`

Action:
- Set `Allow new sessions` = `No`, click `Save`.

PowerShell equivalent:
```powershell
Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hostPool -Name $affectedSession -AllowNewSession:$false
```

Expected result:
- No new users are routed to unstable host.

### 2) Revert to last known good image/state
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Virtual machine`
- Use approved rollback action from change record:
  - `Operations > Restart`
  - or `Support + troubleshooting > Redeploy + reapply`
  - or VMSS reimage to approved baseline.

Azure CLI rollback actions:
```bash
az vm restart --resource-group <RESOURCE_GROUP> --name <AffectedHostVMName>
# If approved and using VMSS:
# az vmss reimage --resource-group <RESOURCE_GROUP> --name <VMSS_NAME> --instance-ids <INSTANCE_ID>
```

Expected result:
- Host is restored to last known good runtime/image state.

### 3) Validate rollback succeeded before reopening host
Exact log locations:
- `Event Viewer > Windows Logs > Application`
- `Event Viewer > Windows Logs > System`

PowerShell quick validation:
```powershell
$rbStart=(Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=$rbStart} |
  Where-Object { $_.ProviderName -eq 'Application Error' -and $_.Message -match 'dwm\.exe' -and $_.Message -match 'igdumd64\.dll' } |
  Select-Object TimeCreated,Id,ProviderName

Get-WinEvent -FilterHashtable @{LogName='System'; Id=9009; StartTime=$rbStart} |
  Where-Object { $_.ProviderName -eq 'Desktop Window Manager' } |
  Select-Object TimeCreated,Id,ProviderName
```

Expected result:
- No new Event `1000` (`dwm.exe`/`igdumd64.dll`) and no new Event `9009` in rollback window.

### 4) Reopen host only after rollback verification
Exact Azure portal path and option:
- `https://portal.azure.com > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <AffectedHost> > Properties > Allow new sessions`

Action:
- Set `Allow new sessions` = `Yes`, click `Save`.

PowerShell equivalent:
```powershell
Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hostPool -Name $affectedSession -AllowNewSession:$true
```

Expected result:
- Host safely re-enters production routing.

---

## Preventive
Implement specific controls to prevent recurrence.

1. Image release quality gate for AVD pools
- Owner: Release engineer | Timing: Before deployment | Mode: Automated [REQUIRES: image CI/CD gate].
- Signal: scripted login test queries Application Event `1000` (`Application Error`, `dwm.exe`, `igdumd64.dll`) and System Event `9009`.
- Pass/Fail: Pass = zero matching events across test hosts; Fail = one or more matching events.
- If fail: block promotion, notify image owner, raise rollback-readiness task in change record.

2. Ring-based host pool rollout
- Owner: Change manager | Timing: During deployment | Mode: Manual gate with automated evidence.
- Signal: Ring 0 (`POOL-FIN-02`) soak window 60 minutes, Ring 1 partial `POOL-FIN-01` soak window 60 minutes.
- Pass/Fail: Pass = zero Event `1000/9009` and zero black-screen tickets in each ring; Fail = any breach.
- If fail: stop progression to next ring and keep `POOL-FIN-01` in drain state until triage completes.

3. Automated telemetry alerting
- Owner: DWP engineer | Timing: During deployment and after deployment | Mode: Automated [REQUIRES: Log Analytics + alert rule + ticket integration].
- Signal: alert on Event `1000` (`dwm.exe` + `igdumd64.dll`) OR Event `9009`; critical threshold = 3 hosts in 30 minutes.
- Pass/Fail: Pass = no threshold breach during rollout/24h watch; Fail = threshold breach.
- If fail: auto-create P1 incident, auto-page on-call, and trigger rollback decision meeting.

4. Drift-control for graphics component versions
- Owner: Image owner | Timing: Before deployment | Mode: Automated [REQUIRES: image manifest/version compliance job].
- Signal: build manifest compares `igdumd64.dll` file version/hash to approved baseline list.
- Pass/Fail: Pass = exact version/hash match; Fail = mismatch or missing entry.
- If fail: fail image build, prevent publishing to gallery, create defect ticket for image owner.

5. Mandatory comparison evidence in change closure
- Owner: Change manager | Timing: After deployment | Mode: Manual [REQUIRES: change checklist update].
- Signal: closure record includes both pools, event counts (`1000`,`9009`,`9011`), and user validation outcome.
- Pass/Fail: Pass = evidence attached and approved by service desk lead; Fail = missing/incomplete evidence.
- If fail: keep change open, route back to DWP engineer for evidence completion.

6. Post-deployment validation gate
- Owner: Service desk lead | Timing: After deployment | Mode: Manual with command output attachment.
- Signal: 30-minute and 24-hour checks show `POOL-FIN-01` has zero new `1000/9009` and `POOL-FIN-02` has expected `9011` baseline.
- Pass/Fail: Pass = both checkpoints clean; Fail = any new crash event or renewed black-screen ticket.
- If fail: reopen incident, put affected host(s) in drain mode, assign to DWP engineer immediately.

7. Rollback trigger threshold
- Owner: Change manager | Timing: During deployment | Mode: Automated trigger + manual approval [REQUIRES: rollout threshold policy].
- Signal: trigger rollback if 2 or more remediated hosts show new `1000` plus `9009` within 15 minutes, or 5+ user black-screen tickets in 30 minutes.
- Pass/Fail: Pass = threshold not reached; Fail = threshold reached.
- If fail: execute rollback runbook section immediately and freeze further rollout.

8. Knowledge update control
- Owner: DWP engineer | Timing: After deployment | Mode: Manual [REQUIRES: KB/runbook review workflow].
- Signal: runbook and KB include confirmed signatures (`1000`,`9009`,`9011`, `igdumd64.dll`) and command snippets used in incident.
- Pass/Fail: Pass = updates published within 2 business days and linked in change record; Fail = missed SLA.
- If fail: escalate to service desk lead and hold formal closure until documentation is complete.

---

## Related
- Runbook source: `Day 5/DWP_Runbook_AVD_Black_Screen_POOL-FIN-01_2026-08-07.md`
- RCA source (referenced by runbook): AVD black-screen RCA for `POOL-FIN-01`
- Related GP connectivity runbook: `Day 5 Lab/DWP_Runbook_Group_Policy_Failure_Finance_OU_DHCP_DNS.md`
- Related drive mapping runbook: `Day 5 Lab/DWP_Runbook_Shared_Drive_Mapping_Failure_Finance_OU_Intune.md`
