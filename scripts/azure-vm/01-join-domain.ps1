<#
  Phase 5.3: run ON AZ-VM01 (via RDP from DC01 over the tunnel) after the VNet DNS
  points at DC01 and the VM has restarted.
#>
param(
  [string]$Domain = "corp.contoso.local",
  [string]$OuPath = "OU=Servers,OU=Contoso,DC=corp,DC=contoso,DC=local"
)

$ErrorActionPreference = "Stop"

Resolve-DnsName $Domain            # must succeed, otherwise the join will fail
Test-NetConnection 192.168.10.10 -Port 389

Add-Computer -DomainName $Domain -Credential CORP\Administrator -OUPath $OuPath -Restart
