# End User Communication — Microsoft Copilot Issues
**Issued by:** DWP Service Desk
**Date:** 12 August 2026
**Audience:** Affected Legal Team Members

---

## T-1001 — Copilot cannot access a document in SharePoint

**Who this affects:** The paralegal who reported Copilot returning "I don't have access to that content" when trying to summarise a client NDA.

**What is happening:**
Microsoft Copilot can only read documents that you already have permission to open yourself. If you heard about a folder in a meeting but have never actually opened it, you most likely do not have access to it yet — and Copilot will not be able to read it on your behalf.

**What to do next:**
1. Try opening the SharePoint folder and the NDA file directly in your browser.
2. If you see an "Access Denied" message or cannot find the file, this confirms you do not yet have permission.
3. Contact the Service Desk or the owner of that SharePoint site and ask them to grant you read access to the folder.
4. Once access is confirmed and you can open the file yourself, try asking Copilot to summarise it again.

---

## T-1002 — Copilot in Outlook cannot find case emails

**Who this affects:** The new associate who started this week and cannot get Copilot to surface case-related emails.

**What is happening:**
Copilot in Outlook can only work with emails that are already in your mailbox. As a new starter, your mailbox is likely still being set up and indexed — this process can take up to 72 hours. It is also possible that the case emails you need have not yet been shared or forwarded to you.

**What to do next:**
1. First, check whether the emails exist in your Outlook inbox by searching manually (press Ctrl+E in Outlook and type a keyword).
2. If the emails are not there, ask a colleague or your manager to forward the relevant case emails to you.
3. If the emails are in your mailbox but Copilot still cannot find them, this is likely a short-term indexing delay. Please wait 24–48 hours and try again.
4. If the issue continues after 48 hours, contact the Service Desk and we will investigate further.

---

## T-1003 — Copilot showed a confidential document from an unrelated matter

**Who this affects:** The partner who was shown a draft settlement document from a matter they are not assigned to.

**What is happening:**
This is being treated as a priority issue. Copilot only surfaces documents that the signed-in user already has permission to access. The fact that Copilot showed you this document means your account currently has access to that file — which should not be the case.

This is a permissions configuration issue and has been escalated as a potential data governance concern.

**What to do next:**
1. Please do not open, share, or action the document you were shown.
2. The Service Desk has already escalated this to the SharePoint administrator and the Information Governance team to review and correct the permissions on that matter folder.
3. You do not need to take any further action — we will update you once the permissions have been corrected and the matter has been reviewed.
4. If you have any concerns about confidentiality, please speak to your Information Governance or Data Protection contact directly.

---

## T-1004 — Entire Legal team has lost Copilot access

**Who this affects:** All 40 members of the Legal team who lost Copilot access this morning.

**What is happening:**
We are aware that all Copilot access for the Legal team stopped working this morning. This appears to be related to a change in how Copilot licences are assigned to the Legal team group, rather than a problem with individual accounts. The Service Desk is actively investigating.

**What to do next:**
1. You do not need to log individual tickets — we are treating this as a single high-priority incident (T-1004) affecting the whole team.
2. Please avoid attempting workarounds such as logging in on a different device, as this is unlikely to help.
3. The Service Desk is checking licence assignments and reviewing any recent changes made to the Legal team group.
4. We will send an update as soon as access has been restored. We aim to provide a progress update within two hours.

---

## T-1005 — Copilot gives generic answers about contract templates

**Who this affects:** The contract specialist who asked Copilot about clauses in the contract templates library and received vague, unhelpful answers.

**What is happening:**
When Copilot gives generic answers rather than quoting specific content from your documents, it usually means it has not been able to read the actual files — either because it is answering from general knowledge, the files are not yet indexed, or the documents are in a format Copilot cannot read (such as a scanned PDF image).

**What to do next:**
1. Try a different approach: open the specific contract template file directly in SharePoint or Word, then use the Copilot pane within that document to ask your question. This gives Copilot direct access to that file's content.
2. When using Copilot in chat, be specific — paste the link to the document into your prompt, for example: *"Summarise the indemnity clause in [paste link here]."*
3. If the templates are scanned PDFs (i.e., images of documents rather than typed text), Copilot cannot read them. In that case, please contact the Service Desk so we can explore whether the files can be converted to a readable format.
4. If none of the above helps, contact the Service Desk and we will check whether the library has been fully indexed and whether your permissions are correctly configured.

---

*For any of the above issues, you can contact the Service Desk by raising a ticket at the self-service portal or calling the helpdesk directly. Please quote the ticket reference number shown in each section above.*
