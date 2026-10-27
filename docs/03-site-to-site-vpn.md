# 03. Site-to-site VPN

## 3.1 Public IP and NAT

- Find your home router's **public IP** (any "what is my IP" site).
- VPN-GW sits behind your router, so the tunnel uses NAT-Traversal. Forward **UDP 500** and **UDP 4500** on the router to VPN-GW's WAN address, and give that address a DHCP reservation.
- If your public IP changes, update the Local Network Gateway (it accepts an FQDN, so a DDNS name works).
- If your ISP uses CGNAT (router WAN IP is not public), this lab will not work from home.

## 3.2 and 3.3 Local Network Gateway and connection

Set `ONPREM_PUBLIC_IP` and `SHARED_KEY` in `config.env`, then:

```bash
./scripts/azure/05-vpn-connection.sh
```

It prints the Azure gateway's public IP. You need it on VPN-GW.

## 3.4 IPsec policy

Keep Azure's defaults. RRAS is route-based and works with them, so no custom IPsec policy or policy-based traffic selectors are needed. If you applied one earlier, delete the connection and rerun script 05.

## 3.5 VPN-GW site-to-site interface

On VPN-GW (elevated PowerShell):

```powershell
.\02-s2s-interface.ps1 -AzureGatewayIp <AZURE_GW_IP> -SharedKey "<SHARED_KEY>"
```

See [`02-s2s-interface.ps1`](../scripts/onprem/vpn-gw/02-s2s-interface.ps1). The two subnets (hub and spoke) become routes with metric 100, and `-Persistent` redials after reboot.

If it stays disconnected, check in order:

1. The Local Network Gateway has your router's **current** public IP.
2. UDP 500 and 4500 are forwarded to VPN-GW's WAN address.
3. Some home routers only pass IPsec in DMZ or "1:1 NAT" mode. Test only, aimed at VPN-GW and never DC01.
4. The shared key matches exactly on both sides.

## 3.6 Validate

- Azure portal: connection `cn-azure-to-onprem` shows **Connected**, or `az network vpn-connection show -g rg-hybrid-lab -n cn-azure-to-onprem --query connectionStatus -o tsv`.
- VPN-GW: `Get-VpnS2SInterface -Name Azure` shows `ConnectionState` Connected.
- From DC01: `ping 10.1.1.4` and `Test-NetConnection 10.1.1.4 -Port 3389`.
- AZ-VM01 needs the Windows Firewall ICMP rule, see `scripts/azure-vm/02-allow-rdp-and-icmp.ps1`.
