<#
  Run on AZ-VM01 after the domain join: let labuser1 connect over RDP and allow ping
  through Windows Firewall (the Azure NSG alone is not enough for ICMP).
#>
$ErrorActionPreference = "Stop"

Add-LocalGroupMember -Group "Remote Desktop Users" -Member "CORP\labuser1"
New-NetFirewallRule -DisplayName "ICMPv4" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow
