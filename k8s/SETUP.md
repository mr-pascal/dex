# Cluster Setup Guide

This guide ensures reproducible, production-grade cluster setup.

## Prerequisites

- k3d installed
- kubectl configured
- Helm 3.x installed
- MetalLB IP pool configured (172.22.255.1-172.22.255.250)

## Setup Steps

### 1. Create k3d Cluster

```bash
k3d cluster create dex-cluster --config ../k3d-config.yaml
```

### 2. Bootstrap CoreDNS

CoreDNS must be installed **before** other services to enable DNS resolution:

```bash
./bootstrap.sh
```

This script:

- Installs CoreDNS via Helm with custom configuration
- Configures DNS resolution for `*.cluster.local` domains
- Configures service as LoadBalancer type (via `serviceType: LoadBalancer` in values file)

**Note:** The LoadBalancer IP (172.22.255.2) will be automatically assigned once MetalLB is installed via ArgoCD in step 3. The script does not wait for MetalLB to be available.

### 2.5 Push Docker images to registry

Push Docker images to cluster registry

```sh
docker tag rapi:latest dex-registry.localhost:5000/rapi:latest
docker push dex-registry.localhost:5000/rapi:latest

docker tag grpcapi:latest dex-registry.localhost:5000/grpcapi:latest
docker push dex-registry.localhost:5000/grpcapi:latest
```

### 3. Apply Kubernetes Resources

```bash
./apply.sh
```

This applies (in order):

1. Namespaces
2. GitOps (ArgoCD)
3. Load Balancer (MetalLB)
4. Metrics Server
5. Traefik (with fixed IP 172.22.255.1)
6. Applications (rapi, grpcapi)

## TODO

refresh argocd (dunno why, maybe because metallb isn'T there yet?)
kubectl get applications -n argocd -o name | xargs -I {} kubectl patch {} -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
OR via

```sh
# Wait till the ArgoCD pods are ready before execution!
./refresh-argocd.sh kubectl

kubectl get applications -n argocd
# --> Wait till metallb is synced and healthy (actually metallb only has to install the CRDs, not completely healthy)
```

then go `apply.sh` again to install ip pool etc

## Verification

### Check CoreDNS DNS Service

```bash
kubectl get svc -n kube-system coredns
# Should show: EXTERNAL-IP 172.22.255.2
```

### Test DNS Resolution

```bash
docker run --rm --network k3d-dex-cluster --dns 172.22.255.2 alpine/curl:8.14.1 nslookup rapi.cluster.local
# Should resolve to: 172.22.255.1
```

### Test HTTP Access

```bash
docker run --rm --network k3d-dex-cluster --dns 172.22.255.2 alpine/curl:8.14.1 curl http://rapi.cluster.local
```

## IP Address Allocation

| Service              | IP Address       | Purpose             |
| -------------------- | ---------------- | ------------------- |
| Traefik LoadBalancer | 172.22.255.1     | Ingress controller  |
| CoreDNS LoadBalancer | 172.22.255.2     | External DNS access |
| MetalLB Pool         | 172.22.255.1-250 | Available IPs       |

## Troubleshooting

### CoreDNS service is ClusterIP instead of LoadBalancer

The service type is configured in `coredns-values.yaml` via `serviceType: LoadBalancer`. If it's still ClusterIP, verify the values file and re-run `./bootstrap.sh`.

### DNS resolution fails

1. Verify CoreDNS pods are running: `kubectl get pods -n kube-system -l app.kubernetes.io/name=coredns`
2. Check CoreDNS ConfigMap: `kubectl get configmap -n kube-system coredns -o yaml`
3. Verify hosts plugin configuration includes your domains

### Traefik not accessible

1. Verify Traefik LoadBalancer IP: `kubectl get svc -n traefik traefik`
2. Check MetalLB IP pool: `kubectl get ipaddresspool -n metallb`
3. Ensure Traefik Helm values specify `loadBalancerIP: "172.22.255.1"`

## Reproducibility

All configuration is declarative and stored in:

- `k3d-config.yaml` - Cluster configuration
- `k8s/bootstrap.sh` - CoreDNS installation script
- `k8s/coredns-values.yaml` - CoreDNS Helm values
- `k8s/traefik/traefik.yaml` - Traefik ArgoCD Application
- `k8s/apply.sh` - Resource application order

To recreate the cluster:

```bash
k3d cluster delete dex-cluster
k3d cluster create dex-cluster --config k3d-config.yaml
cd k8s && ./bootstrap.sh && ./apply.sh
```
