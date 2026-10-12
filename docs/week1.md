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

_To be filled in._

## Day 5: Environment variables

_To be filled in._

## Day 6: Healthcheck

_To be filled in._

## Day 7: Week 1 summary

_To be filled in._