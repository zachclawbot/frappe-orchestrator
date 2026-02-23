# Frappe Orchestrator

A modular, enterprise-grade healthcare and business management system built on the Frappe Framework. Designed for multi-department workflows, external data synchronization, and seamless GCP deployment.

## Features

### Integrated Modules
- **CRM Module** - Customer relationship management, leads, opportunities, communication history
- **HR Module** - Employee management, payroll, leave management, attendance tracking
- **Helpdesk Module** - Ticket management, SLA tracking, escalation, multi-tenancy
- **Documents Module** - File storage, versioning, metadata tagging, audit trails
- **Insights Module** - Dashboards, KPIs, custom reports, real-time metrics
- **Gameplan Module** - Project management, task hierarchies, resource allocation, sprint planning

### Architecture Highlights
- **Unified Data Schema** - Single source of truth with department-scoped subcollections
- **Role-Based Access Control** - Fine-grained permissions at DocType and field level
- **External Data Sync** - Pluggable adapters for Kipu and other data sources
- **Multi-Tenancy Ready** - Support for multiple organizations/departments
- **Production-Ready** - Docker-based deployment, GCP integration, monitoring/logging

## Quick Start

### Prerequisites
- Docker & Docker Compose (v20.10+)
- Git
- 4GB RAM, 10GB disk space

### Installation

```bash
# Clone repository
git clone <repo-url>
cd frappe-orchestrator

# Setup environment
cp .env.example .env

# Generate SSL certificates for development
mkdir -p docker/ssl
openssl req -x509 -newkey rsa:4096 -nodes \
  -out docker/ssl/cert.pem -keyout docker/ssl/key.pem -days 365 \
  -subj "/C=US/ST=CA/L=San Francisco/O=Orchestrator/CN=frappe-orchestrator.local"

# Start application
cd docker
docker-compose up -d
```

### Access Application

- **URL:** http://localhost (or https://frappe-orchestrator.local after hosts entry)
- **Username:** admin
- **Password:** admin123

For detailed setup instructions, see [SETUP.md](docs/SETUP.md)

## Project Structure

```
frappe-orchestrator/
├── apps/                          # Custom Frappe applications
│   ├── orchestrator-crm/
│   ├── orchestrator-hr/
│   ├── orchestrator-helpdesk/
│   ├── orchestrator-docs/
│   ├── orchestrator-insights/
│   └── orchestrator-gameplan/
├── docker/
│   ├── docker-compose.yml        # Main orchestration
│   ├── Dockerfile                # Frappe image definition
│   ├── docker-entrypoint.sh      # Startup script
│   ├── nginx.conf                # Reverse proxy config
│   ├── mariadb.cnf               # Database config
│   └── ssl/                      # SSL certificates
├── docs/
│   ├── SETUP.md                  # Setup guide
│   ├── ARCHITECTURE.md           # System architecture
│   ├── DATA_SCHEMA.md            # Database schema
│   ├── API_REFERENCE.md          # API documentation
│   └── TROUBLESHOOTING.md        # Common issues
├── scripts/
│   ├── init-db.sql              # Database initialization
│   └── migrate-data.sh          # Data migration utilities
└── .env.example                  # Environment template
```

## Documentation

- **[SETUP.md](docs/SETUP.md)** - Installation and basic usage
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - System design, components, integrations
- **[DATA_SCHEMA.md](docs/DATA_SCHEMA.md)** - Database structure and DocType definitions
- **[API_REFERENCE.md](docs/API_REFERENCE.md)** - REST API endpoints and usage

## Development

### Common Commands

```bash
# Start services
cd docker && docker-compose up -d

# View logs
docker-compose logs -f frappe

# Install custom app
docker-compose exec frappe bench get-app <repo-url>

# Run migrations
docker-compose exec frappe bench --site frappe-orchestrator.local migrate

# Access Frappe console
docker-compose exec frappe bench --site frappe-orchestrator.local console

# Stop services
docker-compose down
```

### Docker Services

