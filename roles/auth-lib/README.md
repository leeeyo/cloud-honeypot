# Auth-Lib Ansible Role

Deploys and configures the auth-lib Spring Boot application.

## Requirements

- Ubuntu/Debian-based system
- Ansible 2.9+
- MySQL and OpenLDAP roles should be run first (or services available)

## Role Variables

### Application User and Directories

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_user` | `aziz` | Application user |
| `auth_lib_group` | `aziz` | Application group |
| `auth_lib_app_dir` | `/opt/auth-lib` | Application directory |
| `auth_lib_log_dir` | `/opt/auth-lib/logs` | Log directory |
| `auth_lib_config_dir` | `/opt/auth-lib/config` | Config directory |

### JAR File Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_jar_name` | `auth-lib.jar` | JAR file name |
| `auth_lib_jar_path` | `""` | Path to JAR file (required) |

### Application Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_app_name` | `auth` | Application name |
| `auth_lib_port` | `9090` | Application port |
| `auth_lib_authentication_type` | `ldap` | Auth type: `ldap` or `db` |

### JVM Options

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_jvm_opts` | `""` | Additional JVM options |
| `auth_lib_heap_min` | `256m` | Minimum heap size |
| `auth_lib_heap_max` | `512m` | Maximum heap size |
| `auth_lib_metaspace_size` | `128m` | Metaspace size |
| `auth_lib_gc_options` | `-XX:+UseG1GC` | GC options |

### MySQL Connection

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_mysql_host` | `localhost` | MySQL host |
| `auth_lib_mysql_port` | `3306` | MySQL port |
| `auth_lib_mysql_database` | `mydb` | Database name |
| `auth_lib_mysql_username` | `root` | Database user |
| `auth_lib_mysql_password` | `root` | Database password |
| `auth_lib_mysql_driver` | `com.mysql.cj.jdbc.Driver` | JDBC driver |
| `auth_lib_mysql_dialect` | `org.hibernate.dialect.MySQLDialect` | Hibernate dialect |

### JPA/Hibernate Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_jpa_ddl_auto` | `update` | DDL auto mode |
| `auth_lib_jpa_show_sql` | `true` | Show SQL in logs |
| `auth_lib_jpa_open_in_view` | `false` | Open session in view |

### LDAP Connection

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_ldap_url` | `ldap://localhost:389/dc=maxcrc,dc=com` | LDAP URL |
| `auth_lib_ldap_base` | `dc=maxcrc,dc=com` | LDAP base DN |
| `auth_lib_ldap_username` | `cn=admin,dc=maxcrc,dc=com` | LDAP bind DN |
| `auth_lib_ldap_password` | `secret` | LDAP password |
| `auth_lib_ldap_users_ou` | `users` | Users OU |
| `auth_lib_ldap_user_search_filter` | `(uid={0})` | Search filter |
| `auth_lib_ldap_user_dn_pattern` | `uid={username},ou=users,...` | DN pattern |

### Logging Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_log_level_root` | `INFO` | Root log level |
| `auth_lib_log_level_app` | `INFO` | Application log level |
| `auth_lib_log_file` | `/opt/auth-lib/logs/app.log` | Log file path |
| `auth_lib_log_max_file_size` | `10MB` | Max log file size |
| `auth_lib_log_max_history` | `30` | Days to keep logs |
| `auth_lib_log_total_size_cap` | `100MB` | Total log size cap |

### Service Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_service_name` | `auth-lib` | Systemd service name |
| `auth_lib_service_enabled` | `true` | Enable at boot |
| `auth_lib_service_state` | `started` | Service state |
| `auth_lib_service_restart_sec` | `10` | Restart delay |

### Health Check

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_health_check_enabled` | `true` | Enable health check |
| `auth_lib_health_check_endpoint` | `/actuator/health` | Health endpoint |
| `auth_lib_health_check_timeout` | `60` | Timeout in seconds |

### Java Installation

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_java_package` | `openjdk-17-jdk` | Java package |
| `auth_lib_java_home` | `/usr/lib/jvm/java-17-openjdk-amd64` | JAVA_HOME path |

### Additional Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `auth_lib_environment_vars` | `{}` | Additional env vars |

## Dependencies

- `mysql` role (or MySQL service available)
- `openldap` role (or OpenLDAP service available)

## Example Playbook

### Basic Usage

```yaml
- hosts: app_servers
  become: true
  roles:
    - role: auth-lib
      vars:
        auth_lib_jar_path: "{{ playbook_dir }}/../auth-lib/build/libs/Project1-1.0.0.jar"
```

### Production Configuration

```yaml
- hosts: app_servers
  become: true
  roles:
    - role: auth-lib
      vars:
        auth_lib_jar_path: "/tmp/auth-lib-1.0.0.jar"
        auth_lib_user: appuser
        auth_lib_group: appuser
        auth_lib_port: 8080
        auth_lib_authentication_type: ldap
        auth_lib_heap_max: 1024m
        auth_lib_mysql_host: db.example.com
        auth_lib_mysql_password: "{{ vault_mysql_password }}"
        auth_lib_ldap_url: "ldap://ldap.example.com:389/dc=example,dc=com"
        auth_lib_ldap_password: "{{ vault_ldap_password }}"
        auth_lib_log_level_root: WARN
        auth_lib_environment_vars:
          SPRING_PROFILES_ACTIVE: production
          SERVER_SERVLET_CONTEXT_PATH: /auth
```

### With Database Authentication

```yaml
- hosts: app_servers
  become: true
  roles:
    - role: auth-lib
      vars:
        auth_lib_jar_path: "/tmp/auth-lib-1.0.0.jar"
        auth_lib_authentication_type: db
        auth_lib_mysql_host: localhost
        auth_lib_mysql_database: auth_db
        auth_lib_mysql_username: auth_user
        auth_lib_mysql_password: secure_password
```

## Service Management

```bash
# Check service status
sudo systemctl status auth-lib

# View logs
sudo journalctl -u auth-lib -f

# Restart service
sudo systemctl restart auth-lib

# Stop service
sudo systemctl stop auth-lib
```

## Verification

After deployment, verify the application:

```bash
# Check if service is running
sudo systemctl status auth-lib

# Test HTTP endpoint
curl http://localhost:9090/login

# Check application logs
tail -f /opt/auth-lib/logs/app.log
```

## License

MIT

## Author

DigiTechNova

