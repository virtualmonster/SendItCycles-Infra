# SendIt Cycles — Infrastructure

Docker-based deployment configuration for **SendIt Cycles**. Contains everything needed to run the full stack (frontend, backend, optional PostgreSQL) in containers for local demos, dev, staging, and production environments.

## Start Here (Most Users)

If you are not a developer and just want to run SendIt Cycles, follow this exact path.

SendIt Cycles uses 3 repositories:

1. https://github.com/virtualmonster/SendItCycles-FrontEnd
2. https://github.com/virtualmonster/SendItCycles-BackEnd
3. https://github.com/virtualmonster/SendItCycles-Infra (this repo)

### 1. Prerequisites

Install these first:

1. `Git`
2. `Docker Desktop` (must include Docker Compose)

Before continuing, confirm Docker is running.

You need these ports free on your machine:

- `3000` (frontend)
- `5000` (backend API)
- `5432` (PostgreSQL, only when using PostgreSQL mode)

### 2. Create a local folder and clone repos

Use PowerShell on Windows:

```powershell
mkdir C:\SendItCycles
cd C:\SendItCycles

git clone https://github.com/virtualmonster/SendItCycles-Infra.git infra
cd infra

# Clone FrontEnd and BackEnd into the folder names expected by compose
git clone https://github.com/virtualmonster/SendItCycles-FrontEnd.git client
git clone https://github.com/virtualmonster/SendItCycles-BackEnd.git server
```

After cloning, your folder should look like this:

```text
C:\SendItCycles\infra\
	docker-compose.demo.yml
	docker-compose.yml
	client\   (SendItCycles-FrontEnd)
	server\   (SendItCycles-BackEnd)
```

### 3. Start SendIt Cycles (recommended mode)

From `C:\SendItCycles\infra` run:

```powershell
docker compose -f docker-compose.demo.yml up --build
```

This is SQLite mode and is the easiest way to run the app.

### 4. Open the app

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5000/api`
- API docs: `http://localhost:5000/api-docs`

### 5. Stop the app

In the same terminal, press `Ctrl+C`.

If containers remain running:

```powershell
docker compose -f docker-compose.demo.yml down
```

### 6. Optional: start with PostgreSQL instead of SQLite

From `C:\SendItCycles\infra`:

```powershell
docker compose up --build
```

Use this mode only if you specifically need PostgreSQL.

### Important Note About Repository Layout

The top-level compose files in this repo expect the frontend and backend code at:

- `./client`
- `./server`

If your local checkout uses separate sibling repos (`SendItCycles-FrontEnd`, `SendItCycles-BackEnd`), use your local wrapper compose setup or adjust build contexts before running these files.

### Infra Script Entry Point

For environment deployments (dev/staging/prod), use:

- `scripts/deploy.sh`

Example:

```bash
./scripts/deploy.sh dev deploy
```

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

## Environment Configurations (CI/CD)

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

> **Note:** The environment docker-compose files reference a private container image registry. They will not work without registry access.

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

## Repo Links

- Frontend repo: https://github.com/virtualmonster/SendItCycles-FrontEnd
- Backend repo: https://github.com/virtualmonster/SendItCycles-BackEnd
- Infra repo: https://github.com/virtualmonster/SendItCycles-Infra

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
