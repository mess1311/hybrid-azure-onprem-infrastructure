# Troubleshooting

## DC01 has no internet

Test from the inside out.

1. **DC01 to VPN-GW:** `Get-NetIPConfiguration` (gateway must be `192.168.10.1`) and `Test-NetConnection 192.168.10.1`. Add a missing gateway with `New-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias Ethernet -NextHop 192.168.10.1`. Check both VMs use the same `intnet-lan` name.
2. **VPN-GW itself:** `Test-NetConnection 1.1.1.1 -Port 443` and `Get-NetIPAddress -InterfaceAlias WAN -AddressFamily IPv4`. If it fails, the WAN side is the problem: bridge to a wired NIC or use the NAT Network option. A `169.254.x.x` WAN address means no DHCP.
3. **NAT on VPN-GW:**
   ```powershell
   Get-Service RemoteAccess
   netsh routing ip nat show interface
   Get-NetIPInterface -AddressFamily IPv4 | Format-Table InterfaceAlias, Forwarding
   ```
   Rerun the three `netsh routing ip nat` lines if the list is wrong, then `Restart-Service RemoteAccess`. If forwarding is disabled: `Set-NetIPInterface -InterfaceAlias WAN,LAN -Forwarding Enabled`. If NAT will not install, reboot and retry.
4. **Detail from DC01:** `Test-NetConnection 1.1.1.1 -Port 443 -InformationLevel Detailed` and `Resolve-DnsName login.microsoftonline.com`. If TCP works but DNS fails, check the DNS forwarders.

**Fallback:** give DC01 a second adapter on VirtualBox NAT with a non-overlapping subnet (`VBoxManage modifyvm "DC01" --nic2 nat --natnet2 "172.30.0.0/24"`), keep its default gateway there, and add `route -p add 10.0.0.0 mask 255.254.0.0 192.168.10.1` so Azure traffic still uses VPN-GW. Disable "Register this connection's addresses in DNS" on that adapter.

## VPN tunnel

| Symptom | Likely cause |
|---|---|
| Never connects | UDP 500/4500 not forwarded, CGNAT, or wrong public IP in the Local Network Gateway |
| Auth failure | Shared key typo |
| Connects, then drops | Custom IPsec policy left on the Azure connection; delete and recreate it |
| Tunnel up, ping fails | Windows Firewall ICMP rule missing, NSG, or missing route for a subnet in `-IPv4Subnet` |
| Large transfers hang | MTU too high: `Set-NetIPInterface -InterfaceAlias WAN -NlMtuBytes 1400` |

Logs: `Get-WinEvent -LogName System -MaxEvents 30` on VPN-GW.

## Identity and domain join

| Problem | Check |
|---|---|
| Users not in Entra ID | OU in sync scope, UPN suffix matches a verified domain, run a delta sync, review Synchronization Service Manager |
| Cannot sign in with synced password | Password Hash Sync enabled, wait a few minutes after first sync, event IDs 6900/6902 on DC01 |
| AZ-VM01 cannot find the domain | VNet DNS setting, restart the VM, `nslookup _ldap._tcp.dc._msdcs.corp.contoso.local` |
| Domain join fails with tunnel up | Windows Firewall on VPN-GW and Azure NSG allow AD ports (53, 88, 135, 389, 445, 464, 636, 3268, 49152-65535) |
| Spoke VM unreachable but hub works | Peering flags (gateway transit, use remote gateways) and both subnets in `-IPv4Subnet` |
