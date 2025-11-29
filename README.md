# Cloud Honeypot with Auth-Lib

A cloud security monitoring project that deploys a Spring Boot authentication application with Falco runtime security monitoring on Azure.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AZURE CLOUD                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Virtual Machine (Ubuntu 22.04)         │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │                                                     │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │    │
│  │  │   MySQL     │  │  OpenLDAP   │  │  Auth-Lib   │  │    │
│  │  │  :3306      │  │   :389      │  │   :9090     │  │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  │    │
│  │                                                     │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │              Falco (Security Monitoring)      │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  │                                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Project Structure

```
mini-projet/
├── .github/workflows/
│   ├── ci-cd.yml              # Unified CI/CD pipeline
│   └── archive/               # Archived workflows
├── auth-lib/                  # Spring Boot application
│   ├── src/
│   ├── build.gradle
│   └── run.sh
├── playbooks/
│   ├── setup-infrastructure.yml
│   ├── deploy-auth-lib.yml
│   ├── vm-falco.yml
│   └── aks-falco.yml
├── roles/
│   ├── mysql/                 # MySQL installation role
│   ├── openldap/              # OpenLDAP installation role
│   ├── auth-lib/              # Application deployment role
│   └── falco/                 # Security monitoring role
├── inventories/
│   └── dev/
├── group_vars/
│   ├── all.yml                # Global variables
│   ├── dev.yml                # Development overrides
│   └── prod.yml               # Production overrides
├── terraform/
│   ├── main.tf                # Azure infrastructure
│   ├── variables.tf
│   └── outputs.tf
├── site.yml                   # Main orchestration playbook
└── ansible.cfg
```

## Quick Start

### Prerequisites

- Azure CLI configured with credentials
- Terraform >= 1.0
- Ansible >= 2.9
- Java 17 (for building auth-lib)
- Python 3.x

### 1. Provision Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Build Application

```bash
cd auth-lib
./gradlew clean build -x test
```

### 3. Deploy Everything

```bash
# Full deployment (infrastructure + app + monitoring)
ansible-playbook site.yml

# Infrastructure only
ansible-playbook site.yml --tags infrastructure

# Application only
ansible-playbook site.yml --tags application

# Security monitoring only
ansible-playbook site.yml --tags security
```

## Ansible Roles

### MySQL Role

Installs and configures MySQL server.

**Key Variables:**
| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_database` | `mydb` | Database name |
| `mysql_username` | `root` | Database user |
| `mysql_password` | `root` | User password |
| `mysql_port` | `3306` | MySQL port |

See [roles/mysql/README.md](roles/mysql/README.md) for full documentation.

### OpenLDAP Role

Installs and configures OpenLDAP directory service.

**Key Variables:**
| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_domain` | `maxcrc.com` | LDAP domain |
| `ldap_base_dn` | `dc=maxcrc,dc=com` | Base DN |
| `ldap_admin_password` | `secret` | Admin password |
| `ldap_users` | See defaults | User list |

See [roles/openldap/README.md](roles/openldap/README.md) for full documentation.

### Auth-Lib Role

Deploys the Spring Boot authentication application.

**Key Variables:**
| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_port` | `9090` | Application port |
| `auth_lib_authentication_type` | `ldap` | Auth method (ldap/db) |
| `auth_lib_heap_max` | `512m` | JVM heap size |
| `auth_lib_jar_path` | Required | Path to JAR file |

See [roles/auth-lib/README.md](roles/auth-lib/README.md) for full documentation.

### Falco Role

Installs Falco runtime security monitoring.

See [roles/falco/README.md](roles/falco/README.md) for full documentation.

## CI/CD Pipeline

The unified GitHub Actions pipeline (`.github/workflows/ci-cd.yml`) includes:

### Jobs

1. **terraform-validate**: Terraform format, init, validate, plan
2. **terraform-security**: Checkov security scanning
3. **ansible-lint**: YAML lint, Ansible lint, syntax check
4. **build**: Gradle build, tests, coverage, artifacts
5. **code-quality**: SonarQube analysis
6. **security-scan**: OWASP dependency check
7. **deploy**: Ansible deployment to Azure

### Required Secrets

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure service principal |
| `AZURE_CLIENT_SECRET` | Azure client secret |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription |
| `AZURE_TENANT_ID` | Azure tenant |
| `SSH_PRIVATE_KEY` | SSH key for VM access |
| `VM_HOST` | VM public IP/hostname |
| `VM_USER` | VM SSH username |
| `SONAR_TOKEN` | SonarQube token (optional) |
| `SONAR_HOST_URL` | SonarQube URL (optional) |

## Configuration

### Environment Variables

All configuration is managed through Ansible group variables:

- `group_vars/all.yml` - Global defaults
- `group_vars/dev.yml` - Development overrides
- `group_vars/prod.yml` - Production overrides

### Sensitive Data

Use Ansible Vault for production secrets:

```bash
# Create vault password file
echo "your-vault-password" > .vault_pass

# Encrypt secrets
ansible-vault encrypt_string 'secret_value' --name 'mysql_password'

# Run with vault
ansible-playbook site.yml --vault-password-file .vault_pass
```

## Verification

After deployment:

```bash
# Check services
ssh user@vm-ip "systemctl status mysql slapd auth-lib falco"

# Test application
curl http://vm-ip:9090/login

# Check LDAP
ldapsearch -x -H ldap://vm-ip -b "dc=maxcrc,dc=com"

# View Falco alerts
ssh user@vm-ip "journalctl -u falco -f"
```

## Troubleshooting

### Application won't start

1. Check MySQL is running: `systemctl status mysql`
2. Check LDAP is running: `systemctl status slapd`
3. View app logs: `journalctl -u auth-lib -f`

### LDAP connection issues

```bash
ldapsearch -x -H ldap://localhost:389 -b "dc=maxcrc,dc=com" -D "cn=admin,dc=maxcrc,dc=com" -w secret
```

### MySQL connection issues

```bash
mysql -u root -p -e "SHOW DATABASES;"
```

## License

MIT

## Author

DigiTechNova

