#!/bin/bash

INTERFACE_INFO_FILE=$1
VM_HOSTNAME=$2


vm_ip=$(jq '.[] | select(.["hardware-address"]!="00:00:00:00:00:00") | .["ip-addresses"][] | select(.["ip-address-type"]=="ipv4") | .["ip-address"]' $INTERFACE_INFO_FILE)

ansible_hostname=$VM_HOSTNAME

echo "$ansible_hostname ansible_host=$vm_ip"
