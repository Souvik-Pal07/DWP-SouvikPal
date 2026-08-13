param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "b2aec6aa-1e56-4921-a853-0faa80e541d3",

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "dwpai-lab-rg",

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory = $false)]
    [string]$HostPoolName = "POOL-FIN-01",

    [Parameter(Mandatory = $false)]
    [string]$DesktopAppGroupName = "POOL-FIN-01-DAG",

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceName = "FinBridge-Workspace",

    [Parameter(Mandatory = $false)]
    [string]$VmName = "finavdsh75",

    [Parameter(Mandatory = $false)]
    [string]$VmSize = "Standard_B2ms",

    [Parameter(Mandatory = $false)]
    [string]$VmImage = "MicrosoftWindowsDesktop:office-365:win11-24h2-avd-m365:latest",

    [Parameter(Mandatory = $false)]
    [string]$AdminUsername = "localavdadmin",

    [Parameter(Mandatory = $false)]
    [string]$TargetUserUpn = "p55@zippyops.in"
)

$ErrorActionPreference = "Stop"

function New-RandomPassword {
    param([int]$Length = 24)
    $chars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^*-_=+".ToCharArray()
    -join (1..$Length | ForEach-Object { $chars | Get-Random })
}

Write-Host "Setting subscription context..."
az account set -s $SubscriptionId

Write-Host "Checking signed-in identity and RBAC..."
$currentUser = az ad signed-in-user show --query "{id:id,userPrincipalName:userPrincipalName}" -o json | ConvertFrom-Json
$ownerAtSub = az role assignment list --assignee $currentUser.id --scope "/subscriptions/$SubscriptionId" --query "[?roleDefinitionName=='Owner'] | length(@)" -o tsv
Write-Host "Signed-in user: $($currentUser.userPrincipalName)"
Write-Host "Owner assignments at subscription scope: $ownerAtSub"

Write-Host "Resolving target M365 user..."
$targetUser = az ad user show --id $TargetUserUpn -o json | ConvertFrom-Json
if (-not $targetUser.id) {
    throw "Target user not found: $TargetUserUpn"
}

Write-Host "Creating host pool..."
$hostPool = az desktopvirtualization hostpool create `
    -g $ResourceGroup `
    -n $HostPoolName `
    -l $Location `
    --friendly-name $HostPoolName `
    --description "Finance pooled host pool for Windows 11 migration" `
    --host-pool-type Pooled `
    --load-balancer-type BreadthFirst `
    --max-session-limit 5 `
    --preferred-app-group-type Desktop `
    --custom-rdp-property "targetisaadjoined:i:1;" `
    -o json | ConvertFrom-Json

Write-Host "Creating desktop application group..."
$appGroup = az desktopvirtualization applicationgroup create `
    -g $ResourceGroup `
    -n $DesktopAppGroupName `
    -l $Location `
    --friendly-name $DesktopAppGroupName `
    --description "Desktop application group for finance workspace" `
    --host-pool-arm-path $hostPool.id `
    --application-group-type Desktop `
    -o json | ConvertFrom-Json

Write-Host "Creating workspace and linking app group..."
$workspace = az desktopvirtualization workspace create `
    -g $ResourceGroup `
    -n $WorkspaceName `
    -l $Location `
    --friendly-name $WorkspaceName `
    --description "Finance workspace" `
    --application-group-references $appGroup.id `
    -o json | ConvertFrom-Json

Write-Host "Creating session host VM with Trusted Launch and system-assigned identity..."
$adminPassword = New-RandomPassword
$vmCreate = az vm create `
    -g $ResourceGroup `
    -n $VmName `
    -l $Location `
    --image $VmImage `
    --size $VmSize `
    --admin-username $AdminUsername `
    --admin-password $adminPassword `
    --assign-identity [system] `
    --security-type TrustedLaunch `
    --enable-secure-boot true `
    --enable-vtpm true `
    --license-type Windows_Client `
    --public-ip-sku Standard `
    --nsg-rule RDP `
    --vnet-name dwpai-avd-vnet `
    --subnet dwpai-avd-sessionhosts `
    --vnet-address-prefix 10.20.0.0/16 `
    --subnet-address-prefix 10.20.1.0/24 `
    -o json | ConvertFrom-Json

Write-Host "Enabling AADLoginForWindows extension..."
az vm extension set `
    -g $ResourceGroup `
    --vm-name $VmName `
    --publisher Microsoft.Azure.ActiveDirectory `
    --name AADLoginForWindows `
    -o none

Write-Host "Assigning RBAC for direct VM login and published desktop access..."
$vmId = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VmName"
az role assignment create --assignee-object-id $targetUser.id --assignee-principal-type User --role "Virtual Machine User Login" --scope $vmId -o none
az role assignment create --assignee-object-id $targetUser.id --assignee-principal-type User --role "Desktop Virtualization User" --scope $appGroup.id -o none

Write-Host "Deployment phase complete."

[pscustomobject]@{
    SubscriptionId = $SubscriptionId
    ResourceGroup = $ResourceGroup
    HostPoolName = $HostPoolName
    DesktopAppGroupName = $DesktopAppGroupName
    WorkspaceName = $WorkspaceName
    VmName = $VmName
    VmPrivateIp = $vmCreate.privateIpAddress
    VmPublicIp = $vmCreate.publicIpAddress
    TargetUser = $TargetUserUpn
} | Format-List
