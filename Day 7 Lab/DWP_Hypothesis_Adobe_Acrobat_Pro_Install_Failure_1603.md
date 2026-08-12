# DWP Hypothesis – Adobe Acrobat Pro v23.6 Intune Install Failure (Error 1603)

**Date of logs:** 2024-03-15  
**Analyst role:** DWP Engineer  
**Log source:** Intune AgentExecutor / AppInstaller  

---

## Summary of Observed Behaviour

Adobe Acrobat Pro v23.6 was deployed via Intune using an `.intunewin` package under SYSTEM context. Both the initial install attempt and a 60-minute retry failed with **MSI return code 1603**. Post-install detection (registry check) confirmed the application was not present on the device.

---

## Key Log Observations

| Timestamp | Event | Significance |
|---|---|---|
| 10:01:03 | `msiexec /i AcrobatPro.msi /quiet` | Silent install, no `/log` flag – no verbose MSI log generated |
| 10:01:44 | Return code **1603** | Fatal error during installation |
| 10:01:45 | Detection key: `HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0` | Registry path references **Reader**, not **Pro** |
| 10:01:45 | Detection result: Not detected | Confirms installation did not complete |
| 11:02:31 | Retry also returns **1603** | Error is consistent and not transient |

---

## Hypothesis

### Primary Hypothesis – Conflicting Existing Adobe Installation

**MSI error 1603 ("Fatal error during installation")** with Adobe products is most commonly triggered when a prior version of Adobe Acrobat or Adobe Reader is already installed on the device and was not removed before deploying the new package.

Adobe's MSI installer enforces upgrade/conflict rules. If an older version of Adobe Acrobat or a copy of Adobe Reader is present, the installer may fail during the upgrade phase and roll back, producing error 1603 without a clear on-screen message (due to the `/quiet` flag suppressing UI).

The fact that both attempts fail with the same code rules out a transient or timing issue, pointing to a persistent blocking condition on the device.

### Supporting Hypothesis – Detection Rule Misconfiguration

The detection rule checks:

```
HKLM\SOFTWARE\Adobe\Acrobat Reader\23.0
```

However, the package being deployed is **Adobe Acrobat Pro**, which installs to a different registry path, typically:

```
HKLM\SOFTWARE\Adobe\Adobe Acrobat\23.0
```

This mismatch suggests the Intune app package may have been configured with an incorrect detection rule. While this would not cause the 1603 failure itself, it indicates the package was likely cloned from an Adobe Reader deployment and not properly updated, raising the possibility of other misconfigured settings (e.g., incorrect MSI product code, wrong install command, or missing prerequisites).

### Secondary Hypothesis – Missing MSI Verbose Logging

The install command does not include a `/log` parameter:

```
msiexec /i AcrobatPro.msi /quiet
```

Without a verbose MSI log (`/L*V`), the root cause of 1603 cannot be confirmed from these logs alone. A definitive diagnosis requires reviewing the MSI log file, which would show exactly which action failed during installation.

---

## Most Likely Root Cause

A pre-existing Adobe application (Reader or an older Acrobat version) on the target device is blocking the silent MSI installation, causing a rollback and return code 1603. The misconfigured detection rule supports the view that the package configuration was not fully validated before deployment.

---

## Recommended Next Steps

1. **Check the device** for any existing Adobe Acrobat or Reader installations via Apps & Features or registry.
2. **Add an uninstall prerequisite** in Intune (dependency or requirement rule) to remove conflicting Adobe products before installing Acrobat Pro.
3. **Enable verbose MSI logging** by updating the install command:
   ```
   msiexec /i AcrobatPro.msi /quiet /L*V "%TEMP%\AcrobatPro_install.log"
   ```
4. **Correct the detection rule** to point to the Acrobat Pro registry path, not the Acrobat Reader path.
5. **Review the `.intunewin` package** to confirm the MSI is not corrupt and all prerequisites (Visual C++ Redistributables, .NET) are met.
6. **Test on a clean VM** without any Adobe products to determine whether the issue is device-specific or a package defect.

---

*Hypothesis created by DWP Engineer – 2026-08-12*
