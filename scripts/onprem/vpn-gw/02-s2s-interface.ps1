<#
  Phase 3.5: site-to-site interface from VPN-GW to the Azure VPN gateway.
  Run on VPN-GW once the Azure gateway and connection exist (scripts/azure/05).

  .\02-s2s-interface.ps1 -AzureGatewayIp 20.1.2.3 -SharedKey "<same key as config.env>"
#>
param(
  [Parameter(Mandatory)][string]$AzureGatewayIp,
  [Parameter(Mandatory)][string]$SharedKey,
  [string[]]$AzureSubnets = @("10.0.0.0/16:100", "10.1.0.0/16:100")
)

$ErrorActionPreference = "Stop"

Add-VpnS2SInterface -Name Azure -Protocol IKEv2 -Destination $AzureGatewayIp `
  -AuthenticationMethod PSKOnly -SharedSecret $SharedKey `
  -IPv4Subnet $AzureSubnets -Persistent -NumberOfTries 0

Connect-VpnS2SInterface -Name Azure
Start-Sleep -Seconds 10
Get-VpnS2SInterface -Name Azure | Format-List Name, Destination, ConnectionState
