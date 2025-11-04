# ArgoCD

## TODO

Add `ingress` resource for the ArgoCD instead of port forwarding!

## Access

```sh

### Port forward for the UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

### Login
# username: admin
# password:
# Remove the "%" at the end, if it is printed
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

## Refresh Applications

### Quick Refresh (One-liner)

Refresh all applications via kubectl (no external dependencies):

```bash
kubectl get applications -n argocd -o name | xargs -I {} kubectl patch {} -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

### Using the Refresh Script

A comprehensive script is available with multiple methods:

```bash
# Method 1: kubectl (default, recommended)
./refresh-argocd.sh kubectl

# Method 2: ArgoCD CLI (requires argocd CLI installed)
./refresh-argocd.sh cli

# Method 3: REST API (requires curl and jq)
./refresh-argocd.sh api
```

### Refresh Specific Application

```bash
# Via kubectl patch
kubectl patch application <app-name> -n argocd \
  --type merge \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Via ArgoCD CLI
argocd app get <app-name> --refresh

# Via REST API
TOKEN=$(curl -s -k "https://argocd-server.argocd.svc.cluster.local:443/api/v1/session" \
  -d '{"username":"admin","password":"'"$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d)"'"}' \
  -H "Content-Type: application/json" | jq -r '.token')
curl -k -X POST "https://argocd-server.argocd.svc.cluster.local:443/api/v1/applications/<app-name>/refresh" \
  -H "Authorization: Bearer ${TOKEN}"
```
