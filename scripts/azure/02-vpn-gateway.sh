#!/usr/bin/env bash
# Phase 2.2: public IP + VPN gateway. Takes 30-45 minutes, so it runs in the background.
source "$(dirname "$0")/_common.sh"

az network public-ip create -g "$RG" -n "$VPN_GW_PIP" --sku Standard \
  --allocation-method Static -o none

az network vnet-gateway create -g "$RG" -n "$VPN_GW" --vnet "$HUB_VNET" \
  --public-ip-addresses "$VPN_GW_PIP" --gateway-type Vpn --vpn-type RouteBased \
  --sku "$VPN_GW_SKU" --no-wait

echo "Gateway deployment started. Check progress with:"
echo "  az network vnet-gateway show -g $RG -n $VPN_GW --query provisioningState -o tsv"
echo "Public IP (needed for the on-prem side) once allocated:"
echo "  az network public-ip show -g $RG -n $VPN_GW_PIP --query ipAddress -o tsv"
