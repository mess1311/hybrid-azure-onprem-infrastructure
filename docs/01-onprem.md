# 01. On-prem network (VirtualBox)

## 1.1 VirtualBox networks and VMs

Two networks are needed:

- **WAN**: VPN-GW adapter 1, to reach the internet through your home router.
- **LAN** (`192.168.10.0/24`): an **Internal Network** named `intnet-lan` on VPN-GW adapter 2 and on DC01. No DHCP on it.

WAN options:

1. **Bridged Adapter** (simplest): bridge to your **wired** NIC. Avoid Wi-Fi bridging, which is unreliable in VirtualBox.
2. **NAT Network** (Wi-Fi only): create one in **File > Tools > Network Manager** with CIDR `172.20.0.0/24` and port-forward UDP 500 and 4500 to VPN-GW. Also forward them on your home router to the host. This is double NAT, which NAT-T handles.

| VM | RAM | Settings |
|---|---|---|
| VPN-GW | 1 GB | Windows Server 2022 Core; 2 vCPU; 32 GB dynamic disk; Intel PRO/1000 MT Desktop; Adapter 1 Bridged/NAT Network, Adapter 2 Internal `intnet-lan` |
| DC01 | 3 GB | Windows Server 2022; 2 vCPU; 60 GB dynamic disk; Internal `intnet-lan`; Guest Additions |

Tips: video memory 16 MB with 3D off, enable I/O APIC, paravirtualization interface Hyper-V. If the host has Hyper-V or WSL2 enabled, VirtualBox runs slower. Start VPN-GW first, then DC01. Do not revert a snapshot of DC01 after you add a second domain controller (USN rollback).

## 1.2 VPN-GW: Windows Server Core as router

1. Create the VM and install Windows Server 2022 **Standard without Desktop Experience**.
2. In `sconfig` choose option 2, rename the computer to `VPN-GW`, restart, and type `powershell`.
3. List adapters: `Get-NetIPAddress -AddressFamily IPv4 | Format-Table InterfaceAlias, IPAddress`. The WAN adapter has the home-router address. The LAN adapter has `169.254.x.x`.
4. Run [`scripts/onprem/vpn-gw/01-network-and-rras.ps1`](../scripts/onprem/vpn-gw/01-network-and-rras.ps1):

```powershell
.\01-network-and-rras.ps1 -WanAdapter "Ethernet" -LanAdapter "Ethernet 2"
```

It renames the adapters, sets the LAN to `192.168.10.1/24`, installs RRAS, adds NAT (WAN full, LAN private) and opens UDP 500 and 4500.

Check: `Get-Service RemoteAccess` is Running and `netsh routing ip nat show interface` lists both adapters.

## 1.3 DC01

1. Install Windows Server 2022 (Desktop Experience), set the static IP `192.168.10.10/24`, gateway `192.168.10.1`, DNS `127.0.0.1`, and rename it `DC01`.
2. Run [`01-promote-dc.ps1`](../scripts/onprem/dc01/01-promote-dc.ps1). The server reboots.
3. Run [`02-dhcp-dns.ps1`](../scripts/onprem/dc01/02-dhcp-dns.ps1). It sets DNS forwarders and tests internet access.

If `Test-NetConnection 1.1.1.1 -Port 443` fails, see [troubleshooting](troubleshooting.md#dc01-has-no-internet).

## 1.4 OUs, groups and users

Run [`03-ous-users-groups.ps1`](../scripts/onprem/dc01/03-ous-users-groups.ps1).

| Object | Detail |
|---|---|
| OU `Contoso` | with child OUs Users, Groups, Servers, Workstations, ServiceAccounts |
| Groups | `Azure-Admins`, `Azure-Readers` (Global security groups) |
| Users | `labuser1` to `labuser5`; `labuser1` in Admins, `labuser2-4` in Readers |

Why it matters: Entra Connect syncs only `OU=Contoso` (phase 4), AZ-VM01 joins into `OU=Servers` (phase 5), and the groups receive Azure roles.

Common errors: "server is unwilling to process the request" means the password failed complexity; "already exists" means you ran it before; `$base` and `$pw` vanish when you close PowerShell.

## 1.5 File share

Run [`04-file-share.ps1`](../scripts/onprem/dc01/04-file-share.ps1). It creates `\\DC01\Data`.

**Checkpoint:** `Get-SmbShare` lists `Data`, and VPN-GW can ping `192.168.10.10`. Snapshot both VMs.
