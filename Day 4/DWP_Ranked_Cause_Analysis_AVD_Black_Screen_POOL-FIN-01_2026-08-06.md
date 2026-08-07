# Ranked Cause Analysis: AVD Black Screen on POOL-FIN-01

## Scope Facts
- **Symptom:** Blank screen post login. Clears after ~30 seconds for some users and persists for others.
- **Who:** Approximately 40% of users on `POOL-FIN-01`. `POOL-FIN-02` is completely unaffected.
- **Since:** Approximately 07:00 this morning.
- **Change:** Overnight image update applied to `POOL-FIN-01` at 02:00. `POOL-FIN-02` was **not** updated.

## Working Position
Do not commit to a single root cause yet.

The strongest weighting factor in the current scope is the clean split between the two pools:
- `POOL-FIN-01` changed and is affected.
- `POOL-FIN-02` did not change and is unaffected.

That timing and scope pattern makes an image-linked regression the leading hypothesis. Causes that depend on shared infrastructure are less likely unless the new image changed how `POOL-FIN-01` interacts with that shared dependency.

## Cause Most Consistent With The Timing Clue
**Most consistent cause:** An image-introduced regression in `POOL-FIN-01` logon or session initialization.

Why this best fits:
- The only stated difference between the affected and unaffected pools is the 02:00 image update.
- Symptoms begin the same morning after that change window.
- The issue is isolated to the updated pool.
- A post-login black screen that clears after ~30 seconds for some users is consistent with a startup delay introduced in the image rather than a broad platform outage.

## Re-Ranked Top 5 Likely Causes

### 1. Image-level logon initialization regression introduced by the 02:00 `POOL-FIN-01` update
**Why this fits the scope facts**
- Best match for the pool split: updated pool affected, non-updated pool clean.
- Timing aligns directly with the overnight image change.
- Mixed severity across users fits a regression that depends on host state, session timing, or user-specific startup load.

**Single fastest check**
- Test a fresh login on a known updated `POOL-FIN-01` host and compare it directly with a login to `POOL-FIN-02` using the prior image.

### 2. FSLogix profile attach or profile-load delay triggered by the new image
**Why this fits the scope facts**
- Black screen after login with delayed recovery is a common sign of profile load delay.
- The new image may have changed service timing, agent version, filter behavior, or profile mount sequence.
- `POOL-FIN-02` being unaffected lowers the chance of a pure storage/platform issue and raises the chance of an image-to-profile interaction issue.

**Single fastest check**
- Review FSLogix logs on one affected `POOL-FIN-01` session host for slow attach, retries, or failures during the user sign-in window.

### 3. Windows shell, AppX, or AppReadiness startup delay introduced by the updated image
**Why this fits the scope facts**
- A blank desktop immediately after login that clears after about 30 seconds strongly fits delayed shell or AppX startup.
- These components are image-resident, which matches the affected-only-after-update pattern.
- `POOL-FIN-02` staying healthy makes a general AVD service issue less likely.

**Single fastest check**
- Check shell and AppReadiness-related events on an affected `POOL-FIN-01` host at logon time and compare them with a normal login on `POOL-FIN-02`.

### 4. GPO, logon script, or startup task delay exposed by the new image
**Why this fits the scope facts**
- The policy itself may be shared, but the new image could have changed a dependency, service state, scheduled task behavior, or script path.
- That would explain why only the updated pool shows the symptom.
- The roughly 30-second delay is compatible with synchronous logon processing or a timeout during startup actions.

**Single fastest check**
- Review Winlogon and Group Policy operational logs on an affected `POOL-FIN-01` host for delays during the black-screen window.

### 5. Display or remote rendering regression introduced by the updated image
**Why this fits the scope facts**
- Graphics and rendering components are image-specific, so the updated-only pool boundary supports this possibility.
- It ranks lower because the symptom pattern sounds more like delayed logon completion than a pure display fault.
- Still plausible if the new image changed display drivers or remote rendering components.

**Single fastest check**
- Inspect display and remote desktop event logs on an affected updated host for graphics initialization errors around user logon.

## Current Hypothesis
The most likely explanation, based on scope facts alone, is that the 02:00 image update introduced a regression into `POOL-FIN-01` that delays or breaks post-login session initialization.

