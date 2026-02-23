#!/usr/bin/env python3
"""
Update Frappe Website Settings with Chateau Orchestrator branding
"""
import frappe

def update_website_settings():
    """Update website settings with custom logo"""
    frappe.init(site='orchestrator.local')
    frappe.connect()
    
    # Get Website Settings
    doc = frappe.get_doc('Website Settings', 'Website Settings')
    
    # Update branding
    doc.app_name = 'Chateau Orchestrator'
    doc.app_logo = '/assets/orchestrator_theme/images/logo.png'
    doc.favicon = '/assets/orchestrator_theme/images/favicon.png'
    doc.brand_html = 'Chateau Orchestrator'
    
    # Hide footer
    doc.hide_footer_signup = 1
    
    # Save
    doc.save()
    frappe.db.commit()
    
    print("✅ Website Settings updated!")
    print(f"   App Name: {doc.app_name}")
    print(f"   Logo: {doc.app_logo}")
    print(f"   Favicon: {doc.favicon}")

if __name__ == '__main__':
    update_website_settings()
