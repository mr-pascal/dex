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
