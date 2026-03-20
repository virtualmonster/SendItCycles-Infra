# SendIt Cycles — Infrastructure

Docker-based deployment configuration for **SendIt Cycles**. Contains everything needed to run the full stack (frontend, backend, optional PostgreSQL) in containers for local demos, dev, staging, and production environments.

---

## Quick Start — Full Stack Locally (SQLite, no database needed)

The fastest way to run the entire SendIt Cycles application locally:

```bash
# From this repo root
JWT_SECRET=local-secret docker compose -f docker-compose.demo.yml up --build
```

- Frontend: **http://localhost:3000**
- Backend API: **http://localhost:5000/api**
- API Docs: **http://localhost:5000/api-docs**

Uses SQLite — no PostgreSQL required.

---

## Quick Start — Full Stack with PostgreSQL

```bash
# From this repo root
docker compose up --build
```

This starts:
- PostgreSQL 15 database (auto-initialised from `server/database/init-postgres.sql`)
- Backend API on port 5000 (connected to PostgreSQL)
- Frontend on port 3000

The `docker-compose.yml` has hardcoded demo credentials. For production, replace them with environment variables or use the environment-specific configs below.

---

## Repository Structure

```
├── docker-compose.yml          # Full stack with PostgreSQL (demo/dev)
├── docker-compose.demo.yml     # Full stack with SQLite (zero-config demo)
├── environments/
│   ├── dev/                    # Dev environment — builds against internal image registry
│   │   ├── docker-compose.yml
│   │   ├── .env.dev            # Dev environment variables (loaded by deploy.sh)
│   │   └── config/
│   │       ├── nginx.conf              # Load balancer config
│   │       └── frontend-nginx.conf     # Frontend Nginx config
│   ├── staging/                # Staging environment
│   │   ├── docker-compose.yml
│   │   ├── .env.staging
│   │   └── config/
│   └── prod/                   # Production environment
│       ├── docker-compose.yml
│       ├── .env.prod
│       └── config/
└── scripts/
		└── deploy.sh               # GitOps deployment script
```

---

## Environment Configurations

The `environments/` subdirectories are designed for **CI/CD GitOps deployments** using pre-built images from the internal container registry. They are used by `scripts/deploy.sh` which sources the relevant `.env.*` file and runs docker compose.

```bash
# Deploy to dev (run from CI/CD or manually on a host with registry access)
./scripts/deploy.sh dev deploy

# Deploy to staging
./scripts/deploy.sh staging deploy

# Deploy to production
./scripts/deploy.sh prod deploy

# Roll back an environment
./scripts/deploy.sh prod rollback
```

> **Note:** The environment docker-compose files reference a private container image registry. They will not work without access to that registry. Use `docker-compose.yml` or `docker-compose.demo.yml` for local builds.

---

## Choosing a Database Backend

SendIt Cycles supports two database backends, controlled by the `USE_SQLITE` environment variable in the backend service.

| Mode | Set in compose | When to use |
|------|----------------|-------------|
| **SQLite** | `USE_SQLITE=true` | Local demos, quick tests, no external DB |
| **PostgreSQL** | `USE_SQLITE=false` (default) | Staging, production, persistent data |

`docker-compose.demo.yml` uses SQLite.
`docker-compose.yml` uses PostgreSQL.

---

## Architecture

```
Browser
	└── Nginx (port 3000)
				├── /* ──────────── Frontend container (React / Nginx)
				└── /api/* ───────── Backend container (Node.js / Express)
																	 └── SQLite file  OR  PostgreSQL container
```

---

## Security Scanning

The repo includes HCL AppScan SCA scripts for dependency vulnerability scanning:

```bash
# Authenticate and run SCA scan
bash run-appscan-sca.sh

# Diagnose AppScan connectivity issues
bash diagnose-appscan.sh
```

Trivy configuration for pull-request scanning is in `.devops-loop/code-config.jsonc`.
- `server/database/init-postgres.sql` - PostgreSQL database initialization
