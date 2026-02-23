"""
Boot session customizations for Chateau Orchestrator
"""
import frappe

def boot_session(bootinfo):
    """
    Customize boot info - called on every desk login
    """
    # Custom branding
    bootinfo["app_name"] = "Chateau Orchestrator"
    bootinfo["app_logo_url"] = "/assets/orchestrator_theme/images/logo.png"
    
    # Hide Frappe branding
    bootinfo["hide_footer_branding"] = True
    
    # Custom home page
    bootinfo["home_page"] = "Workspace"
    
    return bootinfo
