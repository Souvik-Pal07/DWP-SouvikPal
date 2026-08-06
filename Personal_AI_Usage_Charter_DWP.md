# Personal AI Usage Charter (DWP Engineer, Public AI Assistants)

**Version:** 1.0  
**Date:** 2026-08-03  
**Applies to:** My use of public AI assistants for desktop and endpoint engineering work

## Purpose

Use public AI tools to improve speed and quality while protecting DWP data, systems, and users. AI outputs are advisory only; I remain accountable for all technical and operational decisions.

## Scope

This charter covers day-to-day endpoint/desktop engineering tasks such as PowerShell scripting, software packaging, Intune/SCCM configuration patterns, troubleshooting approaches, documentation drafting, and automation design.

---

## 1) Appropriate DWP Tasks for Public LLM Help

I may use public AI assistants for low-risk, non-sensitive tasks, including:

1. **Drafting generic scripts and command patterns**
   - PowerShell functions for file checks, registry reads, service status, log parsing, retry logic, and error handling.
   - Generic install/uninstall wrappers and detection script templates.

2. **Explaining technical concepts**
   - Endpoint hardening principles, patching approaches, certificate basics, and Windows internals at a general level.
   - Comparative advice on tools or methods (for example, deployment strategies).

3. **Troubleshooting frameworks**
   - Structured triage steps and likely root-cause trees.
   - Interpreting anonymized error text and proposing next tests.

4. **Documentation and communication**
   - Drafting runbooks, change notes, standard operating procedures, and user communications from non-sensitive inputs.
   - Rewriting technical notes for clarity and consistency.

5. **Test and quality scaffolding**
   - Unit/integration test ideas for scripts.
   - Checklists for rollback, monitoring, and post-change validation.

**Rule of thumb:** If the same prompt could be safely posted on a public technical forum, it is generally in scope.

---

## 2) Tasks Not Appropriate for Public LLM Help

I must not use public AI assistants for any task involving protected or operationally sensitive DWP information, including:

1. **Real incident details**
   - Active security incidents, exploitation paths, internal control weaknesses, and forensic artifacts tied to DWP estate.

2. **Internal architecture or configuration specifics**
   - Network topology, tenant details, endpoint inventory, privileged group structure, exact baselines, and internal URLs/hostnames.

3. **Production operational data**
   - Device/user records, ticket exports, logs containing user/device identifiers, and internal policy exceptions.

4. **Credentialed or privileged operations**
   - Any prompt requiring real admin credentials, tokens, private keys, API secrets, certificates, or one-time codes.

5. **Unreleased policy, legal, or procurement content**
   - Draft contractual terms, unpublished service changes, and internal risk assessments.

**When in doubt:** Do not paste it. Ask for a generic pattern using synthetic examples instead.

---

## 3) Data-Handling Rule for End-User PII and Credentials

**Non-negotiable personal rule:** I never input end-user PII or credentials into a public AI assistant.

This includes, at minimum:
- Names, addresses, NI numbers, dates of birth, and phone/email tied to identifiable users.
- Usernames paired with systems, device IDs tied to individuals, and ticket threads with personal context.
- Passwords, passphrases, tokens, session cookies, client secrets, private keys, and recovery codes.

Required practice:
1. Minimize first: share only the technical minimum needed.
2. Sanitize always: replace real values with placeholders or synthetic data.
3. De-identify logs: remove user/device identifiers and environment fingerprints.
4. Assume persistence: treat every public prompt as externally retained.
5. If sanitization is not possible without losing meaning, do not use public AI.

---

## 4) Personal "Generate Then Verify" Rule (Scripts and System Changes)

AI can generate; only I can approve. No AI-produced script or system-change instruction is used unverified.

My workflow:

1. **Generate**
   - Request a draft with clear assumptions, inputs, outputs, error handling, and rollback steps.

2. **Inspect**
   - Read every line before execution.
   - Check for destructive commands, privilege escalation, hidden downloads, remote execution, broad wildcards, and silent failure paths.

3. **Validate in a safe environment**
   - Run first in a test/lab endpoint using least privilege where possible.

4. **Verify behavior and impact**
   - Confirm expected outputs, logs, exit codes, and no unintended changes to security controls or user data.

5. **Peer review for high-risk changes**
   - For production-impacting endpoint changes, get second-person review before rollout.

6. **Controlled rollout**
   - Pilot to a limited device group, monitor, then phase release.

7. **Record and retain**
   - Document prompt intent, edits made, validation evidence, approval path, and rollback outcome.

**Hard stop:** I do not run AI-generated commands directly in production without manual review and testing.

---

## Personal Accountability Statement

Public AI assistance is a drafting aid, not an authority. I am responsible for confidentiality, integrity, availability, compliance, and user safety in every change I make.
