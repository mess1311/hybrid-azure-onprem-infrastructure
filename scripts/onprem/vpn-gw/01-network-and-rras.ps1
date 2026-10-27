<#
  Phase 1.2: turn the Windows Server Core VM (VPN-GW) into a router.
  Run in an elevated PowerShell on VPN-GW, after renaming the computer to VPN-GW.
  First identify the adapter names with:
      Get-NetIPAddress -AddressFamily IPv4 | Format-Table InterfaceAlias, IPAddress

  -WanAdapter  = adapter that has the home-router address
  -LanAdapter  = adapter that has a 169.254.x.x address (internal network, no DHCP)
#>
param(
  [Parameter(Mandatory)][string]$WanAdapter,
  [Parameter(Mandatory)][string]$LanAdapter
)

$ErrorActionPreference = "Stop"

Rename-NetAdapter -Name $WanAdapter -NewName "WAN"
Rename-NetAdapter -Name $LanAdapter -NewName "LAN"

New-NetIPAddress -InterfaceAlias LAN -IPAddress 192.168.10.1 -PrefixLength 24
Set-DnsClient -InterfaceAlias LAN -RegisterThisConnectionsAddress $false

# RRAS with site-to-site support. Restart the VM if the install asks for it, then rerun
# only the lines below this one.
Install-WindowsFeature RemoteAccess, Routing, DirectAccess-VPN -IncludeManagementTools
Install-RemoteAccess -VpnType VpnS2S

# NAT only for traffic leaving through WAN (not for VPN traffic).
netsh routing ip nat install
netsh routing ip nat add interface "WAN" full
netsh routing ip nat add interface "LAN" private

# IKE and NAT-T, plus ping.
New-NetFirewallRule -DisplayName "IKE and NAT-T" -Direction Inbound -Protocol UDP -LocalPort 500,4500 -Action Allow
Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"

Write-Host "Router configured. Verify with: netsh routing ip nat show interface"
