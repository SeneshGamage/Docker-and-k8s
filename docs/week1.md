# Week 1

# Week 1: Docker Basics

Notes from the first week of the 30 Days of Docker + Kubernetes project.

---

## Day 2: Build and run the Dockerfile

### What I did
- Built an image from the project's `Dockerfile`
- Ran it as a container and tested it in the browser

```bash
docker build -t 30-days-app .
docker images
docker run -p 3000:3000 30-days-app
```

I checked `http://localhost:3000` (JSON greeting) and `http://localhost:3000/health` (`{"status":"ok"}`).

### What I learned

**Image vs container**
- An **image** is a read-only template: the app code, its dependencies and the OS layer, packaged together.
- A **container** is a running instance of an image. I can start many containers from one image.

**What `docker build -t 30-days-app .` does**
- `build` reads the Dockerfile and creates an image, one layer per instruction.
- `-t 30-days-app` gives the image a name (a tag).
- `.` is the build context, the folder Docker is allowed to copy files from.

**What `-p 3000:3000` means**
- The format is `host_port:container_port`.
- It forwards port 3000 on my computer to port 3000 inside the container. Without it, the app runs but I can't reach it from my browser.

**How the Dockerfile works, line by line**

| Instruction | Purpose |
|---|---|
| `FROM node:20-alpine` | Starts from a small Linux image with Node.js 20 already installed |
| `WORKDIR /app` | Sets the folder inside the container where commands run |
| `COPY package*.json ./` | Copies only the dependency files first |
| `RUN npm install --omit=dev` | Installs the app's dependencies (skips dev-only ones) |
| `COPY . .` | Copies the rest of the app code |
| `EXPOSE 3000` | Documents which port the app listens on |
| `HEALTHCHECK ...` | Lets Docker test whether the app is still responding |
| `ENV PORT=3000` | Sets a default environment variable |
| `CMD ["node", "index.js"]` | The command that runs when the container starts |

**Why `package.json` is copied before the rest of the code**
Docker caches each layer. If only my code changes, the `npm install` layer is reused, so rebuilds are much faster.

### Useful commands I practiced
```bash
docker run -d -p 3000:3000 --name app-test 30-days-app   # run in the background
docker logs app-test                                      # see the app's output
docker ps                                                 # list running containers
docker stop app-test                                      # stop it
docker rm app-test                                        # delete the stopped container
```

### Problems I hit
- Docker Desktop's engine wasn't running, so every command failed with an `Internal Server Error` for the `dockerDesktopLinuxEngine` pipe. Fix: restart Docker Desktop and run `wsl --shutdown`, then wait for "Engine running" before using Docker.

---

## Day 3: .dockerignore and image size

### What I did
- Noted the image size before the changes
- Switched `npm install` to `npm ci` in the Dockerfile
- Expanded `.dockerignore`
- Rebuilt the image and confirmed it still runs

### Image size

| | Size |
|---|---|
| Before changes | 140MB |
| After changes | 140MB |

### What I learned

**What `.dockerignore` does**
It lists files Docker should leave out of the build context, like `.gitignore` does for git. Benefits:
- Faster builds, because less data is sent to Docker
- Smaller images
- Safer: secrets like `.env` can't accidentally end up inside an image
- Local `node_modules` don't overwrite the ones installed inside the container

**Why `alpine` helps**
`node:20-alpine` is built on Alpine Linux, which is very small. The regular `node:20` image is several times larger, so alpine means smaller downloads and less to maintain.

**Why `npm ci` instead of `npm install`**
- `npm ci` installs exactly the versions in `package-lock.json`
- It's faster and gives the same result on every build
- It fails if `package.json` and `package-lock.json` disagree, which catches mistakes early

- (The image stayed at 140MB. Most of that size is the node:20-alpine base image, and my app only adds a few MB. npm ci and the expanded .dockerignore improved build repeatability and kept the build context tiny (2.31kB), but they don’t shrink an image that’s already small. Choosing alpine was the real size optimization)

**Files I added to `.dockerignore`**
- `.vs`: Visual Studio's local editor files
- `.github`: CI config isn't needed inside the image
- `templates`: staged files for later days

---

## Day 4: Push the image to Docker Hub

- Created a Docker Hub account and a Read & Write access token
- Logged in with `docker login`, using the token instead of my password
- Tagged the image as `donlenasenesh/30-days-app:latest`
- Pushed it with `docker push` and verified it by pulling it fresh

What I learned:
- A **registry** (Docker Hub) stores images so they can be shared and pulled anywhere
- An image name has the form `donlenasenesh/repo:tag`; the tag is usually a version, and `latest` is the default
- `docker tag` doesn't copy the image, it adds another name to the same one
- Only new layers are uploaded, because shared layers already exist on the registry

## Day 5: Environment variables

- Made the greeting configurable with `APP_MESSAGE`
- Passed variables with `-e` and `--env-file`, and checked them with `docker exec ... printenv`
- Changed `PORT` and learned the `-p` mapping must match it

What I learned:
- Environment variables let me change behaviour without rebuilding the image
- `ENV` in the Dockerfile sets defaults; `-e` at run time overrides them
- `.env` files keep config out of the image and out of git (never commit real secrets)
- The healthcheck is hardcoded to port 3000, so it reports unhealthy when `PORT` changes (to fix on Day 6)

