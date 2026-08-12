# Microsoft 365 Copilot Readiness Checklist — Finance Department
**Organisation:** DWP Financial Services  
**Department:** Finance (~200 users)  
**Data Sensitivity:** HIGH — Payroll, Board Packs, M&A Documents, Client Financial Data  
**Prepared by:** DWP Engineer  
**Date:** 2026-08-12  
**Status:** Pre-Deployment Review

---

> **Risk Notice:** SharePoint permissions for this department were migrated in 2019 and have **never been audited**. Given the sensitivity of the data held (payroll, board packs, M&A, client financials), **Section 3 (Permissions & Oversharing) must be completed and signed off before any Copilot licence is assigned.** Copilot surfaces data the user has access to — misconfigured permissions will be immediately and broadly exposed.

---

## Section 1 — Licensing Prerequisites

| # | Check | Owner | Done |
|---|-------|-------|------|
| 1.1 | Confirm all ~200 Finance users hold an active **M365 E5** licence in Entra ID / M365 Admin Centre | Licence Admin | ☐ |
| 1.2 | Confirm **Microsoft 365 Copilot add-on** licences have been procured (not yet assigned — do not assign until Section 3 is signed off) | Licence Admin | ☐ |
| 1.3 | Verify no users are on legacy E3 or F-series licences that would block Copilot eligibility | Licence Admin | ☐ |
| 1.4 | Confirm Copilot licence assignment is gated behind completion of this checklist — document approval gate in change record | Change Manager | ☐ |

---

## Section 2 — Microsoft 365 Apps Client Version

| # | Check | Owner | Done |
|---|-------|-------|------|
| 2.1 | All Finance devices running **Microsoft 365 Apps for Enterprise** (not perpetual Office 2019/2021) | Desktop Engineer | ☐ |
| 2.2 | Apps build is on **Current Channel** or **Monthly Enterprise Channel** — Copilot features require build **16.0.16626.20170 or later** (verify via Microsoft 365 Apps admin centre) | Desktop Engineer | ☐ |
| 2.3 | No devices pinned to Semi-Annual Enterprise Channel without an approved exception; Semi-Annual lags Copilot feature support by up to 6 months | Desktop Engineer | ☐ |
| 2.4 | Word, Excel, PowerPoint, Outlook, Teams all updated to current supported build — confirm via Intune compliance report or SCCM inventory | Desktop Engineer | ☐ |
| 2.5 | Microsoft Teams desktop client is on a version that supports **Copilot in Teams meetings** (build ≥ 23306.xxxx) | Desktop Engineer | ☐ |

---

## ⚠ Section 3 — SharePoint & OneDrive Permissions and Oversharing (HIGHEST PRIORITY)

> **This section is mandatory before licence assignment.**  
> The 2019 migration left permissions in an unknown state. Copilot will return content from any site, library, or file a user can read. Overshared payroll, M&A, or board pack data will be surfaced in Copilot responses to users who should never have had access.

### 3A — SharePoint Permission Audit

| # | Check | Owner | Done |
|---|-------|-------|------|
| 3A.1 | **Run Microsoft SharePoint Advanced Management (SAM) or Purview Data Access Governance reports** to enumerate all sites Finance users have access to — export full permission report | SharePoint Admin | ☐ |
| 3A.2 | Identify all sites/libraries that were migrated in 2019 and **cross-reference against current org chart** — flag any permissions for leavers, contractors, or users who have changed role since 2019 | SharePoint Admin | ☐ |
| 3A.3 | Remove or expire all **stale user permissions** identified in 3A.2 before proceeding | SharePoint Admin | ☐ |
| 3A.4 | Audit all **SharePoint groups inherited from 2019** — confirm membership is still correct; remove generic/unmanaged groups | SharePoint Admin | ☐ |
| 3A.5 | Confirm no Finance-sensitive site is accessible by **"Everyone"**, **"Everyone except external users"**, or **"All Company"** sharing links — remove immediately if found | SharePoint Admin | ☐ |
| 3A.6 | For each site containing payroll, board packs, M&A or client financial data — confirm access is limited to a **named, approved access group** only | SharePoint Admin + Data Owner | ☐ |
| 3A.7 | Enable **site-level access reviews** in Entra ID or SAM for all Finance-sensitive sites; schedule quarterly recurring review | SharePoint Admin | ☐ |

### 3B — OneDrive Oversharing Checks

| # | Check | Owner | Done |
|---|-------|-------|------|
| 3B.1 | Run **Purview Data Access Governance — OneDrive oversharing report** to identify Finance users sharing sensitive files broadly | SharePoint/Purview Admin | ☐ |
| 3B.2 | Identify any **"Anyone with the link"** shares (anonymous links) originating from Finance OneDrives — revoke all | SharePoint Admin | ☐ |
| 3B.3 | Identify **"People in organisation"** links on files containing sensitive financial data — evaluate and restrict to specific people where appropriate | SharePoint Admin + Data Owner | ☐ |
| 3B.4 | Confirm OneDrive tenant sharing settings restrict **anonymous/Anyone links** for this department or org-wide | SharePoint Admin | ☐ |
| 3B.5 | Confirm sensitive files are **not stored in personal OneDrive root** without labelling — Finance data should reside in governed SharePoint document libraries | Data Owner / Finance Manager | ☐ |

