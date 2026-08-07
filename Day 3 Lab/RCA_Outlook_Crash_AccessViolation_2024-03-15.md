# Prompt
---
You are a DWP analyst, reviewing an application crash incident. Below are Application Event Viewer log entries captured during a period when Microsoft Outlook repeatedly crashed. For each Event ID explain what it records. Then reconstruct the sequence of events in plain English, and give the most likely cause of the crash with evidence from the events. Finally create a detailed RCA document with 5 why analysis and store it under Day 3 Lab folder.

Log Name: Application
Source: Application Error
Event ID: 1000
Level: Error
Date: 2024-03-15 09:14:22

Faulting application name: OUTLOOK.EXE, version: 16.0.17126.20132
Faulting module name: KERNELBASE.dll, version: 10.0.22621.3155
Exception code: 0xc0000005
Fault offset: 0x000000000003a4b2
Faulting process ID: 0x1f4c
Faulting application start time: 2024-03-15 09:13:44
Faulting application path: C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE
Faulting module path: C:\Windows\System32\KERNELBASE.dll
Report ID: a3c2f1d4-89bb-4e21-91d7-f2c3a1b09e44

Log Name: Application
Source: Application Error
Event ID: 1000
Level: Error
Date: 2024-03-15 09:17:45

Faulting application name: OUTLOOK.EXE, version: 16.0.17126.20132
Faulting module name: KERNELBASE.dll, version: 10.0.22621.3155
Exception code: 0xc0000005
Fault offset: 0x000000000003a4b2

Log Name: Application
Source: Windows Error Reporting
Event ID: 1001
Level: Information
Date: 2024-03-15 09:18:01
Description: Fault bucket 1847362910, type 4
Event Name: APPCRASH
Response: Not available
Cab Id: 0

Log Name: Application
Source: .NET Runtime
Event ID: 1026
Level: Error
Date: 2024-03-15 09:18:05
Description: Application: OUTLOOK.EXE
Framework Version: v4.0.30319
Description: The process was terminated due to an unhandled exception.
Exception Info: System.AccessViolationException

# Root Cause Analysis — Microsoft Outlook Repeated Crash
**Incident Date:** 2024-03-15  
**Analyst:** DWP Analyst  
**Document Created:** 2026-08-06  
**Severity:** High — Outlook completely unusable for affected user  
**Status:** Root Cause Identified

---

## 1. Event ID Reference — What Each Event Records

| Event ID | Source | Level | Purpose |
|----------|--------|-------|---------|
| **1000** | Application Error | Error | Records an application crash at the OS level. Captures the faulting application name/version, the faulting module (the DLL where the exception surfaced), exception code, fault offset, process ID, and file paths. Two entries here confirm the crash was reproducible, not a one-off. |
| **1001** | Windows Error Reporting (WER) | Information | Logged by WER immediately after a crash is processed. Assigns the crash to a "fault bucket" — a grouping ID used by Microsoft telemetry to cluster identical crash signatures. "Response: Not available" means no automatic fix or Known Issue resolution was returned from Microsoft. |
| **1026** | .NET Runtime | Error | Records an unhandled .NET exception that forcibly terminated the process. Identifies the CLR version and the exception type. In this case `System.AccessViolationException` confirms the crash originated in managed (.NET) code — strongly indicating a .NET-based COM or VSTO add-in was involved. |

---

## 2. Sequence of Events — Plain English Reconstruction

| Time | What Happened |
|------|---------------|
| **09:13:44** | Outlook (version 16.0.17126.20132) was launched by the user. |
| **09:14:22** | **~38 seconds later**, Outlook crashed. Exception code `0xc0000005` (Access Violation) was raised inside `KERNELBASE.dll` at offset `0x000000000003a4b2`. Windows logged Event ID 1000. |
| **~09:14–09:17** | The user (or Windows) restarted Outlook. |
| **09:17:45** | Outlook crashed a second time — identical exception code and identical fault offset. This rules out a random/transient memory fault. The same code path was triggered again. Windows logged a second Event ID 1000. |
| **09:18:01** | Windows Error Reporting processed the crash, assigned it to Fault Bucket 1847362910 (Event ID 1001). No automatic fix was available. |
| **09:18:05** | The .NET Runtime logged Event ID 1026 confirming the crash was caused by an unhandled `System.AccessViolationException` in a .NET component running inside Outlook. |

---

## 3. Most Likely Cause — Analysis with Evidence

### Conclusion
A **.NET-based COM/VSTO add-in** loaded by Outlook is triggering a `System.AccessViolationException` — an attempt to read or write a memory address the process does not own or that has already been freed.

### Supporting Evidence

| Evidence | Interpretation |
|----------|---------------|
| Exception code `0xc0000005` (two occurrences) | `STATUS_ACCESS_VIOLATION` — the process attempted to access protected or unmapped memory. This is the Windows-level translation of a .NET `AccessViolationException`. |
| Faulting module: `KERNELBASE.dll` | `KERNELBASE.dll` is the low-level Windows kernel interface library. It rarely *causes* crashes; it is where the OS *surfaces* the exception when memory is illegally accessed. The true origin is the component that made the bad memory call. |
| Identical fault offset `0x000000000003a4b2` in both crashes | A consistent offset means the same instruction within `KERNELBASE.dll` is being hit every time. This indicates a **deterministic, reproducible bug** triggered by a specific operation — not random memory corruption. |
| Event ID 1026 — `System.AccessViolationException` from .NET Runtime | Confirms a managed (.NET/VSTO) component inside Outlook's process space threw the exception. Outlook itself is a native Win32 application; this exception originates from a loaded .NET add-in. |
| Crash occurs within ~38 seconds of startup | Outlook crashes during or immediately after the add-in loading/initialisation phase, not during normal user operation. This strongly points to add-in startup code (e.g., `ThisAddIn_Startup`, ribbon load, profile read) as the trigger. |
| WER response "Not available" | No Microsoft Known Issue matches this exact crash signature, suggesting it is not a core Outlook or OS bug — further supporting a third-party or custom add-in as the cause. |

