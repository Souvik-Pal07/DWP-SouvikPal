# DWP – Windows 11 Intune Compliance Policy
## Security Baseline Translation
**Author:** DWP Engineer  
**Date:** 2026-08-11  
**Scope:** Windows 11 Managed Devices (Intune MDM)  
**Grace Period:** 7 days applied to all settings

---

## How to Apply Grace Period

In the Intune compliance policy wizard, under **Actions for noncompliance**, set:

- **Mark device noncompliant** → Schedule: **7 days**

This applies globally across all settings in the policy. Devices flagged as non-compliant will not be marked as such in Azure AD/Conditional Access until the 7-day window elapses without remediation.

---

## Requirement 1 – BitLocker Must Be Enabled on the OS Drive

| Field | Detail |
|---|---|
| **Setting Name** | Require BitLocker |
| **Value** | Require |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **Device Health** → BitLocker → *Require* |

**Effect:**  
Intune queries the Windows Health Attestation Service (HAS) to confirm BitLocker is active and protecting the OS (C:) drive. Devices without BitLocker enabled will be marked non-compliant.

**False-Positive Risk:**  
- HAS reporting lag — BitLocker may be enabled but the attestation report has not yet refreshed (can take up to 24 hours post-enable).  
- TPM chip not provisioned correctly after a hardware repair or board replacement.  
- Devices recently re-imaged where BitLocker has been enabled but encryption is still in progress.

**Recommendation:**  
Allow the 7-day grace period to absorb attestation lag. Do not reduce to 0 days for BitLocker — it is a common false-positive trigger on freshly built devices.

---

## Requirement 2 – Secure Boot Must Be Enabled

| Field | Detail |
|---|---|
| **Setting Name** | Require Secure Boot to be enabled on the device |
| **Value** | Require |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **Device Health** → Secure Boot → *Require* |

**Effect:**  
Verified via the Windows Health Attestation Service. Ensures the device boots using only firmware and OS components trusted and signed by the manufacturer. Blocks rootkits and bootkits that load before Windows.

**False-Positive Risk:**  
- Older hardware (pre-2017) may have a UEFI implementation that does not report Secure Boot state correctly to HAS, even when physically enabled.  
- Dual-boot configurations (e.g., Linux alongside Windows) often require Secure Boot to be disabled.  
- HAS attestation failures caused by intermittent TPM communication errors.

**Recommendation:**  
Identify any legacy hardware models in your estate that cannot support Secure Boot and place them in a separate compliance policy with this setting excluded, or create a device group exclusion.

---

## Requirement 3 – Minimum OS Build (N-1 Policy)

| Field | Detail |
|---|---|
| **Setting Name** | Minimum OS version |
| **Value** | `10.0.22621.2861` |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **Device Properties** → Operating System Version → Minimum OS version |

**Effect:**  
Devices running a Windows 11 build older than `22621.2861` (N-1 from current known-good `22621.3155`) will be flagged as non-compliant. This enforces that devices are no more than one patch cycle behind the current stable release, reducing exposure to known CVEs.

**False-Positive Risk:**  
- Devices held back by WSUS or Windows Update for Business deferral rings — the device may be intentionally deferred by policy.  
- Devices in a pilot ring that has not yet received the cumulative update.  
- Devices recently enrolled that are mid-update at compliance check time.

**Recommendation:**  
Align your Windows Update for Business deferral ring with this compliance threshold. Ensure the update ring delivers `22621.2861` (or later) before the compliance policy enforcement date. Review and update the minimum build value each Patch Tuesday cycle.

> **Note:** This value must be manually updated as new cumulative updates are released. Intune does not auto-increment the minimum build. Consider scheduling a monthly review task.

---

## Requirement 4 – Windows Defender Real-Time Protection Must Be On

| Field | Detail |
|---|---|
| **Setting Name** | Require real-time protection |
| **Value** | Require |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **System Security** → Microsoft Defender Antimalware → Real-time protection → *Require* |

**Effect:**  
Confirms that Microsoft Defender Antivirus real-time protection is actively running. Devices where it is disabled, paused, or replaced by an unrecognised third-party AV product will be flagged non-compliant.

