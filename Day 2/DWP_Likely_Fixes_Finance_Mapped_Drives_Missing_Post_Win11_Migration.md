1. Restore reliable logon script execution after Win11 migration
Why it is likely, given what we know: Ticket explicitly says a logon script exists and seems unreliable post-upgrade; drives return when remapped manually, which points to an execution/timing issue rather than share loss.
Specific check to confirm it is the right fix: Verify script assignment and execution at morning sign-in via Group Policy results and logon-related event logs; confirm script did not run or failed (to confirm).
Action to take if confirmed: Correct script assignment/scope and execution context, fix any script/path errors, and re-test at cold morning logon (to confirm).

2. Fix Group Policy drive mapping processing (if mappings are GPP-backed, to confirm)
Why it is likely, given what we know: Post-migration policy processing changes commonly affect mapped drives; symptoms are daily disappearance and manual recovery.
Specific check to confirm it is the right fix: Check whether S: and P: are defined in Group Policy Preferences and whether policy application for drive mappings succeeds at user logon (to confirm).
Action to take if confirmed: Correct the GPP drive-map item targeting/order/action settings, force policy refresh, and validate persistence across reboot and next-day sign-in (to confirm).

3. Resolve logon-time network readiness race condition
Why it is likely, given what we know: “Missing every morning” can indicate user session starts before network/domain path is ready; manual remap later works.
Specific check to confirm it is the right fix: Correlate sign-in timing with network availability and domain connectivity at logon; confirm mappings appear if user waits for full network initialization before sign-in (to confirm).
Action to take if confirmed: Enforce synchronous/“wait for network at startup and logon” behavior and retest first sign-in of the day (to confirm).

4. Correct credential/session token issues for mapped shares
Why it is likely, given what we know: Manual remap success can occur when credentials are re-prompted or refreshed; upgrade can invalidate stored auth context (to confirm).
Specific check to confirm it is the right fix: Confirm whether mapped drive failures coincide with auth prompts/access denied and whether remap succeeds only after credential refresh (to confirm).
Action to take if confirmed: Update/remove stale stored credentials, ensure correct user context to target shares, and validate reconnect on subsequent logons (to confirm).

5. Replace per-session manual mappings with persistent policy-based mappings
Why it is likely, given what we know: Repeated morning remap suggests mapping may not be persistently managed in a durable enterprise method (to confirm).
Specific check to confirm it is the right fix: Determine current mapping method (manual vs script vs GPP) and verify whether mappings are configured to persist and reapply automatically (to confirm).
Action to take if confirmed: Standardize to centrally managed persistent mappings (preferred policy method), then validate across reboot and next-day logon (to confirm).

6. Validate Win11-specific client configuration/regression affecting drive reconnect
Why it is likely, given what we know: Issue started only after migration; could be a client-side Win11 behavior/regression impacting reconnect logic (to confirm).
Specific check to confirm it is the right fix: Compare affected device config/build against a known-good Win11 peer in Finance; confirm issue reproduces only on certain build/config combinations (to confirm).
Action to take if confirmed: Apply the approved Win11 configuration correction/patch for reconnect behavior, then monitor for at least two morning cycles (to confirm).
