#!/bin/bash
set -e

BASE_DIR="${1:-.}"
ANSIBLE_DIR="$BASE_DIR/ansible"

echo "==> Starting the ansible playbook in $ANSIBLE_DIR"
if [ -d "$ANSIBLE_DIR" ]; then
    (cd "$ANSIBLE_DIR" && ansible-playbook -i inventory playbooks/jenkins.yml playbooks/k3s.yml)
else
    echo "Error: Directory $ANSIBLE_DIR not found"
    exit 1
fi
