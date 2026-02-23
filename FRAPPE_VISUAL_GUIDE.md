# 🎓 Frappe Visual Walkthrough - Complete Guide

**Your Frappe is running at: http://localhost:8000**

Since browser control isn't available, here's a detailed visual guide of what you'll see and how to navigate everything.

---

## 📱 **Login Screen (First Thing You'll See)**

```
┌─────────────────────────────────────────────┐
│                                             │
│            [Frappe Logo]                    │
│                                             │
│     Username: [Administrator          ]    │
│     Password: [admin123               ]    │
│                                             │
│            [Login Button]                   │
│                                             │
└─────────────────────────────────────────────┘
```

**Enter:**
- Username: `Administrator`
- Password: `admin123`
- Click **Login**

---

## 🏠 **Home Screen (After Login)**

You'll see:

```
┌─────────────────────────────────────────────────────────────┐
│ [☰ Menu] [Search: Ctrl+K]           [🔔] [?] [👤 Admin] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Welcome to Frappe                                          │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Desk      │  │   Tools     │  │  Settings   │        │
│  │             │  │             │  │             │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│                                                             │
│  Quick Access:                                              │
│  • DocType List                                             │
│  • User List                                                │
│  • Website                                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Click the big "Desk" button to enter the application.**

---

## 🎯 **Desk View (Your Main Workspace)**

```
┌─────────────────────────────────────────────────────────────────┐
│ [Search: Ctrl+K]              [🔔] [?] [👤 Administrator]    │
├──────────┬──────────────────────────────────────────────────────┤
│          │                                                      │
│ Modules  │   Workspace                                          │
│          │                                                      │
│ • Home   │   ┌──────────────────────────────────────┐          │
│ • Build  │   │  Shortcuts                           │          │
│ • CRM    │   │  • DocType List                     │          │
│ • Setup  │   │  • Report Builder                   │          │
│ • Tools  │   │  • Dashboard                        │          │
│          │   └──────────────────────────────────────┘          │
│          │                                                      │
│          │   Recent Documents                                   │
│          │   (empty for now)                                    │
│          │                                                      │
└──────────┴──────────────────────────────────────────────────────┘
```

**Key Elements:**

1. **Search Bar (Top)**: Press `Ctrl+K` or `Cmd+K` - searches EVERYTHING
2. **Left Sidebar**: Modules (collapsible)
3. **Main Area**: Workspace with shortcuts
4. **Top-Right**: Notifications, Help, User menu

---

## 🔍 **The Most Important Feature: SEARCH (Awesome Bar)**

**Click the search bar or press Ctrl+K:**

```
┌─────────────────────────────────────────────┐
│ Search: doctypes, pages, reports...        │
│                                             │
│ Recent:                                     │
│ • DocType List                              │
│ • User                                      │
│                                             │
│ Suggestions:                                │
│ • Create DocType                            │
│ • Dashboard                                 │
│ • Report Builder                            │
│ • Workspace                                 │
│                                             │
└─────────────────────────────────────────────┘
```

**Type anything to search:**
- `"doctype"` → Opens DocType List
- `"user"` → Opens User management
- `"report"` → Shows all reports
- `"dashboard"` → Opens dashboards

**This is your main navigation tool!**

---

## 🛠️ **Creating Your First DocType: The "Lead" Example**

### **Step 1: Open DocType List**

1. Press `Ctrl+K` (or click search bar)
2. Type: `doctype list`
3. Click **"DocType List"**

You'll see a table of all DocTypes:

```
┌─────────────────────────────────────────────────────────────┐
│ DocType List                               [+ New]          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Name                  │ Module    │ Custom │ Istable       │
│ ─────────────────────────────────────────────────────────── │
│ User                  │ Core      │ No     │ No            │
│ Role                  │ Core      │ No     │ No            │
│ DocType               │ Core      │ No     │ No            │
│ ...                   │ ...       │ ...    │ ...           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### **Step 2: Click "+ New" (Top-Right)**

You'll see the DocType creation form:

