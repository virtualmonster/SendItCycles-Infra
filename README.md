# CycleShop Infrastructure

Infrastructure as Code for deploying the CycleShop application.

## Contents

- `docker-compose.yml` - Standard Docker Compose configuration
- `docker-compose.demo.yml` - Demo environment configuration
- `environments/` - Environment-specific configurations (dev, staging, prod)
- `scripts/` - Deployment and utility scripts

## Deployment

### Development Environment

```bash
cd environments/dev
docker compose up -d
```

### Staging Environment

```bash
cd environments/staging
docker compose up -d
```

### Production Environment

```bash
cd environments/prod
docker compose up -d
```

## Architecture

The application uses a load-balanced architecture:
- Nginx load balancer (port 3000)
- Frontend service (React app on port 80)
- Backend API service (Node.js on port 3001)
- SQLite database

## Configuration

Each environment contains:
- `docker-compose.yml` - Service definitions
- `config/nginx.conf` - Load balancer configuration
- `config/frontend-nginx.conf` - Frontend web server configuration
- `config/init.sql` - Database initialization