## Day 6: Healthcheck

- Fixed the `HEALTHCHECK` so it uses `${PORT}` instead of a hardcoded 3000
- Tuned `--interval`, `--timeout`, `--start-period` and `--retries`
- Confirmed the status with `docker ps` and `docker inspect`
- Forced an unhealthy state with `--health-cmd="exit 1"` to see it fail

- PS D:\30-days-docker-k8s> docker run -d -p 5000:5000 -e PORT=5000 --name health-port 30-days-app
- b0115c4e3da02ced0783039a9bebe7aa3f595bf5779329820ef3ec711e1c5f1a
- PS D:\30-days-docker-k8s> docker ps
- CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                    PORTS                           
- NAMES 
- b0115c4e3da0   30-days-app   "docker-entrypoint.s…"   24 seconds ago   Up 24 seconds (healthy)   3000/tcp, 0.0.0.0:5000->5000/tcp   - health-port
- PS D:\30-days-docker-k8s> docker run -d --name sick-test --health-cmd="exit 1" --health-interval=5s --health-retries=2 30-days-app
- eef0f13f0cca50bb5cc6259d2bd5f85d771cfb012579978a57c47d43ea79444b
- PS D:\30-days-docker-k8s> docker ps
- CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                           PORTS                              NAMES
eef0f13f0cca   30-days-app   "docker-entrypoint.s…"   3 seconds ago    `Up 3 seconds (health: starting)`   3000/tcp                           `sick-test`
b0115c4e3da0   30-days-app   "docker-entrypoint.s…"   46 seconds ago   Up 46 seconds (healthy)           3000/tcp, 0.0.0.0:5000->5000/tcp   health-port        
PS D:\30-days-docker-k8s> docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED              STATUS                        PORTS                              NAMES
eef0f13f0cca   30-days-app   "docker-entrypoint.s…"   23 seconds ago       `Up 22 seconds (unhealthy)`    3000/tcp                           `sick-test`
b0115c4e3da0   30-days-app   "docker-entrypoint.s…"   About a minute ago   Up About a minute (healthy)   3000/tcp, 0.0.0.0:5000->5000/tcp   health-port 

What I learned:
- A healthcheck is a command Docker runs inside the container on a schedule; exit code 0 = healthy, 1 = unhealthy
- Status goes `starting` → `healthy` or `unhealthy`; `start-period` gives the app time to boot
- `docker ps` shows the status, and `docker inspect` shows the full check history
- Docker only *reports* unhealthy containers, it doesn't restart them. Kubernetes probes (Week 3-4) act on this idea
- The app's `/health` endpoint is what the check calls

## Day 7: Week 1 summary

### What I built this week
A Node.js/Express app packaged as a Docker image that:
- builds from a Dockerfile on `node:20-alpine` (140MB)
- is configured through environment variables (`PORT`, `APP_MESSAGE`)
- reports its health through a `HEALTHCHECK` that follows `PORT`
- is published on Docker Hub as `donlenasenesh/30-days-app`

### Key concepts
| Concept | In my own words |
|---|---|
| Image | A packaged snapshot of an app, its dependencies, and the OS layer, ready to be run. |
| Container | A running instance of an image, isolated and lightweight. |
| Dockerfile | A script with instructions to build a Docker image. |
| Registry (Docker Hub) | A storage for Docker images, allowing sharing and pulling from anywhere. |
| Layer caching | Docker's way of reusing unchanged layers to speed up builds. |
| Environment variable | A key-value pair used to configure an app without changing its code. |
| Healthcheck | A periodic test to check if a container is running as expected. |

### Commands I now know
| Command | What it does |
|---|---|
| `docker build -t name .` | Builds an image from the Dockerfile |
| `docker run -d -p H:C --name n image` | Runs a container in the background with a port mapping |
| `docker ps` / `docker ps -a` | Lists running / all containers |
| `docker logs name` | Shows a container's output |
| `docker exec name cmd` | Runs a command inside a running container |
| `docker stop` / `docker rm` | Stops / deletes a container |
| `docker images` / `docker rmi` | Lists / deletes images |
| `docker tag` / `docker push` | Names an image for a registry / uploads it |
| `docker inspect` | Shows detailed info, including health history |

### Problems I hit and how I fixed them

- **Docker Desktop engine errors**: Every command failed with an `Internal Server Error` for the `dockerDesktopLinuxEngine` pipe. I fixed this by restarting Docker Desktop and running `wsl --shutdown`. After that, I waited for "Engine running" before using Docker.

- **Port 3000 already allocated**: The app failed to start because another process was using port 3000. I identified the conflicting process using `netstat -ano | findstr :3000` and stopped it. Alternatively, I ran the container on a different port using `-p 4000:3000`.

### What surprised me
- How much faster rebuilds became with Docker's layer caching.
- How easy it was to push and pull images from Docker Hub.
- How environment variables made the app flexible without changing the code.
- How the healthcheck status updates dynamically in `docker ps`.
- That Alpine Linux is so small yet functional for Node.js apps.
- How Docker's CLI commands are intuitive once you understand the concepts.

### What I'd like to understand better

- How multi-stage builds can optimize image size further.
- Best practices for writing efficient Dockerfiles.
- Advanced healthcheck configurations and their use cases.
- How Docker handles networking between containers.


### Next week
Docker Compose: running the app together with a database.