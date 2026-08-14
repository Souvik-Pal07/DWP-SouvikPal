# Process Improvement Recommendation: Floor 6 Login Delay

**Issue:** Slow login after Windows 11 migration  
**Date:** 2026-08-14  
**Status:** Draft

## 1. Specific Named Control
**KFM Pilot Release Gate**

## 2. How It Works
Before any OneDrive Known Folder Move policy is assigned to a live floor, the release must be piloted on one test device from that floor and signed off only after the first login completes in under 15 seconds. The pilot device must also show no 32-minute policy application window in Event Viewer and no first-login sync block in the OneDrive log.

## 3. Owner
**Intune Release Manager**

## 4. Trigger
Any new or changed OneDrive folder redirection policy for a user group larger than one device.

## 5. Success Metric
- Pilot device first login completes in under 15 seconds.
- Event Viewer does not show a 32-minute policy application window.
- OneDrive log does not show the first-login sync block.
- The policy is not expanded to the full floor until all checks pass.

## 6. Why It Would Have Caught This Before Monday Morning
The Floor 6 issue was caused by the first post-deployment login running a large desktop sync. A pilot gate would have exposed that delay on the Friday test device before the policy reached the full Floor 6 group, so the slow login would have been blocked before Monday morning users were affected.
