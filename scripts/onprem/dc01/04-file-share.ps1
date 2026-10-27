<#
  Phase 1.5: the Data share on DC01 (replaces a separate FS01 in the 8 GB build).
#>
$ErrorActionPreference = "Stop"

New-Item -Path C:\Shares\Data -ItemType Directory -Force | Out-Null
New-SmbShare -Name Data -Path C:\Shares\Data `
  -FullAccess "CORP\Domain Admins" -ChangeAccess "CORP\Domain Users"

Get-SmbShare -Name Data