### 3C — Sign-Off Gate

| # | Check | Owner | Done |
|---|-------|-------|------|
| 3C.1 | SharePoint Admin formally signs off that permission audit is complete and remediated | SharePoint Admin | ☐ |
| 3C.2 | Data/Information Owner for Finance formally signs off that oversharing has been reviewed | Finance Data Owner | ☐ |
| 3C.3 | Sign-off recorded in the change record — Copilot licences **must not be assigned** until this gate is closed | Change Manager | ☐ |

---

## Section 4 — Identity & MFA Readiness

| # | Check | Owner | Done |
|---|-------|-------|------|
| 4.1 | All Finance user accounts are **cloud-only or hybrid-synced** in Entra ID (no on-prem-only accounts) | Identity Admin | ☐ |
| 4.2 | **MFA is enforced** for all 200 Finance users — confirm via Entra ID MFA registration report; no users exempt | Identity Admin | ☐ |
| 4.3 | MFA method is **Microsoft Authenticator (push or passwordless)** — SMS OTP is not recommended for high-sensitivity departments | Identity Admin | ☐ |
| 4.4 | **Conditional Access policy** requires compliant/hybrid-joined device for M365 access from Finance accounts | Identity Admin | ☐ |
| 4.5 | No Finance accounts have **legacy authentication enabled** — block legacy auth via Conditional Access | Identity Admin | ☐ |
| 4.6 | Confirm **Entra ID licences** (included in E5) are active — required for Conditional Access and Identity Protection | Identity Admin | ☐ |
| 4.7 | Review any **service accounts or shared mailboxes** in Finance — confirm they cannot be assigned Copilot licences and are excluded from user-facing rollout | Identity Admin | ☐ |

---

## Section 5 — Sensitivity Labelling

| # | Check | Owner | Done |
|---|-------|-------|------|
| 5.1 | **Microsoft Purview Information Protection** sensitivity labels are published to Finance users | Compliance / Purview Admin | ☐ |
| 5.2 | Labels appropriate for Finance data exist and are in use — at minimum: `Internal`, `Confidential`, `Highly Confidential — Finance` | Compliance Admin | ☐ |
| 5.3 | **Auto-labelling policies** are configured for known Finance content types (payroll keywords, IBAN patterns, financial reporting terms) using Trainable Classifiers or sensitive info types | Compliance Admin | ☐ |
| 5.4 | SharePoint sites holding payroll, board packs, M&A, and client financial data have a **default site sensitivity label** applied | SharePoint Admin | ☐ |
| 5.5 | Confirm **Copilot will not summarise or extract content from Highly Confidential labelled items** unless intentional — review Purview Copilot interaction policies | Compliance Admin | ☐ |
| 5.6 | Labels with **encryption (RMS protection)** are applied to the most sensitive document libraries — verify Copilot can still function with encrypted content for licensed users (requires Azure Information Protection unified labelling) | Compliance Admin | ☐ |
| 5.7 | **DLP policies** are in place for Finance — prevent sensitive financial data from being pasted into Copilot prompts or BizChat where inappropriate | Compliance Admin | ☐ |

---

## Section 6 — End-User Communications & Enablement

| # | Check | Owner | Done |
|---|-------|-------|------|
| 6.1 | **Copilot readiness briefing** delivered to Finance managers before rollout — covering what Copilot can and cannot access, and the importance of correct labelling | Change Manager | ☐ |
| 6.2 | **User communication sent** to all 200 Finance users explaining: what Copilot is, when it will be available, what data it can see, and responsible use expectations | Change Manager / Comms | ☐ |
| 6.3 | **Acceptable Use guidance** specific to Finance published — covering: do not enter client data/PII into Copilot prompts, do not use Copilot outputs as authoritative financial data without verification | Compliance / Change Manager | ☐ |
| 6.4 | **Training sessions or self-serve learning paths** (e.g. Microsoft Copilot Adoption Hub, Viva Learning) assigned to Finance users prior to licence activation | L&D / Change Manager | ☐ |
| 6.5 | **Feedback channel** established (e.g. Teams channel, ServiceNow category) for Finance users to report unexpected Copilot behaviour or suspected data exposure | Service Desk / Change Manager | ☐ |
| 6.6 | Post-rollout **30-day review** scheduled — check Copilot usage reports in M365 Admin Centre and Purview audit logs for anomalies | Change Manager + SharePoint Admin | ☐ |

---

## Checklist Sign-Off Summary

| Section | Description | Priority | Signed Off By | Date |
|---------|-------------|----------|---------------|------|
| 1 | Licensing Prerequisites | High | | |
| 2 | M365 Apps Client Version | High | | |
| **3** | **Permissions & Oversharing Audit** | **CRITICAL — BLOCKER** | | |
| 4 | Identity & MFA Readiness | High | | |
| 5 | Sensitivity Labelling | High | | |
| 6 | End-User Comms & Enablement | Medium | | |

> **Deployment decision:** Section 3 sign-off is a hard blocker. All other sections should be completed in parallel but Copilot licences **must not be assigned** until the permissions and oversharing gate (3C) is formally closed and recorded in the change record.

---

*Document owner: DWP Engineer | Review cycle: Prior to each Copilot licence assignment wave*
