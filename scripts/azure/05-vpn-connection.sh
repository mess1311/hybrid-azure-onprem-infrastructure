#!/usr/bin/env bash
# Phase 3.2 + 3.3: Local Network Gateway (your on-prem site) and the connection.
# No custom IPsec policy: RRAS is route-based and works with Azure's defaults.
source "$(dirname "$0")/_common.sh"
require ONPREM_PUBLIC_IP SHARED_KEY ONPREM_CIDR

az network local-gateway create -g "$RG" -n "$LOCAL_GW" \
  --gateway-ip-address "$ONPREM_PUBLIC_IP" \
  --local-address-prefixes "$ONPREM_CIDR" -o none

az network vpn-connection create -g "$RG" -n "$CONNECTION" \
  --vnet-gateway1 "$VPN_GW" --local-gateway2 "$LOCAL_GW" \
  --shared-key "$SHARED_KEY" --enable-bgp false -o none

echo "Connection created. Azure gateway public IP (use it on VPN-GW):"
az network public-ip show -g "$RG" -n "$VPN_GW_PIP" --query ipAddress -o tsv
echo
echo "Check status:"
echo "  az network vpn-connection show -g $RG -n $CONNECTION --query connectionStatus -o tsv"
