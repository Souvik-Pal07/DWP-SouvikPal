# DWP Root Cause Analysis (RCA)
## Adobe Acrobat Pro v23.6 Intune Installation Failure (MSI 1603)

Document owner: DWP Engineering  
Document date: 2026-08-12  
Incident date: 2024-03-15  
Environment: Windows 11 endpoint managed by Intune  
Deployment type: Intune Win32 app (.intunewin)  
Application: Adobe Acrobat Pro v23.6

---

## 1. Executive Summary

Adobe Acrobat Pro v23.6 failed to install on a managed Windows 11 endpoint via Intune. The initial deployment and first retry both failed with MSI return code 1603. Detection did not find the target registry key and the app remained uninstalled.

Primary root cause is most likely a persistent endpoint-level install block caused by existing/conflicting Adobe components or upgrade-state conflict during silent MSI execution. A secondary process/configuration weakness was identified: the Intune detection rule appears aligned to Adobe Reader instead of Acrobat Pro, indicating packaging quality-control gaps that increased deployment risk and troubleshooting time.

---

## 2. Incident Scope and Impact

Affected service: Endpoint software deployment via Intune Win32 app  
Affected user outcome: Required app unavailable  
Business impact:
- User productivity delay where Acrobat Pro is required.
- Repeat failed retries increase endpoint management noise and support overhead.
- Potential broader deployment risk if package/detection misconfiguration is used at scale.

Current known scope based on provided logs: Single endpoint evidence set. Fleet impact not confirmed from available data.

---

## 3. Supporting Evidence

### 3.1 Source Log Extract (Provided)

[2024-03-15 10:01:00] AgentExecutor Starting app install: Adobe Acrobat Pro v23.6  
[2024-03-15 10:01:01] AppInstaller Install context: SYSTEM  
[2024-03-15 10:01:02] AppInstaller Package: AdobeAcrobatPro.intunewin  
[2024-03-15 10:01:03] AppInstaller Install command: msiexec /i AcrobatPro.msi /quiet  
[2024-03-15 10:01:44] AppInstaller Return code: 1603  
[2024-03-15 10:01:44] AppInstaller Install failed. Return code 1603.  
[2024-03-15 10:01:45] DetectionRule Running detection: registry check  
[2024-03-15 10:01:45] DetectionRule Key: HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0  
[2024-03-15 10:01:45] DetectionRule Value: not found  
[2024-03-15 10:01:46] DetectionRule Detection result: Not detected  
[2024-03-15 10:01:47] AgentExecutor App install result: Failed  
[2024-03-15 10:01:47] AgentExecutor Retry scheduled: 60 minutes  
[2024-03-15 11:01:47] AgentExecutor Retry attempt 1: Adobe Acrobat Pro v23.6  
[2024-03-15 11:01:48] AppInstaller Install command: msiexec /i AcrobatPro.msi /quiet  
[2024-03-15 11:02:31] AppInstaller Return code: 1603  
[2024-03-15 11:02:32] AgentExecutor Retry 1 failed. Next retry: 60 minutes

### 3.2 Evidence Interpretation

- MSI 1603 on both attempts indicates a stable blocking condition, not a transient network or timing issue.
- SYSTEM context confirms execution had elevated local privileges; failure is likely package logic, endpoint state, or MSI precondition conflict rather than standard user-rights limitation.
- Detection key checks Acrobat Reader path while deployed app is Acrobat Pro; this is a configuration inconsistency and a control failure in packaging validation.
- Install command omitted verbose MSI logging, preventing immediate determination of failing MSI action.

### 3.3 Confidence Grading

- Root cause confidence: Medium-High (pattern-consistent with Adobe MSI conflict behavior).
- Detection misconfiguration confidence: High (directly observed in logs).
- Exact MSI failing action confidence: Low without verbose MSI log.

---

## 4. Incident Timeline (UTC not specified in source)

| Time | Event | Evidence-based Interpretation |
|---|---|---|
| 10:01:00 | Install started | Intune agent begins Win32 app deployment |
| 10:01:03 | Silent MSI command launched | No verbose log switch included |
| 10:01:44 | MSI returned 1603 | Fatal install failure/rollback occurred |
| 10:01:45 | Detection rule executed | Registry check targeted Acrobat Reader path |
| 10:01:46 | Not detected | App not installed or incorrect detection target |
| 10:01:47 | Deployment marked failed | Retry policy engaged |
| 11:01:47 | Retry attempt 1 started | Automated remediation attempt |
| 11:02:31 | Retry returned 1603 | Persistent blocking condition confirmed |
| 11:02:32 | Retry failed | Issue remains unresolved |

---

