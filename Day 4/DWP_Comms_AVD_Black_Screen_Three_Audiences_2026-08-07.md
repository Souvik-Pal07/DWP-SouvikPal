# AVD Incident Communication Pack (Three Audiences)

## Shared Facts Used In All Versions
- Access is restored and data is safe.
- Incident scope was limited to POOL-FIN-01.
- POOL-FIN-02 was unaffected.
- About 40% of users in POOL-FIN-01 were impacted.
- Symptom was a black screen after login, sometimes clearing in about 30 seconds, sometimes followed by disconnect.
- Issue started around 07:00.
- POOL-FIN-01 had an overnight image update at 02:00.
- Root cause was an image-linked display/rendering regression where dwm.exe crashed in igdumd64.dll.
- The remediation plan was applied to POOL-FIN-01 and service was restored at 10:00.
- Verification confirmed users could log in to POOL-FIN-01 and no further issues were reported.

## Audience 1 - Non-Technical Executive
Access is restored and your data is safe. This morning, around 07:00, a login display issue affected about 40% of users in POOL-FIN-01 after its 02:00 overnight update; POOL-FIN-02 was unaffected. The fix was applied, service was restored at 10:00, and users are now logging in normally with no further reports. No action is needed from you.

## Audience 2 - Affected End-User Team
Your access is restored and your data is safe. Around 07:00, about 40% of users in POOL-FIN-01 saw a black screen after login after an overnight 02:00 update, while POOL-FIN-02 was not affected. Some screens cleared in about 30 seconds and some sessions disconnected. The fix was applied and service was restored at 10:00, and users are now logging in normally with no further reports. If you see this again, contact the Service Desk immediately.

## Audience 3 - Engineer-to-Engineer Internal Note
Status: Resolved at 10:00. Access restored, data safe, and no further user issues reported.

Scope and timing:
- Affected pool: POOL-FIN-01 only
- Unaffected control: POOL-FIN-02
- User impact: about 40% of POOL-FIN-01 users
- Symptom: post-logon black screen; some sessions recovered in about 30s, others disconnected
- Start time: about 07:00
- Change correlation: POOL-FIN-01 image update at 02:00; POOL-FIN-02 not updated

Root cause:
- Image-linked display/rendering regression on POOL-FIN-01.
- Failure mode: dwm.exe crash in igdumd64.dll on affected hosts.

Supporting config and evidence detail:
- Affected host example: SHFIN-01-A boot reflected post-update window (Kernel-General Event 1 seen at 07:02:14 with boot time 02:03:11).
- Repeated app fault pattern on affected host: Application Error Event 1000 (dwm.exe faulting module igdumd64.dll, version 31.0.101.4146, exception 0xc0000005) with follow-on DWM exit Event 9009 and user disconnect events.
- Unaffected comparison host SHFIN-02-A (pre-update image) showed normal DWM start (Event 9011) and no matching Application Error events in window.

Exact action taken:
- New-user impact was contained while remediation was executed against the affected pool.
- The affected image path in POOL-FIN-01 was remediated in line with the approved graphics-regression fix plan.
- POOL-FIN-01 was returned to service after validation checks.

Verification step and outcome:
- Verified users can log in to POOL-FIN-01 hosts after remediation.
- No further issue reports after service restoration.

Preventive action required:
1. Enforce post-image AVD validation with repeated fresh logons, reconnect tests, and DWM health checks before production rollout.
2. Gate image release on graphics/display component comparison against last known good image.
3. Add alerting for Application Error Event 1000 involving dwm.exe and DWM Event 9009 on session hosts.
4. Use phased rollout with canary hosts or pilot users before broad assignment.
5. Maintain documented rollback criteria and trigger thresholds for image regressions.
6. Include cross-pool post-deployment comparison when an unchanged control pool is available.