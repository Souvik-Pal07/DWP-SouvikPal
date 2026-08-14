# Process Improvement Recommendation: Floor 6 Desktop Shortcuts Missing

**Issue:** Desktop shortcuts appeared missing after login  
**Date:** 2026-08-14  
**Status:** Draft

## 1. Specific Named Control
**Desktop Content Pre-Sync Gate**

## 2. How It Works
Before a OneDrive Known Folder Move policy is applied to a floor, the Desktop folder for a pilot user is inventoried and fully synced to OneDrive in advance. The policy may only be released after the pilot device confirms the Desktop contents are already present in OneDrive\Desktop and the local desktop does not appear empty during sign-in.

## 3. Owner
**Desktop Services Lead**

## 4. Trigger
Any deployment of a folder-redirection policy that changes where the Desktop folder is stored for an active user group.

## 5. Success Metric
- Pilot Desktop contents are present in OneDrive\Desktop before go-live.
- First login does not show an empty desktop.
- Shortcuts remain visible during and after sign-in.
- No missing-shortcuts calls are raised for the floor within the first business day.

## 6. Why It Would Have Caught This Before Monday Morning
The Floor 6 issue happened because the policy moved 2.3 GB of desktop content during the first login, which made the desktop look empty until sync completed. A pre-sync gate would have moved that work to Friday, confirmed the shortcuts were already in OneDrive, and prevented the Monday morning empty-desktop symptom entirely.
