# DWP Service Desk Triage Summary

## Summary (one line)
User reports they cannot connect to VDI today from home Wi-Fi, after it was working on Friday.

## Impact (who/how many/ business urgency)
- Who: Single end user (as reported).
- How many: 1 user reported so far.
- Business urgency: Not stated (to confirm).

## known facts
- Current issue: "cant get on the vdi thing today keeps saying cannot connect."
- Last known good: "worked friday."
- User location/network context: "im at home on wifi."

## Missing information to gather
- Exact error wording, code, and where it appears (VDI client, web portal, MFA prompt) (to confirm).
- Whether the issue affects only this user or multiple users (to confirm).
- Whether user can access corporate resources outside VDI (for example webmail or VPN) (to confirm).
- Whether home internet is otherwise stable and whether reconnect/reboot was attempted (to confirm).
- VDI client and endpoint details: client version, device type, OS updates, recent changes since Friday (to confirm).
- Whether MFA/authentication succeeds or fails during connection attempt (to confirm).
- Whether user can connect using an alternate network/hotspot as a comparison test (to confirm).

## likely catagory
VDI remote access connectivity/authentication issue (to confirm).

## Suggest first diagnostic step
Capture the exact connection error message and code from the user’s VDI client or portal, then verify whether authentication (including MFA) completes; this quickly separates identity/auth failures from endpoint/network connectivity issues.
