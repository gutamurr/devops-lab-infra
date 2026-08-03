# 🏗️ DevOps Lab Infra

[![Vagrant](https://img.shields.io/badge/Vagrant-Provisioning-1868F2?logo=vagrant&logoColor=white)](https://www.vagrantup.com/)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Cluster-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-Chart-0F1689?logo=helm&logoColor=white)](https://helm.sh/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

This repository provisions and configures the infrastructure layer for a small DevOps lab environment based on Vagrant, Ansible, Jenkins, and Kubernetes. It is designed to create two virtual machines:

- a Jenkins node
- an application node

The infrastructure setup prepares the environment for CI/CD automation, container image delivery, Kubernetes deployment, ingress support, and monitoring.

## Project Goal

The repository is meant to automate the provisioning of a practical lab topology that demonstrates:

- VM bootstrap with Vagrant
- machine configuration with Ansible
- Jenkins installation and configuration
- Docker and Kubernetes tooling setup
- cluster RBAC for Jenkins service account access
- NGINX ingress deployment via Helm
- monitoring stack installation via Helm
- webhook forwarding with Smee

## Architecture Overview

The lab topology is split into two nodes:

1. `jenkins-node`
   - runs Jenkins
   - has Docker installed
   - is configured for CI/CD automation
   - receives GitHub webhook traffic through Smee

2. `app-node`
   - acts as the Kubernetes worker node
   - installs Helm, kubectl, ingress controller, and monitoring stack
   - provides the cluster runtime for app deployment

## Repository Structure

```text
.
├── ansible.sh
├── start.sh
├── vagrant/
│   └── Vagrantfile
├── vagrant_up.sh
├── vagrant_halt.sh
├── vagrant_restart.sh
├── vagrant_destroy.sh
└── ansible/
    ├── inventory/
    └── playbooks/
        ├── app-node-playbook.yml
        ├── jenkins-node-playbook.yml
        └── roles/
```

## Infrastructure Components

### Vagrant

The Vagrant configuration in [vagrant/Vagrantfile](vagrant/Vagrantfile) defines the lab machines.

It creates:

- `jenkins-node` with 2 vCPUs and 4 GB RAM
- `app-node` with 4 vCPUs and 4 GB RAM

Port forwarding is also configured:

- Jenkins on host port `8080`
- HTTP on host port `80`
- HTTPS on host port `443`

### Ansible

The playbooks in the [ansible](ansible) directory provision the nodes.

#### Playbooks

- [ansible/playbooks/app-node-playbook.yml](ansible/playbooks/app-node-playbook.yml)
  - configures the application node
  - installs Kubernetes-related tools and cluster support

- [ansible/playbooks/jenkins-node-playbook.yml](ansible/playbooks/jenkins-node-playbook.yml)
  - installs and configures Jenkins
  - installs the Smee forwarding client

### Roles

The repository uses a set of reusable roles:

- `common`
  - common OS preparation and shared setup

- `devopslab.app-node`
  - installs tools on the Kubernetes node, including Helm, ingress controller support, and monitoring components

- `devopslab.jenkins`
  - installs Jenkins, Docker support, and Jenkins configuration-as-code settings

- `devopslab.kubernetes-rbac`
  - creates a ServiceAccount and RBAC binding for Jenkins deployment access

- `gutamurr.smee`
  - installs and configures the Smee client service for GitHub webhook forwarding

## Bootstrapping the Environment

### Option 1: Full startup script

From the repository root:

```bash
./start.sh
```

This script performs the following:

1. launches the Vagrant machines
2. waits 15 seconds for VM boot
3. runs the Ansible provisioning playbooks

### Option 2: Vagrant only

```bash
cd vagrant
vagrant up
```

### Option 3: Ansible only

```bash
cd ansible
ansible-playbook -i inventory playbooks/app-node-playbook.yml playbooks/jenkins-node-playbook.yml
```

## Helper Scripts

The repo includes convenience commands:

- [vagrant_up.sh](vagrant_up.sh) — start the VMs
- [vagrant_halt.sh](vagrant_halt.sh) — halt the VMs
- [vagrant_restart.sh](vagrant_restart.sh) — restart the VMs
- [vagrant_destroy.sh](vagrant_destroy.sh) — destroy the VMs
- [ansible.sh](ansible.sh) — run the Ansible provisioning workflow

## Inventory and Variables

### Inventory

The inventory file defines two host groups:

- `jenkins`
- `worker`

The actual hosts are mapped to the VM names created by Vagrant.

### Group Variables

Key variables are stored in:

- [ansible/inventory/group_vars/all/main.yml](ansible/inventory/group_vars/all/main.yml)
- [ansible/inventory/group_vars/all/secrets.yml](ansible/inventory/group_vars/all/secrets.yml)

The default base IP is `192.168.254` and can be overridden using the `VAGRANT_BASE_IP` environment variable.

## Jenkins and CI/CD Configuration

The Jenkins role installs:

- Jenkins LTS
- Java dependencies
- Docker tooling
- the required plugin set
- Jenkins Configuration as Code (JCasC) support

The JCasC template is defined in:

- [ansible/playbooks/roles/devopslab.jenkins/templates/jenkins.yaml.j2](ansible/playbooks/roles/devopslab.jenkins/templates/jenkins.yaml.j2)

This config provides:

- admin user setup
- Kubernetes credentials for Jenkins
- Jenkins job configuration

## Kubernetes and RBAC

The worker node role installs Kubernetes support and then declares cluster resources so Jenkins can deploy applications.

Key responsibilities include:

- installing `kubectl`
- installing `helm`
- adding the NGINX ingress Helm repository
- installing the NGINX ingress controller
- installing the kube-prometheus stack for monitoring
- creating a Jenkins deployment service account and RBAC binding
- generating a Kubernetes kubeconfig that the Jenkins pipeline can use

## Monitoring and Ingress

The application node deployment installs:

- the NGINX ingress controller using Helm
- the Prometheus stack using the kube-prometheus-stack chart

This provides the ingress path and observability layer for the sample application infrastructure.

## Smee Webhook Forwarding

The `gutamurr.smee` role installs the Smee client service and forwards GitHub webhook traffic to the local Jenkins endpoint. This is useful for triggering Jenkins jobs from GitHub events during the lab workflow.

## Prerequisites

To use this repository successfully, you will need:

- Vagrant
- VirtualBox
- Ansible
- SSH access to the provisioned VMs
- a working network bridge environment for Vagrant public networking

## Notes

The repository is designed as a lab-oriented environment and includes example credentials and templates that must be adapted for a production or shared environment.

## License

This repository is distributed under the MIT License. See [LICENSE](LICENSE) for details.
