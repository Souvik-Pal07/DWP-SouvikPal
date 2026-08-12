# Digital Employee Experience — Root Cause Analysis
## Finance-Win11 Startup Performance Drop (2026-08-04)

---

## Ranked Hypothesis List

### 1. **Compliance Logging Startup Script — HIGH PROBABILITY**

**Why It Fits the Evidence:**
- The config change explicitly included a "startup script added for compliance logging"
- Startup scripts run synchronously during login, directly blocking the "login to usable desktop" metric
- Timing is perfect: deployed 2026-08-04 02:00, impact visible in same-day metrics
- Magnitude (23.8 sec increase) is consistent with I/O-heavy logging operations at startup
- **Comparison group has no script deployment** → IT-Win11 unaffected, confirming deployment causation

**Fastest Confirmation Check:**
1. Review deployed baseline profile in Intune/SCCM — extract exact startup script payload
2. Execute script on test device, measure startup time with/without script
3. Check Finance-Win11 event logs (Application, Security) for script execution timing/errors on 2026-08-04 onwards
4. **Expected result:** Script typically adds 15–30 sec if writing compliance telemetry to local/network logs

---

### 2. **Defender Scan Policy Initialization — MEDIUM-HIGH PROBABILITY**

**Why It Fits the Evidence:**
- Config included "additional Defender scan policy" — explicitly a Defender change
- If policy triggers full/quick scan at startup, would cause CPU/disk contention, extending login time
- Timing aligns perfectly with deployment
- Magnitude could account for scan overhead (depends on scope — quick vs. full scan)
- **Comparison group (IT-Win11) had no policy change** → would not experience Defender overhead

**Fastest Confirmation Check:**
1. Compare Defender policy settings: Finance-Win11 vs. IT-Win11 baseline
2. Check Windows Defender event logs (Event ID 1000–1005) for scan initiation on 2026-08-04
3. Run test device with old policy: measure startup time
4. Deploy new policy to test device, measure startup time
5. **Expected result:** Quick scans add 5–15 sec; full scans can add 20+ sec if running at login

---

### 3. **Configuration Engine Reprocessing Overhead — MEDIUM PROBABILITY**

**Why It Fits the Evidence:**
- Large baseline profile deployment can trigger repeated reprocessing/reapplication cycles
- Initial deployment day often shows higher overhead as settings are applied and validated
- Timing matches deployment window
- Could explain why degradation sustained (2026-08-05, 2026-08-06) — reapplication cycles or uncompleted sync
- **Comparison group was not targeted**, so would not experience this overhead

**Fastest Confirmation Check:**
1. Check client logs on Finance-Win11 devices: ConfigMgr/Intune logs for 2026-08-04 timestamps
2. Search for "reapply" or "retry" events in logs (indicate repeated config cycles)
3. Monitor Policy Engine CPU/Disk during startup on 2026-08-04 vs. 2026-08-05 on a test device
4. Check if degradation reduces after 2026-08-07 (would suggest initial sync overhead resolved)
5. **Expected result:** If reprocessing, logs will show multiple application cycles; should improve as sync completes

---

## Investigation Priority

**Start with #1 (Startup Script)** — highest confidence, most specific to deployment detail, fastest to check.
Then #2 (Defender) — explicit policy change, measurable via event logs.
Rule out #3 only if #1 and #2 are cleared.

---

**Document Generated:** 2026-08-12  
**Analysis Basis:** Scope facts from Finance-Win11 vs. IT-Win11 comparison  
**Next Step:** Execute confirmation checks; escalate findings to deployment team
