<#
  Phase 1.3: install AD DS, DNS and DHCP on DC01 and create the forest.
  Run in an elevated PowerShell on DC01 AFTER setting the static IP (192.168.10.10)
  and renaming the server to DC01. The server reboots when promotion finishes.
#>
param(
  [string]$DomainName = "corp.contoso.local",
  [string]$NetbiosName = "CORP"
)

$ErrorActionPreference = "Stop"

Install-WindowsFeature AD-Domain-Services, DNS, DHCP -IncludeManagementTools

Install-ADDSForest `
  -DomainName $DomainName `
  -DomainNetbiosName $NetbiosName `
  -InstallDns `
  -SafeModeAdministratorPassword (Read-Host -AsSecureString "DSRM password")
