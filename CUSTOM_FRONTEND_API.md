# Custom Frontend + Frappe Backend API Approach

**Goal:** Build a completely custom UI (React/Vue/Next.js) while using Frappe as a powerful backend API.

---

## **Architecture Overview**

```
┌─────────────────────────────────────────────────────────┐
│  Your Custom Frontend                                   │
│  (React, Vue, Angular, Next.js, or even mobile app)    │
│                                                         │
│  • Your branding & design                              │
│  • Complete UI control                                  │
│  • Modern frameworks                                    │
│  • Deploy anywhere (Vercel, Netlify, etc.)            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ REST API calls
                     │
┌────────────────────▼────────────────────────────────────┐
│  Frappe Backend (http://api.yourcompany.com)           │
│                                                         │
│  • Database (MariaDB)                                   │
│  • REST API (auto-generated for all DocTypes)         │
│  • Business logic (Python server scripts)              │
│  • Authentication & permissions                         │
│  • File storage                                         │
│  • Email/notifications                                  │
│  • Workflows                                            │
└─────────────────────────────────────────────────────────┘
```

---

## **Benefits of This Approach**

### **✅ Pros:**
- **Complete design freedom** - Build any UI you want
- **Modern frameworks** - Use React, Vue, Next.js, etc.
- **Multiple frontends** - Web app + mobile app sharing same backend
- **Deploy separately** - Frontend on Vercel, backend on your server
- **Flexibility** - Replace frontend anytime without touching data/logic
- **Performance** - Optimize frontend separately from backend

### **⚠️ Cons:**
- More development work (you build the entire frontend)
- Need frontend development skills (React/Vue/etc.)
- Longer initial setup

---

## **Frappe's REST API (What You Get Out of the Box)**

### **Auto-Generated Endpoints for Every DocType**

When you create a "Lead" DocType, Frappe automatically creates these API endpoints:

```bash
# Get all leads
GET /api/resource/Lead

# Get a specific lead
GET /api/resource/Lead/{name}

# Create a new lead
POST /api/resource/Lead

# Update a lead
PUT /api/resource/Lead/{name}

# Delete a lead
DELETE /api/resource/Lead/{name}

# Search/filter leads
GET /api/resource/Lead?filters=[["status","=","Qualified"]]

# Get specific fields only
GET /api/resource/Lead?fields=["lead_name","email","status"]

# Pagination
GET /api/resource/Lead?limit=20&start=0
```

---

## **Example: Building a React CRM Frontend**

### **Project Structure**

```
your-crm-frontend/
├── src/
│   ├── components/
│   │   ├── LeadList.jsx
│   │   ├── LeadForm.jsx
│   │   ├── Dashboard.jsx
│   │   └── Navbar.jsx
│   ├── services/
│   │   ├── api.js          ← Frappe API client
│   │   └── auth.js         ← Authentication
│   ├── pages/
│   │   ├── Home.jsx
│   │   ├── Leads.jsx
│   │   ├── Opportunities.jsx
│   │   └── Login.jsx
│   └── App.jsx
├── package.json
└── README.md
```

### **1. Frappe API Client**

**`services/api.js`**

```javascript
import axios from 'axios';

const FRAPPE_URL = 'http://localhost:8000'; // Your Frappe backend

class FrappeAPI {
  constructor() {
    this.client = axios.create({
      baseURL: FRAPPE_URL,
      withCredentials: true, // For cookie-based auth
    });
  }

  // Authentication
  async login(username, password) {
    const response = await this.client.post('/api/method/login', {
      usr: username,
      pwd: password,
    });
    return response.data;
  }

  async logout() {
    return this.client.post('/api/method/logout');
  }

  // Generic CRUD operations
  async getList(doctype, filters = {}, fields = [], limit = 20) {
    const params = {
      fields: JSON.stringify(fields),
      filters: JSON.stringify(filters),
      limit_page_length: limit,
    };
    
    const response = await this.client.get(`/api/resource/${doctype}`, { params });
    return response.data.data;
  }

  async getDoc(doctype, name) {
    const response = await this.client.get(`/api/resource/${doctype}/${name}`);
    return response.data.data;
  }

  async createDoc(doctype, data) {
    const response = await this.client.post(`/api/resource/${doctype}`, {
      data: data
    });
    return response.data.data;
  }

  async updateDoc(doctype, name, data) {
    const response = await this.client.put(`/api/resource/${doctype}/${name}`, {
      data: data
    });
    return response.data.data;
  }

  async deleteDoc(doctype, name) {
    return this.client.delete(`/api/resource/${doctype}/${name}`);
  }

  // Custom API methods
  async call(method, args = {}) {
    const response = await this.client.post(`/api/method/${method}`, args);
    return response.data.message;
  }
}

export default new FrappeAPI();
```

### **2. Lead List Component**