**False-Positive Risk:**  
- Devices running a third-party AV solution (e.g., CrowdStrike, Symantec) that registers as the active AV provider via Windows Security Center — Defender real-time protection is intentionally disabled in this scenario and will always flag non-compliant.  
- Defender temporarily paused by an admin for troubleshooting.  
- Windows Security Centre service not running, causing incorrect status reporting.

**Recommendation:**  
If DWP uses a third-party EDR/AV product as the primary engine, evaluate whether to use the **Microsoft Defender Antimalware** compliance setting or rely instead on the EDR platform's own health compliance reporting (e.g., via Defender for Endpoint integration with Intune). Do not enforce this setting if it will generate false positives for every managed device using a third-party AV.

---

## Requirement 5 – Firewall Must Be Enabled for All Profiles

| Field | Detail |
|---|---|
| **Setting Name** | Microsoft Defender Firewall |
| **Value** | Require |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **System Security** → Windows Firewall → Microsoft Defender Firewall → *Require* |

**Effect:**  
Checks that Windows Firewall is enabled across all three network profiles: Domain, Private, and Public. A device with firewall disabled on any profile will be marked non-compliant.

**False-Positive Risk:**  
- Third-party firewall products (e.g., Cisco AnyConnect host firewall, ZScaler) may disable or replace Windows Firewall, causing a false non-compliant state.  
- Group Policy conflict — an existing GPO set to disable the firewall for domain-joined devices will fight against this Intune compliance setting.  
- Legacy LOB applications that require firewall exceptions may have been configured by disabling the firewall entirely rather than adding a rule.

**Recommendation:**  
Before enforcing, audit whether any existing GPO or software stack disables Windows Firewall on managed devices. If so, remediate those configurations first. For co-managed devices (Intune + ConfigMgr), confirm workload ownership for Windows Firewall is set to Intune.

---

## Requirement 6 – A PIN or Password Must Be Configured

| Field | Detail |
|---|---|
| **Setting Name** | Require a password to unlock mobile devices / Password required |
| **Value** | Require |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **System Security** → Password → Require a password to unlock mobile devices → *Require* |

**Supporting Settings (recommended alongside):**

| Setting | Value |
|---|---|
| Minimum password length | 8 |
| Password type | Alphanumeric (or at minimum: Numeric / PIN) |
| Password expiration (days) | Per DWP policy (e.g., 90) |
| Number of previous passwords to prevent reuse | 5 |

**Effect:**  
Ensures the device lock screen requires a PIN, password, or Windows Hello credential to unlock. Devices with no lock screen protection will be flagged non-compliant.

**False-Positive Risk:**  
- Shared kiosk or frontline worker devices intentionally configured with no password (auto-logon) — these will always be non-compliant under this policy.  
- Devices enrolled via Windows Autopilot with a local admin account that has not yet set a PIN.  
- Windows Hello for Business provisioning incomplete post-enrolment — user may not yet have set up their PIN.

**Recommendation:**  
Exclude kiosk/shared devices from this compliance policy and manage them under a dedicated Kiosk compliance policy. For Windows Hello for Business rollouts, allow the 7-day grace period to cover the provisioning window.

---

## Requirement 7 – Device Must Not Be Jailbroken or Rooted

| Field | Detail |
|---|---|
| **Setting Name** | No jailbreak / Rooted devices |
| **Value** | Block |
| **Intune UI Path** | Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **Device Health** → Windows Health Attestation Service evaluation rules → Require the device to be at or under the machine risk score → *Clear* |

> **Important Note for Windows 11:**  
> The "jailbroken or rooted" setting as a direct toggle is **primarily a mobile (iOS/Android) compliance concept**. On Windows 11, the equivalent control is:  
> - **Machine Risk Score** (via Microsoft Defender for Endpoint integration): Set to **Clear** or **Low**  
> - **Health Attestation** checks (Code Integrity, Secure Boot, BitLocker) collectively enforce device integrity  
> 
> **Intune UI Path (Defender for Endpoint integration):**  
> Devices → Manage devices → **Compliance** → Create policy → Platform: *Windows 10 and later* → Compliance settings → **Microsoft Defender for Endpoint** → Require the device to be at or under the machine risk score → *Clear*

**Effect:**  
Combines Health Attestation (Secure Boot, Code Integrity Policy enforcement) with Defender for Endpoint risk scoring to detect devices that have been tampered with, have disabled security controls, or exhibit behaviour consistent with a compromised system.

