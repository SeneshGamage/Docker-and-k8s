# Docker Desktop WSL2 Error — Troubleshooting Guide

## 1. Overview

This document explains how I resolved a Docker Desktop startup issue on Windows involving WSL2 (Windows Subsystem for Linux 2).

**Environment:**
- **Operating System:** Windows 11 (Build 22621)
- **Docker Desktop:** WSL2 backend
- **WSL Version:** 3.0.1.0
- **WSL Kernel:** 6.18.40.1-1
- **Project Environment:** Docker containers and volumes

## 2. Errors Encountered

### Error 1: WSL service could not start

When running:

```powershell
wsl --shutdown
```

The following error appeared:

```text
The service cannot be started, either because it is disabled
or because it has no enabled devices associated with it.

Error code: Wsl/ERROR_SERVICE_DISABLED
```

### Error 2: Docker Desktop could not access its WSL distributions

Docker Desktop displayed an error similar to:

```text
deploying WSL2 distributions:
open \\wsl$\docker-desktop\etc\wsl_bootstrap_version:
The network name cannot be found.
```

Another error referenced:

```text
\\wsl$\docker-desktop-data\isocache\
The network name cannot be found.
```

### Error 3: Missing WSL virtual disk

Running:

```powershell
wsl -d docker-desktop
```

Returned:

```text
Failed to attach disk
'C:\Users\<user>\AppData\Local\Docker\wsl\main\ext4.vhdx'
to WSL2: The system cannot find the file specified.

Error code:
Wsl/Service/CreateInstance/MountDisk/ERROR_FILE_NOT_FOUND
```

## 3. Cause of the Problem

Docker Desktop uses WSL2 to run its Linux-based container environment. WSL2 relies on virtual disk files (`.vhdx`) to store Linux filesystem data.

In this case, Docker attempted to access:

```text
C:\Users\<user>\AppData\Local\Docker\wsl\main\ext4.vhdx
```

However, the expected file was missing.

A separate virtual disk was still present:

```text
C:\Users\<user>\AppData\Local\Docker\wsl\disk\docker_data.vhdx
```

The disk file was approximately 2.6 GB.

Because Docker could not find or mount the expected virtual disk, its WSL environment failed to initialize correctly. This also caused the `\\wsl$` network path errors.

**Important:** The immediate cause was the missing virtual disk. The exact reason why the file disappeared was not established. A failed initialization or update, interrupted operation, or another filesystem-related issue could have contributed.

## 4. Solution That Worked

The following steps resolved the Docker Desktop startup issue.

### Step 1: Inspect the WSL environment

Open PowerShell or Command Prompt and run:

```powershell
wsl --status
wsl -l -v
wsl --version
```

These commands display the WSL configuration, installed distributions, and WSL version.

### Step 2: Locate the Docker virtual disk files

Run:

```cmd
dir "%LOCALAPPDATA%\Docker\wsl" /s /b | findstr /i ".vhdx"
```

This searches the Docker WSL directory for virtual disk files.

The expected `main\ext4.vhdx` file was missing, but `disk\docker_data.vhdx` existed.

### Step 3: Back up the existing virtual disk

Before changing Docker's WSL configuration, make a copy of the existing disk to another drive with sufficient free space.

For example:

```cmd
mkdir D:\DockerBackup
copy "%LOCALAPPDATA%\Docker\wsl\disk\docker_data.vhdx" D:\DockerBackup\
```

Verify that the copy completed successfully.

**Important:** A disk backup does not guarantee that all Docker containers, images, or volumes can be recovered automatically. Keep the backup until the project's data has been verified.

### Step 4: Shut down WSL

Run:

```powershell
wsl --shutdown
```

This stops running WSL distributions.

### Step 5: Unregister the broken Docker distribution

Run:

```powershell
wsl --unregister docker-desktop
```

This successfully unregistered the `docker-desktop` WSL distribution in this case.

**Warning:** `wsl --unregister` deletes the specified WSL distribution and its registered filesystem. Do not run it against a project distribution or another WSL distribution containing important data. Back up relevant data before unregistering anything.

### Step 6: Restart Docker Desktop

Launch Docker Desktop again.

Docker Desktop recreated its required WSL environment, and Docker started working normally.

This was the step that resolved the issue in this case.

## 5. Verify That Docker Is Working

After Docker Desktop starts, open PowerShell and run the following commands.

### Check the Docker engine

```powershell
docker version
docker info
```

These commands should return Docker client and server information.

### Check containers

```powershell
docker ps
docker ps -a
```

- `docker ps` lists running containers.
- `docker ps -a` lists all containers, including stopped containers.

### Check images and volumes

```powershell
docker images
docker volume ls
```

Confirm that the images and volumes required by the project are present.

### Check the project

Navigate to the project directory and run:

```powershell
docker compose ps
```

If the project uses Docker Compose, start its services when appropriate:

```powershell
docker compose up -d
```

Then check the service status and application logs:

```powershell
docker compose ps
docker compose logs --tail=100
```

**Note:** Starting the containers successfully does not by itself prove that previous database data has been recovered. Verify the actual application and database contents.

## 6. Docker Security Warning

After Docker restarted, the following warning appeared:

```text
WARNING: daemon is not using the default seccomp profile
```

Seccomp is a Linux security mechanism that restricts which system calls a process can make.

This warning is separate from the missing virtual disk error. Since Docker was working, it did not necessarily indicate a startup failure.

Do not disable container security features merely to hide this warning. Investigate the Docker configuration and runtime if the warning persists or if the environment requires a specific security configuration.

## 7. Backup Verification

Two copies of the virtual disk were created:

```text
D:\dkr\docker_data.vhdx
D:\DockerBackup\docker_data.vhdx
```

To check whether they are identical, run:

```cmd
certutil -hashfile "D:\dkr\docker_data.vhdx" SHA256
certutil -hashfile "D:\DockerBackup\docker_data.vhdx" SHA256
```

Compare the SHA-256 hashes.

- **Matching hashes:** The files are byte-for-byte identical.
- **Different hashes:** The files differ; retain both until the difference is understood.

Keep at least one verified backup until the project, containers, and database contents have been checked. Only delete a duplicate after confirming it is no longer needed.

## 8. Prevention

To reduce the risk of encountering this issue again:

1. Keep Docker Desktop and WSL reasonably up to date.
2. Avoid manually deleting or moving files inside `%LOCALAPPDATA%\Docker\wsl`.
3. Keep enough free disk space on the Windows system drive.
4. Back up important databases and persistent Docker volumes separately.
5. Verify the contents of backups before deleting the originals.
6. Avoid running `docker system prune --volumes` unless you fully understand which resources it may remove.
7. Before resetting or unregistering Docker's WSL distributions, inspect the existing data and create backups.

For important project databases, use database-native backups when possible rather than relying exclusively on a copy of Docker's internal virtual disk.

## 9. Summary

**Problem:** Docker Desktop could not initialize its WSL2 environment because the expected `main\ext4.vhdx` virtual disk was missing.

**Resolution:** The existing `docker_data.vhdx` was backed up, the broken `docker-desktop` distribution was unregistered, and Docker Desktop was launched again. It recreated its WSL environment and Docker started working.

**Final status:** Docker was working after the recovery steps.

**Remaining verification:** Confirm that the required containers, images, persistent volumes, and actual project/database data are present before deleting backup files.

---

*Document purpose: Record the troubleshooting process and recovery steps for future reference. Commands and paths reflect the environment in which this issue occurred; verify them before applying them on another machine.*