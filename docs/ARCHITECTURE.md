# Frappe Orchestrator Architecture

## System Overview

Frappe Orchestrator is a modular, multi-tenant healthcare and business management system built on the Frappe Framework. It provides integrated modules for CRM, HR, Helpdesk, Documents, Analytics, and Project Management while maintaining strict role-based access control and department-scoped data isolation.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Nginx Reverse Proxy                   │
│              (Load Balancing, SSL/TLS)                   │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
┌───────▼─────────────▼──────────────▼───────┐
│        Frappe Application Container        │
│  ┌──────────────────────────────────────┐  │
│  │   Frappe Web Framework (Python)      │  │
│  │  ┌────────────────────────────────┐  │  │
│  │  │  Custom Module Applications    │  │  │
│  │  │  • Orchestrator CRM           │  │  │
│  │  │  • Orchestrator HR            │  │  │
│  │  │  • Orchestrator Helpdesk      │  │  │
│  │  │  • Orchestrator Documents     │  │  │
│  │  │  • Orchestrator Insights      │  │  │
│  │  │  • Orchestrator Gameplan      │  │  │
│  │  └────────────────────────────────┘  │  │
│  │                                       │  │
│  │  Frappe Core                         │  │
│  │  • DocType Engine                    │  │
│  │  • Permissions & Roles               │  │
│  │  • Workflow Engine                   │  │
│  │  • REST API                          │  │
│  │  • Background Jobs                   │  │
│  └──────────────────────────────────────┘  │
└───────┬──────────────┬──────────────┬───────┘
        │              │              │
┌───────▼────┐ ┌───────▼────┐ ┌──────▼──────┐
│  MariaDB   │ │ Redis      │ │ Redis Queue │
│  Database  │ │ Cache      │ │ (Celery)    │
└────────────┘ └────────────┘ └─────────────┘
```

## Component Architecture

### 1. Web Layer (Nginx)

- **Purpose:** Reverse proxy, SSL/TLS termination, static file serving
- **Responsibilities:**
  - Route HTTP/HTTPS traffic to Frappe application
  - Cache static assets (JS, CSS, images)
  - Apply security headers
  - Load balancing (in production)

### 2. Application Layer (Frappe)

Built on Frappe Framework v14 with custom modules:

#### Core Frappe Features
- **DocType Engine:** Define and manage data structures
- **Permissions System:** Role-based access control (RBAC)
- **Workflow Engine:** Automated approval chains and state transitions
- **REST API:** JSON API for integrations and custom clients
- **Background Jobs:** Asynchronous task processing via Celery

#### Custom Modules

**Orchestrator CRM**
- Lead, Contact, Company, Customer management
- Opportunity and pipeline tracking
- Communication history and interaction logging
- Integration with Email, Phone, SMS

**Orchestrator HR**
- Employee records and profiles
- Department and team structure
- Shift scheduling and attendance
- Leave management and approvals
- Payroll and compensation
- Performance tracking

**Orchestrator Helpdesk**
- Ticket/Issue lifecycle management
- Service Level Agreements (SLA)
- Escalation policies
- Assignment algorithms (round-robin, skill-based)
- Knowledge base integration
- Multitenancy support (client-specific tickets)

**Orchestrator Documents**
- File/document storage and versioning
- Metadata tagging and classification
- Full-text search
- Audit trail logging
- Access control by department

**Orchestrator Insights**
- Executive dashboards
- KPI metrics and tracking
- Custom report builder
- Data visualization (charts, tables, graphs)
- Scheduled reports and alerts
- Real-time metrics aggregation

**Orchestrator Gameplan**
- Project and initiative management
- Task hierarchies (Epic → Story → Task → Subtask)
- Sprint planning and management
- Resource allocation and capacity planning
- Gantt chart and timeline views
- Dependency tracking

### 3. Data Layer

#### Database (MariaDB)
- **Purpose:** Persistent data storage
- **Features:**
  - ACID compliance via InnoDB
  - Row-based binary logging for replication
  - Character set: UTF-8 MB4 (supports emoji, multiple languages)
  - Automatic backups and snapshots (in production)

#### Cache (Redis)
- **Purpose:** Session storage, caching, real-time data
- **Responsibilities:**
  - User session management
  - Document caching (reduces database queries)
  - Rate limiting and throttling
  - Pub/Sub for real-time updates

#### Job Queue (Redis Queue)
- **Purpose:** Asynchronous task processing
- **Responsibilities:**
  - Background job execution (Celery workers)
  - Scheduled tasks (cron jobs, periodic syncs)
  - Email delivery
  - Report generation
  - Data migration and bulk operations

## Data Model

### Unified Client Schema

```
Client
├── Core Fields
│   ├── id (PrimaryKey)
│   ├── status (active, discharged, pending)
│   ├── admission_date
│   ├── discharge_date
│   └── sync_metadata (kipuLastSyncedAt, syncedFromKipu)
│
├── Medical Assignment (Child Table)
│   ├── template_id
│   ├── status (active, inactive)
│   ├── activated_at
│   └── task_generation_metadata
│
└── Program Assignment (Child Table)
    ├── program_id
    ├── status
    ├── start_date
    └── group_assignment
```

### Department-Scoped Access

```
Department
├── name (Medical, Program, Finance, etc.)
├── manager
├── roles (Medical Staff, Program Coordinator, etc.)
└── Sub-resources
    ├── tasks
    ├── templates
    ├── metrics
    └── settings