```
┌─────────────────────────────────────────────────────────────┐
│ New DocType                                    [Save] [Cancel]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Name*: [Lead                                          ]     │
│ Module: [CRM ▼                                        ]     │
│                                                             │
│ ┌─ Options ─────────────────────────────────────────────┐  │
│ │ ☐ Is Submittable                                     │  │
│ │ ☐ Is Table                                           │  │
│ │ ☐ Is Single                                          │  │
│ │ ☑ Track Changes                                      │  │
│ └──────────────────────────────────────────────────────┘  │
│                                                             │
│ ┌─ Fields ──────────────────────────────────────────────┐  │
│ │                                          [+ Add Row]  │  │
│ │ Label      │ Type    │ Name       │ Options           │  │
│ │ ────────────────────────────────────────────────────  │  │
│ │ (empty table - add your fields here)                 │  │
│ │                                                       │  │
│ └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### **Step 3: Fill in Basic Info**

**Name:** `Lead`  
**Module:** Select "CRM" (or click "+ New Module" to create one)

### **Step 4: Add Fields**

Click **"+ Add Row"** in the Fields section for each field:

**Field 1:**
- Label: `Lead Name`
- Type: `Data`
- Name: `lead_name` (auto-filled)
- Mandatory: ✓ (check the box)

**Field 2:**
- Label: `Email`
- Type: `Data`
- Name: `email`

**Field 3:**
- Label: `Phone`
- Type: `Data`
- Name: `phone`

**Field 4:**
- Label: `Company`
- Type: `Data`
- Name: `company`

**Field 5:**
- Label: `Status`
- Type: `Select`
- Name: `status`
- Options: (click "Options" field and enter)
  ```
  New
  Contacted
  Qualified
  Lost
  ```

**Field 6:**
- Label: `Source`
- Type: `Select`
- Name: `source`
- Options:
  ```
  Website
  Referral
  Cold Call
  Partner
  ```

**Field 7:**
- Label: `Notes`
- Type: `Text Editor`
- Name: `notes`

### **Step 5: Click "Save" (Top-Right)**

**🎉 Congratulations! You just created your first DocType!**

---

## 📝 **Using Your New "Lead" DocType**

After saving, Frappe will ask: **"Would you like to view the list?"**

Click **"Yes"** and you'll see:

```
┌─────────────────────────────────────────────────────────────┐
│ Lead                                          [+ New]        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ 🔍 Search...                      [Filters ▼] [Export ▼]   │
│                                                             │
│ Name           │ Lead Name │ Email        │ Status         │
│ ─────────────────────────────────────────────────────────── │
│ (No records yet - click "+ New" to create your first lead) │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### **Create Your First Lead**

Click **"+ New"** and you'll see the form:

```
┌─────────────────────────────────────────────────────────────┐
│ New Lead                                      [Save] [Cancel]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Lead Name*: [John Doe                                 ]     │
│ Email:      [john@example.com                         ]     │
│ Phone:      [555-1234                                 ]     │
│ Company:    [Acme Corp                                ]     │
│ Status:     [New ▼                                    ]     │
│ Source:     [Website ▼                                ]     │
│ Notes:      [Interested in CRM software               ]     │
│             [                                         ]     │
│                                                             │
│                                   [Save]                     │
└─────────────────────────────────────────────────────────────┘
```

Fill it out and click **Save**. Your first lead is created!

---

## 🎨 **Customizing the Form Layout**

Want to organize fields into sections?

1. Go back to **DocType List**
2. Open your **Lead** DocType
3. Look for **"Customize Form"** button (top-right)
4. Click it

You'll see:

```
┌─────────────────────────────────────────────────────────────┐
│ Customize Form: Lead                          [Update]       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Fields (drag to reorder):                                   │
│                                                             │
│ ☰ lead_name        [Data]       Mandatory                  │
│ ☰ email            [Data]                                  │
│ ☰ phone            [Data]                                  │
│ ☰ company          [Data]                                  │
│ ☰ status           [Select]                                │
│ ☰ source           [Select]                                │
│ ☰ notes            [Text]                                  │
│                                                             │
│ [+ Add Section Break]  [+ Add Column Break]                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Add Section Breaks:**

1. Click **"+ Add Section Break"** above `email`
2. Label it: "Contact Information"
3. Click **"+ Add Section Break"** above `status`
4. Label it: "Lead Details"

Now your form will be organized into sections!

---

## 📊 **Creating a Dashboard**

1. Press `Ctrl+K`
2. Type: `dashboard`
3. Click **"Dashboard"** → **"+ New"**

```
┌─────────────────────────────────────────────────────────────┐
│ New Dashboard                                 [Save]         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Dashboard Name: [Sales Dashboard                     ]     │
│ Module:         [CRM ▼                                ]     │
│                                                             │
│ Charts:                                     [+ Add Chart]   │
│                                                             │
│ (Click "+ Add Chart" to create visualizations)             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Add a Chart:**

1. Click **"+ Add Chart"**
2. Chart Name: `Leads by Status`
3. Chart Type: `Donut`
4. Document Type: `Lead`
5. Based On: `status`
6. Save

**Your dashboard will show a donut chart of leads by status!**

---

## 📈 **Creating a Report**

### **Option 1: Report Builder (No Code)**

1. Press `Ctrl+K`
2. Type: `report builder`
3. Click **"Report Builder"**

```
┌─────────────────────────────────────────────────────────────┐
│ Report Builder                                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Select DocType: [Lead ▼                               ]     │
│                                                             │
│ Columns (Select fields to show):                            │
│ ☑ Lead Name                                                 │
│ ☑ Email                                                     │
│ ☑ Phone                                                     │
│ ☑ Company                                                   │
│ ☑ Status                                                    │
│ ☐ Source                                                    │
│ ☐ Notes                                                     │
│                                                             │
│ Filters:                                    [+ Add Filter]  │
│ • Status = "Qualified"                                      │
│                                                             │
│ [Save Report]                                               │
└─────────────────────────────────────────────────────────────┘
```

