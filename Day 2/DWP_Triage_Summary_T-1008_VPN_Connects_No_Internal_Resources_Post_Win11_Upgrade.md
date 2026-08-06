# DWP Service Desk Triage Summary

## Summary (one line)
User reports VPN connects but internal resources are unreachable after a Windows 11 upgrade.

## Impact (who/how many/ business urgency)
- Who: Reporting remote user dependent on VPN access (to-verify).
- How many: Single reported user/device currently; broader scope unknown (to-verify).
- Business urgency: High potential impact if internal apps/shares are inaccessible for core work (to-verify).

## known facts
- Ticket reference: T-1008.
- Reported behavior: VPN shows connected state.
- Reported issue: No internal resources reachable.
- Reported timing/context: After Windows 11 upgrade.

## Missing information to gather
- Which internal resources fail (file shares, intranet, line-of-business apps, remote desktop, name-based endpoints) (to-verify).
- Whether access fails by hostname only, by IP only, or both (to-verify).
- Whether internet browsing works normally while VPN is connected (to-verify).
- Whether issue occurs on all networks (home, hotspot, office) (to-verify).
- Whether other users on same VPN profile can reach resources (to-verify).
- Whether VPN profile or client settings changed during/after upgrade (to-verify).
- Whether DNS resolution for internal names succeeds while connected (to-verify).
- Whether split tunneling or route enforcement behavior differs from expected baseline (to-verify).

## likely catagory
Post-Windows 11 upgrade VPN routing/name-resolution/access path issue despite successful tunnel connection (to-verify).

## First diagnostic step
Test one known internal resource by both hostname and IP immediately after VPN connection, and record results; this quickly distinguishes DNS resolution issues from routing/access-control path failures.