## 5. Technical Root Cause Statement

The Acrobat Pro installation package failed due to a persistent MSI fatal condition (1603), most likely triggered by endpoint Adobe product conflict or upgrade-state incompatibility during silent install. In parallel, the Intune detection rule was configured for Acrobat Reader registry location rather than Acrobat Pro, exposing a packaging governance gap and increasing risk of incorrect install-state evaluation.

---

## 6. 5 Whys Analysis

### Problem
Acrobat Pro v23.6 did not install through Intune and repeatedly failed with error 1603.

1. Why did the application fail to install?
Because MSI execution returned fatal error 1603 and installation rolled back.

2. Why did MSI return 1603?
Most likely because a local precondition/conflict existed on the endpoint, such as existing Adobe Reader/Acrobat components, upgrade path conflict, or product-state mismatch.

3. Why was that precondition/conflict not handled before installation?
Because deployment packaging did not include enforced prerequisite remediation (for example conflict uninstall logic or explicit pre-check requirements).

4. Why was package robustness not validated before rollout?
Because packaging QA controls were incomplete: the detection rule references Acrobat Reader, suggesting template reuse without full app-specific validation.

5. Why were QA controls incomplete?
Because the deployment process lacked a mandatory release gate requiring evidence of clean-room test results, detection-rule verification, and verbose logging readiness for failure diagnostics.

### 5 Whys Conclusion
A technical install block triggered failure, but the systemic root cause is process weakness in packaging validation and release governance for Intune Win32 apps.

---

## 7. Contributing Factors

- No MSI verbose logging in install command.
- Detection rule likely copied from Reader baseline and not updated to Pro-specific path.
- No explicit conflict-removal dependency documented in deployment flow.
- Retry mechanism re-attempted unchanged failing conditions without corrective signal.

---

## 8. Corrective Actions (Immediate)

1. Repackage deployment with diagnostic logging:
   - msiexec /i AcrobatPro.msi /quiet /L*V "%TEMP%\AcrobatPro_install.log"
2. Validate and correct detection rule to Acrobat Pro-specific key/value.
3. Add pre-install script or dependency to remove/upgrade conflicting Adobe components.
4. Execute pilot validation on:
   - Clean Windows 11 endpoint
   - Endpoint with existing Reader
   - Endpoint with prior Acrobat version
5. Capture and review failed endpoint artifacts:
   - IntuneManagementExtension logs
   - MSI verbose log
   - Application and MsiInstaller event logs

---

## 9. Preventive Actions (Systemic)

### 9.1 Process Controls

- Introduce a packaging release checklist gate requiring:
  - Detection rule peer review
  - Install and uninstall command verification
  - Return-code mapping validation
  - Test evidence across clean and conflict states
- Enforce a two-engineer sign-off for production Win32 package promotions.
- Maintain application-specific templates instead of generic Reader/Acrobat shared templates without review.

### 9.2 Engineering Standards

- Standardize MSI installs to always include verbose log switch in pilot and phased rollout waves.
- Define mandatory conflict-handling strategy for software with known mutual-exclusion behavior.
- Add telemetry tagging in deployment naming for faster root-cause slicing (app family, package version, detection version).

### 9.3 Monitoring and Alerting

- Create Intune dashboard/KQL view for repeated 1603 failures by app/version.
- Trigger alert when failure rate exceeds threshold in first deployment ring.
- Include auto-escalation when same endpoint fails twice with same code.

---

## 10. Verification Plan

Success criteria for remediation closure:

- Acrobat Pro installs successfully on all pilot cohorts.
- Detection returns Installed state using corrected Pro key/path.
- No recurring 1603 on remediated endpoints within 7-day observation window.
- Packaging checklist artifacts are attached to release ticket.

Proposed validation cadence:
- Day 0: Packaging correction and lab test
- Day 1-2: Pilot ring deployment and telemetry review
- Day 3-5: Expanded phased rollout
- Day 7: Post-implementation review and closure decision

---

## 11. Residual Risk

- Unknown edge-case conflicts may still occur on heavily customized endpoints.
- If Acrobat vendor MSI behavior changes between versions, previously valid detection/install assumptions may regress.

Risk treatment: Keep first-wave deployments constrained, monitor failure signatures, and update baseline package controls per version.

---

## 12. Final RCA Determination

Direct failure mode: MSI 1603 during silent install of Acrobat Pro.  
Most probable technical trigger: Existing/conflicting Adobe endpoint state.  
Systemic root cause: Inadequate packaging governance and pre-release validation, evidenced by detection-rule mismatch and insufficient diagnostic logging configuration.

---

Prepared by: DWP Engineer  
Date: 2026-08-12
