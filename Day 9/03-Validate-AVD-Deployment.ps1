param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "b2aec6aa-1e56-4921-a853-0faa80e541d3",

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = "dwpai-lab-rg",

    [Parameter(Mandatory = $false)]
    [string]$HostPoolName = "POOL-FIN-01",

    [Parameter(Mandatory = $false)]
    [string]$DesktopAppGroupName = "POOL-FIN-01-DAG",

    [Parameter(Mandatory = $false)]
    [string]$WorkspaceName = "FinBridge-Workspace",

    [Parameter(Mandatory = $false)]
    [string]$VmName = "finavdsh75",

    [Parameter(Mandatory = $false)]
    [string]$TargetUserObjectId = "d82f1368-c4f3-41ee-9165-60f787fa67a3",

    [Parameter(Mandatory = $false)]
    [string]$PublicIpName = "finavdsh75PublicIP"
)

$ErrorActionPreference = "Stop"
az account set -s $SubscriptionId

Write-Host "Checking session host state..."
$sessionHosts = az rest --method get --url "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.DesktopVirtualization/hostPools/$HostPoolName/sessionHosts?api-version=2024-04-03" --query "value[].{name:name,status:properties.status,lastHeartBeat:properties.lastHeartBeat,aadCheck:properties.sessionHostHealthCheckResults[?healthCheckName=='AADJoinedHealthCheck'].healthCheckResult | [0]}" -o json | ConvertFrom-Json

Write-Host "Checking user role assignments..."
$vmScope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Compute/virtualMachines/$VmName"
$appGroupScope = "/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup/providers/Microsoft.DesktopVirtualization/applicationgroups/$DesktopAppGroupName"
$vmRoles = az role assignment list --assignee $TargetUserObjectId --scope $vmScope --query "[].roleDefinitionName" -o json | ConvertFrom-Json
$appRoles = az role assignment list --assignee $TargetUserObjectId --scope $appGroupScope --query "[].roleDefinitionName" -o json | ConvertFrom-Json

Write-Host "Checking workspace binding..."
$workspace = az desktopvirtualization workspace show -g $ResourceGroup -n $WorkspaceName --query "{name:name,appGroups:applicationGroupReferences}" -o json | ConvertFrom-Json

Write-Host "Checking VM endpoint details..."
$vm = az vm show -d -g $ResourceGroup -n $VmName --query "{name:name,computerName:osProfile.computerName,privateIp:privateIps,publicIp:publicIps}" -o json | ConvertFrom-Json
$pip = az network public-ip show -g $ResourceGroup -n $PublicIpName --query "{dnsLabel:dnsSettings.domainNameLabel,fqdn:dnsSettings.fqdn,ip:ipAddress}" -o json | ConvertFrom-Json

[pscustomobject]@{
    SessionHosts = $sessionHosts
    VmRoleAssignments = $vmRoles
    AppGroupRoleAssignments = $appRoles
    Workspace = $workspace
    Vm = $vm
    PublicEndpoint = $pip
} | ConvertTo-Json -Depth 8
