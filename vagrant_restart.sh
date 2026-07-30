#!/bin/bash
set -e

BASE_DIR="${1:-.}"
VAGRANT_DIR="$BASE_DIR/vagrant"

echo "==> Halt VMs from $VAGRANT_DIR"
if [ -f "$VAGRANT_DIR/Vagrantfile" ]; then
    (cd "$VAGRANT_DIR" && vagrant halt)
else
    echo "Error: Vagrantfile wasn't found in $VAGRANT_DIR"
    exit 1
fi

echo "==> Start VMs on $VAGRANT_DIR"
if [ -f "$VAGRANT_DIR/Vagrantfile" ]; then
    (cd "$VAGRANT_DIR" && vagrant up)
else
    echo "Error: Vagrantfile wasn't found in $VAGRANT_DIR"
    exit 1
fi