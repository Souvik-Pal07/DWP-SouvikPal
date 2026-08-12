# DWP Copilot Support Ticket Triage Assessment (Day 8)

Date: 2026-08-12
Engineer role: DWP Copilot ticket triage

## Ticket 1
**ID:** 1  
**Ticket:** Finance lead: Copilot will not summarise the Q3 board pack in SharePoint. "It is right there, I can see it myself."

**Likely cause (ranked):**
1. permissions/access boundary
2. data indexing lag
3. sensitivity label restriction
4. license/client prerequisite issue
5. guest/external sharing limitation
6. genuine Copilot fault

**Fastest check:**
Check whether the board pack library/file has unique permissions that exclude Copilot-relevant access path (for example, the user can open manually but inherited permissions or group scope differs).

**Is this actually a Copilot bug?**
No. Most evidence points to an access-scope mismatch or indexing timing issue before a product fault.

---

## Ticket 2
**ID:** 2  
**Ticket:** New hire (started yesterday): Copilot in Outlook seems to know nothing about my recent emails.

**Likely cause (ranked):**
1. data indexing lag
2. license/client prerequisite issue
3. permissions/access boundary
4. sensitivity label restriction
5. guest/external sharing limitation
6. genuine Copilot fault

**Fastest check:**
Confirm mailbox/content indexing freshness for the user (new account started yesterday is a strong lag signal).

**Is this actually a Copilot bug?**
No. New-hire timing strongly suggests indexing and/or provisioning latency rather than Copilot failure.

---

## Ticket 3
**ID:** 3  
**Ticket:** HR manager: Asked Copilot in Word to pull data from a sensitive salary review spreadsheet, got "I do not have access to that content."

**Likely cause (ranked):**
1. sensitivity label restriction
2. permissions/access boundary
3. license/client prerequisite issue
4. data indexing lag
5. guest/external sharing limitation
6. genuine Copilot fault

**Fastest check:**
Check the spreadsheet sensitivity label/policy (encryption and usage rights) and whether Copilot scenarios are blocked by policy.

**Is this actually a Copilot bug?**
No. The explicit access-denied message on sensitive HR content aligns with policy restrictions.

---

## Ticket 4
**ID:** 4  
**Ticket:** Sales rep: Copilot in Teams cannot find a client contract that was shared with her via a guest link from another org.

**Likely cause (ranked):**
1. guest/external sharing limitation
2. permissions/access boundary
3. data indexing lag
4. sensitivity label restriction
5. license/client prerequisite issue
6. genuine Copilot fault

**Fastest check:**
Verify whether the content is external/guest-shared from another tenant and therefore outside enterprise graph grounding scope.

**Is this actually a Copilot bug?**
No. Cross-tenant guest-link scenarios are commonly constrained by sharing and grounding boundaries.

---

## Ticket 5
**ID:** 5  
**Ticket:** IT admin: Copilot suddenly stopped working for the whole Finance team this morning, was fine yesterday.

**Likely cause (ranked):**
1. license/client prerequisite issue
2. permissions/access boundary
3. genuine Copilot fault
4. data indexing lag
5. sensitivity label restriction
6. guest/external sharing limitation

**Fastest check:**
Check tenant-level and group-level Copilot license assignment status/changes for the Finance users.

**Is this actually a Copilot bug?**
Unclear. Team-wide abrupt failure can be caused by licensing or service change; classify as bug only after licensing and access controls are ruled out.

---

## Ticket 6
**ID:** 6  
**Ticket:** Manager: Copilot found and summarised a file I do not remember ever opening, from a folder I forgot I had access to.

**Likely cause (ranked):**
1. permissions/access boundary
2. data indexing lag
3. license/client prerequisite issue
4. sensitivity label restriction
5. guest/external sharing limitation
6. genuine Copilot fault

**Fastest check:**
Validate that the manager currently has access permissions to that folder/file.

**Is this actually a Copilot bug?**
No. This behavior is consistent with Copilot grounding on accessible organizational content, not only recently opened files.

---

## Ticket 7
**ID:** 7  
**Ticket:** Analyst: Copilot gives generic answers, does not seem to use any of our internal SharePoint content at all.

**Likely cause (ranked):**
1. license/client prerequisite issue
2. permissions/access boundary
3. data indexing lag
4. sensitivity label restriction
5. guest/external sharing limitation
6. genuine Copilot fault

**Fastest check:**
Confirm the analyst is using a supported Copilot-enabled client/account context with the correct Copilot license.

**Is this actually a Copilot bug?**
No. Generic responses are most often explained by client/license/context issues before product defects.

---

## Ticket 8
**ID:** 8  
**Ticket:** Executive assistant: Copilot in Outlook cannot see a shared mailbox calendar that I manage on behalf of my director.

**Likely cause (ranked):**
1. permissions/access boundary
2. guest/external sharing limitation
3. license/client prerequisite issue
4. data indexing lag
5. sensitivity label restriction
6. genuine Copilot fault

**Fastest check:**
Verify whether delegate/shared mailbox calendar permissions are supported for Copilot grounding in this usage path and that access is direct in the same tenant context.

**Is this actually a Copilot bug?**
No. Delegate/shared mailbox access often differs from primary mailbox permissions in Copilot grounding behavior.
