# White-Labeling & Customizing Frappe UI

**Goal:** Make Frappe look like your own custom application with your branding, colors, and layout.

---

## **1. Custom Branding (Logo, Colors, Name)**

### **Upload Your Logo**

1. **Navigate to:** Search → "Website Settings"
2. **Upload your logo:**
   - App Logo: Your main logo (appears in sidebar)
   - Banner Image: Hero image for public pages
   - Favicon: Browser tab icon

3. **Set App Name:**
   - App Name: "Your Company Portal" (instead of "Frappe")

**Visual result:** Your logo appears instead of Frappe logo everywhere.

---

### **Custom Color Scheme**

**Method 1: Through UI**

1. Search → "System Settings"
2. Scroll to "Theme"
3. Select a base theme or create custom

**Method 2: Custom CSS (Full Control)**

1. Create a custom app or use "Custom" module
2. Add CSS file in `public/css/`
3. Override Frappe styles:

```css
/* Your brand colors */
:root {
    --primary-color: #FF5733;        /* Your primary brand color */
    --secondary-color: #2C3E50;      /* Your secondary color */
    --text-color: #333333;
    --background-color: #F8F9FA;
}

/* Custom header */
.navbar {
    background: var(--primary-color) !important;
}

/* Custom buttons */
.btn-primary {
    background: var(--primary-color) !important;
    border-color: var(--primary-color) !important;
}

/* Custom sidebar */
.desk-sidebar {
    background: var(--secondary-color) !important;
}

/* Hide Frappe branding */
.footer-powered {
    display: none !important;
}
```

4. **Include CSS in hooks.py:**

```python
app_include_css = "/assets/your_app/css/custom.css"
```

**Visual result:** Entire app matches your brand colors.

---

## **2. Custom Landing Page / Workspace**

### **Create Custom Home Page**

1. Search → "Workspace"
2. Create "Home" workspace
3. Add:
   - Custom banner with your logo
   - Quick links (colored cards)
   - Charts/KPIs
   - Recent activity
   - Custom HTML/images

**Example Home Page Structure:**

```
┌─────────────────────────────────────────────────────┐
│  [Your Logo]           Welcome, Zach!      [Logout] │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Quick Actions:                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ New Lead │  │ New Task │  │ Reports  │         │
│  └──────────┘  └──────────┘  └──────────┘         │
│                                                     │
│  Recent Activity:                                   │
│  • 5 new leads today                               │
│  • 3 tickets pending                               │
│  • Team meeting at 2pm                             │
│                                                     │
│  [Sales Pipeline Chart]  [Team Performance Chart]  │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## **3. Custom Navigation & Modules**

### **Hide Unwanted Modules**

1. Search → "Module Def"
2. For each module you don't want:
   - Uncheck "Show in Sidebar"

**Result:** Only YOUR modules appear in navigation.

### **Rename Modules**

1. Open "Module Def" for your module
2. Change "Module Name" to anything you want:
   - "CRM" → "Client Management"
   - "HR" → "Team Management"
   - "Helpdesk" → "Support Center"

### **Custom Sidebar Menu**

Create custom workspace with your menu structure:

```yaml
Modules:
  - Client Management
    - Leads
    - Opportunities
    - Companies
  - Team Management
    - Employees
    - Time Off
  - Support Center
    - Tickets
    - Knowledge Base
```

---

## **4. Custom Login Screen**

### **Create Custom Login Page**

1. Create `login.html` in your custom app
2. Design your login UI:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Your Company Portal</title>
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: 'Arial', sans-serif;
        }
        .login-container {
            max-width: 400px;
            margin: 100px auto;
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo img {
            max-width: 200px;
        }
        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="logo">
            <img src="/files/your-logo.png" alt="Your Company">
        </div>
        <h2>Welcome Back</h2>
        <form id="login-form">
            <input type="text" placeholder="Username" name="usr">
            <input type="password" placeholder="Password" name="pwd">
            <button type="submit">Sign In</button>
        </form>
    </div>
</body>
</html>
```

3. **Set as default login page in hooks.py:**

```python
website_route_rules = [
    {"from_route": "/login", "to_route": "your_custom_login"},
]
```

**Visual result:** Custom branded login page.

---

## **5. Custom DocType Forms**

### **Fully Customize Any Form**

For each DocType (Lead, Opportunity, etc.):

1. Open DocType → "Customize Form"
2. **Customize:**
   - Field layout (sections, columns)
   - Field labels
   - Field colors/styling
   - Hide/show fields based on roles
   - Add custom HTML sections
   - Add custom buttons

**Example: Custom Lead Form**

