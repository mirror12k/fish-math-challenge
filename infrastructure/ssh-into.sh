#!/bin/sh

echo "[+] getting instance ip from infrastructure..."
INSTANCE_IP=$(terraform output -json | jq -r ".server_ip.value")

SSH_COMMAND="ssh -i instance_ssh_key ubuntu@${INSTANCE_IP} -o StrictHostKeyChecking=no"
echo "[+] executing ssh: $SSH_COMMAND"
sh -c "$SSH_COMMAND"

