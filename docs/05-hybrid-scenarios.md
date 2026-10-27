# 05. Hybrid scenarios

## 5.0 How to connect to AZ-VM01

AZ-VM01 has no public IP, so you reach it over the tunnel. Pick one:

1. **RDP from DC01 (the main method).** With the tunnel up, open `mstsc` on DC01 and connect to `10.1.1.4` (check the real IP with `az vm list-ip-addresses -g rg-hybrid-lab -n AZ-VM01`). Sign in as `azadmin` with `VM_ADMIN_PASSWORD`, or after the domain join as `CORP\labuser1`.
2. **Run Command (no network needed).** In the portal open AZ-VM01 > **Operations > Run command > RunPowerShellScript**, or from the CLI:
   ```bash
   az vm run-command invoke -g rg-hybrid-lab -n AZ-VM01 --command-id RunPowerShellScript --scripts "hostname; ipconfig"
   ```
   Use this when the tunnel is down or RDP is blocked.
3. **Azure Bastion** (stretch goal) gives browser-based RDP without any tunnel, but bills hourly.

If RDP times out: confirm the tunnel is Connected, the NSG rule `Allow-RDP-OnPrem` exists, the VM is running (not auto-shut-down), and the VM's Windows Firewall allows RDP.

## 5.1 DNS

```bash
./scripts/azure/06-dns.sh
```

Points both VNets at DC01 and restarts AZ-VM01. Test on the VM: `nslookup corp.contoso.local`.

## 5.2 AD Sites and Services

On DC01 open **Active Directory Sites and Services**, create a site `Azure`, add subnets `10.0.0.0/16` and `10.1.0.0/16` to it, and add the site to the default site link.

## 5.3 Domain-join AZ-VM01

Connect (5.0), then run [`01-join-domain.ps1`](../scripts/azure-vm/01-join-domain.ps1). After the reboot run [`02-allow-rdp-and-icmp.ps1`](../scripts/azure-vm/02-allow-rdp-and-icmp.ps1) as the local admin, then sign in as `CORP\labuser1` and open `\\DC01\Data`.

## 5.4 Azure RBAC with synced groups

1. Confirm `Azure-Admins` and `Azure-Readers` synced to Entra ID.
2. In **rg-hybrid-lab > Access control (IAM)** assign **Contributor** to `Azure-Admins` and **Reader** to `Azure-Readers`.
3. Sign in as `labuser1` (can modify) and `labuser2` (read only) and compare. `labuser5` has no role and sees nothing.

## 5.5 Seamless SSO test from AZ-VM01

If you enabled SSO in the Entra Connect wizard, the computer account `AZUREADSSOACC` exists in AD.

1. On DC01 create a GPO linked to `OU=Servers`.
2. **User Configuration > Administrative Templates > Windows Components > Internet Explorer > Internet Control Panel > Security Page > Site to Zone Assignment List**: enable it and add `https://autologon.microsoftazuread-sso.com` with value `1`.
3. On AZ-VM01 run `gpupdate /force`, sign in over RDP as `CORP\labuser1`, and browse to `https://myapps.microsoft.com` in Edge. You should get in without typing a password.
