#!/bin/bash
set -e

BASE_DIR="${1:-.}"
VAGRANT_DIR="$BASE_DIR/vagrant"
ANSIBLE_DIR="$BASE_DIR/ansible"

echo "==> Start VMs on $VAGRANT_DIR"
if [ -f "$VAGRANT_DIR/Vagrantfile" ]; then
    (cd "$VAGRANT_DIR" && vagrant up)
else
    echo "Error: Vagrantfile wasn't found in $VAGRANT_DIR"
    exit 1
fi

echo "==> Starting the ansible playbook in $ANSIBLE_DIR"
if [ -d "$ANSIBLE_DIR" ]; then
    (cd "$ANSIBLE_DIR" && ansible-playbook -i inventory playbooks/jenkins.yml playbooks/k3s.yml)
else
    echo "Error: Directory $ANSIBLE_DIR not found"
    exit 1
fi