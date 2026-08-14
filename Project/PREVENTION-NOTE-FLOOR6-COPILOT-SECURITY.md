# Process Improvement Recommendation: Floor 6 Copilot Security

**Issue:** Copilot displayed confidential legal information  
**Date:** 2026-08-14  
**Status:** Draft

## 1. Specific Named Control
**Legal Data Copilot Approval Gate**

## 2. How It Works
Any policy or setting that allows Copilot to search legal users' files, email, or synced content must be approved by the legal partner responsible for the data before it is enabled. Approval is only granted after a documented review of what content Copilot can reach, what locations it can index, and what the user group is permitted to see directly.

## 3. Owner
**Security and Compliance Lead**

## 4. Trigger
Any change that enables Copilot search, broadens Copilot data access, or introduces Copilot to a legal department or other sensitive group.

## 5. Success Metric
- No Copilot-related change goes live without legal and security approval.
- The approved search scope is documented before deployment.
- Sensitive matters are excluded from Copilot visibility unless explicitly approved.
- A full approval record exists for every sensitive group rollout.

## 6. Why It Would Have Caught This Before Monday Morning
The Floor 6 report involved a confidential matter appearing in Copilot during the same period as the login issues. A legal-data approval gate would have forced a review of Copilot search scope before the feature could affect the legal floor, which would have exposed the risk of confidential content being surfaced and blocked the change before users saw it on Monday morning.
