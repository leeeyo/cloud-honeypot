# GitHub Actions Workflows

## Current Workflow

### `ci-cd.yml` - Unified CI/CD Pipeline

The main unified pipeline that handles all CI/CD tasks for the project.

**Trigger:** Push or PR to `main` or `develop` branches

**Jobs:**

| Job | Description | Dependencies |
|-----|-------------|--------------|
| `terraform-validate` | Format, init, validate Terraform | None |
| `terraform-security` | Checkov security scan | None |
| `ansible-lint` | YAML lint, Ansible lint, syntax check | None |
| `build` | Gradle build, tests, coverage | ansible-lint |
| `code-quality` | SonarQube analysis | build |
| `security-scan` | OWASP dependency check | build |
| `deploy` | Ansible deployment to Azure | terraform-validate, ansible-lint, build |

**Required Secrets:**

- `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_SUBSCRIPTION_ID`, `AZURE_TENANT_ID`
- `SSH_PRIVATE_KEY`, `VM_HOST`, `VM_USER`
- `SONAR_TOKEN`, `SONAR_HOST_URL` (optional)

## Archived Workflows

The `archive/` directory contains previous separate workflows that have been replaced by the unified pipeline:

- `ansible.yml` - Original Ansible linting workflow
- `ci.yml` - Original CI workflow
- `integration.yml` - Original integration testing workflow
- `security.yml` - Original security scanning workflow
- `terraform.yml` - Original Terraform workflow

These are kept for reference but are no longer active.