```
┌─────────────────────────────────────────────────────┐
│  Lead: John Doe                           [Save]    │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Contact Information                                │
│  ┌──────────────────────┬──────────────────────┐   │
│  │ Name: [John Doe    ] │ Email: [john@...   ] │   │
│  │ Phone: [555-1234   ] │ Company: [Acme     ] │   │
│  └──────────────────────┴──────────────────────┘   │
│                                                     │
│  Lead Details                                       │
│  Status: [Qualified ▼]  Source: [Website ▼]       │
│                                                     │
│  Notes:                                             │
│  [Rich text editor with your branding...]          │
│                                                     │
│  [Convert to Opportunity]  [Send Email]            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## **6. Custom Pages & Views**

### **Create Standalone Pages**

Build custom pages for specific workflows:

1. Create a "Page" DocType
2. Add custom HTML/JS/CSS
3. Link from sidebar or workspace

**Example: Custom Dashboard Page**

```javascript
frappe.pages['sales-dashboard'].on_page_load = function(wrapper) {
    var page = frappe.ui.make_app_page({
        parent: wrapper,
        title: 'Sales Dashboard',
        single_column: true
    });
    
    // Custom HTML
    $(page.body).html(`
        <div class="dashboard-container">
            <div class="metric-card">
                <h3>Total Leads</h3>
                <div class="metric-value">245</div>
            </div>
            <div class="metric-card">
                <h3>Opportunities</h3>
                <div class="metric-value">$1.2M</div>
            </div>
        </div>
    `);
    
    // Load data via API
    frappe.call({
        method: 'your_app.api.get_sales_metrics',
        callback: function(r) {
            // Update with real data
        }
    });
}
```

---

## **7. Remove Frappe Branding**

### **Hide "Powered by Frappe"**

1. **CSS Method (Quick):**

```css
/* Hide footer branding */
.footer-powered,
.powered-by,
.frappe-brand {
    display: none !important;
}

/* Hide help menu Frappe links */
.dropdown-help .frappe-docs {
    display: none !important;
}
```

2. **Template Override (Complete):**

Override `templates/includes/footer/footer.html`:

```html
<footer class="custom-footer">
    <p>&copy; 2026 Your Company. All rights reserved.</p>
</footer>
```

---

## **8. Custom Email Templates**

Make emails match your brand:

1. Search → "Email Template"
2. Create templates with your branding:

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; }
        .header { background: #YOUR_COLOR; padding: 20px; }
        .header img { max-width: 150px; }
    </style>
</head>
<body>
    <div class="header">
        <img src="YOUR_LOGO_URL" alt="Your Company">
    </div>
    <div class="content">
        {{ message }}
    </div>
    <div class="footer">
        <p>Your Company | yourcompany.com</p>
    </div>
</body>
</html>
```

---

## **9. Mobile Responsiveness**

Frappe is mobile-responsive by default, but you can enhance:

```css
/* Custom mobile styles */
@media (max-width: 768px) {
    .navbar-brand img {
        max-width: 120px;
    }
    
    .desk-sidebar {
        display: none; /* Hide on mobile */
    }
    
    /* Custom mobile menu */
    .mobile-menu {
        display: block;
    }
}
```

---

## **10. Integration Examples**

### **Embed in Your Website**

Use iframe or custom integration:

```html
<!-- Embed Frappe portal in your website -->
<iframe src="https://portal.yourcompany.com" 
        width="100%" 
        height="800px"
        frameborder="0">
</iframe>
```

### **SSO Integration**

Integrate with your existing auth:

```python
# Custom SSO
@frappe.whitelist(allow_guest=True)
def custom_login(token):
    # Validate token with your auth service
    user = validate_sso_token(token)
    frappe.local.login_manager.login_as(user)
```

---

## **Complete White-Label Checklist**

- [ ] Upload company logo
- [ ] Set custom app name
- [ ] Apply brand colors (CSS)
- [ ] Create custom home workspace
- [ ] Hide unwanted modules
- [ ] Rename modules to match your terminology
- [ ] Customize login page
- [ ] Remove "Powered by Frappe"
- [ ] Create custom email templates
- [ ] Customize DocType forms
- [ ] Add custom pages/dashboards
- [ ] Set up custom domain

---

## **Result**

**Before:** Generic Frappe interface  
**After:** Fully branded "Your Company Portal" that looks like a custom enterprise application

**Users will never know it's built on Frappe!**

---

## **Time Investment**

- Basic branding (logo, colors): **30 minutes**
- Custom workspace/home: **1-2 hours**
- Full white-label: **1 day**
- Advanced customization: **Ongoing as needed**

**It's worth it** - you get a professional, branded application that looks custom-built for your company!
