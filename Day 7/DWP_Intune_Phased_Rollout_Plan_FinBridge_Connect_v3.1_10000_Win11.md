# DWP Phased Intune Deployment Plan - FinBridge Connect v3.1

Plan date: 2026-08-12  
Deadline date (3 weeks): 2026-09-02  
Target: 10,000 Windows 11 endpoints

## 1. RING STRUCTURE
Ring design is built to meet stability goals and the 3-week deadline while prioritizing Finance users.

Ring 1 (Pilot)
- Size: 300 endpoints (3% of fleet).
- Duration: 3 calendar days deployment + 2 calendar days monitoring (5 days total).
- Include: IT engineering test devices, Service Desk power users, 30 Finance representatives, mixed hardware including at least 50 devices from the 4GB RAM cohort.
- Purpose: Validate install command behavior, detection-rule accuracy, uninstall path, reboot impact, and early app stability on mixed hardware.
- Intune assignment group type: Microsoft Entra ID dynamic device security group, assignment type Required.
- Group naming: DWP-FB31-R1-Pilot-Required.

Ring 2 (Early)
- Size: 2,200 endpoints total, including all remaining Finance users.
- Duration: 4 calendar days deployment + 3 calendar days monitoring (7 days total).
- Include: Finance remaining 470 users first in this ring, then Operations and selected business units with normal support coverage windows.
- Purpose: Validate business-process fit at departmental scale, verify helpdesk ticket trend under real load, and confirm no ring-specific regressions.
- Intune assignment group type: Static Entra ID security group for department-targeted control, assignment type Required.
- Group naming: DWP-FB31-R2-Early-Required.

Ring 3 (Broad)
- Size: 7,500 endpoints (remaining fleet after Rings 1 and 2).
- Duration: 5 calendar days staged deployment + 4 calendar days monitoring (9 days total).
- Include: All remaining eligible Win11 endpoints except explicitly excluded risk/isolation groups.
- Purpose: Complete rollout at scale while retaining rapid containment capability by sub-wave.
- Intune assignment group type: Dynamic Entra ID device security groups split into sub-waves, assignment type Required.
- Group naming: DWP-FB31-R3-WaveA-Required, DWP-FB31-R3-WaveB-Required, DWP-FB31-R3-WaveC-Required.

Execution timeline to hit deadline
- Week 1: Ring 1 complete, Ring 2 starts with Finance first.
- Week 2: Ring 2 complete and evaluated, Ring 3 Wave A and Wave B start.
- Week 3: Ring 3 Wave C complete, final stabilization and closure report.

## 2. ADVANCE CRITERIA
All criteria are mandatory. If any single criterion is missed, do not advance.

Ring 1 to Ring 2 gate
- Install success rate: >= 97.0% on Ring 1 devices, measured in Intune App install status, evaluated after monitoring window.
- Error rate threshold: <= 2.0% Failed status in Intune App install status.
- User-reported issues: <= 3.0 tickets per 100 deployed users per 24 hours, severity-1 tickets must be 0.
- Monitoring period: Minimum 48 continuous hours after 95% of Ring 1 assignment attempts are reported.
- Time-bound decision point: CAB go/no-go meeting at end of Day 5, 16:00 local time.

Ring 2 to Ring 3 gate
- Install success rate: >= 98.0% on Ring 2 devices, measured in Intune App install status.
- Error rate threshold: <= 1.5% Failed status in Intune reporting.
- User-reported issues: <= 2.0 tickets per 100 deployed users per 24 hours, severity-1 tickets must be 0, severity-2 tickets <= 0.5 per 100 users per 24 hours.
- Monitoring period: Minimum 72 continuous hours after 95% of Ring 2 assignment attempts are reported.
- Time-bound decision point: CAB go/no-go meeting at end of Ring 2 monitoring window, 16:00 local time.

Hold condition (pause without full rollback)
- Trigger: Detection mismatch pattern where Failed exceeds 2.0% but manual checks show app is installed and functional on at least 80% of sampled failed devices.
- Example: Registry detection path is correct but value format changed from 3.1 to 3.1.0 on subset builds.
- Action: Pause next ring for up to 24 hours, correct detection rule, re-sync policy, and re-evaluate the same ring before advancing.

