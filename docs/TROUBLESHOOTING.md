# Troubleshooting Guide

## Docker & Container Issues

### Container Won't Start

**Problem:** `docker-compose up` fails or containers exit immediately

**Solutions:**

1. **Check logs:**
   ```bash
   docker-compose logs frappe
   docker-compose logs mariadb
   ```

2. **Verify images built correctly:**
   ```bash
   docker-compose build --no-cache
   docker-compose down -v
   docker-compose up -d
   ```

3. **Check disk space:**
   ```bash
   docker system df
   # If >80% used, clean up:
   docker system prune -a
   ```

4. **Verify Docker daemon is running:**
   ```bash
   docker ps
   docker-compose version
   ```

### Port Already in Use

**Problem:** `Error: Port 8000 is already allocated`

**Solutions:**

```bash
# Find process using port
lsof -i :8000

# Kill the process
kill -9 <PID>

# Or change port in docker-compose.yml
# Change: ports: - "8001:8000"
```

### Out of Memory

**Problem:** Containers crash or become unresponsive

**Solutions:**

1. **Increase Docker memory limits:**
   - Docker Desktop → Preferences → Resources
   - Set Memory to 4GB+

2. **Check current usage:**
   ```bash
   docker stats
   ```

3. **Optimize Frappe:**
   ```bash
   docker-compose exec frappe bench setup requirements
   bench config set-common-config '{"max_db_connections": 50}'
   ```

### Network Issues

**Problem:** Container can't reach database or Redis

**Solutions:**

```bash
# Test network connectivity
docker-compose exec frappe ping mariadb
docker-compose exec frappe ping redis-cache

# Verify services are running
docker-compose ps

# Check network
docker network ls
docker-compose exec frappe ip addr show
```

---

## Database Issues

### Cannot Connect to MariaDB

**Problem:** "ERROR 2003: Can't connect to MySQL server"

**Solutions:**

```bash
# Verify MariaDB is running
docker-compose exec mariadb mysql -u frappe -p -e "SELECT 1"

# Check container health
docker-compose logs mariadb

# Verify credentials in .env
cat docker/.env

# Restart database
docker-compose restart mariadb
sleep 10
docker-compose exec frappe bench --site frappe-orchestrator.local migrate
```

### Database Migration Fails

**Problem:** `Migration failed: FileNotFoundError` or permission errors

**Solutions:**

1. **Rebuild bench:**
   ```bash
   docker-compose down
   docker volume rm docker_frappe_sites docker_frappe_logs
   docker-compose up -d
   sleep 30
   docker-compose logs frappe
   ```

2. **Manual migration:**
   ```bash
   docker-compose exec frappe \
     bench --site frappe-orchestrator.local migrate --rebuild-index
   ```

3. **Check database user permissions:**
   ```bash
   docker-compose exec mariadb mysql -u root -p
   # In MySQL:
   GRANT ALL ON frappe.* TO 'frappe'@'%';
   FLUSH PRIVILEGES;
   ```

### Database Too Large

**Problem:** Database dump or restore is very slow

**Solutions:**

```bash
# Check table sizes
docker-compose exec mariadb mysql -u frappe -p frappe \
  -e "SELECT table_name, ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size in MB' FROM information_schema.TABLES WHERE table_schema = 'frappe' ORDER BY (data_length + index_length) DESC;"

# Archive old data
docker-compose exec frappe bench --site frappe-orchestrator.local execute \
  orchestrator.scripts.archive_old_data
```

---

## Frappe Framework Issues

### Application Won't Load

**Problem:** White screen or 500 error when accessing http://localhost

**Solutions:**

1. **Check Frappe logs:**
   ```bash
   docker-compose logs frappe | grep -i error
   tail -f docker/frappe_logs/error.log
   ```

2. **Rebuild static files:**
   ```bash
   docker-compose exec frappe bench build --app orchestrator-crm
   docker-compose exec frappe bench clear-cache
   docker-compose restart frappe
   ```

3. **Verify site is active:**
   ```bash
   docker-compose exec frappe bench --site frappe-orchestrator.local list-apps
   ```

4. **Reset admin password:**
   ```bash
   docker-compose exec frappe \
     bench --site frappe-orchestrator.local set-admin-password admin123
   ```

### 403 Forbidden / Permission Denied

**Problem:** "You do not have permission to access this"

**Solutions:**

1. **Check user role:**
   ```bash
   # Via Frappe UI: Setup → Users → <user> → Check roles
   ```

2. **Debug permissions:**
   ```bash
   docker-compose exec frappe bench --site frappe-orchestrator.local console
   >>> from frappe.desk.reportview import get_report_columns
   >>> frappe.get_user().get_roles()
   ```

3. **Reset permissions:**
   ```bash
   docker-compose exec frappe \
     bench --site frappe-orchestrator.local reset-permissions
   ```

### Slow Application

**Problem:** High latency, slow page loads

**Solutions:**

1. **Check performance bottlenecks:**
   ```bash
   # View active processes
   docker stats frappe
   
   # Check slow queries
   docker-compose exec mariadb mysql -u frappe -p frappe \
     -e "SELECT * FROM mysql.slow_log LIMIT 10;"
   ```

2. **Enable query caching:**
   ```bash
   # In .env:
   QUERY_CACHE_SIZE=268435456  # 256MB
   QUERY_CACHE_TYPE=1
   ```

