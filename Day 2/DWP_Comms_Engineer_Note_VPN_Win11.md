Engineer note:
Root cause:
- Win11 upgrade removed the legacy VPN client.
- Intune did not trigger re-deployment of the new VPN client due to a detection-rule gap.

Exact action taken:
- Manually removed stale VPN registry entries under HKLM\SOFTWARE\<vendor>.
- Force-triggered Intune sync.
- New VPN client deployed.
- Split-tunnel configuration applied.

Verification:
- Connectivity confirmed to all internal subnets.
- No data loss observed.

Preventive action needed:
- Fix the Intune detection-rule gap so Win11-upgraded devices trigger automatic deployment of the new VPN client and avoid recurrence.