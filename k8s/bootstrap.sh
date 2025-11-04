#!/bin/bash
set -euo pipefail

# Install CoreDNS with production-grade configuration
# This script configures CoreDNS to:
# 1. Expose DNS service as LoadBalancer (172.22.255.2) for external access from Docker network
# 2. Resolve *.cluster.local domains to Traefik LoadBalancer IP (172.22.255.1)
#
# Prerequisites:
# - Traefik LoadBalancer must be configured to use IP 172.22.255.1
# - MetalLB IP pool must include 172.22.255.1-172.22.255.250

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

helm repo add coredns https://coredns.github.io/helm
helm repo update

# Install or upgrade CoreDNS with Helm values
# The LoadBalancer service type is configured in coredns-values.yaml via serviceType: LoadBalancer
# Note: We don't use --wait because the LoadBalancer IP won't be assigned until MetalLB is installed
if helm list -n kube-system | grep -q "^coredns"; then
  echo "Upgrading existing CoreDNS installation..."
  helm upgrade coredns coredns/coredns \
    -n kube-system \
    -f "${SCRIPT_DIR}/coredns-values.yaml"
else
  echo "Installing CoreDNS..."
  helm install coredns coredns/coredns \
    -n kube-system \
    --create-namespace \
    -f "${SCRIPT_DIR}/coredns-values.yaml"
fi

# Wait for CoreDNS pods to be ready (but not for LoadBalancer IP)
echo "Waiting for CoreDNS pods to be ready..."
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=coredns \
  -n kube-system \
  --timeout=120s || {
  echo "⚠ Warning: CoreDNS pods may not be ready yet"
  echo "  Check status with: kubectl get pods -n kube-system -l app.kubernetes.io/name=coredns"
}

echo "✓ CoreDNS installed with LoadBalancer service type"
echo "  LoadBalancer IP (172.22.255.2) will be assigned automatically once MetalLB is installed"
echo "  Check service status with: kubectl get svc -n kube-system coredns"
