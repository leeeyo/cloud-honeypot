# Cloud Honeypot with Automated Infrastructure

## Project Overview
This project aims to build a **cloud-based honeypot system** deployed on **Microsoft Azure**.
The infrastructure and configuration are fully automated using **Terraform**, **Ansible**, and **CI/CD pipelines** (Jenkins).

The honeypot hosts a **bait web application** monitored by **Falco**, an open-source runtime security tool for real-time threat detection.
This setup allows automated environment provisioning, configuration, and monitoring to detect malicious activities targeting the deployed system.

---

## Core Components

| Component | Tool | Description |
|------------|------|-------------|
| **Infrastructure as Code (IaC)** | Terraform | Provisions Azure VMs, virtual networks (VNets), and security groups (NSGs). |
| **Configuration Management** | Ansible | Installs the bait web app, deploys Falco, and manages system configuration. |
| **Automation Pipeline** Automates Terraform and Ansible workflows for reliable infrastructure deployment. |
| **Monitoring & Security** | Falco | Detects abnormal system calls and alerts on suspicious runtime behavior. |

---

## Architecture Overview

**Azure Components:**
- **Virtual Network (VNet):** Private network for the honeypot environment.
- **Network Security Group (NSG):** Controls inbound/outbound traffic rules to simulate vulnerable exposure safely.
- **Virtual Machine (VM):** Hosts the bait web application and Falco security agent.
