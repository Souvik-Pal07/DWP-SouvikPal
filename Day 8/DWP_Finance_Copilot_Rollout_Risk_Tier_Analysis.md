# Microsoft 365 Copilot Rollout — Risk Tier Analysis
**Finance Department Context Analysis**  
**Date:** 2026-08-12

---

## Executive Summary

The checklist items have been ranked into three risk tiers. **The critical insight** is that permissions and oversharing audit is a **MUST-block**, not because it is technically complex, but because it is the **only item that directly determines whether Copilot increases data breach risk**. Licensing and client version are operational prerequisites; permissions governance is a data security gate.

---

## Tier 1: MUST Complete Before Rollout (Blocking)

### Why This Tier Exists

Items in this tier, if deferred or skipped, create **unacceptable risk of unintended data exposure or system failure**. For Finance specifically, this means:
- **Copilot will immediately expose data the user can access.** If permissions are wrong, the exposure is instantaneous and at scale (200 users × 7–8 hours daily use).
- **Finance data is high-value and strictly regulated** — payroll, board packs, M&A, client financial data attract compliance audits and breaches carry severe reputational and financial penalties.
- **Rollback is difficult** — once Copilot is live and ingesting content, audit trails become noisy; identifying what was exposed and to whom requires forensic investigation.

---

### Tier 1 Items

#### 1. **Section 3: Permissions & Oversharing Audit (HIGHEST PRIORITY)**

**Checklist items:** 3A.1–3A.7, 3B.1–3B.5, 3C.1–3C.3

**Why MUST for Finance:**

- **Root cause:** 2019 migration, never audited. Unknown state = unknown exposure surface.
- **Copilot amplifies the risk.** Without Copilot, a user who shouldn't have access to payroll data might never discover it because they don't routinely browse that library. With Copilot, users will ask natural language questions like *"What is our payroll budget for FY2026?"* and Copilot will return the answer if any document in any accessible site contains it.
- **Scale.** 200 users × stale permissions = 200 users potentially reading data from 2019 access grants that were never re-evaluated. A single compromised account, or a user who moved teams internally, suddenly has visibility to board packs they never should have had.
- **Audit and legal exposure.** If a Finance analyst mistakenly forwards a Copilot-generated summary to an external party, and that summary was drawn from confidential M&A material, the audit trail shows the user had access to it via a deprecated 2019 SharePoint group. Your organisation's defence ("we didn't mean to give them that access") is weak; permissions systems don't distinguish intent.
- **Cannot be partially remediated.** You either know your permissions are clean, or you don't. Leaving this ambiguous and rolling out Copilot is a compliance gamble.

**Evidence within checklist:**
- 3A.1–3A.3: Enumerate all sites, cross-reference against org chart, remove stale permissions.
- 3B.1–3B.3: Identify and revoke oversharing (anonymous links, "anyone" links, org-wide shares on sensitive docs).
- 3C.1–3C.3: Formal sign-off gate — must be closed before licence assignment.

**Sign-Off Required:** SharePoint Admin + Finance Data Owner (required before any Copilot licence is assigned)

---

#### 2. **Section 1: Licensing Prerequisites (1.1–1.4)**

**Why MUST for Finance:**

- **No licence, no Copilot.** All 200 users must have active E5 and Copilot add-on assigned — prerequisite to rollout.
- **Intentional gating.** Item 1.4 explicitly creates a change record gate linking licence assignment to completion of this entire checklist, especially Section 3. This is administrative enforcement of the blocking dependency.
- **Compliance audit trail.** When (not if) Finance auditors or compliance teams ask "when did you roll out Copilot, and what controls were in place?", the change record with licence assignment gated behind sign-off is your evidence of disciplined governance.

**Sign-Off Required:** Licence Admin + Change Manager

---

#### 3. **Section 4: Identity & MFA Readiness (4.1–4.7)**

**Why MUST for Finance:**

- **Compromised identity = Copilot data breach.** If a Finance user account is hijacked and MFA is not enforced, an attacker gains Copilot access with all the permissions that user has accumulated since 2019.
- **Conditional Access is foundational.** Item 4.4 (Conditional Access requiring compliant device) is a known control that limits the attack surface. Without it, a user can authenticate from an unmanaged device and prompt Copilot for confidential data.
- **High-sensitivity department norm.** For Finance, MFA via SMS (item 4.3) is known-weak; Authenticator push or passwordless should be mandatory, not optional.
- **Entra ID licence dependency.** E5 includes Entra ID; if licenses are misconfigured, Conditional Access policies may not apply, and you have no visibility.

**Sign-Off Required:** Identity Admin

---

#### 4. **Section 2: M365 Apps Client Version (2.1–2.5)**

**Why MUST for Finance:**

