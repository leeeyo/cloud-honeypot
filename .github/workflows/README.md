# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automating Terraform, Ansible, and Falco deployments.

## Workflows Overview

### 1. **CI Pipeline** (`ci.yml`)
Main continuous integration pipeline that runs on every push and pull request:
- Validates required files exist
- Runs Terraform format and validation checks
- Runs Ansible linting and syntax checks

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

### 2. **Terraform Validation** (`terraform.yml`)
Validates and plans Terraform infrastructure:
- Terraform format checking
- Terraform initialization and validation
- Terraform plan generation (for PRs)
- Security scanning with Checkov
- Automatic PR comments with plan output

**Triggers:**
- Push/PR when `terraform/**` files change
- Manual workflow dispatch

### 3. **Ansible Linting** (`ansible.yml`)
Validates Ansible playbooks and roles:
- Ansible linting with `ansible-lint`
- YAML linting with `yamllint`
- Syntax checking for all playbooks

**Triggers:**
- Push/PR when Ansible files change (`playbooks/`, `roles/`, `inventories/`, `group_vars/`)
- Manual workflow dispatch

### 4. **Integration Workflow** (`integration.yml`)
End-to-end deployment workflow combining Terraform and Ansible:
- Terraform plan/apply/destroy
- Automatic Ansible deployment after infrastructure creation
- VM readiness checks
- Falco installation verification

**Triggers:**
- Manual workflow dispatch (recommended for deployments)
- Automatic on push to `main` (if configured)

**Manual Inputs:**
- `environment`: dev/prod
- `action`: plan/apply/destroy
- `run_ansible`: Whether to run Ansible after Terraform

### 5. **Security Scanning** (`security.yml`)
Comprehensive security scanning:
- CodeQL analysis for Python and JavaScript
- Dependency review for pull requests
- Secret scanning with Gitleaks
- YAML security checks

**Triggers:**
- Push/PR to `main` or `develop`
- Weekly schedule (Mondays at 00:00 UTC)
- Manual workflow dispatch

## Required GitHub Secrets

Configure these secrets in your GitHub repository settings:

### Azure Credentials
- `AZURE_CLIENT_ID`: Azure service principal client ID
- `AZURE_CLIENT_SECRET`: Azure service principal client secret
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `AZURE_CREDENTIALS`: JSON credentials (alternative to individual secrets)

### Optional
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions

## Setup Instructions

1. **Configure Azure Secrets:**
   ```bash
   # Create service principal
   az ad sp create-for-rbac --name "github-actions-sp" \
     --role contributor \
     --scopes /subscriptions/<subscription-id> \
     --sdk-auth
   ```
   Copy the JSON output to `AZURE_CREDENTIALS` secret, or extract individual values.

2. **Test Workflows:**
   - Create a test branch and push changes to trigger CI workflows
   - Use "Run workflow" button in GitHub Actions tab for manual workflows

3. **Deploy Infrastructure:**
   - Go to Actions → Integration Workflow → Run workflow
   - Select `action: plan` first to review changes
   - Then select `action: apply` to deploy
   - Set `run_ansible: true` to automatically deploy Falco

## Workflow Best Practices

1. **Always run `plan` before `apply`** to review infrastructure changes
2. **Use `destroy` carefully** - it will remove all infrastructure
3. **Monitor costs** - Azure resources created by Terraform will incur charges
4. **Review security scan results** before merging PRs
5. **Keep secrets secure** - never commit credentials to the repository

## Troubleshooting

### Terraform Authentication Errors
- Verify Azure secrets are correctly configured
- Check service principal has required permissions
- Ensure subscription is active

### Ansible Connection Failures
- Wait for VM to be fully booted (workflow includes wait step)
- Check SSH key permissions (should be 600)
- Verify network security group allows SSH (port 22)

### Workflow Not Triggering
- Check file paths in workflow `paths:` filters
- Verify branch names match workflow triggers
- Ensure workflow files are in `.github/workflows/` directory

## Workflow Status Badges

Add these badges to your README.md:

```markdown
![CI Pipeline](https://github.com/your-org/your-repo/workflows/CI%20Pipeline/badge.svg)
![Terraform Validation](https://github.com/your-org/your-repo/workflows/Terraform%20Validation%20and%20Plan/badge.svg)
![Ansible Linting](https://github.com/your-org/your-repo/workflows/Ansible%20Linting%20and%20Validation/badge.svg)
```

