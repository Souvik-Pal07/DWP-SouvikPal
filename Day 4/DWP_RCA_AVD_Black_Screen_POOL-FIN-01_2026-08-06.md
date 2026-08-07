# RCA: AVD Black Screen Incident - `POOL-FIN-01`

## Incident Summary
- **Incident Type:** AVD post-logon black screen and session disconnect
- **Affected Pool:** `POOL-FIN-01`
- **Unaffected Pool:** `POOL-FIN-02`
- **Impact Start:** Approximately `07:00`
- **Resolution Time:** `10:00`
- **User Impact:** Approximately `40%` of users logging into `POOL-FIN-01`
- **User Symptom:** Blank screen after login; for some users the screen cleared after about `30` seconds, while for others the session persisted in a failed state or disconnected
- **Current Status:** Resolved. Users verified logging in successfully to hosts in `POOL-FIN-01` with no further issues reported

## Executive Summary
An overnight image update was applied to `POOL-FIN-01` at `02:00`. `POOL-FIN-02` was not updated and remained fully unaffected. During the morning incident window, affected `POOL-FIN-01` session hosts showed repeated `dwm.exe` application crashes in the Intel graphics module `igdumd64.dll`, followed by Desktop Window Manager termination and user session disconnects. Comparison logs from an unaffected `POOL-FIN-02` host showed normal Desktop Window Manager startup and no matching application errors.

The evidence supports an image-linked display or remote rendering regression introduced into `POOL-FIN-01` by the overnight image update. The reported remediation was applied and service was restored by `10:00`. Post-remediation validation confirmed users were able to log in to `POOL-FIN-01` successfully and no further issues were reported.

## Scope Facts
- **Symptom:** Blank screen post login
- **Behavior Pattern:** Clears after about `30` seconds for some users and persists for others
- **Who:** Approximately `40%` of users on `POOL-FIN-01`
- **Isolation Boundary:** `POOL-FIN-02` completely unaffected
- **Timing:** Issue began around `07:00`, after the overnight image update
- **Known Change:** `POOL-FIN-01` image updated at `02:00`; `POOL-FIN-02` not updated

## Business Impact
- Users assigned to `POOL-FIN-01` experienced failed or unstable desktop access during the business morning.
- The issue impaired access to AVD-hosted applications and desktop workflows.
- Impact was partial rather than total, but significant enough to require pool-level remediation.

## Supporting Evidence

### Change and Scope Evidence
- `POOL-FIN-01` received an image update at `02:00`.
- `POOL-FIN-02` did not receive the update.
- Only the updated pool experienced the symptom.
- The unaffected pool provides a direct control sample that weighs strongly toward an image-specific fault.

### Affected Host Event Evidence: `SHFIN-01-A`

**07:02:10 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Session logon succeeded for `FINBRIDGE\mlopez`, Session ID `3`, Source `10.10.1.55`

**07:02:14 - Microsoft-Windows-Kernel-General Event 1**
- System boot time recorded as `02:03:11`
- Confirms the host restarted shortly after the overnight image update window

**07:02:16 - Application Error Event 1000**
- Faulting application: `dwm.exe`
- Faulting module: `igdumd64.dll`
- Module version: `31.0.101.4146`
- Exception code: `0xc0000005`

**07:02:17 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40**
- Session disconnected for `FINBRIDGE\mlopez`, Session ID `3`

**07:02:18 - Desktop Window Manager Event 9009**
- Desktop Window Manager exited with code `0x40010004`

**07:02:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Reconnect logon succeeded for `FINBRIDGE\mlopez`, Session ID `3`

**07:02:46 - Application Error Event 1000**
- `dwm.exe` faulted again in `igdumd64.dll`

**07:02:47 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40**
- Session disconnected again for `FINBRIDGE\mlopez`, Session ID `3`

**07:03:01 - Desktop Window Manager Event 9009**
- Desktop Window Manager exited again with code `0x40010004`

**07:03:10 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Second reconnect logon succeeded for `FINBRIDGE\mlopez`, Session ID `4`

**07:08:22 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Session logon succeeded for `FINBRIDGE\akapoor`, Session ID `5`, Source `10.10.1.61`

**07:08:24 - Application Error Event 1000**
- `dwm.exe` faulted in `igdumd64.dll` again during a second user session

### Unaffected Comparison Evidence: `SHFIN-02-A` in `POOL-FIN-02`

