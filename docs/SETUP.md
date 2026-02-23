# Frappe Orchestrator Setup Guide

## Prerequisites

- Docker and Docker Compose (version 20.10+)
- Git
- 4GB+ RAM available
- 10GB+ free disk space

## Quick Start

### 1. Clone and Setup

```bash
cd frappe-orchestrator
cp .env.example .env
```

### 2. Create SSL Certificates for Development

```bash
mkdir -p docker/ssl
openssl req -x509 -newkey rsa:4096 -nodes -out docker/ssl/cert.pem -keyout docker/ssl/key.pem -days 365 \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=frappe-orchestrator.local"
```

### 3. Start Docker Containers

```bash
cd docker
docker-compose up -d
```

This will:
- Create MariaDB database container
- Create Redis cache and queue containers
- Build and start Frappe application container
- Start Nginx reverse proxy
- Initialize database and create default site

### 4. Verify Installation

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f frappe

# Access application
# Web: http://localhost (or https://frappe-orchestrator.local)
# Default credentials: admin / admin123
```

## Common Commands

### Start/Stop Services

```bash
cd docker
docker-compose up -d          # Start all services
docker-compose down           # Stop all services
docker-compose restart        # Restart all services
docker-compose logs -f        # View logs
```

### Frappe Bench Commands

```bash
# Enter Frappe container
docker-compose exec frappe bash

# Inside container:
bench status                              # Check status
bench --site frappe-orchestrator.local list-apps  # List installed apps
bench --site frappe-orchestrator.local migrate    # Run migrations
bench --site frappe-orchestrator.local console    # Python console
```

### Database Commands

```bash
# Backup database
docker-compose exec mariadb mysqldump -u frappe -pFrappePassword123 frappe > backup.sql

# Restore database
docker-compose exec mariadb mysql -u frappe -pFrappePassword123 frappe < backup.sql

# Access MySQL shell
docker-compose exec mariadb mysql -u frappe -pFrappePassword123 frappe
```

### Development

```bash
# Install new app
docker-compose exec frappe bench get-app <repo-url>
docker-compose exec frappe bench --site frappe-orchestrator.local install-app <app-name>

# Install dependencies
docker-compose exec frappe bench setup requirements

# Run Frappe in development mode
docker-compose exec frappe bench start
```

## Project Structure

```
frappe-orchestrator/
├── apps/                          # Frappe custom applications
│   ├── orchestrator-crm/         # CRM module
│   ├── orchestrator-hr/          # HR module
│   ├── orchestrator-helpdesk/    # Helpdesk module
│   ├── orchestrator-docs/        # Documents module
│   ├── orchestrator-insights/    # Analytics module
│   └── orchestrator-gameplan/    # Project management module
├── docker/
│   ├── docker-compose.yml        # Main compose file
│   ├── Dockerfile                # Frappe app image
│   ├── docker-entrypoint.sh      # Startup script
│   ├── nginx.conf                # Nginx configuration
│   ├── mariadb.cnf               # MariaDB configuration
│   └── ssl/                      # SSL certificates
├── docs/
│   ├── SETUP.md                  # This file
│   ├── ARCHITECTURE.md           # System architecture
│   ├── API_REFERENCE.md          # API documentation
│   └── DATA_SCHEMA.md            # Database schema
├── scripts/
│   ├── init-db.sql              # Database initialization
│   └── migrate-data.sh           # Data migration scripts
├── .env.example                  # Environment variables template
└── README.md                      # Project overview
```

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs frappe

# Rebuild image
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Database connection errors

```bash
# Verify MariaDB is running
docker-compose exec mariadb mysqladmin -u frappe -pFrappePassword123 ping

# Check network
docker network ls
docker-compose exec frappe ping mariadb
```

### Port already in use

```bash
# Change ports in docker-compose.yml or:
docker-compose down
# Kill process on port
lsof -ti:8000 | xargs kill -9
```

### Slow performance

```bash
# Increase resource allocation in Docker Desktop Settings
# Or check container resource usage:
docker stats frappe
```

## Accessing the Application

### Local Development

- **URL:** http://localhost:80 or https://frappe-orchestrator.local
- **Username:** admin
- **Password:** admin123

### Adding Hosts Entry (for HTTPS)

```bash
# macOS/Linux
sudo nano /etc/hosts
# Add: 127.0.0.1 frappe-orchestrator.local

# Windows (as Administrator)
notepad C:\Windows\System32\drivers\etc\hosts
# Add: 127.0.0.1 frappe-orchestrator.local
```

## Next Steps

1. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
2. Start implementing custom modules in `apps/`
3. Define data schema in [DATA_SCHEMA.md](DATA_SCHEMA.md)
4. Set up version control and CI/CD
5. Configure production deployment for GCP

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. Consult [Frappe Documentation](https://frappeframework.com/docs)
