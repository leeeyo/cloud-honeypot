# OpenLDAP Ansible Role

Installs and configures OpenLDAP (slapd) server for the auth-lib application.

## Requirements

- Ubuntu/Debian-based system
- Ansible 2.9+

## Role Variables

### LDAP Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_domain` | `maxcrc.com` | LDAP domain name |
| `ldap_organization` | `maxcrc` | Organization name |
| `ldap_base_dn` | `dc=maxcrc,dc=com` | Base DN for LDAP tree |
| `ldap_admin_dn` | `cn=admin,dc=maxcrc,dc=com` | Admin DN |
| `ldap_admin_password` | `secret` | Admin password |

### Server Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_server_uri` | `ldap://localhost:389` | LDAP server URI |
| `ldap_port` | `389` | LDAP port |
| `ldap_ssl_port` | `636` | LDAPS port |
| `ldap_enable_ssl` | `false` | Enable SSL/TLS |

### Organizational Units

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_users_ou` | `users` | Users OU name |
| `ldap_groups_ou` | `groups` | Groups OU name |

### Service Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_service_name` | `slapd` | LDAP service name |
| `ldap_service_enabled` | `true` | Enable service at boot |
| `ldap_service_state` | `started` | Service state |

### LDAP Users

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_users` | See defaults | List of LDAP users |
| `ldap_default_user_object_classes` | `[inetOrgPerson, ...]` | Object classes for users |

**User structure:**
```yaml
ldap_users:
  - uid: username
    cn: Common Name
    sn: Surname
    mail: user@example.com
    userPassword: "{SSHA}hashedpassword"
    title: ADMIN  # Role: ADMIN, USER, GUEST
    description: online  # Status
```

### LDAP Groups (Optional)

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_groups` | `[]` | List of LDAP groups |

**Group structure:**
```yaml
ldap_groups:
  - cn: admins
    description: Administrator group
    members:
      - uid=aziz,ou=users,dc=maxcrc,dc=com
```

### LDAP Search Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_search_base` | `ou=users,dc=maxcrc,dc=com` | Search base |
| `ldap_user_search_filter` | `(uid={0})` | User search filter |
| `ldap_user_dn_pattern` | `uid={username},ou=users,...` | User DN pattern |

### Database Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `ldap_backend` | `mdb` | Database backend |
| `ldap_db_directory` | `/var/lib/ldap` | Database directory |
| `ldap_log_level` | `stats` | Log level |

## Dependencies

None.

## Example Playbook

### Basic Usage

```yaml
- hosts: ldap_servers
  become: true
  roles:
    - role: openldap
      vars:
        ldap_domain: example.com
        ldap_organization: Example Inc
        ldap_admin_password: secure_password
```

### With Custom Users

```yaml
- hosts: ldap_servers
  become: true
  roles:
    - role: openldap
      vars:
        ldap_domain: company.com
        ldap_base_dn: "dc=company,dc=com"
        ldap_admin_password: "{{ vault_ldap_admin_password }}"
        ldap_users:
          - uid: admin
            cn: Admin User
            sn: Admin
            mail: admin@company.com
            userPassword: "{SSHA}hashedpassword"
            title: ADMIN
            description: online
          - uid: john.doe
            cn: John Doe
            sn: Doe
            givenName: John
            mail: john.doe@company.com
            userPassword: "{SSHA}hashedpassword"
            title: USER
            description: online
        ldap_groups:
          - cn: developers
            description: Development team
            members:
              - uid=john.doe,ou=users,dc=company,dc=com
```

### Integration with auth-lib

This role is designed to work with the auth-lib application. The default users match the auth-lib's expected structure:

- `title` attribute maps to user role (ADMIN, USER, GUEST)
- `description` attribute maps to user status (online, offline)
- `uid` is used for authentication

## Verification Commands

After running the role, verify the setup:

```bash
# Test LDAP connection
ldapsearch -x -H ldap://localhost:389 -b "dc=maxcrc,dc=com" -D "cn=admin,dc=maxcrc,dc=com" -w secret

# List all users
ldapsearch -x -H ldap://localhost:389 -b "ou=users,dc=maxcrc,dc=com" -D "cn=admin,dc=maxcrc,dc=com" -w secret "(objectClass=person)"
```

## License

MIT

## Author

DigiTechNova

