app_name = "orchestrator_theme"
app_title = "Orchestrator Theme"
app_publisher = "Chateau Health"
app_description = "Custom theme and branding for Chateau Orchestrator"
app_email = "dev@chateauhealth.com"
app_license = "mit"

# Includes in <head>
# ------------------

# Include custom CSS in header of desk.html (Frappe backend)
app_include_css = "/assets/orchestrator_theme/css/orchestrator.css"

# Include custom CSS in website (frontend portal)
web_include_css = [
    "https://fonts.googleapis.com/css2?family=Archivo:wght@400;500;600;700&display=swap",
    "/assets/orchestrator_theme/css/orchestrator.css"
]

# Website Settings
# ----------------
website_context = {
    "brand_html": "Chateau Orchestrator",
    "top_bar_items": [],
    "footer_items": []
}

# Boot Session
# ------------
boot_session = "orchestrator_theme.boot.boot_session"
