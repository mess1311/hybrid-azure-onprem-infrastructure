<#
  Phase 1.3 (after the reboot): authorize DHCP, create the scope, add DNS forwarders.
  Note: with the 8 GB build there are no on-prem DHCP clients, so DHCP is optional.
#>
$ErrorActionPreference = "Stop"

Add-DhcpServerInDC
Add-DhcpServerv4Scope -Name "LAN" -StartRange 192.168.10.100 -EndRange 192.168.10.150 -SubnetMask 255.255.255.0
Set-DhcpServerv4OptionValue -ScopeId 192.168.10.0 -Router 192.168.10.1 -DnsServer 192.168.10.10 -DnsDomain corp.contoso.local

# Let domain members resolve internet names.
Set-DnsServerForwarder -IPAddress 1.1.1.1, 8.8.8.8

# Verify internet access through VPN-GW's NAT.
Test-NetConnection 1.1.1.1 -Port 443
Resolve-DnsName login.microsoftonline.com
