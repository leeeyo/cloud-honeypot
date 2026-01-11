# Azure Cloud Honeypot

<p align="center">
  <img src="https://img.shields.io/badge/Azure-Cloud-0078D4?style=for-the-badge&logo=microsoft-azure" alt="Azure"/>
  <img src="https://img.shields.io/badge/Terraform-Infrastructure-7B42BC?style=for-the-badge&logo=terraform" alt="Terraform"/>
  <img src="https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible" alt="Ansible"/>
  <img src="https://img.shields.io/badge/Falco-Security-00AEC7?style=for-the-badge&logo=falco" alt="Falco"/>
  <img src="https://img.shields.io/badge/Spring_Boot-Application-6DB33F?style=for-the-badge&logo=spring" alt="Spring Boot"/>
</p>

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/leeeyo/cloud-honeypot/ci-cd.yml?branch=main&style=flat-square&label=CI/CD" alt="CI/CD Status"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
</p>

---

## Executive Summary

**Azure Cloud Honeypot** is a security research platform designed to attract, detect, and analyze malicious activities in a controlled cloud environment. The system deploys decoy services that mimic real authentication infrastructure, while continuously monitoring all interactions using runtime security tools.

This project demonstrates modern DevSecOps practices by combining Infrastructure as Code (Terraform), Configuration Management (Ansible), and runtime threat detection (Falco) into a fully automated deployment pipeline.

---

## Architecture Overview

```mermaid
flowchart TB
    subgraph External["External"]
        GH[("GitHub Repository")]
        ATK["Attacker"]
        SA["Security Analyst"]
    end
    
    subgraph CICD["CI/CD Pipeline"]
        GHA["GitHub Actions"]
        TF["Terraform"]
        ANS["Ansible"]
    end
    
    subgraph Azure["Azure Cloud"]
        subgraph RG["Resource Group"]
            subgraph VNET["Virtual Network"]
                subgraph NSG["Network Security Group"]
                    subgraph VM1["honeypot-vm-1"]
                        AL1["Auth-Lib :9090"]
                        MY1[("MySQL :3306")]
                        LD1[("LDAP :389")]
                        FA1["Falco Agent"]
                    end
                    subgraph VM2["honeypot-vm-2"]
                        AL2["Auth-Lib :9090"]
                        MY2[("MySQL :3306")]
                        LD2[("LDAP :389")]
                        FA2["Falco Agent"]
                    end
                end
            end
        end
    end
    
    subgraph Logs["Monitoring"]
        LOG[("Local Logs")]
    end
    
    GH --> GHA
    GHA --> TF
    GHA --> ANS
    TF -->|Provision| RG
    ANS -->|Configure| VM1
    ANS -->|Configure| VM2
    
    ATK -->|"HTTP Requests"| AL1
    ATK -->|"HTTP Requests"| AL2
    
    AL1 --> MY1
    AL1 --> LD1
    AL2 --> MY2
    AL2 --> LD2
    
    FA1 -->|"Alerts"| LOG
    FA2 -->|"Alerts"| LOG
    
    LOG --> SA
```

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Automated Deployment** | Complete infrastructure provisioning and application deployment through CI/CD |
| **Multi-VM Architecture** | Scalable design supporting multiple honeypot instances |
| **Real Authentication Backend** | Spring Boot application with MySQL and LDAP integration |
| **Runtime Security Monitoring** | Falco-based syscall monitoring and threat detection |
| **Infrastructure as Code** | Reproducible Azure infrastructure using Terraform |
| **Configuration Management** | Consistent server configuration using Ansible roles |

---

## Technology Stack

<table>
<tr>
<td align="center" width="150">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/azure/azure-original.svg" width="48" height="48" alt="Azure"/>
<br><strong>Microsoft Azure</strong>
<br><sub>Cloud Platform</sub>
</td>
<td align="center" width="150">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/terraform/terraform-original.svg" width="48" height="48" alt="Terraform"/>
<br><strong>Terraform</strong>
<br><sub>Infrastructure</sub>
</td>
<td align="center" width="150">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/ansible/ansible-original.svg" width="48" height="48" alt="Ansible"/>
<br><strong>Ansible</strong>
<br><sub>Automation</sub>
</td>
<td align="center" width="150">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/spring/spring-original.svg" width="48" height="48" alt="Spring"/>
<br><strong>Spring Boot</strong>
<br><sub>Application</sub>
</td>
</tr>
<tr>
<td align="center" width="150">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/mysql/mysql-original.svg" width="48" height="48" alt="MySQL"/>
<br><strong>MySQL</strong>
<br><sub>Database</sub>
</td>
<td align="center" width="150">
<img src="https://www.openldap.org/images/headers/LDAPworm.gif" width="48" height="48" alt="LDAP"/>
<br><strong>OpenLDAP</strong>
<br><sub>Directory</sub>
</td>
<td align="center" width="150">
<img src="https://falco.org/img/brand/falco-mark-blue.svg" width="48" height="48" alt="Falco"/>
<br><strong>Falco</strong>
<br><sub>Security</sub>
</td>
<td align="center" width="150">
<img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" width="48" height="48" alt="GitHub"/>
<br><strong>GitHub Actions</strong>
<br><sub>CI/CD</sub>
</td>
</tr>
</table>

---

## How It Works

### 1. Infrastructure Provisioning

