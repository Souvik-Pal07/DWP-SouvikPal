# DWP Service Desk Triage Summary

## Summary (one line)
Teams audio is reported as non-functional on three machines in the same meeting room.

## Impact (who/how many/ business urgency)
- Who: Users operating three meeting-room machines (to-verify).
- How many: Three affected machines reported in one room.
- Business urgency: Medium to high impact due to meeting disruption and communication failure (to-verify).

## known facts
- Ticket reference: T-1005.
- Application context: Teams.
- Reported issue: Audio is dead/non-functional.
- Scope clue: Three machines in the same meeting room.

## Missing information to gather
- Whether issue is no input, no output, or both (to-verify).
- Whether all three machines use the same room audio peripherals/dock/cabling path (to-verify).
- Whether issue occurs in Teams only or also in system sound tests/other apps (to-verify).
- Whether affected users can hear/be heard using a USB headset directly on each machine (to-verify).
- Whether Teams audio device selection shows expected room devices (to-verify).
- Whether this began after a recent update/change in room hardware or configuration (to-verify).
- Whether any mute states (hardware/software) or audio enhancements are enabled (to-verify).
- Whether problem occurs in all meetings or one specific meeting scenario (to-verify).

## likely catagory
Meeting-room endpoint audio path failure affecting Teams across multiple room devices (to-verify).

## First diagnostic step
Run a quick isolation check by connecting a known-good USB headset to one affected machine and testing Teams call audio; this immediately separates shared room hardware-path issues from Teams client or OS audio stack issues.
