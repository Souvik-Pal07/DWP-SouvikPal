# DWP AVD Provisioning Runbook - FinBridge Win11 Migration

Date: 2026-08-13
Engineer Role: DWP (Desktop Workplace)
Deployment Scope: Azure Virtual Desktop end-to-end build in East US

## Environment

- Subscription ID: b2aec6aa-1e56-4921-a853-0faa80e541d3
- Resource Group: dwpai-lab-rg
- Region: eastus
- Tenant: zippyops.in
- Target user account: p55@zippyops.in

## What Was Provisioned

- Host pool: POOL-FIN-01
  - Type: Pooled
  - Load balancer: BreadthFirst
  - Max sessions per host: 5
  - Custom RDP property: targetisaadjoined:i:1;
- Desktop application group: POOL-FIN-01-DAG
- Workspace: FinBridge-Workspace
- Session host VM: finavdsh75
  - OS Image: MicrosoftWindowsDesktop:office-365:win11-24h2-avd-m365:latest
  - Size: Standard_B2ms
  - Security: TrustedLaunch with Secure Boot and vTPM
  - Join model: Microsoft Entra ID joined (AADLoginForWindows)

## Access and RBAC

Assigned to p55@zippyops.in:

- Virtual Machine User Login on VM scope (direct RDP to Entra joined VM)
- Desktop Virtualization User on application group scope (AVD desktop entitlement)

## Final Verified State

- Session host: POOL-FIN-01/finavdsh75
- Session host status: Available
- AAD joined health check: HealthCheckSucceeded
- VM endpoint:
  - Public IP: 20.102.63.253
  - FQDN: finavdsh75-eastus-avd.eastus.cloudapp.azure.com

## Direct Login Details

Use Microsoft Entra credentials:

- Host: finavdsh75-eastus-avd.eastus.cloudapp.azure.com
- Username: AzureAD\\p55@zippyops.in

Notes:

- For direct RDP to Entra joined VM, hostname-based connection is preferred over raw IP.
- Host pool includes targetisaadjoined:i:1; to support compatible client behavior.

## Scripts Captured Under Day 9

Execution order:

1. 01-Deploy-AVD-ControlPlane-And-Host.ps1
2. 02-Register-SessionHost.ps1
3. 03-Validate-AVD-Deployment.ps1

## Important Troubleshooting Notes From This Build

1. AADLoginForWindows extension rejected --enable-auto-upgrade.
   - Fix: deploy extension without that flag.
2. PowerShell inline JSON quoting broke CustomScriptExtension settings.
   - Fix: write settings JSON to a file and pass with --settings @file.
3. Run Command extension had execution lock conflict.
   - Fix: used CustomScriptExtension path for agent and bootloader install.

## Security and Cleanup Performed

- Host pool registration token was deleted after host registration.
- Temporary local JSON containing token was removed after use.

## Suggested Re-run Pattern

For repeatable deployments in this lab:

1. Run script 01 for infrastructure, host, and RBAC.
2. Run script 02 for host registration.
3. Run script 03 to confirm final health and access outcomes.
