#!/usr/bin/env bash
# Phase 2.4: NSG on the workload subnet (RDP + ICMP from on-prem only), then AZ-VM01.
source "$(dirname "$0")/_common.sh"
require VM_ADMIN_PASSWORD ONPREM_CIDR

# 1. NSG. Azure's default DenyAllInBound (priority 65500) already blocks the internet,
#    so we only add the two allow rules for on-prem.
az network nsg create -g "$RG" -n "$NSG" -l "$LOCATION" -o none

az network nsg rule create -g "$RG" --nsg-name "$NSG" -n Allow-RDP-OnPrem \
  --priority 100 --direction Inbound --access Allow --protocol Tcp \
  --source-address-prefixes "$ONPREM_CIDR" --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges 3389 -o none

az network nsg rule create -g "$RG" --nsg-name "$NSG" -n Allow-ICMP-OnPrem \
  --priority 110 --direction Inbound --access Allow --protocol Icmp \
  --source-address-prefixes "$ONPREM_CIDR" --source-port-ranges '*' \
  --destination-address-prefixes '*' --destination-port-ranges '*' -o none

az network vnet subnet update -g "$RG" --vnet-name "$SPOKE_VNET" -n "$WORKLOAD_SUBNET" \
  --network-security-group "$NSG" -o none

# 2. VM: no public IP, and --nsg "" so no per-NIC NSG is created that could open RDP
#    to the internet. Only the subnet NSG above applies.
az vm create -g "$RG" -n "$VM_NAME" --image Win2022Datacenter --size "$VM_SIZE" \
  --vnet-name "$SPOKE_VNET" --subnet "$WORKLOAD_SUBNET" \
  --public-ip-address "" --nsg "" \
  --admin-username "$VM_ADMIN_USER" --admin-password "$VM_ADMIN_PASSWORD" -o none

# 3. Auto-shutdown at 19:00 UTC to control cost.
az vm auto-shutdown -g "$RG" -n "$VM_NAME" --time 1900 -o none

echo "Private IP of $VM_NAME:"
az vm list-ip-addresses -g "$RG" -n "$VM_NAME" \
  --query "[0].virtualMachine.network.privateIpAddresses[0]" -o tsv
