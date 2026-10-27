<#
  Phase 4.1: add a routable UPN suffix and move the lab users onto it.
  Entra ID cannot use corp.contoso.local, so users need a verified suffix first.

  Examples:
    .\05-upn-suffix.ps1 -Suffix yourname.com
    .\05-upn-suffix.ps1 -Suffix yourtenant.onmicrosoft.com
#>
param(
  [Parameter(Mandatory)][string]$Suffix,
  [string]$Base = "DC=corp,DC=contoso,DC=local"
)

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

Get-ADForest | Set-ADForest -UPNSuffixes @{ Add = $Suffix }

Get-ADUser -Filter * -SearchBase "OU=Users,OU=Contoso,$Base" | ForEach-Object {
  Set-ADUser $_ -UserPrincipalName "$($_.SamAccountName)@$Suffix"
}

Get-ADUser -Filter * -SearchBase "OU=Users,OU=Contoso,$Base" |
  Select-Object Name, UserPrincipalName
