# Week 2: Docker Compose

## Day 8: The database service

- Moved `docker-compose.yml` to the project root
- Ran the app and Postgres together with `docker compose up --build`
- Queried the database with `docker compose exec db psql ...`

What I learned:
- Compose describes a multi-container app in one file, and one command starts it all
- Each entry under `services:` becomes a container; `build:` builds from a Dockerfile, `image:` pulls a ready-made one
- Compose creates a private network, so containers reach each other by service name (`db`, not an IP)
- The Postgres image creates the user and database from its `POSTGRES_*` variables on first start
- `docker compose down` removes containers and the network but keeps named volumes
- `depends_on` controls start order only; it doesn't wait for the database to be ready (to handle on Day 9)