- **Copilot features require minimum build.** If a user's Office build is too old, Copilot features will not surface or will be partially broken (e.g., summarisation in Word fails, Teams meetings lose Copilot transcription). Finance users will become frustrated, lose trust, and workaround by forwarding files or using unsupported shadow tools.
- **Known tech debt risk.** If any Finance devices are still on Semi-Annual Channel or perpetual Office 2019/2021, they will be unable to use Copilot, creating a two-tier rollout that complicates support and change management.
- **Verifiable in 30 minutes.** Unlike permissions audit (weeks), client version is quick to check via Intune/SCCM — no reason to defer.

**Sign-Off Required:** Desktop Engineer

---

#### 5. **Section 5: Sensitivity Labelling (5.1–5.7)**

**Why MUST for Finance:**

- **Copilot respects labels (partially).** Sensitivity labels are the technical control that tells Copilot "this is confidential; be cautious or refuse to summarise it." Without labels on Finance documents, Copilot has no guardrails.
- **DLP prevents accidental leakage.** Item 5.7 (DLP policies) block sensitive financial terms from being pasted into Copilot prompts, e.g., preventing a user from typing "Client ABC balance sheet is $X million — help me summarise this." Without DLP, users will attempt to paste sensitive content into Copilot.
- **Auto-labelling via classifiers.** Item 5.3 ensures that legacy, unlabelled Finance documents get labelled automatically so they are protected before Copilot is live.
- **Not a one-liner.** This requires Purview config, testing, and user education — cannot be rushed.

**Sign-Off Required:** Compliance / Purview Admin

---

## Tier 2: SHOULD Complete Before Rollout (High Risk If Skipped)

### Why This Tier Exists

Items in this tier are **not hard blockers** (Copilot will still launch), but skipping them creates **significant operational, compliance, or support risk**. They should be completed in parallel with Tier 1 but with a contingency: if one item in Tier 2 is delayed, rollout can proceed with a documented risk acceptance and mitigation plan.

---

### Tier 2 Items

#### 1. **Section 6: End-User Communications & Enablement (6.1–6.6)**

**Why SHOULD for Finance:**

- **User awareness prevents misuse.** If Finance staff do not understand that Copilot can see all documents they have access to, they will treat it as a safe sandbox and paste PII, client data, or regulatory-sensitive material into prompts.
- **Acceptable Use guidance is critical for Finance.** Unlike a general department, Finance has explicit expectations: do not use Copilot to generate financial advice, do not rely on Copilot outputs without verification, do not paste confidential data into prompts.
- **Training reduces support load.** A 30-minute training session prevents 200 helpdesk tickets in week one.
- **Feedback channel catches problems early.** A Teams channel or ServiceNow category allows users to report "Copilot showed me data I shouldn't have had access to" — essential for catching permissions issues that the audit missed.
- **Risk if skipped:** Users misuse Copilot, get exposed to confidential data they shouldn't have, or paste sensitive data into Copilot thinking it is local. Compliance audit finds evidence of unintended disclosure.

**Mitigation if delayed:** Communications can start immediately after licence assignment; training can use self-paced learning paths (Viva Learning, Microsoft Learn). However, do not assign licences until communications materials are drafted.

**Sign-Off Required:** Change Manager + Compliance

---

#### 2. **Section 5: Sensitivity Labelling — Subset (5.4, 5.5, 5.7)**

(Note: 5.1–5.3 and 5.6 are Tier 1; 5.4, 5.5, 5.7 are Tier 2 because they are reactive governance after labels exist.)

**Why SHOULD for Finance:**

- **Default site labelling** (5.4) ensures that when new Finance documents are uploaded to SharePoint, they are automatically classified. Critical for payroll and board pack repositories.
- **Copilot interaction policies** (5.5) require Purview configuration to prevent Copilot from summarising highly confidential content. This is a policy gate, not a technical fix.
- **DLP for Copilot prompts** (5.7) is the final safeguard preventing users from pasting sensitive data into Copilot. However, if user training (Tier 2, Section 6) is effective, the need for DLP is reduced.
- **Risk if skipped:** Copilot generates summaries of highly confidential documents, or users paste sensitive data into prompts assuming it is discarded immediately.

**Mitigation if delayed:** Tier 1 labelling (5.1–5.3) still protects documents; Tier 2 policies (5.4, 5.5, 5.7) add an extra layer. If user training emphasises manual discipline, the gap can be bridged for 2–4 weeks while policies are configured.

**Sign-Off Required:** Compliance / Purview Admin

---

## Tier 3: CAN Complete During/After Rollout (Lower Risk)

### Why This Tier Exists

Items in this tier are **beneficial but not blocking** because:
1. They are operational optimisation, not security or compliance gates.
2. The core Copilot functionality is unaffected if they are delayed by 2–4 weeks.
3. They can be verified and remediated in the weeks after licence assignment without requiring a rollback.

---

### Tier 3 Items

