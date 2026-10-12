# Day 27 template — Helm chart

On Day 27, scaffold a chart and wire it to your existing manifests:

```bash
helm create thirty-days-chart
```

Then replace the generated `templates/deployment.yaml` and `templates/service.yaml`
with versions of your own `k8s/deployment.yaml` and `k8s/service.yaml`, parameterizing
values like image name/tag and replica count into `values.yaml`, e.g.:

```yaml
# values.yaml
image:
  repository: yourdockerhubuser/30-days-app
  tag: latest
replicaCount: 1
```

Install it with:

```bash
helm install thirty-days-app ./thirty-days-chart
```

Document what you learned in `docs/week4.md`.