3. **Clear cache:**
   ```bash
   docker-compose exec frappe bench clear-cache
   ```

4. **Rebuild indexes:**
   ```bash
   docker-compose exec frappe \
     bench --site frappe-orchestrator.local migrate --rebuild-index
   ```

### Module Won't Install

**Problem:** `Error installing app: [Errno ENOENT]` or dependency issues

**Solutions:**

```bash
# Install from git
docker-compose exec frappe \
  bench get-app orchestrator-crm https://github.com/your-org/orchestrator-crm.git

# Install app
docker-compose exec frappe \
  bench --site frappe-orchestrator.local install-app orchestrator_crm

# Rebuild requirements
docker-compose exec frappe bench setup requirements

# Check installed apps
docker-compose exec frappe bench --site frappe-orchestrator.local list-apps
```

---

## API & Integration Issues

### API Authentication Fails

**Problem:** "Unauthorised" or "Invalid API token"

**Solutions:**

1. **Verify API token:**
   - Frappe UI → Setup → API → Generate new token
   - Use format: `Authorization: token api-key:api-secret`

2. **Check role permissions:**
   ```bash
   # API user needs "API User" role
   # Via UI: Setup → Users → <user> → Roles
   ```

3. **Test authentication:**
   ```bash
   curl -H "Authorization: token key:secret" \
     http://localhost:8000/api/method/frappe.client.get_list?doctype=Lead
   ```

### Sync Data Missing

**Problem:** Data from Kipu not appearing in Frappe

**Solutions:**

1. **Check sync logs:**
   ```bash
   docker-compose exec frappe bench --site frappe-orchestrator.local console
   >>> from frappe.desk.notifications import clear_notifications
   >>> frappe.get_list('Data Sync', fields=['name', 'status', 'error_log'])
   ```

2. **Verify Kipu credentials:**
   - Frappe UI → Setup → Kipu Settings
   - Test connection

3. **Run sync manually:**
   ```bash
   docker-compose exec frappe \
     bench --site frappe-orchestrator.local execute \
     orchestrator.sync.sync_kipu_clients
   ```

4. **Check mapped fields:**
   - Verify field mapping in sync configuration
   - Ensure Kipu API response matches expected schema

### Webhook Not Triggering

**Problem:** External webhooks not being called

**Solutions:**

1. **Check webhook configuration:**
   ```bash
   docker-compose exec frappe bench --site frappe-orchestrator.local console
   >>> frappe.get_list('Webhook', fields=all)
   ```

2. **Verify webhook URL is accessible:**
   ```bash
   curl -X POST https://your-webhook-url/endpoint
   ```

3. **Check logs:**
   ```bash
   docker-compose exec frappe tail -f frappe-bench/logs/error.log | grep -i webhook
   ```

4. **Enable webhook debug:**
   ```bash
   docker-compose exec frappe \
     bench --site frappe-orchestrator.local set-config webhook_debug 1
   ```

---

## Email Configuration Issues

### Can't Send Emails

**Problem:** "SMTPAuthenticationError" or emails not being sent

**Solutions:**

1. **Configure mail server:**
   - Frappe UI → Setup → Email Account
   - Test settings:
     ```bash
     docker-compose exec frappe bench --site frappe-orchestrator.local console
     >>> from frappe.email.email_base import send_mail
     >>> send_mail(recipients=['test@example.com'], subject='Test', message='Test')
     ```

2. **Check SMTP credentials in .env:**
   ```bash
   MAIL_SERVER=smtp.gmail.com
   MAIL_PORT=587
   MAIL_USE_TLS=1
   MAIL_USERNAME=your-email@gmail.com
   MAIL_PASSWORD=your-app-password
   ```

3. **View email queue:**
   ```bash
   docker-compose exec frappe bench --site frappe-orchestrator.local console
   >>> frappe.get_list('Email Queue', filters=[['Status', '!=', 'Sent']])
   ```

---

## Performance Optimization

### High Database Load

**Create missing indexes:**
```bash
docker-compose exec mariadb mysql -u frappe -p frappe \
  -e "CREATE INDEX idx_status_updated ON clients(status, updated_at);"
```

### Slow Reports

**Enable report caching:**
```bash
# In Frappe UI: Report → Configure → Enable Query Report Caching
```

### Memory Leaks

**Restart Frappe periodically:**
```bash
# Add to crontab
docker-compose restart frappe
```

---

## Backup & Recovery

### Create Backup

```bash
# Full backup (database + files)
docker-compose exec frappe \
  bench --site frappe-orchestrator.local backup

# Database only
docker-compose exec mariadb mysqldump -u frappe -p frappe > backup.sql

# Files only
tar -czf frappe-files.tar.gz frappe_sites/
```

### Restore from Backup

```bash
# Restore database
docker-compose exec mariadb mysql -u frappe -p frappe < backup.sql

# Restore full site
docker-compose exec frappe \
  bench --site frappe-orchestrator.local restore /path/to/backup
```

---

## Getting Help

1. **Check Frappe Documentation:** https://frappeframework.com/docs
2. **Community Forum:** https://discuss.frappe.io
3. **GitHub Issues:** [Create issue](../../issues)
4. **Check logs:** `docker-compose logs -f`
5. **Enable debug mode:** Add `debug=1` to .env

---

**Last Updated:** February 2026
