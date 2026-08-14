# Knowledge Base - L2/L3
## Floor 6 Copilot Displays Confidential Legal Data

**Version:** v1.0  
**Date:** 07/08/2026  
**Status:** Draft

## Background
Copilot is integrated with the user session and can surface content the user is allowed to reach through connected Microsoft services. In a legal department, that means the data model, file locations, and permissions matter. If Copilot surfaces a confidential matter that the user says they should not see, treat it as a security incident until proven otherwise.

## Symptom
The engineer receives a report that Copilot displayed a client matter, legal document, or confidential result the user did not expect. The user may say they were asking about login delay, searching something else, or simply saw the document name appear in Copilot results. The incident must be treated as possible unauthorized exposure, not a normal help request.

## Root Cause
Specific technical cause:
- The exact root cause is not confirmed by the report alone.
- The technically relevant condition is that Copilot surfaced a confidential legal item during the user session.
- The likely cause is one of four control failures: over-broad Copilot search scope, unintended indexing of synced content, shared-drive permissions exposed through the user session, or user misunderstanding of an authorized result.

Evidence that confirms the incident is real enough to investigate:
- The user reported the specific document or matter name.
- The user stated they did not expect to have access to it.
- The report happened in the same window as the Floor 6 login and OneDrive activity.
- The device and audit trail may contain the query, the returned result, and the source path.

Evidence required to confirm the exact cause:
- Microsoft 365 audit or Copilot activity logs for the user and timestamp.
- OneDrive sync logs at C:\Users\[user]\AppData\Local\Microsoft\OneDrive\logs\.
- Intune or Microsoft 365 policy settings that define Copilot search scope.
- File permissions on the source document or shared location.

## Detection
Target: prove whether Copilot returned a permitted item, a mis-scoped item, or an unauthorized item.

### 1) Preserve the user session
Action:
- Do not restart, log off, or clear browser history on the device.

Expected result:
- The device remains in its original state for evidence collection.

### 2) Capture the user statement and query text
Action:
- Record the exact wording of what Copilot showed and the exact prompt the user entered.

Expected result:
- You have a timestamped record of the visible document name, matter name, and query.

### 3) Check Microsoft 365 audit evidence
Portal path:
- https://compliance.microsoft.com > Audit

What to look for:
- User name, incident time, and any Copilot-related activity that matches the reported window.
- Query source, returned content, and the location that Copilot surfaced.

### 4) Check OneDrive sync evidence
Log location:
- C:\Users\[user]\AppData\Local\Microsoft\OneDrive\logs\

What to look for:
- Whether the file or folder containing the matter synced to OneDrive during the same window.
- Whether the content existed in a location Copilot could index or surface.

### 5) Review policy scope if security authorizes it
Portal path:
- https://endpoint.microsoft.com > Devices > Configuration policies

What to look for:
- Any Copilot-related policy, search scope, data access scope, or assignment to Floor 6 or the wider tenant.

### 6) Verify the user’s direct access path
Action:
- Confirm whether the user could open the same file directly through the normal source location.

Expected result:
- If the user can open it directly, the issue may be a policy/expectation problem.
- If the user cannot open it directly, treat it as a possible access-control exposure.

## Resolution
Use this sequence to contain the exposure and hand the case to security.

### A) Escalate immediately
Action:
- Call the security team and create the security incident ticket.

Expected result:
- Security owns the investigation and the incident is tracked.

### B) Preserve evidence
Action:
- Keep the device powered on and unchanged.
- Capture screenshots only if they do not alter the system state.

Expected result:
- The audit trail remains usable for forensic review.

### C) Collect the evidence package
Action:
- Attach the user statement, timestamps, audit results, and OneDrive log references to the incident ticket.

Expected result:
- Security has enough data to confirm whether Copilot surfaced an authorized item or exposed something it should not have.

### D) Apply containment only if security authorizes it
Portal path:
- https://endpoint.microsoft.com > Devices > Configuration policies > Copilot-related policy

Action:
- Reduce the Copilot search scope or disable the affected setting only if security directs that change.

Expected result:
- Copilot no longer surfaces the same content while investigation continues.

## Verification
1. Security team acknowledges receipt and takes ownership.
2. Device and logs remain unchanged.
3. Investigation record contains user statement, timestamps, and screenshots.
4. Any containment setting is confirmed by Intune policy status.
5. No additional users report the same exposure while the investigation is open.

## Rollback
There is no technical rollback for a confirmed security incident. If containment causes a wider service issue, revert only the security-directed Copilot policy change and immediately inform the security team. If the report is determined to be a misunderstanding, close the incident with security approval and provide user guidance. Do not undo evidence-preservation steps.

## Preventive
Review Copilot and OneDrive permissions before rollout, limit search scope to the minimum required data, and test with a legal-department pilot group before broad enablement. Add a security sign-off to any change that can expose legal or confidential content.

## Related
Related to [KB-L1-COPILOT-SECURITY-ARTICLE.md](KB-L1-COPILOT-SECURITY-ARTICLE.md), [RUNBOOK-FLOOR6-COPILOT-SECURITY-INCIDENT-RESPONSE.md](RUNBOOK-FLOOR6-COPILOT-SECURITY-INCIDENT-RESPONSE.md), and [INCIDENT-03-COPILOT-SECURITY-RCA.md](INCIDENT-03-COPILOT-SECURITY-RCA.md).