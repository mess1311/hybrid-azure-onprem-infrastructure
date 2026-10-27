#!/usr/bin/env bash
# Phase 2.1: resource group, hub and spoke VNets.
source "$(dirname "$0")/_common.sh"

az group create -n "$RG" -l "$LOCATION" -o none

# The subnet name must be exactly GatewaySubnet.
az network vnet create -g "$RG" -n "$HUB_VNET" --address-prefixes "$HUB_PREFIX" \
  --subnet-name GatewaySubnet --subnet-prefixes "$GATEWAY_SUBNET_PREFIX" -o none

az network vnet create -g "$RG" -n "$SPOKE_VNET" --address-prefixes "$SPOKE_PREFIX" \
  --subnet-name "$WORKLOAD_SUBNET" --subnet-prefixes "$WORKLOAD_SUBNET_PREFIX" -o none

echo "Done: resource group, hub and spoke VNets created."
