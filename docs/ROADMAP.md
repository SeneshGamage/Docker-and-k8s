# 30-Day Roadmap

Each day = one small commit. Move files out of `templates/` into place on
their listed day, or make the described edit directly.

## Week 1 — Docker Basics
- [ ] **Day 1** — Push initial app code + this README
- [ ] **Day 2** — Add `Dockerfile`, build & run locally
- [ ] **Day 3** — Add `.dockerignore`, confirm slim image size (`docker images`)
- [ ] **Day 4** — Push image to Docker Hub, document the command in README
- [ ] **Day 5** — Document the `PORT` env var usage (already wired in `index.js`)
- [ ] **Day 6** — Confirm the `HEALTHCHECK` in the Dockerfile works (`docker inspect`)
- [ ] **Day 7** — Write `docs/week1.md`: what Docker concepts you learned

## Week 2 — Docker Compose
- [ ] **Day 8** — Move `templates/docker-compose.yml` to repo root, add the `db` service
- [ ] **Day 9** — Run `docker compose up --build`, confirm app + db talk to each other
- [ ] **Day 10** — Confirm the `db_data` volume persists after `docker compose down`
- [ ] **Day 11** — (Optional) add a Redis service
- [ ] **Day 12** — Move `templates/.env.example` to root, wire up `.env` locally (gitignored)
- [ ] **Day 13** — Move `templates/docker-compose.override.yml` to root, test live-reload
- [ ] **Day 14** — Write `docs/week2.md` + add an architecture diagram to the README

## Week 3 — Kubernetes with Minikube
- [ ] **Day 15** — `minikube start`, move `templates/k8s/deployment.yaml` into `k8s/`, apply it
- [ ] **Day 16** — Move `templates/k8s/service.yaml` into `k8s/`, apply as ClusterIP
- [ ] **Day 17** — Switch service to NodePort, `minikube service app-service`
- [ ] **Day 18** — Move `templates/k8s/configmap.yaml` into `k8s/`, wire into deployment
- [ ] **Day 19** — Move `templates/k8s/secret.yaml` into `k8s/` (document base64 ≠ encryption)
- [ ] **Day 20** — Move `templates/k8s/db.yaml` into `k8s/`, apply the Postgres deployment + PVC
- [ ] **Day 21** — Write `docs/week3.md`: Pods, Deployments, Services explained in your own words

## Week 4 — Scaling, CI/CD & Polish
- [ ] **Day 22** — `kubectl scale deployment app-deployment --replicas=3`, hit `/` a few times and note the changing hostname
- [ ] **Day 23** — Resource requests/limits are already in `templates/k8s/deployment.yaml` — confirm and explain them
- [ ] **Day 24** — Confirm liveness/readiness probes are working (`kubectl describe pod`)
- [ ] **Day 25** — Move `templates/github-workflows/ci.yml` to `.github/workflows/ci.yml`, add Docker Hub secrets
- [ ] **Day 26** — Add a real test (even one `node --test` assertion) and wire it into the workflow
- [ ] **Day 27** — Follow `templates/helm-chart-README.md` to scaffold a Helm chart
- [ ] **Day 28** — (Optional) move `templates/k8s/ingress.yaml` into `k8s/`
- [ ] **Day 29** — Polish the root README: add a build-status badge, architecture diagram, cleanup
- [ ] **Day 30** — Write `docs/retrospective.md`: what you built, what was hardest, what's next

## Tips
- A tiny commit (fixing a typo, tweaking a YAML value) still counts — don't
  let "not enough time today" break the streak.
- If you fall behind, just keep going forward — don't try to cram missed days.
- Push in the morning if you're worried about forgetting.
