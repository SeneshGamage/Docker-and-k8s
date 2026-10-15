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

## Day 9: App and database talking

- Installed the `pg` library and added a `/db` route that runs a query
- The app reads the connection string from `DATABASE_URL`
- Verified the connection at `/db`, then stopped and restarted the `db` service to see the failure and recovery

### Debugging the database connection

#### Commands used:

```bash
PS D:\30-days-docker-k8s> docker compose stop db
[+] Stopping 1/1
 ✔ Container 30-days-docker-k8s-db-1  Stopped                                                                                               0.2s 
PS D:\30-days-docker-k8s> docker compose start db
[+] Running 1/1
 ✔ Container 30-days-docker-k8s-db-1  Started                                                                                               0.3s 
PS D:\30-days-docker-k8s> docker compose exec app nslookup db
Server:         127.0.0.11
Address:        127.0.0.11:53

Non-authoritative answer:
Name:   db
Address: 172.19.0.2

Non-authoritative answer:
```

#### What I learned:
- `docker compose stop <service>` stops a specific service without affecting others.
- `docker compose start <service>` restarts a stopped service without rebuilding it.
- `docker compose exec <service> <command>` runs a command inside a running container.
- The `nslookup` command can verify DNS resolution within the Compose network.
- Compose assigns a unique IP to each service, but services communicate using their names, not IPs.
- Containers in one Compose project share a private network and reach each other by service name (`db`)
- `DATABASE_URL` is `postgres://user:password@host:port/database`; the host is the service name
- `localhost` inside a container means that container itself, not my PC or another container
- `depends_on` only controls start order; it doesn't wait until the database is ready, so apps should handle a database that isn't up yet
- `npm ci` needs `package-lock.json` to match `package.json`, so I run `npm install` locally when adding a dependency

## Day 10: Persistent volume

- Added a `/visits` route that stores a row in Postgres on every visit
- Ran `docker compose down` and `up` and confirmed the visit count continued
- Ran `docker compose down -v` and confirmed the data was deleted

What I learned:
- A container's own filesystem is temporary: when the container is removed, its data goes with it
- A **volume** is storage managed by Docker that lives outside the container, so data survives removal and re-creation
- In Compose, `db_data:/var/lib/postgresql/data` connects the named volume to the folder where Postgres keeps its files
- `docker compose down` keeps volumes; `docker compose down -v` deletes them, so use `-v` carefully
- `docker volume ls` and `docker volume inspect` show what exists and where
- Volumes are how databases, uploads and other stateful data are kept in containers (and Kubernetes uses the same idea with PersistentVolumeClaims in Week 3)

### Commands and Observations

#### Commands Used:

```bash
# Check running services
docker compose ps

# Query the database
docker compose exec db psql -U postgres -d appdb -c "SELECT COUNT(*) FROM visits;"

# List volumes
docker volume ls

# Inspect a specific volume
docker volume inspect 30-days-docker-k8s_db_data

# Stop and remove containers, networks, and volumes
docker compose down
docker compose down -v

# Start services
docker compose up -d
```

#### Observations:

- `docker compose ps` shows the status of services, including health checks.
- `docker compose exec` allows running commands inside a container, such as querying the database.
- Volumes persist data even after `docker compose down`, unless `-v` is used to remove them.
- `docker volume inspect` reveals details like mount points and labels.
- `docker compose up -d` recreates containers and networks, and restores volumes if they exist.
- Use `docker compose down -v` cautiously, as it permanently deletes volumes and their data.
- Named volumes like `30-days-docker-k8s_db_data` are essential for persisting stateful data.
- Services communicate over a private network created by Compose, and volumes are automatically reattached when services are restarted.
- Always verify the state of services and volumes after running `down` or `up` commands.
- The `COUNT(*)` query confirms data persistence across container restarts.
- Health checks in `docker compose ps` indicate the readiness of services.

