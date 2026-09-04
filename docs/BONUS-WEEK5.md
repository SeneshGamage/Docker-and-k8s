# Bonus Week 5 — Jenkins + SonarQube + ArgoCD (100% Free, Local)

This extends your 30-day project with the tools from the "CI/CD Pipeline to
Deploy to Kubernetes Using Jenkins" video — but run entirely on your own
machine with Minikube instead of AWS EKS, so there's no cloud cost.

## What's different from the video
| Video (paid) | This version (free) |
|---|---|
| AWS EKS cluster | Minikube (already installed from Week 3) |
| Jenkins on a dedicated EC2 server | Jenkins running in a local Docker container |
| ArgoCD on EKS | ArgoCD installed on Minikube |
| Real GitHub repo + webhook | Same — GitHub webhooks work fine with a free tunnel tool (see Day 33) |

The concepts transfer 1:1 — Jenkins pipelines, SonarQube quality gates, and
ArgoCD's GitOps model work the same locally as they do on EKS. You're only
swapping where the cluster lives.

## Setup
- Make sure Minikube is still running from Week 3 (`minikube start`)
- Docker Desktop running (for Jenkins container)
- A second GitHub repo for GitOps manifests, separate from your app repo —
  this mirrors the video's "Application Repo" / "Manifest File Repo" split

## Day-by-day

- [ ] **Day 31** — Run Jenkins locally: `docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts`. Unlock it, install suggested plugins, create an admin user. Write `docs/week5.md` notes on what Jenkins is and how it differs from GitHub Actions.
- [ ] **Day 32** — Install the Docker and Kubernetes CLI plugins in Jenkins. Add your GitHub credentials (Manage Jenkins → Credentials).
- [ ] **Day 33** — Create a `Jenkinsfile` in your app repo with stages: checkout → install deps → run tests. Create a Jenkins Pipeline job pointing at it. (Optional: use `ngrok` — free tier — to expose local Jenkins so GitHub webhooks can trigger it automatically.)
- [ ] **Day 34** — Add a SonarQube stage: run SonarQube locally too (`docker run -d -p 9000:9000 sonarqube:lts-community`), integrate it into the Jenkinsfile as a code-quality gate before build.
- [ ] **Day 35** — Add a Docker build & push stage to the Jenkinsfile (reuse your existing Dockerfile from Week 1). Push to Docker Hub, same as your GitHub Actions workflow did.
- [ ] **Day 36** — Install ArgoCD on Minikube: `kubectl create namespace argocd && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`. Point ArgoCD at your GitOps manifest repo (the `k8s/` files from Week 3) so it auto-syncs deployments.
- [ ] **Day 37** — End-to-end test: make a small code change, push it, watch Jenkins build → test → push image → update the manifest repo → ArgoCD auto-deploy the new version to Minikube. Write `docs/week5-retrospective.md` comparing this pipeline to the GitHub Actions one from Week 4.

## Why this is worth doing after the core 30 days
GitHub Actions (Week 4) is simpler and fine for most personal/small-team
projects. Jenkins + ArgoCD is what a lot of larger companies actually run,
so having hands-on experience with both is a strong addition to a DevOps
portfolio — and doing it locally means you learn the same skills as the
video, without any AWS bill.
