# 02. Azure foundation

Prepare the config first:

```bash
cp config.example.env config.env
# edit config.env: location, VM password, on-prem public IP, shared key
az login
```

## 2.1 Resource group and VNets

```bash
./scripts/azure/01-network.sh
```

Creates `rg-hybrid-lab`, the hub VNet with a `GatewaySubnet`, and the spoke VNet with `snet-workload`.

## 2.2 VPN gateway (start early)

```bash
./scripts/azure/02-vpn-gateway.sh
```

Takes 30 to 45 minutes. If your region requires zone-redundant SKUs, set `VPN_GW_SKU=VpnGw1AZ` in `config.env`. Check progress:

```bash
az network vnet-gateway show -g rg-hybrid-lab -n vgw-hub --query provisioningState -o tsv
```

## 2.3 Hub-spoke peering

Wait until the gateway state is `Succeeded`, then:

```bash
./scripts/azure/03-peering.sh
```

The hub allows gateway transit and the spoke uses the remote gateway, so the spoke can reach on-prem through the hub's VPN gateway.

## 2.4 NSG and AZ-VM01

```bash
./scripts/azure/04-nsg-and-vm.sh
```

What it does:

- Creates `nsg-workload` with two allow rules from `192.168.10.0/24` only: RDP 3389 (priority 100) and ICMP (priority 110).
- Attaches it to `snet-workload`. Azure's default `DenyAllInBound` (priority 65500) already blocks the internet, so no deny rule is added.
- Creates `AZ-VM01` with **no public IP** and `--nsg ""`, so no per-NIC NSG that might open RDP to the internet is created.
- Enables auto-shutdown at 19:00 UTC.

Note the VM's private IP (likely `10.1.1.4`).

Verify with **Network Watcher > IP flow verify**: remote IP `192.168.10.10`, TCP 3389 should match `Allow-RDP-OnPrem`; remote IP `8.8.8.8` should match `DenyAllInBound`.
