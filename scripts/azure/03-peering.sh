#!/usr/bin/env bash
# Phase 2.3: hub-spoke peering with gateway transit.
# Run AFTER the VPN gateway has finished provisioning ("Succeeded").
source "$(dirname "$0")/_common.sh"

state=$(az network vnet-gateway show -g "$RG" -n "$VPN_GW" --query provisioningState -o tsv)
if [[ "$state" != "Succeeded" ]]; then
  echo "Gateway state is '$state'. Wait until it is 'Succeeded' and rerun." >&2
  exit 1
fi

az network vnet peering create -g "$RG" -n hub-to-spoke --vnet-name "$HUB_VNET" \
  --remote-vnet "$SPOKE_VNET" --allow-vnet-access --allow-gateway-transit -o none

az network vnet peering create -g "$RG" -n spoke-to-hub --vnet-name "$SPOKE_VNET" \
  --remote-vnet "$HUB_VNET" --allow-vnet-access --use-remote-gateways -o none

echo "Done: peering created."
