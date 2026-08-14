# DWP Analysis: Citrix VDI Session Launch Failure (FinBridge)

## Document Control
- Date: 2026-08-14
- Analyst: DWP
- Scope: Fact-based incident analysis and hypothesis ranking from provided logs
- Out of Scope: Final platform-wide architectural redesign and non-evidenced assumptions

## Incident Summary
A major launch impact was observed for users assigned to `FinBridge-VDI-Pool-02` while `FinBridge-VDI-Pool-01` remained largely healthy in the same site.

## Scope Facts (Evidence Extract)
1. User impact and pool scope
- Affected: 22 of 30 users on `FinBridge-VDI-Pool-02`
- Unaffected: `FinBridge-VDI-Pool-01`

2. Broker events and exact errors
- `[08:58:34] Broker: Timeout waiting for machine registration response (30000ms exceeded)`
- `[08:58:34] Session launch FAILED: error 1030 'No machines available in the desktop group'`

3. Machine catalog and registration state
- Pool-02 catalog: 25 provisioned, 3 registered, 22 unregistered, maintenance mode 0
- Pool-01 catalog: 20 provisioned, 19 registered, 1 unregistered

4. Unregistered machine sample evidence (Pool-02)
- `VDI-P02-014` and `VDI-P02-017` show failed registration attempts
- Error text: `Unable to contact Delivery Controller`
- Endpoint failure detail: `dc-vdi-02.finbridge.local:80 - connection refused`

5. Delivery Controller health state
- `dc-vdi-02`:
  - `Citrix Broker Service`: STOPPED
  - Last known running: yesterday 23:40
  - Windows Update installed: today 00:15
  - Reboot required flag: set
  - Host not rebooted
- `dc-vdi-01` (serves Pool-01):
  - `Citrix Broker Service`: RUNNING
  - Uptime: 14 days

## Ranked Likely Causes (Most Probable First)

### 1) Citrix Broker Service outage on dc-vdi-02 prevents Pool-02 VDA registration (Primary)
Why it fits the evidence:
- Direct controller health evidence shows the broker service is STOPPED on `dc-vdi-02`.
- Pool-02 has a high unregistered count (22/25), matching broad registration failure.
- Sample VDAs explicitly fail to contact `dc-vdi-02` with `connection refused` on port 80.
- Broker timeout and error 1030 text are consistent with no available registered machines in the affected desktop group.

Fastest confirm/eliminate check:
- On `dc-vdi-02`, check service state and listener availability:
  - Verify `Citrix Broker Service` status = STOPPED/RUNNING.
  - Validate local port/service binding and VDA reachability to controller endpoint.
- In Citrix Studio/Director, refresh `Pool-02` registration counts immediately after service restart.

Specific remediation if confirmed:
- Start/recover `Citrix Broker Service` on `dc-vdi-02`.
- If service start is blocked due to pending update state, perform controlled reboot of `dc-vdi-02` and re-validate service auto-start.
- Trigger/allow VDA re-registration and confirm registered count recovery in Pool-02.

### 2) Post-update host state on dc-vdi-02 left controller in partial/broken service condition
Why it fits the evidence:
- Update installed at 00:15 with reboot required but host not rebooted.
- Broker service has been down since 23:40 (service availability disrupted across maintenance window).
- This scenario often correlates with service dependency/startup anomalies until reboot finalizes patch state.

Fastest confirm/eliminate check:
- Review system/service event logs around 23:40-00:30 for Broker service stop/start failures.
- Perform one controlled reboot and verify whether Broker service starts cleanly and stays up.

Specific remediation if confirmed:
- Execute maintenance reboot of `dc-vdi-02`.
- Post-reboot confirm Broker service dependencies, startup type, and stable running state.
- Validate Pool-02 VDA registration recovers.

### 3) Pool-02 controller assignment/preference issue causing VDAs to target dc-vdi-02 only
Why it fits the evidence:
- Unaffected Pool-01 is served by `dc-vdi-01` and remains healthy.
- Pool-02 failures reference `dc-vdi-02` specifically; if Pool-02 VDAs primarily target this controller, outage blast radius aligns with observed impact.

Fastest confirm/eliminate check:
- Inspect Pool-02 VDA controller list (ListOfDDCs/GPO) and registration routing policy.
- Confirm whether VDAs have viable fallback to `dc-vdi-01` and whether fallback is being attempted.

Specific remediation if confirmed:
- Correct VDA controller list/routing policy to include resilient multi-controller configuration.
- Force policy refresh on Pool-02 VDAs and verify successful fallback registration behavior.

## Error Code Handling Note
- Error `1030` appears in the provided log with explicit text: `No machines available in the desktop group`.
- This analysis uses that exact provided text and does not extend meaning beyond supplied evidence.

## Finalized Hypothesis
`Citrix Broker Service` outage on `dc-vdi-02` is the most probable and selected hypothesis for resolution execution.

## Exact Remediation Steps (Order of Operations)
1. Incident control and change window
- Declare controller recovery action for `dc-vdi-02` and notify operations/service desk.

2. Pre-change validation snapshot
- Capture current status:
  - `Citrix Broker Service` state on `dc-vdi-02`
  - Pool-02 registration counts (registered/unregistered)
  - Launch failure rate for Pool-02 users

3. Service recovery attempt (non-disruptive first)
- Start `Citrix Broker Service` on `dc-vdi-02`.
- If it starts, monitor for stable state for at least 5-10 minutes.

4. Controlled reboot path (if service fails to start or remains unstable)
- Reboot `dc-vdi-02` to clear pending update state.
- After reboot, confirm service auto-start and dependencies healthy.

5. Registration recovery
- Confirm Pool-02 VDAs begin re-registering.
- If needed, trigger VDA registration refresh (policy refresh/restart VDA service on outliers).

6. User validation
- Re-test session launches for previously affected Pool-02 users.

## Verification Checks (Post-Remediation)
- Controller health:
  - `Citrix Broker Service` on `dc-vdi-02` = RUNNING and stable
- Catalog health:
  - Pool-02 registered count rises substantially from 3 toward expected baseline
  - Unregistered count drops from 22 accordingly
- Functional check:
  - New launches in Pool-02 succeed without timeout
  - No recurrence of `30000ms exceeded` and `error 1030` for test cohort

## Preventive Action (Recurrence Control)
1. Monitoring and alerting
- Implement proactive alerts for `Citrix Broker Service` stopped state on all controllers.
- Alert on sudden registration drops per pool threshold.

2. Patch orchestration hardening
- Enforce controller maintenance runbook:
  - Pre-patch drain/health checks
  - Mandatory reboot completion for update cycles requiring reboot
  - Post-patch service validation gates before closure

3. Resilience configuration review
- Validate VDA controller lists and fallback behavior across all pools.
- Test failover quarterly using controlled controller outage simulation.

## Analyst Note
This document intentionally limits statements to observed evidence and ranked operational hypotheses. Root cause confirmation should be locked only after execution-time validation outcomes are recorded.