The leading branches under that hypothesis are:
1. General logon initialization regression in the new image
2. FSLogix profile load interaction with the new image
3. Shell or AppReadiness startup delay in the new image

## Analyst Guardrail
Do not commit to one root cause until host-level checks confirm whether the delay is occurring in:
- profile attach
- shell startup
- policy or script processing
- display stack initialization

## Event Details Reviewed

### Affected Session Host: `SHFIN-01-A`
### Incident Window: `07:00-07:30`
### Source: Application and System Logs

**07:02:10 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Remote Desktop Services session logon succeeded.
- User: `FINBRIDGE\mlopez`
- Session ID: `3`
- Source: `10.10.1.55`

**07:02:14 - Microsoft-Windows-Kernel-General Event 1**
- System boot time recorded as `02:03:11`.
- This confirms the host restarted shortly after the overnight image update window.

**07:02:16 - Application Error Event 1000**
- Faulting application: `dwm.exe`
- Version: `10.0.22621.2861`
- Faulting module: `igdumd64.dll`
- Module version: `31.0.101.4146`
- Exception code: `0xc0000005`
- Fault offset: `0x0000000000047f12`

**07:02:17 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40**
- Session disconnected.
- User: `FINBRIDGE\mlopez`
- Session ID: `3`
- Reason code: `0`

**07:02:18 - Desktop Window Manager Event 9009**
- Desktop Window Manager exited with code `0x40010004`.

**07:02:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Session logon succeeded on reconnect.
- User: `FINBRIDGE\mlopez`
- Session ID: `3`

**07:02:46 - Application Error Event 1000**
- `dwm.exe` faulted again in `igdumd64.dll`.
- Exception code: `0xc0000005`

**07:02:47 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 40**
- Session disconnected again.
- User: `FINBRIDGE\mlopez`
- Session ID: `3`

**07:03:01 - Desktop Window Manager Event 9009**
- Desktop Window Manager exited again with code `0x40010004`.

**07:03:10 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Second reconnect logon succeeded.
- User: `FINBRIDGE\mlopez`
- Session ID: `4`

**07:08:22 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Session logon succeeded.
- User: `FINBRIDGE\akapoor`
- Session ID: `5`
- Source: `10.10.1.61`

**07:08:24 - Application Error Event 1000**
- `dwm.exe` faulted in `igdumd64.dll` again for a second user session.
- Exception code: `0xc0000005`

### Unaffected Comparison Host: `SHFIN-02-A` (`POOL-FIN-02`)
### Image Version: `10.0.22621.2861-build-20240313` (pre-update)

**07:01:44 - Microsoft-Windows-TerminalServices-LocalSessionManager Event 21**
- Session logon succeeded.
- User: `FINBRIDGE\bwalker`
- Session ID: `2`

**07:01:46 - Desktop Window Manager Event 9011**
- Desktop Window Manager started successfully.
- No Application Error events were recorded in the same window.

## Reviewed Hypotheses Against Evidence

### 1. Image-level logon initialization regression introduced by the 02:00 `POOL-FIN-01` update
**Judgement:** Supports

**Determining event(s)**
- `Kernel-General Event 1` at `07:02:14`
- `Desktop Window Manager Event 9011` on unaffected `SHFIN-02-A` at `07:01:46`

**Reasoning**
- The affected host rebooted immediately after the image update window.
- The unaffected host on the pre-update image showed normal DWM startup and no matching crash pattern.
- This supports an image-linked regression on `POOL-FIN-01`.

### 2. FSLogix profile attach or profile-load delay triggered by the new image
**Judgement:** Contradicts

**Determining event(s)**
- `TerminalServices-LocalSessionManager Event 21` at `07:02:10`
- `Application Error Event 1000` at `07:02:16`, `07:02:46`, and `07:08:24`

**Reasoning**
- Logon succeeded before the failure occurred.
- The decisive error is repeated `dwm.exe` crashing in `igdumd64.dll`, not a profile load stall or attach failure.
- The evidence points away from FSLogix as the primary explanation.

### 3. Windows shell, AppX, or AppReadiness startup delay introduced by the updated image
**Judgement:** Contradicts

