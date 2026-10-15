# 30 Days of Docker + Kubernetes

A beginner DevOps learning project: take one small app and progressively
containerize it, orchestrate it, and automate its deployment — one commit a day
for 30 days.

## What this project covers
- **Week 1** — Docker basics: Dockerfile, image building, Docker Hub
- **Week 2** — Multi-container apps with Docker Compose
- **Week 3** — Deploying to Kubernetes with Minikube
- **Week 4** — Scaling, health checks, CI/CD with GitHub Actions, Helm

Full day-by-day plan: [`docs/ROADMAP.md`](docs/ROADMAP.md)

## The app
A minimal Node.js/Express API with two routes:
- `GET /` — returns a JSON greeting + the container hostname (handy later for
  seeing load balancing across replicas)
- `GET /health` — health check endpoint used by Docker and Kubernetes probes

## Running locally (no Docker)
```bash
npm install
npm start
# visit http://localhost:3000
```

## Running with Docker (from Day 2 onward)
```bash
docker build -t 30-days-app .
docker run -p 3000:3000 30-days-app
```

## Docker Hub
The image is published at `donlenasenesh/30-days-app`.

Pull and run it:

```bash
docker pull YOUR_DOCKERHUB_USERNAME/30-days-app:latest
docker run -p 3000:3000 YOUR_DOCKERHUB_USERNAME/30-days-app:latest
```

## Progress log
See `docs/week1.md`, `docs/week2.md`, `docs/week3.md`, `docs/week4.md` as they
get filled in throughout the month, plus `docs/retrospective.md` at the end.

## Bonus Week 5 (optional)
Want to go further after Day 30? [`docs/BONUS-WEEK5.md`](docs/BONUS-WEEK5.md)
adds a local, 100%-free Jenkins + SonarQube + ArgoCD pipeline — the same
stack used in popular "real-world DevOps project" tutorials, but run on
Minikube instead of a paid AWS EKS cluster.

## Note on the `templates/` folder
Files in `templates/` are **not part of the live app yet** — they're staged
for later days so you don't accidentally commit Week 3/4 content on Day 1.
Move each file into place on its scheduled day per the roadmap, per the
comment at the top of each file.


## Additional

## Configuration
The app is configured with environment variables:

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `3000` | Port the app listens on |
| `APP_MESSAGE` | `Hello from the 30 Days of Docker + Kubernetes project!` | Greeting returned by `GET /` |

```bash
docker run -p 3000:3000 -e APP_MESSAGE="Hello!" 30-days-app
docker run -p 3000:3000 --env-file .env 30-days-app
```
## Running with Docker Compose
Starts the app and a Postgres database together:

```bash
docker compose up --build
```

Stop and remove the containers:

```bash
docker compose down
```
Check the database connection at `http://localhost:3000/db`.

Visit `http://localhost:3000/visits` to see a counter stored in Postgres. The data lives in the `db_data` volume and survives `docker compose down`. Use `docker compose down -v` to wipe it.

## Setup
Create your own environment file before running with Docker Compose:

```bash
cp .env.example .env
```

Then edit `.env` and set your own values. The `.env` file is ignored by git and must never be committed.