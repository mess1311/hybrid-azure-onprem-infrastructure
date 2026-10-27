#!/usr/bin/env bash
# Deletes EVERYTHING in the lab resource group. Cannot be undone.
# To save money without a full teardown, delete only the gateway instead:
#   az network vnet-gateway delete -g "$RG" -n "$VPN_GW"
source "$(dirname "$0")/_common.sh"

read -r -p "Delete resource group '$RG' and everything in it? Type the name to confirm: " answer
if [[ "$answer" != "$RG" ]]; then
  echo "Cancelled."
  exit 1
fi

az group delete -n "$RG" --yes --no-wait
echo "Deletion started."