```

### Role-Based Access Matrix

| Role | Client View | Medical Data | Program Data | HR Data | Finance Data |
|------|-----------|--------------|--------------|---------|-------------|
| Super Admin | All | RW | RW | RW | RW |
| Medical Staff | Own Dept | RW | R | - | - |
| Program Staff | Own Dept | R | RW | - | - |
| HR Manager | All | - | - | RW | R |
| Finance Manager | All | - | - | R | RW |
| Supervisor | All | R | R | R | R |

## Integration Points

### External Data Sources

**Kipu Integration (Healthcare Example)**
- Periodic sync of patient/client records
- Conflict resolution for duplicate/updated records
- Audit trail of sync operations
- Rollback capability for failed syncs

**Generic Adapter Pattern**
- Pluggable adapters for different external systems
- Scheduled polling or webhook receivers
- Data transformation and validation
- Error handling and retry logic

### API Integrations

```
POST /api/method/orchestrator.sync.sync_kipu_clients
  Body: { "sync_type": "full" | "incremental", "dry_run": false }
  Returns: { "imported": 50, "updated": 10, "skipped": 5, "errors": [] }

GET /api/method/orchestrator.crm.get_client_summary?client_id=C123
  Returns: {
    "client": {...},
    "active_tasks": 5,
    "recent_activities": [...],
    "assigned_modules": [...]
  }
```

## Security Architecture

### Authentication
- **Method:** Session-based (cookies) + API tokens
- **MFA:** Optional via OTP or authenticator apps
- **SSO:** Support for SAML2 and OAuth2 (configured)

### Authorization
- **Model:** Role-Based Access Control (RBAC)
- **Granularity:** DocType + field-level permissions
- **Dynamic Rules:** Custom validators and conditional access

### Data Protection
- **Encryption:** TLS/SSL in transit, at-rest encryption in production (GCP)
- **Audit Trail:** All data changes logged with user, timestamp, before/after values
- **Data Masking:** Sensitive fields can be masked in logs
- **HIPAA Compliance:** Audit logging, access controls, encryption ready (if needed)

## Performance Considerations

### Caching Strategy

```
Request → Nginx Cache (static assets)
       → Redis Cache (document cache, 5min TTL)
       → MariaDB Query (if cache miss)
```

### Query Optimization
- Composite indexes on frequently filtered fields
- Eager loading of relationships (N+1 prevention)
- Pagination for large result sets
- Full-text search via Elasticsearch (optional)

### Scaling

**Vertical Scaling (Development → Staging)**
- Increase container resource limits
- Increase MariaDB buffer pool
- Add more Redis memory

**Horizontal Scaling (Staging → Production)**
- Multiple Frappe app containers behind load balancer
- Database replication with read replicas
- Separate cache and queue Redis instances
- CDN for static assets

## Deployment Strategy

### Development Environment
- Local Docker Compose
- All services on single host
- Hot-reload for Python/JavaScript
- Live database debug access

### Staging Environment
- Multi-container setup on VM or Kubernetes
- Separate database credentials
- Production-like data volume
- Integration testing before production

### Production Environment
- Google Cloud Run for Frappe containers
- Cloud SQL for managed MariaDB
- Cloud Memorystore for Redis
- Cloud Storage for uploaded documents
- Cloud Armor for DDoS protection
- Cloud Load Balancer for SSL/TLS

## Monitoring & Observability

### Logging
- Application logs → Cloud Logging (production)
- Database slow query log
- Nginx access/error logs
- Frappe error log

### Metrics
- Request latency and throughput
- Database query performance
- Cache hit rate
- Job queue depth
- Container resource usage

### Alerting
- High error rate (>1%)
- Slow requests (>5s)
- Database connection pool exhaustion
- Disk space warning (>80%)
- Job queue backed up (>1000 jobs)

## Development Workflow

### Adding a New Module

1. **Scaffold module structure**
   ```bash
   bench new-app orchestrator-module-name
   ```

2. **Define DocTypes** (using Frappe UI or JSON)
   ```python
   # apps/orchestrator-module-name/orchestrator_module_name/doctype_name/
   doctype_name.json     # DocType definition
   doctype_name.py       # Python backend logic
   doctype_name.js       # Frontend form customization
   ```

3. **Add permissions**
   ```python
   # Define roles in module setup
   # Apply DocType permissions via Frappe UI
   ```

4. **Create API endpoints** (if needed)
   ```python
   # apps/orchestrator-module-name/api.py
   @frappe.whitelist()
   def get_module_data():
       return frappe.get_list('DocType', ...)
   ```

5. **Write tests**
   ```python
   # tests/test_doctype_name.py
   class TestDocTypeName(unittest.TestCase):
       def test_creation(self):
           ...
   ```

## Testing Strategy

### Unit Tests
- Test individual DocType methods
- Test validation rules
- Mock external dependencies

### Integration Tests
- Test API endpoints (POST, GET, PUT, DELETE)
- Test permission rules
- Test data relationships

### End-to-End Tests
- Test complete workflows (e.g., client creation → task assignment)
- UI testing with Selenium (optional)
- Performance testing

## Version Control & Releases

### Branching Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Individual feature branches
- `hotfix/*`: Emergency production fixes

### Release Process
1. Merge features to `develop`
2. Create release branch from `develop`
3. Test in staging environment
4. Merge to `main` and tag version (semver)
5. Deploy to production
6. Merge back to `develop`

## Next Steps

1. Review [DATA_SCHEMA.md](DATA_SCHEMA.md) for detailed DocType definitions
2. Implement custom modules in `apps/` directory
3. Set up CI/CD pipeline for automated testing/deployment
4. Configure production GCP infrastructure
5. Establish monitoring and alerting