**False-Positive Risk:**  
- Devices without a Defender for Endpoint licence assigned — the risk score will be absent/unknown and may result in a non-compliant state depending on policy configuration.  
- Test/dev machines with intentional security modifications (e.g., test signing enabled, code integrity policy in audit mode).  
- New device enrolments where the Defender for Endpoint sensor has not yet onboarded and reported a risk score.

**Recommendation:**  
Set Machine Risk Score to **Low** rather than **Clear** if your estate includes developer workstations or security test machines, to avoid blocking legitimate low-risk operational machines. Ensure all devices have a Defender for Endpoint licence and confirm sensor onboarding via the Defender portal before enforcing.

---

## Step 3 – Actions for Noncompliance

**Location in wizard:** Home → Devices | Compliance → *(your policy)* → **Actions for noncompliance** tab

The Actions for noncompliance screen lets you define what happens — and when — after a device is detected as non-compliant. Actions are evaluated sequentially by schedule.

### Recommended Action Sequence for DWP

| Order | Action | Schedule (days after noncompliance) | Message Template | Notes |
|---|---|---|---|---|
| 1 | Send email to end user | 0 (Immediately) | *DWP Compliance Alert* (create template first) | Notifies user immediately so they can self-remediate |
| 2 | Mark device noncompliant | 7 | — | Grants 7-day grace period before Conditional Access blocks the device |
| 3 | Retire the device *(optional — do not enable without approval)* | 30 | — | Only add if DWP policy requires forced retirement of persistently non-compliant devices |

### How to Configure — Step by Step (matching the current screen)

The screen shows two rows under "Specify the sequence of actions on noncompliant devices":

**Row 1 — Mark device noncompliant (pre-populated, cannot be removed)**
- This row is fixed and always present. It shows **Immediately** in the schedule column.
- You cannot edit the Action label, but you **can** edit the schedule number.
- Click the **0** in the Schedule field next to "Immediately" and change it to **7**.
- Leave Message template and Additional recipients blank for this row.

**Row 2 — Empty action row (the dropdown + 0 field below the first row)**
- This is a blank row ready for you to add a second action.
- Click the **dropdown arrow** (the chevron on the left of this row) and select **Send email to end user**.
- Leave the Schedule field as **0** — this sends the email immediately when non-compliance is first detected.
- Click the **Message template** field and select your pre-created notification template (e.g. *DWP Compliance Alert*). If no template exists yet, create one first at: **Tenant administration → Notifications → Create notification**, then return here.
- In the **Additional recipients** field, optionally add the DWP Service Desk distribution group email address.

> **Important:** The Schedule number is **days after the device is first detected as non-compliant**, not days from enrolment. Setting Row 1 to **7** means Conditional Access will not block the device for 7 days, giving the user time to self-remediate after receiving the Row 2 email.

### Additional Recipients (optional)

The **Additional recipients** column accepts Azure AD group email addresses. Consider adding your DWP IT Service Desk distribution list to the email action so the team is aware of non-compliant devices without waiting for a user to raise a ticket.

---

## Step 4 – Assignments

**Location in wizard:** Home → Devices | Compliance → *(your policy)* → **Assignments** tab

Assignments control which users or devices the compliance policy applies to.

### Recommended Assignment Configuration

| Field | Value | Notes |
|---|---|---|
| **Assign to** | Selected groups | Do not assign to All Users/All Devices until pilot validated |
| **Include groups** | `DWP-Win11-Managed-Devices` (or equivalent AAD group) | Target the group containing all Windows 11 Intune-enrolled devices |
| **Exclude groups** | `DWP-Kiosk-Devices`, `DWP-Test-Devices` | Exclude shared/kiosk devices and engineering test machines that would generate false positives |

### Phased Rollout Approach

| Phase | Include Group | Duration |
|---|---|---|
| Pilot | `DWP-Compliance-Pilot` (small sample, ~10 devices) | 2 weeks — monitor for false positives |
| Broad | `DWP-Win11-Managed-Devices` (full estate) | After pilot sign-off |

> **Note:** Compliance policies assigned to user groups evaluate compliance per user. Policies assigned to device groups evaluate per device. For DWP Windows 11 estate, **device group assignment is recommended** to ensure compliance is enforced regardless of which user is logged in.

### Conflict Handling

