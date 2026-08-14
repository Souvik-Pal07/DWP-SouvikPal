# DWP Root Cause Analysis (RCA): Citrix VDI Session Launch Failure

## Document Control
- Date: 2026-08-14
- Incident Type: VDI session launch failure
- Environment: FinBridge Citrix site
- Primary Affected Scope: `FinBridge-VDI-Pool-02`
- Impact: 22 of 30 users unable to launch sessions

## Executive Problem Statement
A large subset of users in `FinBridge-VDI-Pool-02` could not launch VDI sessions, while `FinBridge-VDI-Pool-01` remained largely unaffected. Broker logs showed session launch timeout and desktop group capacity failure text during the impact window.

## Supporting Evidence
1. Broker log evidence
- Timeout: `Timeout waiting for machine registration response (30000ms exceeded)`
- Launch failure: `error 1030 'No machines available in the desktop group'`

2. Catalog registration evidence
- Pool-02: 25 provisioned, 3 registered, 22 unregistered
- Pool-01: 20 provisioned, 19 registered, 1 unregistered

3. Endpoint registration failure evidence
- Multiple Pool-02 VDAs: `Unable to contact Delivery Controller`
- Endpoint detail: `dc-vdi-02.finbridge.local:80 - connection refused`

4. Controller health evidence
- `dc-vdi-02`: `Citrix Broker Service` STOPPED, update installed, reboot required, host not rebooted
- `dc-vdi-01`: `Citrix Broker Service` RUNNING, uptime 14 days

## Incident Timeline (from provided data)
- Yesterday 23:40: `Citrix Broker Service` on `dc-vdi-02` last known running
- Today 00:15: Windows Update installed on `dc-vdi-02` (reboot required, not completed)
- 06:15-06:16: Sample Pool-02 VDAs fail registration attempts to `dc-vdi-02`
- 08:58:34: Broker logs timeout and session launch failure (`error 1030` text)

## 5 Whys Analysis
1. Why did users in Pool-02 fail to launch sessions?
- Because brokered launch could not find sufficient available machines in the desktop group at request time.

2. Why were insufficient machines available?
- Because most Pool-02 machines were unregistered (22 unregistered, only 3 registered).

3. Why were Pool-02 machines unregistered?
- Because sample VDAs could not contact their Delivery Controller endpoint (`dc-vdi-02:80`, connection refused).

4. Why was the controller endpoint refusing connections?
- Because `Citrix Broker Service` on `dc-vdi-02` was STOPPED.

5. Why was the broker service stopped and not recovered?
- Controller was in a post-update state with reboot required and no completed reboot/recovery validation.

## Final Root Cause Hypothesis (Selected)
Operational controller outage on `dc-vdi-02` (Broker service stopped), with unresolved post-update reboot state, caused widespread Pool-02 VDA unregistration and resultant session launch failures.

## Confirmed Error Code Handling Statement
- The RCA uses only the provided error statement for `1030`: `No machines available in the desktop group`.
- No expanded vendor-specific interpretation beyond the supplied log text is asserted.

## Exact Remediation Steps
1. Initiate controlled recovery change on `dc-vdi-02`.
2. Capture pre-change metrics:
- Broker service state
- Pool-02 registered/unregistered counts
- Current launch failure sample
3. Attempt to start `Citrix Broker Service` on `dc-vdi-02`.
4. If start fails or is unstable, reboot `dc-vdi-02` (required update state finalization).
5. Post-reboot, verify:
- Broker service is RUNNING
- Service startup type/dependencies intact
6. Monitor Pool-02 re-registration and assist outlier VDAs if needed.
7. Re-run controlled user launch tests for impacted cohort.

## Correct Order of Operations
1. Communicate and open maintenance/recovery window.
2. Baseline capture before changes.
3. Service start attempt first.
4. Reboot only if needed/unhealthy service state persists.
5. Post-change controller checks.
6. VDA registration recovery checks.
7. End-user functional validation.
8. Incident closure after sustained stability window.

## Verification Checks to Confirm Resolution
- Technical health checks:
  - `dc-vdi-02` Broker service RUNNING and stable
  - Pool-02 registration materially recovered (registered count increased, unregistered count reduced)
- Functional checks:
  - New Pool-02 session launches succeed
  - No repeated 30000ms timeout or error 1030 messages during validation window
- Comparative checks:
  - Pool-01 remains healthy, confirming no cross-pool regression

## Preventive Actions
1. Implement service-level monitoring and paging for Broker service stop events on all controllers.
2. Enforce patch runbook with mandatory reboot completion and post-reboot service health gate.
3. Add pre-business-hours synthetic launch test per pool after controller patch windows.
4. Review and validate multi-controller resilience/fallback configuration for all VDA pools.
5. Record controller service uptime and registration baseline trend thresholds for early warning.

## Residual Risk and Follow-up
- Residual risk remains if controller failover/fallback policies are not uniformly configured.
- Follow-up task: complete resilience validation test and update operational SOP with pass/fail criteria.