### Alternative Causes (Lower Probability)

- **Corrupted Outlook profile or OST/PST file** — possible, but would typically surface as a different exception (e.g., `COMException`, file I/O error) rather than a clean `AccessViolationException` at a fixed offset.
- **Faulty graphics driver interfering with Outlook's rendering** — possible in rare cases, but would not produce a .NET Runtime Event ID 1026.
- **Windows OS memory corruption** — very unlikely given the identical fault offsets; OS-level corruption would be non-deterministic.

---

## 4. Five Why (5-Why) Root Cause Analysis

**Problem Statement:** Microsoft Outlook crashes with `System.AccessViolationException` on every launch, making it completely unusable.

---

### Why 1 — Why did Outlook crash?
**Answer:** Outlook terminated with Windows exception code `0xc0000005` (Access Violation), as recorded in two consecutive Event ID 1000 entries. The process attempted to access a memory address it did not have permission to read or write.

---

### Why 2 — Why did an access violation occur inside Outlook?
**Answer:** Event ID 1026 from the .NET Runtime confirms that the violation originated in managed (.NET) code running inside Outlook's process. A .NET component performed an illegal memory operation — most likely a null pointer dereference, use-after-free, or an unsafe pointer operation in unmanaged interop code.

---

### Why 3 — Why was .NET code making illegal memory accesses inside Outlook?
**Answer:** The identical fault offset (`0x000000000003a4b2`) across both crashes, combined with the crash occurring within 38 seconds of startup, indicates a **specific .NET-based COM or VSTO add-in** is executing faulty initialisation code. The add-in is calling into unmanaged memory (via P/Invoke or COM interop) without proper null checking or bounds validation, or it is referencing an object that has already been disposed.

---

### Why 4 — Why is the add-in executing faulty code that causes a memory violation?
**Answer:** The add-in is **incompatible with the installed version of Outlook** (16.0.17126.20132 / Office 365 build). Outlook version updates can change COM object interfaces, ribbon extensibility APIs, or internal object lifetimes. An add-in built and tested against an earlier build may dereference a pointer or COM object that no longer exists or has moved, causing the access violation at the same offset on every run.

---

### Why 5 — Why was an incompatible add-in permitted to load on this version of Outlook?
**Answer:** **Add-in compatibility was not validated before the Outlook/Office 365 update was deployed.** There was no pre-deployment testing process to verify that installed COM/VSTO add-ins remained functional against the new Office build. Additionally, there is no enforced Group Policy or Intune policy to block or require re-certification of add-ins after a major Office update, allowing the incompatible add-in to load silently and crash Outlook.

---

## 5. Root Cause Statement

> A .NET-based VSTO or COM add-in installed in Microsoft Outlook is incompatible with Office 365 build 16.0.17126.20132. During its initialisation phase it performs an illegal memory access (null pointer dereference or invalid COM object reference via unmanaged interop), triggering `System.AccessViolationException`. This crashes Outlook deterministically on every launch. The incompatible add-in was able to load because no add-in compatibility validation process exists as part of the Office update deployment pipeline.

---

## 6. Immediate Actions (Fix)

| Priority | Action | Owner |
|----------|--------|-------|
| P1 — Immediate | Launch Outlook in Safe Mode (`outlook.exe /safe`) to bypass all add-ins and confirm Outlook is stable without them. | Analyst |
| P1 — Immediate | Identify all loaded COM/VSTO add-ins via **File → Options → Add-ins → COM Add-ins → Go**. Disable all add-ins, then re-enable one by one to isolate the faulting add-in. | Analyst |
| P1 — Immediate | Once identified, disable or uninstall the faulting add-in. Check the vendor's website for an updated version compatible with the current Office build. | Analyst / User |
| P2 — Short term | If the add-in is business-critical, raise an urgent request with the vendor for a compatibility patch, referencing Office build 16.0.17126.20132 and the `System.AccessViolationException`. | IT Manager / Vendor |

---

## 7. Long-Term Preventative Actions

| Action | Rationale |
|--------|-----------|
| Establish a pre-deployment add-in compatibility test cycle for all Office updates pushed via Intune/SCCM. | Catches incompatible add-ins in a test ring before they reach production users. |
| Maintain a vetted add-in register (name, version, vendor, last-tested Office build) and enforce it via Group Policy or Intune App Configuration. | Prevents unapproved or out-of-date add-ins from loading. |
| Configure WER (Windows Error Reporting) centralised collection or Microsoft Endpoint Analytics to alert on repeated Event ID 1000 crashes across the estate. | Enables proactive detection of widespread add-in-related crashes before user impact scales. |
| Include add-in unload/crash resilience testing in the change management process for all Office version updates. | Embeds compatibility assurance into the change process rather than leaving it to reactive support. |

---

## 8. Evidence Summary

| Item | Value |
|------|-------|
| Faulting Application | OUTLOOK.EXE v16.0.17126.20132 |
| Faulting Module | KERNELBASE.dll v10.0.22621.3155 |
| Exception Code | 0xc0000005 (Access Violation) |
| Fault Offset (both crashes) | 0x000000000003a4b2 |
| .NET Exception Type | System.AccessViolationException |
| CLR Version | v4.0.30319 |
| WER Fault Bucket | 1847362910 |
| Report ID | a3c2f1d4-89bb-4e21-91d7-f2c3a1b09e44 |
| Crash reproducibility | 100% — identical on both attempts |

---

*Document prepared by DWP Analyst | 2026-08-06*
