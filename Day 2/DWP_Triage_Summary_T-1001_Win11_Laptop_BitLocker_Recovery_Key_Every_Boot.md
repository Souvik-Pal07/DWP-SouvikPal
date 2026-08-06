# DWP Service Desk Triage Summary

## Summary (one line)
User reports a new Windows 11 laptop prompting for a BitLocker recovery key at every boot.

## Impact (who/how many/ business urgency)
- Who: Reporting end user with new Windows 11 laptop (to-verify).
- How many: Single reported user/device at present (to-verify).
- Business urgency: Access disruption because repeated recovery-key prompts can block normal startup and productivity (to-verify).

## known facts
- Ticket reference: T-1001.
- Device context: New Windows 11 laptop.
- Reported behavior: BitLocker prompts for recovery key on every boot.
- Frequency: Every boot, based on user report.

## Missing information to gather
- Exact BitLocker screen wording and whether it is a full recovery prompt each time (to-verify).
- Whether user can successfully enter a valid recovery key and complete boot (to-verify).
- Whether the same key works repeatedly or fails intermittently (to-verify).
- Whether issue started immediately after initial setup, a restart, firmware change, or policy/application deployment (to-verify).
- Whether TPM/Secure Boot/BIOS settings were changed or updated recently (to-verify).
- Whether device is Azure AD/Entra joined and compliant with expected BitLocker policy (to-verify).
- Whether recovery keys are escrowed and retrievable via approved DWP process (to-verify).
- Scope check: any additional new Win11 laptops with the same symptom (to-verify).

## likely catagory
Windows 11 endpoint startup encryption issue: repeated BitLocker recovery challenge on boot (to-verify).

## First diagnostic step
Confirm the exact pre-boot BitLocker prompt message and validate recovery key availability via approved DWP process, then complete one successful boot and check whether the next restart still triggers recovery; this separates key-access issues from persistent boot trust-state changes.
