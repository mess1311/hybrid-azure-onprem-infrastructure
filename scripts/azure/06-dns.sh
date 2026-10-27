#!/usr/bin/env bash
# Phase 5.1: point both VNets at the on-prem domain controller for DNS.
# Run after the tunnel is up. Restart AZ-VM01 afterwards so it picks the change up.
source "$(dirname "$0")/_common.sh"
require DC_IP

az network vnet update -g "$RG" -n "$SPOKE_VNET" --dns-servers "$DC_IP" -o none
az network vnet update -g "$RG" -n "$HUB_VNET" --dns-servers "$DC_IP" -o none

az vm restart -g "$RG" -n "$VM_NAME" -o none
echo "DNS set to $DC_IP on both VNets and $VM_NAME restarted."
