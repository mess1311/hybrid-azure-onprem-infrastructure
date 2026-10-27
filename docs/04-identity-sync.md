# 04. Sync identity to Entra ID

## 4.1 UPN suffix

`corp.contoso.local` is not routable, so Entra ID cannot use it as a sign-in suffix.

**With a custom domain:** in the Entra admin center go to **Entra ID > Domain names > Add custom domain**, create the TXT record at your registrar, and click **Verify**. Then on DC01:

```powershell
.\scripts\onprem\dc01\05-upn-suffix.ps1 -Suffix yourname.com
```

**Without a custom domain:** use `yourtenant.onmicrosoft.com` as the suffix with the same script.

## 4.2 IdFix

Download Microsoft IdFix on DC01, run it against the forest, and fix duplicate or invalid `mail`, `proxyAddresses` and `userPrincipalName` values. A fresh lab reports very little.

## 4.3 Install Entra Connect on DC01

With 8 GB of RAM there is no separate sync server. Microsoft does not recommend this in production, but it works in a lab. Close everything else on the host. If DC01 struggles, use Entra Cloud Sync instead (a lightweight agent) and check its feature comparison first, since Seamless SSO differs.

1. Make sure TLS 1.2 is enabled (default on Server 2022).
2. Download **Microsoft Entra Connect** from the Entra admin center.
3. Choose **Customize**:
   - Sign-in method: **Password Hash Synchronization**, and tick **Enable single sign-on**.
   - Sign in to Entra with a cloud-only account holding **Hybrid Identity Administrator**.
   - Add forest `corp.contoso.local` with an Enterprise Admin account.
   - Domain/OU filtering: select only `OU=Contoso`.
   - Keep **Start the synchronization process** ticked.
4. Verify the first sync:

```powershell
Import-Module ADSync
Start-ADSyncSyncCycle -PolicyType Initial
Get-ADSyncScheduler
```

## 4.4 Verify

- Entra admin center > **Users**: five lab users with **On-premises sync enabled = Yes**, source **Windows Server AD**.
- Change a display name on DC01, run `Start-ADSyncSyncCycle -PolicyType Delta`, and confirm it in Entra.
- In a private browser window sign in to `https://portal.azure.com` as `labuser1@<suffix>` with the on-prem password to prove Password Hash Sync.
