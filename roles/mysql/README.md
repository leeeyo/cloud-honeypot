# MySQL Ansible Role

Installs and configures MySQL server for the auth-lib application.

## Requirements

- Ubuntu/Debian-based system
- Ansible 2.9+
- `community.mysql` collection

## Role Variables

### Database Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_database` | `mydb` | Main application database name |
| `mysql_username` | `root` | Main application database user |
| `mysql_password` | `root` | Main application database password |
| `mysql_root_password` | `root` | MySQL root password |

### Server Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_port` | `3306` | MySQL server port |
| `mysql_bind_address` | `127.0.0.1` | MySQL bind address |
| `mysql_socket` | `/var/run/mysqld/mysqld.sock` | MySQL socket path |

### Character Set and Collation

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_character_set` | `utf8mb4` | Default character set |
| `mysql_collation` | `utf8mb4_unicode_ci` | Default collation |

### Performance Tuning

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_max_connections` | `151` | Maximum connections |
| `mysql_innodb_buffer_pool_size` | `128M` | InnoDB buffer pool size |
| `mysql_innodb_log_file_size` | `48M` | InnoDB log file size |
| `mysql_key_buffer_size` | `16M` | Key buffer size |
| `mysql_max_allowed_packet` | `16M` | Max allowed packet size |
| `mysql_thread_cache_size` | `8` | Thread cache size |
| `mysql_query_cache_size` | `0` | Query cache size (deprecated in 8.0) |
| `mysql_query_cache_type` | `0` | Query cache type (deprecated in 8.0) |

### Logging Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_log_error` | `/var/log/mysql/error.log` | Error log path |
| `mysql_slow_query_log` | `false` | Enable slow query log |
| `mysql_slow_query_log_file` | `/var/log/mysql/slow.log` | Slow query log path |
| `mysql_long_query_time` | `2` | Slow query threshold (seconds) |

### Service Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_service_name` | `mysql` | MySQL service name |
| `mysql_service_enabled` | `true` | Enable service at boot |
| `mysql_service_state` | `started` | Service state |

### Additional Users and Databases

| Variable | Default | Description |
|----------|---------|-------------|
| `mysql_additional_users` | `[]` | List of additional users (see example below) |
| `mysql_additional_databases` | `[]` | List of additional database names |

## Dependencies

- `community.mysql` collection

Install with:
```bash
ansible-galaxy collection install community.mysql
```

## Example Playbook

### Basic Usage

```yaml
- hosts: database_servers
  become: true
  roles:
    - role: mysql
      vars:
        mysql_database: myapp_db
        mysql_username: myapp_user
        mysql_password: secure_password
        mysql_root_password: root_secure_password
```

### Advanced Usage with Additional Users

```yaml
- hosts: database_servers
  become: true
  roles:
    - role: mysql
      vars:
        mysql_database: production_db
        mysql_root_password: "{{ vault_mysql_root_password }}"
        mysql_max_connections: 300
        mysql_innodb_buffer_pool_size: 512M
        mysql_slow_query_log: true
        mysql_additional_users:
          - name: app_readonly
            password: readonly_pass
            priv: "production_db.*:SELECT"
            host: "%"
          - name: app_admin
            password: admin_pass
            priv: "*.*:ALL"
            host: "10.0.1.%"
        mysql_additional_databases:
          - logs_db
          - analytics_db
```

## License

MIT

## Author

DigiTechNova

