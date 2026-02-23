# Makefile for Frappe Orchestrator

.PHONY: help setup up down logs restart clean sync-schema lint test build deploy

help:
	@echo "Frappe Orchestrator - Available Commands"
	@echo "========================================"
	@echo "make setup              - Initialize project (create .env, certs, etc)"
	@echo "make up                 - Start all Docker services"
	@echo "make down               - Stop all Docker services"
	@echo "make logs               - View application logs (follow mode)"
	@echo "make logs-db            - View MariaDB logs"
	@echo "make restart            - Restart all services"
	@echo "make clean              - Remove containers and volumes (DESTRUCTIVE)"
	@echo "make migrate            - Run database migrations"
	@echo "make shell              - Start Frappe shell"
	@echo "make console            - Start Python console"
	@echo "make test               - Run test suite"
	@echo "make lint               - Check code style"
	@echo "make install-app APP    - Install custom app (e.g., make install-app APP=orchestrator-crm)"
	@echo "make list-apps          - List installed apps"
	@echo "make backup             - Backup database"
	@echo "make restore FILE       - Restore database from file"
	@echo "make setup-dev          - Setup development environment"
	@echo ""

setup:
	@echo "Setting up Frappe Orchestrator..."
	cp .env.example .env
	mkdir -p docker/ssl
	@echo "Generating self-signed SSL certificates..."
	openssl req -x509 -newkey rsa:4096 -nodes \
		-out docker/ssl/cert.pem -keyout docker/ssl/key.pem -days 365 \
		-subj "/C=US/ST=CA/L=San Francisco/O=Orchestrator/CN=frappe-orchestrator.local"
	@echo "✓ Setup complete! Run 'make up' to start services."

setup-dev: setup
	@echo "Setting up development environment..."
	cd docker && docker-compose build --no-cache
	cd docker && docker-compose up -d
	sleep 10
	cd docker && docker-compose exec frappe bash -c "bench --site frappe-orchestrator.local migrate"
	@echo "✓ Development environment ready!"
	@echo "Access at: http://localhost:8000"
	@echo "Admin: admin / admin123"

up:
	cd docker && docker-compose up -d
	@echo "✓ Services started"
	@echo "Waiting for database to be ready..."
	sleep 5
	cd docker && docker-compose exec frappe echo "✓ Frappe app is ready"

down:
	cd docker && docker-compose down
	@echo "✓ Services stopped"

logs:
	cd docker && docker-compose logs -f frappe

logs-db:
	cd docker && docker-compose logs -f mariadb

logs-nginx:
	cd docker && docker-compose logs -f nginx

restart:
	cd docker && docker-compose restart frappe
	@echo "✓ Frappe service restarted"

clean:
	@echo "WARNING: This will delete all data!"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd docker && docker-compose down -v; \
		echo "✓ Cleaned up all containers and volumes"; \
	fi

migrate:
	cd docker && docker-compose exec frappe bash -c "bench --site frappe-orchestrator.local migrate"
	@echo "✓ Migrations complete"

shell:
	cd docker && docker-compose exec frappe bench --site frappe-orchestrator.local shell

console:
	cd docker && docker-compose exec frappe bench --site frappe-orchestrator.local console

test:
	cd docker && docker-compose exec frappe bash -c "bench --site frappe-orchestrator.local run-tests"
	@echo "✓ Tests complete"

lint:
	cd docker && docker-compose exec frappe bash -c "flake8 apps/ --max-line-length=120 --ignore=E501,W503"
	@echo "✓ Linting complete"

install-app:
	@if [ -z "$(APP)" ]; then \
		echo "Usage: make install-app APP=app-name"; \
		exit 1; \
	fi
	cd docker && docker-compose exec frappe bash -c "bench get-app $(APP) && bench --site frappe-orchestrator.local install-app $(APP)"
	@echo "✓ App $(APP) installed"

list-apps:
	cd docker && docker-compose exec frappe bash -c "bench --site frappe-orchestrator.local list-apps"

backup:
	@mkdir -p backups
	cd docker && docker-compose exec mariadb mysqldump -u frappe -pFrappePassword123 frappe > backups/frappe_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✓ Database backed up"

restore:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make restore FILE=backups/file.sql"; \
		exit 1; \
	fi
	cd docker && docker-compose exec mariadb mysql -u frappe -pFrappePassword123 frappe < $(FILE)
	@echo "✓ Database restored"

ps:
	cd docker && docker-compose ps

build:
	cd docker && docker-compose build --no-cache frappe
	@echo "✓ Docker image rebuilt"

.DEFAULT_GOAL := help