**`components/LeadList.jsx`**

```jsx
import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { Card, Button, Table, Badge } from 'react-bootstrap';

function LeadList() {
  const [leads, setLeads] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadLeads();
  }, []);

  const loadLeads = async () => {
    try {
      const data = await api.getList('Lead', {}, 
        ['name', 'lead_name', 'email', 'status', 'company']
      );
      setLeads(data);
    } catch (error) {
      console.error('Error loading leads:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status) => {
    const colors = {
      'New': 'primary',
      'Contacted': 'info',
      'Qualified': 'success',
      'Lost': 'danger'
    };
    return <Badge bg={colors[status] || 'secondary'}>{status}</Badge>;
  };

  if (loading) return <div>Loading...</div>;

  return (
    <Card>
      <Card.Header className="d-flex justify-content-between">
        <h4>Leads</h4>
        <Button variant="primary" href="/leads/new">+ New Lead</Button>
      </Card.Header>
      <Card.Body>
        <Table striped hover>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Company</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {leads.map(lead => (
              <tr key={lead.name}>
                <td>{lead.lead_name}</td>
                <td>{lead.email}</td>
                <td>{lead.company}</td>
                <td>{getStatusBadge(lead.status)}</td>
                <td>
                  <Button size="sm" href={`/leads/${lead.name}`}>View</Button>
                </td>
              </tr>
            ))}
          </tbody>
        </Table>
      </Card.Body>
    </Card>
  );
}

export default LeadList;
```

### **3. Lead Form Component**

**`components/LeadForm.jsx`**

```jsx
import React, { useState } from 'react';
import api from '../services/api';
import { Form, Button, Card } from 'react-bootstrap';

function LeadForm({ leadId = null, onSave }) {
  const [formData, setFormData] = useState({
    lead_name: '',
    email: '',
    phone: '',
    company: '',
    status: 'New',
    source: 'Website',
    notes: ''
  });

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (leadId) {
        await api.updateDoc('Lead', leadId, formData);
      } else {
        await api.createDoc('Lead', formData);
      }
      onSave?.();
    } catch (error) {
      console.error('Error saving lead:', error);
      alert('Failed to save lead');
    }
  };

  return (
    <Card>
      <Card.Header>
        <h4>{leadId ? 'Edit Lead' : 'New Lead'}</h4>
      </Card.Header>
      <Card.Body>
        <Form onSubmit={handleSubmit}>
          <Form.Group className="mb-3">
            <Form.Label>Lead Name *</Form.Label>
            <Form.Control
              type="text"
              name="lead_name"
              value={formData.lead_name}
              onChange={handleChange}
              required
            />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Email</Form.Label>
            <Form.Control
              type="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
            />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Phone</Form.Label>
            <Form.Control
              type="tel"
              name="phone"
              value={formData.phone}
              onChange={handleChange}
            />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Company</Form.Label>
            <Form.Control
              type="text"
              name="company"
              value={formData.company}
              onChange={handleChange}
            />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Status</Form.Label>
            <Form.Select name="status" value={formData.status} onChange={handleChange}>
              <option value="New">New</option>
              <option value="Contacted">Contacted</option>
              <option value="Qualified">Qualified</option>
              <option value="Lost">Lost</option>
            </Form.Select>
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Source</Form.Label>
            <Form.Select name="source" value={formData.source} onChange={handleChange}>
              <option value="Website">Website</option>
              <option value="Referral">Referral</option>
              <option value="Cold Call">Cold Call</option>
              <option value="Partner">Partner</option>
            </Form.Select>
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Notes</Form.Label>
            <Form.Control
              as="textarea"
              rows={4}
              name="notes"
              value={formData.notes}
              onChange={handleChange}
            />
          </Form.Group>

          <Button variant="primary" type="submit">
            {leadId ? 'Update' : 'Create'} Lead
          </Button>
        </Form>
      </Card.Body>
    </Card>
  );
}

export default LeadForm;
```

### **4. Dashboard Component**

**`components/Dashboard.jsx`**