**Determining event(s)**
- `Application Error Event 1000` at `07:02:16` and `07:02:46`
- `Desktop Window Manager Event 9009` at `07:02:18` and `07:03:01`
- `TerminalServices-LocalSessionManager Event 40` at `07:02:17` and `07:02:47`

**Reasoning**
- This is not just a slow startup pattern.
- The evidence shows an actual crash sequence involving DWM and the graphics module, followed by disconnects.
- That contradicts a generic shell or AppReadiness delay as the main cause.

### 4. GPO, logon script, or startup task delay exposed by the new image
**Judgement:** Neutral to slight contradict

**Determining event(s)**
- `TerminalServices-LocalSessionManager Event 21` at `07:02:10`
- `Application Error Event 1000` at `07:02:16`
- `TerminalServices-LocalSessionManager Event 40` at `07:02:17`

**Reasoning**
- The supplied logs do not show direct evidence of GPO, script, or startup-task delay.
- The immediate crash path after successful logon makes a graphics failure a better fit.
- This does not fully eliminate the possibility, but the current evidence is not supportive.

### 5. Display or remote rendering regression introduced by the updated image
**Judgement:** Strongly supports

**Determining event(s)**
- `Application Error Event 1000` at `07:02:16`, `07:02:46`, and `07:08:24`
- `Desktop Window Manager Event 9009` at `07:02:18` and `07:03:01`
- `Desktop Window Manager Event 9011` on unaffected `SHFIN-02-A` at `07:01:46`

**Reasoning**
- The affected host shows repeated `dwm.exe` crashes in `igdumd64.dll` across multiple sessions.
- The unaffected host shows successful DWM startup with no equivalent errors.
- This is direct evidence of an image-linked graphics or rendering failure.

## Resolution Based On Surviving Hypothesis

### Surviving Hypothesis
The surviving hypothesis is a **display or remote rendering regression introduced by the updated `POOL-FIN-01` image**, specifically `dwm.exe` crashing in the Intel graphics module `igdumd64.dll` after logon.

### Why This Hypothesis Survives
- `Application Error Event 1000` at `07:02:16`, `07:02:46`, and `07:08:24` shows repeated `dwm.exe` crashes in `igdumd64.dll`.
- `Desktop Window Manager Event 9009` at `07:02:18` and `07:03:01` confirms DWM exited during the affected sessions.
- `Desktop Window Manager Event 9011` at `07:01:46` on unaffected `SHFIN-02-A` shows the normal comparison case.
- The pattern is consistent with an image-linked graphics stack issue rather than a profile, shell, or policy delay.

## Detailed Resolution Steps

1. Stop new user placements on `POOL-FIN-01` to contain impact.
2. Redirect user sessions to `POOL-FIN-02` where capacity permits.
3. Identify all `POOL-FIN-01` hosts built from the 02:00 updated image and treat them as suspect.
4. Confirm the same `dwm.exe` and `igdumd64.dll` crash pattern on at least two additional affected `POOL-FIN-01` hosts.
5. Compare the Intel graphics driver version on affected `POOL-FIN-01` hosts with the pre-update `POOL-FIN-02` image baseline.
6. Roll back `POOL-FIN-01` to the last known good image if available.
7. If rollback is not immediately possible, remove, replace, or downgrade the Intel graphics component in the updated image and prepare a corrected build.
8. Deploy the corrected or rolled-back image to a small validation set of `POOL-FIN-01` hosts first.
9. Validate with repeated fresh logons and reconnects.
10. Confirm that no new `Application Error 1000` events for `dwm.exe`, no `igdumd64.dll` faults, and no `Desktop Window Manager Event 9009` entries are generated.
11. Confirm normal session behavior and successful DWM startup before reopening the pool for general use.
12. Roll out the corrected image to remaining `POOL-FIN-01` hosts in controlled batches.

## Validation Criteria After Remediation
- Users reach the desktop without black screen persistence or forced disconnect.
- No `Application Error Event 1000` entries for `dwm.exe`.
- No `igdumd64.dll` fault entries during logon.
- No `Desktop Window Manager Event 9009` entries during affected user sessions.
- Normal `Desktop Window Manager Event 9011` startup events are present.