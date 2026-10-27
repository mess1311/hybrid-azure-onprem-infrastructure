# 00. Plan before you build

## Requirements

- Host PC: 8 GB RAM, about 100 GB free disk (an SSD helps), VirtualBox 7.x
- Azure subscription (free trial or pay-as-you-go)
- Microsoft Entra tenant (the default tenant of your subscription works)
- A custom domain is optional; without one use `yourtenant.onmicrosoft.com`
- One ISO: Windows Server 2022 evaluation (used for DC01 and VPN-GW)
- Azure CLI (or use Azure Cloud Shell)

## IP plan

| Component | Value |
|---|---|
| On-prem network | `192.168.10.0/24` |
| VPN-GW LAN (on-prem gateway) | `192.168.10.1` |
| DC01 (AD DS, DNS, DHCP, file share, Entra Connect) | `192.168.10.10` |
| Azure hub VNet | `10.0.0.0/16` (GatewaySubnet `10.0.0.0/27`) |
| Azure spoke VNet | `10.1.0.0/16` (workload subnet `10.1.1.0/24`) |
| AD domain | `corp.contoso.local` (NetBIOS `CORP`) |

Do not let your home network or VirtualBox's default NAT range (`10.0.2.0/24`) overlap these ranges.

## 8 GB RAM budget

| VM | RAM | Notes |
|---|---|---|
| VPN-GW | 1 GB | Windows Server 2022 Core, RRAS. Give it 2 GB during setup if it stalls |
| DC01 | 3 GB | Also the file server and Entra Connect server |
| Host Windows | about 3 GB | Close browsers and other apps while the lab runs |

FS01, SYNC01 and Client01 are intentionally not built. AZ-VM01 in Azure acts as the domain client.

## Repo layout

```
config.example.env      copy to config.env and fill in
scripts/azure/          Azure CLI scripts (run from your PC or Cloud Shell)
scripts/onprem/dc01/    PowerShell for the domain controller
scripts/onprem/vpn-gw/  PowerShell for the Server Core VPN gateway
scripts/azure-vm/       PowerShell to run on AZ-VM01
docs/                   step-by-step guides
```

## Suggested order

| Session | Work | Time |
|---|---|---|
| 1 | Phase 1: VPN-GW and DC01 | 3-4 hours |
| 2 | Phases 2 and 3: Azure, VPN, validation | 2-3 hours plus gateway wait |
| 3 | Phase 4: UPN prep, IdFix, Entra Connect | 1-2 hours |
| 4 | Phase 5: DNS, domain join, RBAC, SSO | 2 hours |
| 5+ | Stretch goals | as desired |

Snapshot your VMs at the end of each phase.