```jsx
import React, { useState, useEffect } from 'react';
import api from '../services/api';
import { Row, Col, Card } from 'react-bootstrap';
import { PieChart, Pie, Cell, BarChart, Bar, XAxis, YAxis, Tooltip } from 'recharts';

function Dashboard() {
  const [metrics, setMetrics] = useState({
    totalLeads: 0,
    leadsByStatus: [],
    opportunitiesByStage: []
  });

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = async () => {
    try {
      // Get total leads
      const leads = await api.getList('Lead', {}, ['status']);
      
      // Count by status
      const statusCounts = leads.reduce((acc, lead) => {
        acc[lead.status] = (acc[lead.status] || 0) + 1;
        return acc;
      }, {});

      const leadsByStatus = Object.entries(statusCounts).map(([name, value]) => ({
        name,
        value
      }));

      setMetrics({
        totalLeads: leads.length,
        leadsByStatus
      });
    } catch (error) {
      console.error('Error loading dashboard:', error);
    }
  };

  const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

  return (
    <div>
      <h2 className="mb-4">Sales Dashboard</h2>
      
      <Row>
        <Col md={3}>
          <Card bg="primary" text="white">
            <Card.Body>
              <h3>{metrics.totalLeads}</h3>
              <p>Total Leads</p>
            </Card.Body>
          </Card>
        </Col>
        {/* Add more metric cards */}
      </Row>

      <Row className="mt-4">
        <Col md={6}>
          <Card>
            <Card.Header>Leads by Status</Card.Header>
            <Card.Body>
              <PieChart width={400} height={300}>
                <Pie
                  data={metrics.leadsByStatus}
                  cx={200}
                  cy={150}
                  labelLine={false}
                  label={(entry) => entry.name}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {metrics.leadsByStatus.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </Card.Body>
          </Card>
        </Col>
      </Row>
    </div>
  );
}

export default Dashboard;
```

---

## **Integration with Other Apps**

### **1. Zapier/Make/n8n Integration**

Frappe's REST API works with automation platforms:

**Example Zap:**
```
Trigger: New lead in Frappe
Action: Add to Mailchimp list
```

**Webhook Setup:**
```python
# In Frappe: Create Server Script for Lead DocType
def after_insert(doc, method):
    # Send to external webhook
    frappe.enqueue('requests.post',
        url='https://hooks.zapier.com/YOUR_WEBHOOK',
        json={
            'lead_name': doc.lead_name,
            'email': doc.email,
            'status': doc.status
        }
    )
```

### **2. External CRM Integration**

**Sync with Salesforce/HubSpot:**

```python
# Custom API endpoint in Frappe
@frappe.whitelist()
def sync_to_salesforce(lead_id):
    lead = frappe.get_doc('Lead', lead_id)
    
    # Send to Salesforce API
    sf_client.create_lead({
        'FirstName': lead.lead_name.split()[0],
        'LastName': lead.lead_name.split()[-1],
        'Email': lead.email,
        'Company': lead.company
    })
    
    return {'success': True}
```

Call from your React app:
```javascript
await api.call('your_app.api.sync_to_salesforce', { lead_id: '12345' });
```

### **3. Mobile App (React Native)**

Use the same API client:

```javascript
// Works identically in React Native
import api from './services/api';

function LeadListScreen() {
  const [leads, setLeads] = useState([]);

  useEffect(() => {
    api.getList('Lead').then(setLeads);
  }, []);

  // Render native components...
}
```

---

## **Deployment Architecture**

### **Production Setup**

```
┌─────────────────────────────────────────────┐
│  yourcompany.com                            │
│  (React app on Vercel/Netlify)             │
│  - Marketing site                           │
│  - Login/signup                             │
│  - Public pages                             │
└───────────────┬─────────────────────────────┘
                │
                ├─── /app/* → Frontend app
                │
                └─── API calls to backend
                          ↓
┌─────────────────────────────────────────────┐
│  api.yourcompany.com                        │
│  (Frappe backend on your server/cloud)     │
│  - REST API                                 │
│  - Database                                 │
│  - Business logic                           │
│  - File storage                             │
└─────────────────────────────────────────────┘
```

### **CORS Configuration**

In Frappe's `sites/yoursite/site_config.json`:

```json
{
  "allow_cors": "https://yourcompany.com",
  "cors_allowed_methods": "GET, POST, PUT, DELETE, OPTIONS",
  "cors_allowed_headers": "Content-Type, Authorization"
}
```

---

## **Which Approach Should You Choose?**

### **Choose White-Label Frappe UI if:**
- ✅ You want to launch quickly (days, not months)
- ✅ You're okay with Frappe's design patterns
- ✅ You need basic customization (colors, logo, layout)
- ✅ You want all features (UI + backend) in one system

### **Choose Custom Frontend if:**
- ✅ You need complete design freedom
- ✅ You have frontend development skills/team
- ✅ You want to use modern frameworks (React/Vue/Next.js)
- ✅ You're building multiple client apps (web + mobile)
- ✅ You need unique UX patterns

---

## **My Recommendation for You**

**Start with White-Label Frappe UI:**

1. **Build your DocTypes** (CRM, HR, Helpdesk) - 1-2 weeks
2. **Customize Frappe UI** with your branding - 1 day
3. **Launch and test** with real users - 1 week
4. **If needed**, build custom frontend later using the same backend

**Why this approach?**
- ✅ Faster time to market
- ✅ Learn Frappe's capabilities first
- ✅ Backend stays the same if you switch to custom UI later
- ✅ Less initial development cost

---

**Bottom line:** Frappe gives you BOTH options. Start fast with white-labeling, then go custom if your needs evolve!
