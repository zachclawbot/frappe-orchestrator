from setuptools import setup, find_packages

with open("requirements.txt") as f:
    install_requires = f.read().splitlines()

setup(
    name="orchestrator-crm",
    version="0.1.0",
    description="Customer Relationship Management module for Frappe Orchestrator",
    author="Orchestrator Team",
    author_email="team@orchestrator.local",
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=install_requires,
    python_requires=">=3.8",
)
