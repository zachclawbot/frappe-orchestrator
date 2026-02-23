# Creating Your First Frappe DocType - Complete Walkthrough

**Time to complete:** 10 minutes  
**What you'll build:** A "Lead" DocType for CRM  
**Current status:** Frappe is running at http://localhost:8000

---

## ✅ **What We Just Saw (Screenshots Captured)**

I successfully navigated Frappe with you and we saw:

1. ✅ **DocType List** - Showing all 266 existing DocTypes
2. ✅ **Create New DocType Dialog** - Where you name and configure your DocType
3. ✅ **Module Selection** - We discovered CRM module needs to be created first

---

## 🎯 **The Right Way to Create a "Lead" DocType**

### **Option A: Use "Custom" Module (Fastest - Do This Now)**

Since the CRM module doesn't exist yet, use the built-in "Custom" module for your first DocType:

**Steps:**

1. **Click "+ Add DocType"** (you were just there!)

2. **Fill in:**
   - **Name:** `Lead`
   - **Module:** Type "Custom" and select it from dropdown

3. **Click "Create & Continue"**

4. **You'll see the DocType designer** - this is where you add fields!

---

### **Adding Fields to Your "Lead" DocType**

Once you click "Create & Continue", you'll see a form with tabs. Look for the **"Fields"** section (it's a table with columns).

**Click "+ Add Row"** for each field below:

| Label | Type | Options | Mandatory |
|-------|------|---------|-----------|
| Lead Name | Data | | ✓ |
| Email | Data | | |
| Phone | Data | | |
| Company | Data | | |
| Status | Select | New<br>Contacted<br>Qualified<br>Lost | ✓ |
| Source | Select | Website<br>Referral<br>Cold Call<br>Partner | |
| Notes | Text Editor | | |

**How to add a "Select" field with options:**

1. Set Type = "Select"
2. In the "Options" column, click and enter each option on a **new line**:
   ```
   New
   Contacted
   Qualified
   Lost
   ```

**After adding all fields, click "Save"** (top-right green button)

---

## 🎉 **What Happens Next**

After saving:

1. **Frappe creates:**
   - Database table: `tabLead`
   - List view at `/app/lead`
   - Form view for create/edit
   - REST API endpoints

2. **You can now:**
   - View the Lead list (will be empty)
   - Click "+ New" to create your first lead
   - Start tracking prospects!

---

## 📸 **Visual Reference From Our Browser Session**

**Screenshot 1: DocType List**
![DocType List](C:\Users\zacha\.openclaw\media\browser\4b5820b4-9d51-4bf4-bb23-ef147afe11bc.png)

This shows the DocType List with 266 existing DocTypes. Click "+ Add DocType" button (top-right).

**Screenshot 2: Create Dialog**
![Create Dialog](C:\Users\zacha\.openclaw\media\browser\eaa01299-83cc-4a8e-bf0e-7469d23cce81.png)

The creation dialog where you name your DocType and select the module.

**Screenshot 3: Module Error**
![Module Error](C:\Users\zacha\.openclaw\media\browser\495ad589-24c9-4944-9a3d-806c1fc46c70.png)

This error appears if you try to use a non-existent module like "CRM". Solution: Use "Custom" instead!

---

## 🔄 **After Creating Your First DocType**

### **Test It:**

1. Search for "Lead" in the awesome bar (Ctrl+K)
2. Click "Lead" to open the list
3. Click "+ New" to create your first lead:
   - Lead Name: "John Doe"
   - Email: "john@example.com"
   - Company: "Acme Corp"
   - Status: "New"
   - Source: "Website"
4. Click "Save"

**Congrats! You just created your first lead!** 🎉

---

## 📝 **Understanding What You're Seeing**

### **DocType Designer (After clicking "Create & Continue")**

```
┌─────────────────────────────────────────────────────────┐
│ Lead                                         [Save]     │
├─────────────────────────────────────────────────────────┤
│ [Details] [Naming] [Fields] [Form Settings] [...]       │
│                                                         │
│ Fields:                                  [+ Add Row]    │
│ ┌───────────────────────────────────────────────────┐  │
│ │ Label    │ Type   │ Name      │ Options   │ Req   │  │
│ ├───────────────────────────────────────────────────┤  │
│ │          │        │           │           │       │  │  ← Add fields here
│ │          │        │           │           │       │  │
│ └───────────────────────────────────────────────────┘  │
│                                                         │
│ Permission Rules:                                       │
│ ...                                                     │
└─────────────────────────────────────────────────────────┘
```

**Key sections:**

- **Fields tab:** Define your data structure
- **Naming tab:** How records are named (auto by default)
- **Form Settings:** Layout customization
- **Permission Rules:** Who can see/edit

---

## 🚀 **Next Steps After Your First DocType**

### **Create More DocTypes:**

1. **Opportunity** (links to Lead)
2. **Contact** 
3. **Company**

### **Build a Dashboard:**

1. Search for "Dashboard"
2. Create "Sales Dashboard"
3. Add charts for Leads by Status

### **Create a Report:**

1. Search for "Report Builder"
2. Select DocType: Lead
3. Choose columns to display
4. Save as "Qualified Leads Report"

---

##Tips & Tricks**

### **Keyboard Shortcuts:**

- `Ctrl+K`: Global search (use this constantly!)
- `Ctrl+S`: Save current form
- `Esc`: Close dialogs

### **Common Field Types:**

- **Data:** Short text (name, email, phone)
- **Text Editor:** Long text with formatting (notes, description)
- **Select:** Dropdown (status, category)
- **Link:** Reference to another DocType (Lead → Company)
- **Check:** Yes/No checkbox
- **Date:** Date picker
- **Currency:** Money amount
- **Percent:** Percentage value

### **Linking DocTypes:**

To create a relationship (e.g., Opportunity → Lead):

1. In Opportunity DocType, add a field:
   - Type: **Link**
   - Options: `Lead` (the DocType name)
2. This creates a dropdown that lets you select a Lead!

---

## ❓ **Troubleshooting**

**Problem:** Can't find the "+ Add Row" button

**Solution:** Make sure you're on the "Fields" tab in the DocType designer.

**Problem:** "Module not found" error

**Solution:** Use "Custom" module for all your DocTypes for now. You can create a CRM module later.

**Problem:** Changes not saving

**Solution:** Click the green "Save" button (top-right). Look for the success message.

**Problem:** Field not showing in form

**Solution:** After adding fields, save the DocType, then reload the page (F5).

---

## ✅ **Success Checklist**

- [ ] Created "Lead" DocType
- [ ] Added 7 fields (name, email, phone, company, status, source, notes)
- [ ] Saved the DocType
- [ ] Created your first lead record
- [ ] Viewed the lead in list view

**Once you check all these, you're ready to build more!**

---

**You're now building your own CRM system!** Each DocType you create becomes a fully functional database table with UI, API, and permissions. That's the power of Frappe.

**Ready for more?** Follow the same process to create Opportunity, Contact, and Company DocTypes. Then link them together with "Link" fields!