| Service | Port | Purpose |
|---------|------|---------|
| Nginx | 80, 443 | Web server & reverse proxy |
| Frappe | 8000 | Application server |
| MariaDB | 3306 | Database |
| Redis Cache | 6379 | Session/document cache |
| Redis Queue | 6380 | Background job queue |

## Module Overview

### Orchestrator CRM
Lead and opportunity management with communication history. Includes contact database, pipeline tracking, and integration with email/SMS.

### Orchestrator HR
Complete HR suite for employee management, payroll, attendance, and leave management. Includes organization structure, shift scheduling, and performance tracking.

### Orchestrator Helpdesk
Professional issue tracking with SLA management, assignment algorithms, and knowledge base. Supports multi-tenancy and escalation policies.

### Orchestrator Documents
File and document management with versioning, metadata tagging, and audit trails. Includes full-text search and access control by department.

### Orchestrator Insights
Business intelligence and analytics. Create dashboards, define KPIs, generate reports, and track real-time metrics across all modules.

### Orchestrator Gameplan
Project and task management with Gantt charts, sprint planning, resource allocation, and dependency tracking. Integrated with other modules for unified visibility.

## Data Synchronization

### Kipu Integration Example

```python
# Sync patient records from Kipu
POST /api/method/orchestrator.sync.sync_kipu_clients
{
  "sync_type": "incremental",  # or "full"
  "dry_run": false
}

Response:
{
  "imported": 45,
  "updated": 12,
  "skipped": 3,
  "errors": []
}
```

### Generic Adapter Pattern

Implement custom adapters for any data source:

```python
# apps/orchestrator-core/adapters/custom_source.py
class CustomSourceAdapter:
    def get_clients(self):
        # Fetch from external API
        ...
    
    def map_to_frappe(self, external_client):
        # Transform to Frappe schema
        ...
    
    def handle_conflicts(self, frappe_doc, external_doc):
        # Merge strategy
        ...
```

## Security

### Authentication
- Session-based (cookies) + API token authentication
- Optional MFA (OTP, authenticator apps)
- SSO ready (SAML2, OAuth2)

### Authorization
- Role-Based Access Control (RBAC) at DocType and field level
- Department-scoped data isolation
- Super-admin override capabilities

### Data Protection
- TLS/SSL encryption in transit
- At-rest encryption in production (GCP)
- Audit trail of all data changes
- PHI/PII handling ready

## Deployment

### Development
Local Docker Compose setup for rapid iteration

### Staging
Multi-container deployment for pre-production testing

### Production
Google Cloud Run + Cloud SQL with automated scaling, monitoring, and backup

See [ARCHITECTURE.md](docs/ARCHITECTURE.md#deployment-strategy) for detailed deployment strategy.

## Performance

- Page load: <2 seconds
- List views: <3 seconds
- API response: <500ms
- Concurrent users: 100+

## Troubleshooting

### Container Issues
```bash
# View logs
docker-compose logs frappe

# Rebuild containers
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Database Connection
```bash
# Test database connection
docker-compose exec mariadb mysqladmin -u frappe -p ping

# Access MySQL shell
docker-compose exec mariadb mysql -u frappe -p frappe
```

For more issues, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes and commit: `git commit -m "feat: your feature"`
3. Push to remote: `git push origin feature/your-feature`
4. Create Pull Request

## License

[MIT License](LICENSE) - Modify and distribute freely

## Support

- **Frappe Documentation:** https://frappeframework.com/docs
- **GitHub Issues:** [Submit an issue](../../issues)
- **Community Forum:** https://discuss.frappe.io

## Roadmap

- [ ] Phase 2: Unified data schema migration
- [ ] Phase 3: Advanced workflow automation
- [ ] Phase 4: Mobile app (iOS/Android)
- [ ] Phase 5: AI-powered insights and automation
- [ ] Phase 6: Multitenancy refinements and scalability

---

**Status:** Active Development  
**Last Updated:** February 2026  
**Version:** 0.1.0-alpha