If a device is in scope of multiple compliance policies with conflicting settings, Intune applies the **most restrictive** result. Ensure kiosk exclusion groups are correctly maintained to prevent those devices from inheriting this policy via a broader group membership.

---

## Migration Risk Analysis – Highest False-Positive Threat

### Verdict: Requirement 1 – BitLocker (Health Attestation)

This is the single setting most likely to trigger a mass false-non-compliant event across a 10,000-device fleet during a Windows 11 migration.

---

### Why This Setting Is the Highest Risk

BitLocker compliance is not checked directly by the Intune agent. It is evaluated via the **Windows Health Attestation Service (HAS)** — a cloud service that reads a signed TPM attestation report. The report is generated at boot and submitted to HAS asynchronously. Intune reads the HAS report, not the live device state.

This creates a structural gap: **the device can be fully compliant, while Intune's compliance record still reflects the pre-upgrade state.**

Every other setting (Firewall, Defender, Password, OS version) is read directly from the device by the Intune agent at check-in. BitLocker is the only one that goes through an intermediary attestation chain with a built-in reporting lag.

---

### The Specific Scenario in Which It Fires Incorrectly

During a Windows 11 in-place upgrade, Windows **automatically suspends BitLocker** for the upgrade reboot sequence. This is by design — Microsoft suspends it to allow the bootloader and TPM PCR measurements to change without locking the device out. After the upgrade completes and the device boots into Windows 11, BitLocker **automatically resumes** without any admin action.

The false-positive sequence:

| Time | What Happens |
|---|---|
| T+0 | Upgrade begins. Windows suspends BitLocker. TPM PCR values change. |
| T+1h | Upgrade completes. Device boots into Windows 11. BitLocker auto-resumes. Device is healthy. |
| T+1h | Device checks in with Intune. Intune queries HAS for the BitLocker attestation report. |
| T+1h to T+24h | **HAS still holds the pre-upgrade attestation report showing BitLocker suspended.** Intune marks device non-compliant. |
| T+24h (approx) | HAS refreshes. New attestation report shows BitLocker active. Intune marks device compliant. |

In a 10,000-device migration running in weekly waves of 2,000–3,000 devices, this means **thousands of healthy, fully encrypted devices are simultaneously flagged as non-compliant** with no actual security risk present. If Conditional Access is enforced, those devices lose access to corporate resources mid-migration.

---

### The Exact Value to Set

Do **not** change the BitLocker setting value — it must stay as **Require**. Weakening it removes the encryption enforcement entirely.

The protection is in the **Actions for noncompliance grace period** and a pre-migration configuration change:

| Control | Setting | Rationale |
|---|---|---|
| Mark device noncompliant — Schedule | **7 days** | HAS refresh takes up to 24h. 7 days absorbs lag plus any re-check delays, without exposing the estate for more than one patch cycle. |
| Conditional Access — Grant control | Set **Require device to be marked as compliant** with a **filter excluding devices in migration group** | Prevents CA from blocking devices that are in-flight through the upgrade process. Remove the filter once migration wave completes. |
| Pre-migration Intune check-in | Force a manual sync on devices **after** BitLocker resumes post-upgrade, not before | Ensures the Intune agent captures the correct post-upgrade state at first opportunity rather than submitting a stale compliance report. |

> **Do not set the grace period to 0 for BitLocker at any point during migration.** Even in steady state, a 1-day grace period is the minimum safe value due to HAS lag on routine reboots and cumulative updates that also trigger TPM re-sealing.

---

### What to Monitor in the First 24 Hours After Policy Assignment

Run these checks immediately after assigning the policy to the first migration wave:

**1. Intune Compliance Report — BitLocker-specific breakdown**
- Path: **Devices → Manage devices → Compliance → Monitor → Setting compliance**
- Filter by: Setting = *Require BitLocker*, Status = *Not compliant*
- Expected: Spike in non-compliant devices shortly after migration wave. Should resolve within 24h as HAS refreshes.
- **Red flag:** Non-compliant count does not decrease after 24h — indicates BitLocker is genuinely not resuming post-upgrade on some devices.

**2. Cross-reference with BitLocker actual state**
- Path: **Devices → All devices → (select a flagged device) → Recovery keys**
- If a recovery key is present and escrowed, BitLocker is active — the non-compliant flag is a HAS lag false positive, not a real failure.
- If no recovery key is present, BitLocker did not resume — this is a genuine compliance failure requiring remediation.