Terraform creates the Azure infrastructure including:
- Resource Group for all resources
- Virtual Network with dedicated subnet
- Network Security Group with firewall rules
- Two Ubuntu 22.04 Virtual Machines
- Public IPs for external access

### 2. Service Configuration

Ansible configures each VM with:
- **MySQL Database** - Stores user accounts and session data
- **OpenLDAP Directory** - Provides directory-based authentication
- **Auth-Lib Application** - Spring Boot web application exposing login endpoints
- **Falco Agent** - Monitors system calls and generates security alerts

### 3. Attack Detection Flow

```mermaid
sequenceDiagram
    participant A as Attacker
    participant H as Auth-Lib
    participant B as MySQL/LDAP
    participant F as Falco
    participant L as Logs
    participant S as Analyst
    
    A->>H: Login attempt
    H->>B: Query credentials
    B-->>H: Auth result
    H-->>A: Response
    
    H->>F: Runtime events
    F->>F: Evaluate rules
    
    alt Suspicious Activity
        F->>L: Write alert
        S->>L: Review alerts
        S->>H: Investigate
    end
```

### 4. Continuous Monitoring

Falco continuously monitors:
- Failed authentication attempts
- Unusual process execution
- File system modifications
- Network connections
- Privilege escalation attempts

---

## Project Structure

```
azure-cloud-honeypot/
├── .github/workflows/
│   └── ci-cd.yml              # Unified CI/CD pipeline
├── auth-lib/                   # Spring Boot application
│   ├── src/                    # Java source code
│   ├── build.gradle            # Gradle build configuration
│   └── run.sh                  # Local run script
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # Azure resources
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Output values
│   └── backend.tf              # Remote state config
├── roles/                      # Ansible roles
│   ├── mysql/                  # MySQL installation
│   ├── openldap/               # OpenLDAP installation
│   ├── auth-lib/               # Application deployment
│   └── falco/                  # Security monitoring
├── playbooks/                  # Ansible playbooks
├── inventories/                # Environment inventories
├── group_vars/                 # Ansible variables
├── docs/                       # Documentation
│   └── diagrams/               # Architecture diagrams
└── site.yml                    # Main orchestration playbook
```

---

## Deployment

### Prerequisites

- Azure subscription with sufficient permissions
- GitHub repository with configured secrets
- Terraform >= 1.0
- Ansible >= 2.9
- Java 17 (for local development)

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/leeeyo/cloud-honeypot.git
   cd cloud-honeypot
   ```

2. **Configure Azure credentials**
   
   Set up GitHub secrets (see [Azure Setup Guide](docs/AZURE_SETUP.md))

3. **Deploy infrastructure**
   ```bash
   cd terraform
   terraform init
   terraform apply
   ```

4. **Configure and deploy services**
   ```bash
   ansible-playbook site.yml
   ```

### CI/CD Deployment

Push to the `main` branch triggers automatic deployment:

```mermaid
flowchart LR
    A[Push to main] --> B[Validate]
    B --> C[Build]
    C --> D[Test]
    D --> E[Deploy]
    E --> F[Verify]
```

---

## Security Monitoring

### Falco Rules

The system includes custom Falco rules for detecting:

| Rule | Description | Severity |
|------|-------------|----------|
| Brute Force Detection | Multiple failed login attempts | WARNING |
| SQL Injection | Suspicious SQL patterns in queries | CRITICAL |
| LDAP Injection | Malformed LDAP queries | CRITICAL |
| Shell Spawn | Unexpected shell processes | WARNING |
| File Tampering | Modifications to sensitive files | ERROR |

### Viewing Alerts

```bash
# SSH into a honeypot VM
ssh -i key.pem azizmaram@<vm-public-ip>

# View Falco alerts in real-time
sudo journalctl -u falco -f

# View Falco log file
sudo tail -f /var/log/falco/falco.log
```

---

## Configuration

All configuration is managed through Ansible variables in `group_vars/all.yml`:

| Category | Variables |
|----------|-----------|
| **MySQL** | Database name, credentials, port, character set |
| **OpenLDAP** | Base DN, admin credentials, user definitions |
| **Auth-Lib** | Port, authentication type, JVM settings |
| **Falco** | Rules, output destinations, alerting |

For sensitive data, use [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html):

```bash
ansible-vault encrypt_string 'secret_password' --name 'mysql_password'
```

---

## Future Enhancements

- [ ] Azure Log Analytics integration for centralized logging
- [ ] Falcosidekick for alert forwarding to Slack/Teams
- [ ] Kubernetes (AKS) deployment option
- [ ] Automated threat intelligence correlation
- [ ] Dashboard for real-time attack visualization
- [ ] Machine learning-based anomaly detection

---

## Documentation

| Document | Description |
|----------|-------------|
| [Azure Setup Guide](docs/AZURE_SETUP.md) | Azure credentials and secrets configuration |
| [Diagrams](docs/diagrams/README.md) | Architecture and flow diagrams |
| [MySQL Role](roles/mysql/README.md) | MySQL installation role documentation |
| [OpenLDAP Role](roles/openldap/README.md) | OpenLDAP role documentation |
| [Auth-Lib Role](roles/auth-lib/README.md) | Application deployment documentation |
| [Falco Role](roles/falco/README.md) | Security monitoring documentation |

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Aziz Maram**

- GitHub: [@leeeyo](https://github.com/leeeyo)
- Project: Cloud Security Research

---

<p align="center">
  <sub>Built with security research in mind</sub>
</p>
