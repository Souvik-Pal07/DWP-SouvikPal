param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "b2aec6aa-1e56-4921-a853-0faa80e541d3",

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "dwpai-lab-rg",

    [Parameter(Mandatory = $false)]
    [string]$HostPoolName = "POOL-FIN-01",

    [Parameter(Mandatory = $false)]
    [string]$VmName = "finavdsh75",

    [Parameter(Mandatory = $false)]
    [int]$TokenLifetimeHours = 24
)

$ErrorActionPreference = "Stop"

Write-Host "Setting subscription context..."
az account set -s $SubscriptionId

Write-Host "Generating host pool registration token..."
$expiration = [DateTime]::UtcNow.AddHours($TokenLifetimeHours).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
az desktopvirtualization hostpool update -g $ResourceGroup -n $HostPoolName --registration-info expiration-time=$expiration registration-token-operation=Update -o none
$token = az desktopvirtualization hostpool retrieve-registration-token -g $ResourceGroup -n $HostPoolName --query token -o tsv
if (-not $token) {
    throw "Failed to retrieve registration token."
}

# Use a JSON file for CSE settings to avoid PowerShell JSON quoting issues.
$tempSettingsPath = Join-Path $env:TEMP "avd-cse-settings.json"
$cmd = "powershell -ExecutionPolicy Bypass -Command `"`$ProgressPreference='SilentlyContinue'; `$ErrorActionPreference='Stop'; Set-Location `$env:TEMP; Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2310011' -UseBasicParsing -OutFile 'avd-agent.msi'; Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2311028' -UseBasicParsing -OutFile 'avd-bootloader.msi'; Start-Process msiexec.exe -ArgumentList '/i avd-agent.msi /quiet REGISTRATIONTOKEN=$token' -Wait -NoNewWindow; Start-Process msiexec.exe -ArgumentList '/i avd-bootloader.msi /quiet' -Wait -NoNewWindow;`""

$settings = @{ commandToExecute = $cmd } | ConvertTo-Json -Compress
Set-Content -Path $tempSettingsPath -Value $settings -Encoding ascii

Write-Host "Installing AVD agent and bootloader through CustomScriptExtension..."
az vm extension set `
    -g $ResourceGroup `
    --vm-name $VmName `
    --publisher Microsoft.Compute `
    --name CustomScriptExtension `
    --settings "@$tempSettingsPath" `
    -o none

Write-Host "Revoking registration token after successful host registration..."
az desktopvirtualization hostpool update -g $ResourceGroup -n $HostPoolName --registration-info registration-token-operation=Delete -o none

Remove-Item -Path $tempSettingsPath -Force -ErrorAction SilentlyContinue
Write-Host "Registration phase complete."
