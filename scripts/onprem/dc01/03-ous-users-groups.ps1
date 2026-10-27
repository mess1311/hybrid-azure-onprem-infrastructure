<#
  Phase 1.4: OUs, groups and lab users.
  Run on DC01 in an elevated PowerShell.
#>
param(
  [string]$Base = "DC=corp,DC=contoso,DC=local"
)

$ErrorActionPreference = "Stop"
Import-Module ActiveDirectory

# --- OUs ---
New-ADOrganizationalUnit -Name "Contoso" -Path $Base
foreach ($ou in "Users", "Groups", "Servers", "Workstations", "ServiceAccounts") {
  New-ADOrganizationalUnit -Name $ou -Path "OU=Contoso,$Base"
}

# --- Groups (Global security groups, so they sync and work with Azure RBAC) ---
New-ADGroup -Name "Azure-Admins"  -GroupScope Global -Path "OU=Groups,OU=Contoso,$Base"
New-ADGroup -Name "Azure-Readers" -GroupScope Global -Path "OU=Groups,OU=Contoso,$Base"

# --- Users ---
$pw = Read-Host -AsSecureString "Password for lab users (must meet complexity rules)"
1..5 | ForEach-Object {
  New-ADUser -Name "Lab User$_" -SamAccountName "labuser$_" `
    -UserPrincipalName "labuser$_@corp.contoso.local" `
    -Path "OU=Users,OU=Contoso,$Base" -AccountPassword $pw -Enabled $true
}

# --- Membership ---
Add-ADGroupMember -Identity "Azure-Admins"  -Members labuser1
Add-ADGroupMember -Identity "Azure-Readers" -Members labuser2, labuser3, labuser4

# --- Verify ---
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName
Get-ADUser -Filter * -SearchBase "OU=Users,OU=Contoso,$Base" | Select-Object Name, SamAccountName, Enabled
Get-ADGroupMember "Azure-Readers" | Select-Object Name
