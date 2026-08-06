# DWP Service Desk Triage Summary

## Summary (one line)
User reports overall system slowness two days after upgrading to Windows 11.

## Impact (who/how many/ business urgency)
- Who: Reporting end user with recently upgraded Windows 11 device (to-verify).
- How many: Single reported user/device currently (to-verify).
- Business urgency: Productivity degradation across multiple tasks; urgency depends on role-critical workload (to-verify).

## known facts
- Ticket reference: T-1006.
- Reported complaint: "Everything is slow".
- Reported timing/context: Windows 11 upgrade completed two days ago.

## Missing information to gather
- Specific slow activities (boot, login, Outlook, browser, Teams, file access, app launch) (to-verify).
- Whether slowness is constant or intermittent and time-of-day dependent (to-verify).
- Whether high CPU, memory, disk, or update activity is observed during incidents (to-verify).
- Whether device is on battery or docked/AC during symptoms (to-verify).
- Whether same user profile behaves similarly on another device/AVD (to-verify).
- Whether recent startup apps, security scans, or sync workloads increased post-upgrade (to-verify).
- Whether there are simultaneous network performance issues (to-verify).
- Baseline comparison: performance before upgrade and immediately after first reboot (to-verify).

## likely catagory
Post-Windows 11 upgrade general performance degradation on endpoint (to-verify).

## First diagnostic step
Identify and time one concrete slow workflow (for example app launch or login) while checking live resource usage, so triage can classify whether the bottleneck is compute, storage, or network related instead of treating "overall slowness" as a single symptom.
