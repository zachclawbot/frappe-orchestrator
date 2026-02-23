import frappe

frappe.init(site='orchestrator.local')
frappe.connect()

doc = frappe.get_doc('Website Settings', 'Website Settings')
doc.app_name = 'Chateau Orchestrator'
doc.app_logo = '/assets/orchestrator_theme/images/logo.png'
doc.favicon = '/assets/orchestrator_theme/images/favicon.png'
doc.brand_html = 'Chateau Orchestrator'
doc.hide_footer_signup = 1
doc.save()
frappe.db.commit()
print('✅ Logo and branding updated successfully!')
print('   App Name:', doc.app_name)
print('   Logo:', doc.app_logo)
print('   Favicon:', doc.favicon)