### **Option 2: Query Report (SQL)**

1. Press `Ctrl+K`
2. Type: `query report`
3. Click **"+ New"**

```sql
SELECT 
    name as "Lead:Link/Lead:200",
    lead_name as "Name:Data:150",
    email as "Email:Data:200",
    company as "Company:Data:150",
    status as "Status::100"
FROM `tabLead`
WHERE status = 'Qualified'
ORDER BY creation DESC
```

---

## 🔒 **Setting Permissions**

1. Go to your **Lead DocType**
2. Scroll down to **"Permission Rules"** section

```
┌─────────────────────────────────────────────────────────────┐
│ Permission Rules                             [+ Add]        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Role          │ Read │ Write │ Create │ Delete │ Submit     │
│ ──────────────────────────────────────────────────────────  │
│ System Manager │  ✓   │   ✓   │   ✓    │   ✓    │   ✓       │
│ Sales Manager  │  ✓   │   ✓   │   ✓    │   ✓    │   -       │
│ Sales User     │  ✓   │   ✓   │   ✓    │   -    │   -       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Click **"+ Add"** to add permissions for different roles.

---

## 💡 **Quick Tips for Navigation**

### **Keyboard Shortcuts**

- `Ctrl+K` or `Cmd+K`: Global search (MOST IMPORTANT!)
- `Ctrl+G`: Go to list
- `Ctrl+S`: Save current form
- `Ctrl+B`: Toggle sidebar
- `Esc`: Close dialog/go back

### **Common Searches**

Type these in the search bar (Ctrl+K):

- `"doctype list"` → Manage DocTypes
- `"user"` → User management
- `"role"` → Role permissions
- `"dashboard"` → Dashboards
- `"report"` → Reports
- `"workspace"` → Customize workspace
- `"system settings"` → System config
- `"customize form"` → Customize any form
- `"server script"` → Add Python logic
- `"client script"` → Add JavaScript

### **Understanding the Sidebar**

The left sidebar shows **Modules**:

- **Home**: Overview
- **CRM**: Your CRM DocTypes (once created)
- **HR**: HR-related DocTypes
- **Tools**: Developer tools
- **Settings**: System configuration

Click any module to see its DocTypes and pages.

---

## 🎯 **Your Next Steps**

### **Immediate Actions:**

1. **Login** to http://localhost:8000
2. **Click "Desk"**
3. **Press Ctrl+K** and type "doctype list"
4. **Create your first DocType** following the steps above
5. **Add some test data**
6. **Create a dashboard** to visualize it

### **30-Minute Challenge:**

Build a mini-CRM:
- ✓ Lead DocType (done above)
- Create Opportunity DocType (link to Lead)
- Create Contact DocType
- Build a sales dashboard
- Add a report

**You'll have a functional CRM by the end!**

---

## 🆘 **Troubleshooting**

### **Problem: Can't find something**

**Solution:** Use the search bar (Ctrl+K). It searches EVERYTHING.

### **Problem: DocType not showing in list**

**Solution:**
1. Clear cache: `bench clear-cache` in WSL
2. Restart: `bench restart`
3. Refresh browser

### **Problem: Changes not appearing**

**Solution:**
1. Click "Reload" in browser
2. Run `bench build` if changing JavaScript/CSS
3. Run `bench migrate` if changing database structure

### **Problem: Permission denied**

**Solution:** You're logged in as Administrator, so you have all permissions. If creating roles later, manage permissions in DocType → Permission Rules.

---

## 📚 **Learning Resources**

### **Inside Frappe**

- Click **"?"** (top-right) → Documentation
- Search for **"Getting Started"**
- Explore the **"Learn"** workspace

### **External**

- Official Docs: https://frappeframework.com/docs/v15
- Forum: https://discuss.frappe.io
- YouTube: Search "Frappe Framework Tutorial"

---

## ✅ **Checklist: What You Should See**

When you open http://localhost:8000:

- [ ] Login screen
- [ ] After login: Home with "Desk" button
- [ ] In Desk: Search bar at top
- [ ] Left sidebar with modules
- [ ] Main workspace area
- [ ] Can search for "DocType List"
- [ ] Can create new DocTypes

**If you see all that, you're ready to build!**

---

## 🎉 **You're Ready!**

**Frappe is:**
- ✅ Running
- ✅ Accessible at http://localhost:8000
- ✅ Ready to build your CRM/HR/Helpdesk

**What makes Frappe powerful:**
- Create data models (DocTypes) visually
- Auto-generated UI (lists, forms, reports)
- Built-in REST API for every DocType
- Python for backend, JavaScript for frontend
- Permissions, workflows, dashboards all included

**Go build something!** Start with the Lead DocType above, then expand from there.

---

**Questions? Just describe what you see on screen and I'll guide you!**
