# Makefile for Medusa Backend
# Two versions: clean database and keep data

.PHONY: help dev dev-clean dev-keep stop clean install

# Default target
help:
	@echo "Available commands:"
	@echo "  make dev-clean  - Start backend with clean database (no confirmations)"
	@echo "  make dev-keep   - Start backend keeping existing data (no confirmations)"
	@echo "  make stop      - Stop all services"
	@echo "  make clean      - Clean all data and stop services"
	@echo "  make install    - Install dependencies"

# Start backend with clean database (no confirmations)
dev-clean:
	@echo "Starting backend with clean database..."
	@cd medusa && docker-compose down -v --remove-orphans
	@cd medusa && docker-compose up -d postgres redis minio meilisearch createbuckets
	@echo "Waiting for services to be ready..."
	@sleep 10
	@cd medusa && yarn install
	@cd medusa && yarn build
	@cd medusa && yarn medusa db:migrate
	@cd medusa && yarn seed
	@cd medusa && yarn medusa user -e "admin@medusa.local" -p "supersecret"
	@cd medusa && yarn dev

# Start backend keeping existing data (no confirmations)
dev-keep:
	@echo "Starting backend keeping existing data..."
	@cd medusa && docker-compose up -d postgres redis minio meilisearch createbuckets
	@echo "Waiting for services to be ready..."
	@sleep 10
	@cd medusa && yarn install
	@cd medusa && yarn build
	@cd medusa && yarn dev

# Stop all services
stop:
	@echo "Stopping all services..."
	@cd medusa && docker-compose down

# Clean all data and stop services
clean:
	@echo "Cleaning all data and stopping services..."
	@cd medusa && docker-compose down -v --remove-orphans
	@docker system prune -f

# Install dependencies
install:
	@echo "Installing dependencies..."
	@cd medusa && yarn install