**3. HAS attestation error codes**
- Path: **Devices → All devices → (select flagged device) → Device compliance → (policy name)**
- Look for error code **0x800704EC** (BitLocker suspended) vs **0x00000000** (healthy, awaiting refresh).
- Suspended errors on devices mid-upgrade are expected. Suspended errors on devices that finished upgrading 24h+ ago are not.

**4. Conditional Access sign-in logs**
- Path: **Azure AD (Entra ID) → Monitoring → Sign-in logs**, filter by: Failure reason = *Device is not compliant*
- If users in the migration wave are being blocked, confirm whether their device's Intune compliance record is in the HAS lag window.
- **Action threshold:** If more than 5% of the migration wave is being CA-blocked after 24h, pause the next wave and investigate.

---

## Post-Assignment Validation – Checking a Device After First Sync

### Where to Look in the Intune Admin Center

After the test device syncs, navigate to the device's individual compliance record:

**Path:**
**Devices → All devices → (select your test device by name) → Device compliance**

You will see a list of every compliance policy assigned to that device. Click the row for your **Windows 10/11 compliance policy** to open the per-setting breakdown.

This view shows:
- The overall compliance state of the policy on that device
- Each individual setting (BitLocker, Secure Boot, OS version, etc.) with its own pass/fail status
- The last evaluation time — confirm this is after the device synced, not a stale result

> **Alternative path if you know the policy name first:**
> Devices → Manage devices → **Compliance** → *(select your policy)* → **Device status**
> This shows all devices assigned to the policy and their current state in a single list. Use this to compare the test device against others in the same wave.

---

### What Each Compliance State Means for Conditional Access

| State | What It Means | Conditional Access Impact |
|---|---|---|
| **Compliant** | All settings in the policy are passing on this device at the last check-in. | CA grants access normally. Device satisfies the *Require device to be marked as compliant* grant control. |
| **In grace period** | One or more settings are failing, but the **Mark device noncompliant** schedule has not yet elapsed (e.g. still within the 7-day window). | **CA still grants access.** The device is treated as compliant for CA purposes during the grace period. The user is not blocked. |
| **Not compliant** | One or more settings are failing AND the grace period has expired. | **CA blocks access** to any resource protected by a policy requiring compliant devices. The user will see an access blocked or remediation required message. |
| **Not evaluated** | The policy has been assigned but the device has not yet checked in since assignment, or the check-in result has not yet been processed. | CA treats this as non-compliant and **may block access**, depending on CA policy configuration. Trigger a manual sync to resolve. |
| **Error** | Intune could not evaluate one or more settings — typically a reporting or connectivity issue, not a device misconfiguration. | Behaviour depends on CA configuration. Some tenants treat Error as non-compliant. Investigate the specific setting error code. |

> **Key point for DWP migration:** During the 7-day grace period, users are **not blocked**. This is intentional — it absorbs HAS attestation lag and mid-upgrade states. The grace period is not a security gap; Conditional Access is still enforced for any device that was already marked non-compliant before the policy was assigned.

---

### BitLocker Shows Non-Compliant Despite BitLocker Being Enabled — Three Causes and Fastest Checks

#### Cause 1 — Health Attestation Service (HAS) Reporting Lag

**What happens:** BitLocker is active on the device, but the HAS cloud report has not refreshed since the last reboot or upgrade. Intune reads the stale report and marks the device non-compliant.

**Fastest check:**
On the device, open an elevated PowerShell prompt and run:
```powershell
manage-bde -status C:
```
Look for **Protection Status: Protection On**. If this shows On, BitLocker is genuinely active and the non-compliant state is a HAS lag false positive.

Also confirm in Intune:
**Devices → All devices → (device) → Recovery keys**
If a BitLocker recovery key is present and escrowed, the drive was encrypted at the time of key escrow. A missing key combined with non-compliant status suggests genuine encryption failure.

**Resolution:** Wait up to 24 hours for HAS to refresh, or force a device restart followed by an Intune sync (**Settings → Accounts → Access work or school → (account) → Info → Sync**).

---

#### Cause 2 — BitLocker Suspended (Not Turned Off, But Paused)