## 3. ROLLBACK TRIGGERS
A rollback trigger halts expansion immediately and starts controlled reversion to v3.0.

Trigger 1: Install failure rate automatic halt
- Condition: Failed status > 8.0% in any rolling 12-hour window in the active ring, after at least 200 devices in that ring have reported status.
- Decision owner: Incident Manager plus EUC Platform Lead.
- Decision window: 60 minutes from threshold breach alert.
- Intune rollback action:
- Remove FinBridge Connect v3.1 Required assignment from active ring group.
- Add FinBridge Connect v3.0 Required assignment to the same ring group.
- Add FinBridge Connect v3.1 Uninstall assignment to the same ring group if downgrade requires clean replace.

Trigger 2: Application crash rate rollback consideration
- Condition: >= 3.0% of deployed devices in active ring record 2 or more FinBridge process crashes within 24 hours.
- Decision owner: EUC Platform Lead, App Owner, and Major Incident Manager.
- Decision window: 2 hours from validated telemetry report.
- Intune rollback action:
- Freeze all new ring assignments immediately.
- If approved, switch active ring from v3.1 Required to v3.0 Required and apply v3.1 Uninstall assignment.

Trigger 3: Business-critical immediate rollback
- Condition: Finance payment approval workflow cannot establish secure connection through FinBridge for one full business unit for 30+ minutes during business hours.
- Decision owner: Business Continuity Manager can invoke immediate rollback; CAB informed after execution.
- Decision window: Immediate, maximum 15 minutes.
- Intune rollback action:
- Remove v3.1 Required from affected business-unit group.
- Assign v3.0 Required to affected business-unit group.
- Keep broader rings paused until root cause is confirmed.

Trigger 4: 4GB RAM at-risk cohort isolation
- Condition: 4GB RAM device failure rate > 12.0% in any 24-hour window, with sample size >= 50 devices.
- Decision owner: Endpoint Engineering Lead.
- Decision window: 90 minutes from threshold breach.
- Intune containment action:
- Move 4GB devices into exclusion/isolation group DWP-FB31-4GB-Isolation.
- Exclude this group from all v3.1 Required assignments.
- Assign v3.0 Required to isolation group.
- Continue rollout for non-4GB cohorts only if other gates remain green.

## 4. FINANCE DEADLINE RESOLUTION
Option A - Compress pilot and move Finance into Ring 2 by end of week 1
- Minimum safe pilot duration: 72 hours total with at least one full business day of active usage telemetry.
- Risk introduced: Lower chance of catching slower-burn stability defects before Finance scale exposure.
- Compensating control: Increase Ring 1 Finance representation to 100 users and enforce twice-daily telemetry review with a same-day rollback readiness drill.

Option B - Finance as separate Ring 0 before main pilot
- Ring 0 structure: 500 Finance users targeted first, split into 3 sub-waves (150, 150, 200) over 4 days.
- Ring 0 advance conditions:
- Sub-wave gate success >= 98.0%.
- Failed <= 1.5%.
- Severity-1 tickets = 0.
- Minimum 24-hour observation between sub-waves.
- Ring 0 rollback plan:
- Any sub-wave breaching thresholds triggers halt of next sub-wave.
- Immediate reassign affected sub-wave users to v3.0 Required and add v3.1 Uninstall if needed.
- Keep non-Finance rollout frozen until Finance root cause closure.

Recommendation
- Choose Option A.
- Justification: Option A preserves technical sequencing discipline of pilot-first deployment while still meeting Finance end-of-week-1 need, avoids creating a high-risk business-first precedent before engineering validation, and can be made safe with expanded Finance representation in Ring 1 plus strict 72-hour monitoring and rapid rollback controls.
- Final execution decision: Run Ring 1 Day 1 to Day 3, hold go/no-go at Day 4 morning, start Finance-first segment of Ring 2 on Day 4 afternoon, complete Finance by end of Day 5.