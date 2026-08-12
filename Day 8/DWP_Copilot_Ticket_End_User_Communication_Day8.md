# DWP Copilot End-User Communications (Day 8)

Date: 2026-08-12
Audience: End users raising Copilot support tickets

## Ticket 1: Finance lead - Copilot will not summarise Q3 board pack in SharePoint
Hello,

Thanks for reporting this. Even when a file is visible to you, Copilot can still fail to use it if access scope or file indexing is not fully aligned yet.

Next steps:
1. Confirm the board pack is stored in the expected SharePoint library (not moved or duplicated).
2. Check if the file/library has unique permissions.
3. Try again after a short wait in case indexing is still catching up.
4. If it still fails, send us the file link and time of test so we can trace access and indexing.

---

## Ticket 2: New hire - Copilot in Outlook knows nothing about recent emails
Hello,

This is common for very new accounts. Your mailbox and Copilot context may still be provisioning and indexing.

Next steps:
1. Sign out and sign back into Outlook with your work account.
2. Confirm Copilot is enabled in your account and app.
3. Wait a little longer and test again (new accounts can take time to fully index).
4. If no improvement, send us a screenshot and the exact prompt you used.

---

## Ticket 3: HR manager - Copilot cannot access sensitive salary spreadsheet
Hello,

The message you received usually means the file is protected by sensitivity or access policy, which is expected for salary data.

Next steps:
1. Confirm the spreadsheet sensitivity label.
2. Confirm your access rights to that file are direct and current.
3. If needed, ask your data owner/security admin whether policy allows Copilot use for that document class.
4. Retry after any approved permission or policy change.

---

## Ticket 4: Sales rep - Copilot in Teams cannot find external guest-shared contract
Hello,

This usually happens when content is shared from another organization using a guest/external link. Copilot may not be able to ground on that external content in the same way as internal files.

Next steps:
1. Confirm the contract is hosted in another tenant/org.
2. Ask for an internal copy in your organization if business policy allows.
3. Open the file directly to confirm your current access still works.
4. Re-run Copilot once the content is in a supported internal location.

---

## Ticket 5: IT admin - Copilot stopped for the whole Finance team
Hello,

A team-wide sudden stop is usually caused by licensing, assignment, or tenant configuration changes rather than a user error.

Next steps:
1. Check Copilot license assignments for affected Finance users/groups.
2. Confirm there were no recent policy or conditional access changes.
3. Validate users are on supported client versions and signed into the correct tenant.
4. If all checks pass and the issue continues, raise as a service incident with timestamps and sample users.

---

## Ticket 6: Manager - Copilot summarised a file not recently opened
Hello,

What you saw can be normal behavior. Copilot can use content you currently have permission to access, even if you have not opened it recently.

Next steps:
1. Review your access to the folder/file mentioned.
2. Remove access if it is no longer needed (least-privilege approach).
3. Re-test Copilot after access changes are applied.
4. Contact IT if you find unexpected access paths and need cleanup help.

---

## Ticket 7: Analyst - Copilot gives generic answers, not using SharePoint content
Hello,

Generic responses often mean Copilot is not getting full enterprise context from account, license, client, or access setup.

Next steps:
1. Confirm you are signed into the correct work account.
2. Confirm your Copilot license is active.
3. Update to a supported app/client version.
4. Test with a clearly accessible internal document link and share result details with IT.

---

## Ticket 8: Executive assistant - Copilot cannot see shared mailbox calendar
Hello,

Shared/delegate mailbox calendar access may behave differently from your primary mailbox in Copilot scenarios.

Next steps:
1. Confirm your delegate permissions on the shared mailbox calendar are active.
2. Confirm both mailboxes are in the same tenant and correctly configured.
3. Try the same request from your primary mailbox context and compare behavior.
4. If needed, provide IT with sample prompt, mailbox details, and timestamp for deeper validation.

---

## Quick note for all users
When reporting Copilot issues, please include:
1. Exact app used (Outlook, Teams, Word, etc.).
2. Exact prompt entered.
3. Time of test.
4. Screenshot of the error/result.
5. Link to the target file/content (if allowed).

These details help us resolve tickets much faster.
