# Runbook: AVD Black Screen Incident - `POOL-FIN-01`

Title: AVD Black Screen Incident - POOL-FIN-01
Version: 1.0
Date: 07/08/2026
Author: Sathishbabu
Reviewed: self
Status: draft
Change: initial version from RCA

## Prerequisites
- [ ] You can sign in to the Azure portal with Azure Virtual Desktop administrator rights for `POOL-FIN-01`.
- [ ] You have permission to change session host drain state in the Azure portal.
- [ ] You have permission to restart, reimage, or redeploy session hosts if rollback is needed.
- [ ] You have access to the session host console, Bastion, or equivalent remote admin path used in your environment.
- [ ] You have access to Event Viewer on the session host, or to Log Analytics if host logs are centralized.
- [ ] You know the approved last known good image name or the approved remediation image for `POOL-FIN-01`.
- [ ] You know the incident bridge, service desk, or escalation contact to use if user impact widens.
- [ ] The end user has provided the affected username or usernames.
- [ ] The end user has provided the affected host pool name: `POOL-FIN-01`.
- [ ] The end user has provided the approximate time the black screen or disconnect started.
- [ ] The end user has confirmed whether the black screen clears after about 30 seconds or stays stuck.
- [ ] The end user has confirmed whether the issue happens on reconnect as well as the first login.
- [ ] The end user has confirmed whether the issue is limited to `POOL-FIN-01` or also appears in `POOL-FIN-02`.
- [ ] The end user has provided any screenshot, error text, or incident ticket reference.

## Procedure
1. Open the Azure portal and go to `Azure Virtual Desktop`.
   - Expected result: The Azure Virtual Desktop landing page is visible.

2. In the Azure portal, open `Host pools`.
   - Expected result: The list of host pools is visible.

3. Select `POOL-FIN-01`.
   - Expected result: The `POOL-FIN-01` host pool overview page opens.

4. Select `Session hosts` from the `POOL-FIN-01` host pool menu.
   - Expected result: The session host list for `POOL-FIN-01` is visible.

5. Select one affected session host from the list.
   - Expected result: The session host details page opens.

6. Set `Allow new sessions` to `No` on the affected session host.
   - Expected result: The host enters drain mode and stops accepting new user sessions.
   - Elevated permissions required: Yes.

7. Open `Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts`.
   - Expected result: The `POOL-FIN-02` session host list is visible and still available.

8. On the affected session host, open `Connect` or the approved remote console path and sign in with an admin account.
   - Expected result: You get an interactive admin session on the host.
   - Elevated permissions required: Yes.

9. Open `Event Viewer` on the session host.
   - Expected result: Event Viewer opens successfully.

10. Expand `Windows Logs` and select `Application`.
   - Expected result: The Application event log is visible.

11. Filter the Application log for `Event ID 1000` and source `Application Error`.
   - Expected result: You can see the `dwm.exe` fault entry that references `igdumd64.dll`.

12. Expand `Windows Logs` and select `System`.
   - Expected result: The System log is visible.

13. Filter the System log for source `Desktop Window Manager` and `Event ID 9009`.
   - Expected result: You can see the DWM exit event that follows the application fault.

14. Apply the approved image remediation for `POOL-FIN-01` from the incident change or rollback record.
   - Expected result: The affected pool is updated to the approved fixed or reverted image state.
   - Elevated permissions required: Yes.

15. Restart or redeploy the affected `POOL-FIN-01` session host or hosts using the approved remediation path.
   - Expected result: The hosts return in the corrected state and are ready for validation.
   - Elevated permissions required: Yes.

16. Return to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
   - Expected result: The remediated session hosts are visible in the pool.

17. Set `Allow new sessions` to `Yes` on the remediated `POOL-FIN-01` session host or hosts.
   - Expected result: The pool can accept new user sessions again.
   - Elevated permissions required: Yes.

## Verification
1. Open the Azure portal and go to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
   - Expected result: The remediated session host is visible and its state is `Available`.

2. On the remediated session host, select `Connect` and sign in with the test or support account.
   - Expected result: The remote desktop opens without a black screen.

3. On the session host, open `Event Viewer`.
   - Expected result: Event Viewer opens.

4. In `Event Viewer`, expand `Windows Logs` and select `Application`.
   - Expected result: The Application log is visible.

5. In `Event Viewer > Windows Logs > Application`, select `Filter Current Log` and filter for `Event ID 1000` and source `Application Error` for the test login time window.
   - Expected result: No new `dwm.exe` fault entries appear during the test login.

6. In `Event Viewer`, expand `Windows Logs` and select `System`.
   - Expected result: The System log is visible.

7. In `Event Viewer > Windows Logs > System`, select `Filter Current Log` and filter for `Event ID 9009` and source `Desktop Window Manager` for the test login time window.
   - Expected result: No new DWM exit events appear during the test login.

8. Return to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and confirm `Allow new sessions` is `Yes`.
   - Expected result: The host is ready to accept user traffic again.

## Rollback
1. Open the Azure portal and go to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
   - Expected result: The affected host is visible.

2. Select the affected session host and set `Allow new sessions` to `No`.
   - Expected result: The host stops taking new user sessions.
   - Elevated permissions required: Yes.

3. Open the approved image or deployment record for `POOL-FIN-01`.
   - Expected result: The last known good image version is visible.

4. Start the approved rollback action for `POOL-FIN-01` from the same host pool page.
   - Expected result: The host begins reimage, redeploy, or restart using the last known good image.
   - Elevated permissions required: Yes.

5. Open `Event Viewer` on the remediated host.
   - Expected result: Event Viewer opens.

6. In `Event Viewer > Windows Logs > Application`, filter for `Event ID 1000` and source `Application Error`.
   - Expected result: No new `dwm.exe` crash appears after the rollback.

7. In `Event Viewer > Windows Logs > System`, filter for `Event ID 9009` and source `Desktop Window Manager`.
   - Expected result: No new DWM exit appears after the rollback.

8. Return to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and set `Allow new sessions` to `Yes`.
   - Expected result: The host is ready to receive users again.

## Notes
- The evidence for this incident points to a display or remote rendering regression, not a profile attach issue.
- The fault signature to look for is `dwm.exe` crashing in `igdumd64.dll` with Event `1000`, followed by DWM exit Event `9009`.
- `POOL-FIN-02` is the safe comparison pool and should remain available during troubleshooting.
- Do not spend time chasing logon scripts, AppX delay, or FSLogix as the primary cause unless the crash signature is absent.
- Do not return `POOL-FIN-01` to production until a successful test login and reconnect have both completed.
- The exact remediation implementation path for the original incident was not specified in the RCA, so use the approved change or rollback record for the actual image action.
- If the affected image cannot be identified quickly, keep the pool drained and escalate to the AVD platform owner.