**07:01:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Session logon succeeded for `FINBRIDGE\bwalker`, Session ID `2`

**07:01:46 - Desktop Window Manager Event 9011**
- Desktop Window Manager started successfully
- No Application Error events recorded in the same time window

## Evidence Interpretation
- The user reaches successful session logon before the failure begins, which reduces likelihood of pre-desktop authentication or profile-attach failure as the primary cause.
- The repeated `Application Error Event 1000` entries identify a concrete process failure: `dwm.exe` crashing in `igdumd64.dll`.
- `Desktop Window Manager Event 9009` immediately follows the application fault, confirming loss of the display compositor.
- The unaffected comparison host on the pre-update image shows the normal inverse pattern: successful DWM startup and no crash events.
- The combined evidence supports an image-linked graphics or remote rendering regression introduced by the updated `POOL-FIN-01` image.

## Reviewed Hypotheses and Outcome

### 1. Image-level logon initialization regression introduced by the 02:00 `POOL-FIN-01` update
- **Outcome:** Supported
- **Determining evidence:** `Kernel-General Event 1` at `07:02:14`; unaffected comparison `Desktop Window Manager Event 9011` at `07:01:46`
- **Interpretation:** The timing and pool split support an image-linked fault, but later evidence narrows the failure mode more specifically to the display stack.

### 2. FSLogix profile attach or profile-load delay triggered by the new image
- **Outcome:** Contradicted
- **Determining evidence:** `TerminalServices-LocalSessionManager Event 21` at `07:02:10`; `Application Error Event 1000` at `07:02:16`, `07:02:46`, and `07:08:24`
- **Interpretation:** Successful logon occurs before failure, and the deciding errors point to DWM and the Intel graphics module rather than profile load issues.

### 3. Windows shell, AppX, or AppReadiness startup delay introduced by the updated image
- **Outcome:** Contradicted
- **Determining evidence:** `Application Error Event 1000` at `07:02:16` and `07:02:46`; `Desktop Window Manager Event 9009` at `07:02:18` and `07:03:01`
- **Interpretation:** The session is not merely slow; it is crashing in the display composition path.

### 4. GPO, logon script, or startup task delay exposed by the new image
- **Outcome:** Neutral to slight contradict
- **Determining evidence:** `TerminalServices-LocalSessionManager Event 21` at `07:02:10`; `Application Error Event 1000` at `07:02:16`; `TerminalServices-LocalSessionManager Event 40` at `07:02:17`
- **Interpretation:** No direct policy or script evidence is present in the supplied logs, while the crash evidence gives a stronger explanation.

### 5. Display or remote rendering regression introduced by the updated image
- **Outcome:** Strongly supported
- **Determining evidence:** `Application Error Event 1000` at `07:02:16`, `07:02:46`, and `07:08:24`; `Desktop Window Manager Event 9009` at `07:02:18` and `07:03:01`; unaffected `Desktop Window Manager Event 9011` at `07:01:46`
- **Interpretation:** This is the surviving and final root-cause hypothesis.

## Root Cause Statement
The incident was caused by a display or remote rendering regression introduced by the overnight `02:00` image update to `POOL-FIN-01`. On affected session hosts, `dwm.exe` repeatedly crashed in the Intel graphics module `igdumd64.dll`, causing Desktop Window Manager failure and resulting in post-logon black screens and session disconnects. `POOL-FIN-02`, which remained on the pre-update image, showed normal DWM startup and no equivalent errors.

## Resolution Summary
The recommended remediation for the image-linked graphics regression was applied to `POOL-FIN-01`, and the issue was resolved by `10:00`.

### Reported Restored State
- Users were verified logging in to hosts in `POOL-FIN-01`
- No further user issues were reported after remediation

### Resolution Actions Applied
- New-user impact was contained while remediation was executed against the affected pool
- The affected image path in `POOL-FIN-01` was remediated in line with the graphics-regression resolution plan
- `POOL-FIN-01` was returned to service after validation confirmed stable user logons and no ongoing issue reports

### Important Note
The exact implementation path of the remediation, for example image rollback to last known good or corrected image redeployment with graphics-component change, was not specified in the source input. This RCA therefore records the verified outcome and the evidence-backed remediation direction without inventing unconfirmed implementation detail.

