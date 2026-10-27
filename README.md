# Contoso Hybrid Lab

A hands-on lab that connects a small **on-prem environment** (VirtualBox) to **Azure** with a **Site-to-Site IPsec VPN**, and syncs **on-prem Active Directory to Microsoft Entra ID** with Entra Connect.

Designed to run on a laptop with **8 GB of RAM**, using only free tools (no appliance downloads, no accounts besides Azure).

## Architecture

```
        On-prem (VirtualBox, 192.168.10.0/24)                       Azure
 ┌──────────────────────────────────────────┐        ┌────────────────────────────────────┐
 │  DC01  192.168.10.10                     │        │  Hub VNet 10.0.0.0/16              │
 │  AD DS · DNS · DHCP · file share         │        │   └ GatewaySubnet → VPN gateway    │
 │  Entra Connect (Password Hash Sync)      │        │            │ peering               │
 │            │                             │        │  Spoke VNet 10.1.0.0/16            │
 │  VPN-GW  192.168.10.1                    │  IPsec │   └ snet-workload                  │
 │  Windows Server Core + RRAS ═════════════╪════════╪═══════ AZ-VM01 (domain-joined)     │
 │  NAT + IKEv2 S2S interface               │ IKEv2  │      NSG: RDP/ICMP from on-prem    │
 └──────────────────────────────────────────┘        └────────────────────────────────────┘
                     │ Entra Connect sync (HTTPS, via VPN-GW NAT)
                     ▼
            Microsoft Entra ID tenant
```

## What you build

- Active Directory domain `corp.contoso.local` with OUs, groups and users
- A Windows Server Core router (RRAS) as the on-prem VPN device
- Azure hub-spoke network with a route-based VPN gateway and an NSG-protected VM
- IKEv2 Site-to-Site VPN through your home NAT (NAT-T)
- Entra Connect with Password Hash Sync and Seamless SSO
- Domain join of an Azure VM over the tunnel, RBAC for synced groups

## Quick start

```bash
git clone <your-repo-url> hybrid-lab && cd hybrid-lab
cp config.example.env config.env      # fill in values; config.env is git-ignored
az login
```

Then follow the guides in order:

| Phase | Guide | Scripts |
|---|---|---|
| 0 | [Plan and requirements](docs/00-plan.md) | |
| 1 | [On-prem network](docs/01-onprem.md) | `scripts/onprem/vpn-gw/01-*`, `scripts/onprem/dc01/01-04` |
| 2 | [Azure foundation](docs/02-azure.md) | `scripts/azure/01-04` |
| 3 | [Site-to-site VPN](docs/03-site-to-site-vpn.md) | `scripts/azure/05`, `scripts/onprem/vpn-gw/02-*` |
| 4 | [Identity sync](docs/04-identity-sync.md) | `scripts/onprem/dc01/05-*` |
| 5 | [Hybrid scenarios](docs/05-hybrid-scenarios.md) | `scripts/azure/06`, `scripts/azure-vm/*` |
| 6 | [Stretch goals and cost](docs/06-stretch-goals-and-cost.md) | `scripts/azure/99-teardown.sh` |
| | [Troubleshooting](docs/troubleshooting.md) | |

Start the Azure VPN gateway (`scripts/azure/02-vpn-gateway.sh`) as early as possible: it takes 30 to 45 minutes.

## Cost warning

The VPN gateway bills while it exists (roughly $140+/month for VpnGw1). Delete it when you are not testing, keep VM auto-shutdown on, and set a budget alert. Full teardown: `scripts/azure/99-teardown.sh`.

## Security notes

- Never commit `config.env`, pre-shared keys or passwords. `.gitignore` excludes `config.env`.
- AZ-VM01 has no public IP, and the NSG only allows RDP and ICMP from `192.168.10.0/24`.
- This is a lab: Entra Connect runs on the domain controller, which is not recommended in production.
- Scripts are written from Microsoft documentation and have not been run end to end. Review each one before running it, and open an issue with the error output if a step fails.

## Requirements

VirtualBox 7.x, a Windows Server 2022 evaluation ISO, an Azure subscription, the Azure CLI (or Cloud Shell), a Microsoft Entra tenant, and a router where you can forward UDP 500 and 4500.

## License

MIT, see [LICENSE](LICENSE).
