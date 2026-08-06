# DWP Service Desk Triage Summary

## Summary (one line)
User reports AVD session disconnecting after about 10 minutes, then reconnecting.

## Impact (who/how many/ business urgency)
- Who: Affected AVD user (to-verify).
- How many: One reported user at present; wider AVD scope unknown (to-verify).
- Business urgency: Ongoing session instability interrupts work and may cause productivity loss (to-verify).

## known facts
- Ticket reference: T-1003.
- Reported platform: AVD.
- Reported behavior: Session disconnects after approximately 10 minutes.
- Reported follow-up behavior: Session reconnects afterward.

## Missing information to gather
- Exact client used (Windows app, web client, other) and version (to-verify).
- Whether disconnect timing is consistently around 10 minutes or variable (to-verify).
- Whether disconnects occur during idle only, active use only, or both (to-verify).
- Whether home/office network conditions or VPN are involved (to-verify).
- Whether similar disconnects affect other users in the same host pool (to-verify).
- Whether reconnect resumes same session state or starts a new session experience (to-verify).
- Whether any user-facing error/notification appears at disconnect time (to-verify).
- Whether issue started after recent policy/client/endpoint change (to-verify).

## likely catagory
AVD session stability issue potentially related to timeout, connectivity, or host pool session policy behavior (to-verify).

## First diagnostic step
Confirm whether disconnects happen during active input versus idle and collect exact disconnect timestamp plus any user-facing message; this is the fastest way to separate session-timeout policy behavior from network/client instability.