## Incident Timeline
1. `02:00` - Overnight image update applied to `POOL-FIN-01`
2. `02:03:11` - Affected host `SHFIN-01-A` records system boot after update, evidenced by `Kernel-General Event 1` seen at `07:02:14`
3. Approximately `07:00` - User impact begins on `POOL-FIN-01`
4. `07:01:44` - Unaffected host `SHFIN-02-A` logs successful user session in `POOL-FIN-02`
5. `07:01:46` - `SHFIN-02-A` records `Desktop Window Manager Event 9011`, confirming normal DWM startup on the pre-update image
6. `07:02:10` - `SHFIN-01-A` records successful session logon for `FINBRIDGE\mlopez`
7. `07:02:16` - `SHFIN-01-A` records `Application Error Event 1000`: `dwm.exe` crashes in `igdumd64.dll`
8. `07:02:17` - `SHFIN-01-A` records session disconnect for `FINBRIDGE\mlopez`
9. `07:02:18` - `SHFIN-01-A` records `Desktop Window Manager Event 9009`
10. `07:02:44` - Reconnect logon succeeds for the same user on `SHFIN-01-A`
11. `07:02:46` - `dwm.exe` crashes again in `igdumd64.dll`
12. `07:02:47` - Session disconnect occurs again
13. `07:03:01` - DWM exit repeats on `SHFIN-01-A`
14. `07:03:10` - Second reconnect logon succeeds for the same user
15. `07:08:22` - Second user `FINBRIDGE\akapoor` logs on successfully to `SHFIN-01-A`
16. `07:08:24` - The same `dwm.exe` to `igdumd64.dll` crash pattern repeats for the second user
17. Between `07:00` and `10:00` - Incident investigation, hypothesis elimination, and remediation activity performed
18. `10:00` - Issue confirmed resolved; users successfully logging into `POOL-FIN-01` and no further issues reported

## 5 Whys Analysis
1. **Why did users see a black screen or get disconnected after login?**
   - Because Desktop Window Manager failed during session initialization on affected `POOL-FIN-01` hosts.
2. **Why did Desktop Window Manager fail?**
   - Because `dwm.exe` crashed in the Intel graphics module `igdumd64.dll`, as shown by repeated `Application Error Event 1000` entries.
3. **Why was the Intel graphics module crashing on affected hosts?**
   - Because the overnight image update introduced a graphics or rendering regression into `POOL-FIN-01`.
4. **Why did the regression affect only one pool?**
   - Because only `POOL-FIN-01` received the updated image; `POOL-FIN-02` remained on the previous image and did not exhibit the fault.
5. **Why was the faulty image able to affect production users?**
   - Because the image change reached the production pool without detecting the post-logon DWM and graphics-stack instability during pre-release validation.

## Contributing Factors
- Production pool update was applied to only one pool, which exposed a clear boundary but still allowed user impact inside that pool.
- The failure occurred after successful authentication, which can initially resemble profile or shell delay rather than a graphics-stack crash.
- Partial impact, around `40%`, may have delayed immediate identification of a single consistent technical fault.

## Corrective Actions Taken
- Isolated remediation on the affected pool
- Applied the approved fix path for the image-linked graphics regression
- Verified successful user logons to `POOL-FIN-01` after remediation
- Confirmed no ongoing issue reports after service restoration

## Preventive Actions
1. Add a mandatory post-image validation test for AVD pools that includes repeated fresh logons, reconnects, and Desktop Window Manager health checks.
2. Add an image release gate that compares critical graphics and display-component versions against the last known good image before production rollout.
3. Add automated monitoring for `Application Error Event 1000` involving `dwm.exe` and for `Desktop Window Manager Event 9009` on session hosts.
4. Require phased pool rollout with a canary host or pilot user set before broad assignment to production users.
5. Document rollback criteria and rollback timing thresholds for image-related AVD regressions.
6. Add a post-deployment verification step that compares an updated pool with an unchanged control pool where available.

## Validation of Resolution
- Resolution declared at `10:00`
- Users verified logging in to hosts in `POOL-FIN-01`
- No issues reported after remediation
- This outcome is consistent with successful removal or correction of the image-linked display regression

## Final Incident Disposition
- **Classification:** Image-induced AVD display or rendering regression
- **Primary Fault:** `dwm.exe` crash in `igdumd64.dll`
- **Affected Scope:** Approximately `40%` of users on `POOL-FIN-01`
- **Unaffected Control Scope:** `POOL-FIN-02`
- **Resolved:** Yes
- **RCA Complete:** Yes