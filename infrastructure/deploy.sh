#!/bin/sh

set -e

ssh-keygen -t rsa -b 2048 -f "instance_ssh_key" -q -N ""

terraform init
terraform apply