**What happens:** BitLocker is installed and the key protectors are in place, but protection has been **suspended** — either by Windows during a cumulative update, by an admin script, or by a BIOS/firmware update. HAS correctly reports the suspended state. Intune correctly flags it. This is not a false positive — it is a real state — but it is transient and auto-resolves.

**Fastest check:**
Run on the device:
```powershell
manage-bde -status C:
```
Look for **Protection Status: Protection Suspended** and **Conversion Status: Fully Encrypted**.

This combination means the drive is fully encrypted, the key protector exists, but protection is temporarily paused. Windows will auto-resume on next restart in most cases.

**Resolution:** Restart the device. BitLocker auto-resumes. Trigger an Intune sync post-restart. HAS will update within the next check cycle.

---

#### Cause 3 — TPM Not Ready or PCR Mismatch After Hardware Change

**What happens:** A hardware change (motherboard replacement, BIOS update, TPM firmware update) has invalidated the TPM PCR measurements that BitLocker sealed the encryption key against. BitLocker may enter recovery mode or show as needing re-sealing. HAS reports this as a failed attestation.

**Fastest check:**
On the device, run:
```powershell
Get-Tpm
```
Check:
- **TpmPresent: True**
- **TpmReady: True**
- **TpmEnabled: True**
- **TpmActivated: True**

If any of these are False, the TPM is not in a usable state and BitLocker cannot attest correctly.

Also check the Windows Event Log:
- Open **Event Viewer → Applications and Services Logs → Microsoft → Windows → BitLocker-API → Management**
- Look for Event ID **853** (TPM not available) or **773** (recovery information not backed up)

**Resolution:** If TpmReady is False, run `tpm.msc`, clear and re-initialise the TPM (requires admin rights and a device restart). After TPM is ready, BitLocker will re-seal against the new PCR values and HAS will update at the next attestation cycle. Ensure the new BitLocker recovery key is escrowed to Intune before clearing the TPM.

---

### Summary: BitLocker False-Positive Quick Reference

| Cause | PowerShell Check | Expected Output if False Positive | Resolution Time |
|---|---|---|---|
| HAS lag | `manage-bde -status C:` | Protection On, Fully Encrypted | Up to 24h (auto) |
| BitLocker suspended | `manage-bde -status C:` | Protection Suspended, Fully Encrypted | Restart device (minutes) |
| TPM not ready | `Get-Tpm` | TpmReady: False | TPM re-init required (30–60 min) |

---



> The following settings have **known UI path changes** since earlier Intune releases. Verify in your tenant before deployment.

| Requirement | Flag | Notes |
|---|---|---|
| Req 1 – BitLocker | ⚠️ | Previously under **Device Health → Windows Health Attestation Service**. As of recent Intune updates (2024+), BitLocker may appear under a renamed section. Verify path in your tenant. |
| Req 4 – Defender Real-Time Protection | ⚠️ | The **Microsoft Defender Antimalware** section has been reorganised in the Intune UI as part of the Security settings consolidation. Some settings previously in Compliance have moved to **Endpoint Security → Antivirus**. Confirm the setting still exists in Compliance vs. needing a separate Endpoint Security policy. |
| Req 7 – Defender for Endpoint Risk Score | ⚠️ | Requires the **Defender for Endpoint connector** to be enabled in Intune (**Tenant administration** → Connectors and tokens → Microsoft Defender for Endpoint). Without the connector active, this setting will not appear in the compliance policy wizard. |

**Recommended action:** Before publishing the compliance policy, open a test tenant or validate in a dev ring and confirm each UI path against the current Intune portal. Microsoft regularly updates the Intune console layout.

---

## Summary Table

| Req | Setting Name | Value | Grace Period |
|---|---|---|---|
| 1 | Require BitLocker | Require | 7 days |
| 2 | Require Secure Boot | Require | 7 days |
| 3 | Minimum OS version | 10.0.22621.2861 | 7 days |
| 4 | Require real-time protection | Require | 7 days |
| 5 | Microsoft Defender Firewall | Require | 7 days |
| 6 | Require a password to unlock mobile devices | Require | 7 days |
| 7 | Machine risk score (Defender for Endpoint) | Clear / Low | 7 days |

---

*Document prepared by DWP Engineering. Review cycle: Monthly (aligned to Patch Tuesday). Next review: 2026-09-08.*
