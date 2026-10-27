# 06. Stretch goals, cost control and cleanup

## Stretch goals

| Goal | How |
|---|---|
| Conditional Access + MFA | Start an Entra ID P1/P2 trial. Require MFA for `Azure-Admins` on the Azure management app |
| SSPR with writeback | Enable SSPR for a synced group and tick **Password writeback** in Entra Connect |
| Hybrid Entra join | Needs a Windows 11 VM, so skip on 8 GB. Re-run Entra Connect, configure device options, check `dsregcmd /status` |
| Azure Bastion | Add `AzureBastionSubnet` (`10.0.1.0/26`) to the hub and deploy Bastion (Basic) |
| Private DNS Resolver | Inbound and outbound endpoints in the hub so Azure and on-prem resolve each other |
| Second DC in Azure | Deploy `AZ-DC01`, promote it into the `Azure` site, set VNet DNS to it plus DC01, then break the tunnel and watch Azure auth keep working |
| BGP | RRAS has no BGP, so this needs a different on-prem device (for example Linux with FRRouting) |
| Azure Arc + Sentinel | Onboard DC01 to Arc, install AMA, send security events to Log Analytics |
| Failover test | Disconnect the tunnel: Password Hash Sync still signs in to the cloud, pass-through authentication would not |
| Infrastructure as code | Rebuild the Azure side in Bicep or Terraform |

## Cost control

- **VPN gateway** is the biggest cost (roughly $140+/month for VpnGw1 running 24/7). Delete it when idle:
  `az network vnet-gateway delete -g rg-hybrid-lab -n vgw-hub`. Recreating takes 30 to 45 minutes, so batch your sessions.
- Use B-series VMs, keep auto-shutdown on, and **deallocate** (not just shut down) VMs when done.
- Delete unused Standard public IPs and Bastion after each session.
- Create a $20 to $50 budget alert in **Cost Management**.
- Check the Azure pricing calculator, since prices change.

## Full teardown

```bash
./scripts/azure/99-teardown.sh
```

Then disable directory synchronization in Entra ID, or delete the lab tenant, to remove synced objects.