#### 1. **Section 4: Identity & MFA Readiness — Subset (4.7, post-rollout review)**

**Tier 3 element:** Service account / shared mailbox exclusion (4.7) and ongoing monitoring.

**Why CAN delay:**
- If service accounts or shared mailboxes are correctly configured by Design, they will not accept Copilot licence assignments — the system will reject them. Low manual verification risk.
- Ongoing access reviews (4.2, quarterly MFA verification) are operational maintenance, not blockers.

**Can verify post-rollout:** In week 2, run a Licence Admin report confirming no shared mailboxes or service accounts have Copilot assigned. If any are found, revoke immediately.

**Risk if delayed:** Minimal — shared mailboxes generally cannot accept interactive licences. If this slips past, it is caught in the first week of usage reporting.

---

#### 2. **Section 6: End-User Communications — Tier 3 Element (6.6, post-rollout review)**

**Tier 3 element:** 30-day review and feedback channel analysis.

**Why CAN delay:**
- Initial communications and training (Tier 2, 6.1–6.5) are pre-rollout.
- The 30-day review and feedback loop (6.6) is post-rollout measurement and optimisation.

**Can verify post-rollout:** In week 3–4, pull Copilot usage reports from M365 Admin Centre and Purview audit logs; review feedback channel for issues. This informs phased rollout of additional user cohorts or refinement of DLP rules.

**Risk if delayed:** No risk to the initial rollout. Delayed analysis means you miss early signals of misuse, but does not prevent 200 users from getting Copilot.

---

## Risk Justification: Why Permissions/Oversharing is MUST Even Though Licensing Is Simpler

| Factor | Licensing (Tier 1) | Permissions Audit (Tier 1) |
|--------|-------------------|---------------------------|
| **Complexity** | Low: Run a report, assign licences. | High: Enumerate sites, audit groups, revoke access, remediate. |
| **Time to Completion** | 2–5 days. | 4–8 weeks (dependent on org size and permissions debt). |
| **Technical Risk if Skipped** | Copilot will not launch; system will prevent it. | Copilot will launch; 200 users immediately access data from stale 2019 permissions. |
| **Reversibility** | Revoke licences, start over. | Cannot un-read data. Audit trails become noisy. Forensic investigation required. |
| **Audit/Compliance Exposure** | "We didn't have licences ready" = process failure, easily explained. | "We rolled out Copilot to 200 users without auditing 7-year-old permissions" = governance failure, data security incident waiting to be discovered. |
| **Finance-Specific Weight** | E5 is a known purchasing requirement. | Payroll, board packs, M&A, client financial data have high regulatory and reputational impact if exposed. |

**Conclusion:** Licensing is a gating factor, but it is a *control-access* gate. Permissions audit is a *data-exposure* gate. For Finance, data exposure is the higher-order risk.

---

## Recommended Rollout Sequence

1. **Weeks 1–2: Initiate Tier 1 in parallel**
   - Section 1 (Licensing): Confirm budget, place Copilot add-on order, create change record with sign-off gate.
   - Section 3 (Permissions): Launch audit; assign SharePoint Admin + Data Owner to intensive 4–6 week remediation.
   - Section 4 (Identity): Verify MFA, Conditional Access, Entra ID licences.
   - Section 2 (Client version): Check device build in Intune/SCCM.
   - Section 5 (Labelling): Begin Purview config, auto-labelling rules, DLP policies.

2. **Weeks 3–8: Section 3 remediation + Tier 2 preparation**
   - Permissions audit continues; status checkpoint every 1–2 weeks.
   - Tier 2 (Communications, advanced labelling, user training materials) prepared in parallel.
   - When Section 3 sign-off is achieved, submit for change approval and licence assignment request.

3. **Week 9: Licence assignment + immediate comms**
   - Assign Copilot licences to first cohort (50–100 Finance users).
   - Activate Section 6 communications and training.

4. **Weeks 10–12: Phased rollout + monitoring**
   - Expand licence assignment to remaining 100–150 users.
   - Monitor Copilot usage, audit logs, and feedback channel.
   - Week 12: Conduct Tier 3 review (30-day analysis).

---

## Summary Table

| Tier | Sections | Blocking? | Can Proceed Without | Timeline |
|------|----------|-----------|-------------------|----------|
| **MUST** | 1, 2, 3, 4, 5 (5.1–5.3, 5.6) | YES | No — rollout will not proceed. | 4–8 weeks (driven by Section 3). |
| **SHOULD** | 6 (6.1–6.5), 5 (5.4, 5.5, 5.7) | NO | Possible with documented risk acceptance and mitigation. | Can slip to post-rollout with contingency comms. |
| **CAN** | 4 (4.7), 6 (6.6) | NO | Yes — post-rollout verification, low risk. | 2–4 weeks post-licence assignment. |

---

*Document owner: DWP Engineer | For use in change advisory and rollout planning*
