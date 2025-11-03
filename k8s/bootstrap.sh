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
if helm list -n kube-system | grep -q "^coredns"; then
  echo "Upgrading existing CoreDNS installation..."
  helm upgrade coredns coredns/coredns \
    -n kube-system \
    -f "${SCRIPT_DIR}/coredns-values.yaml" \
    --wait \
    --timeout 5m
else
  echo "Installing CoreDNS..."
  helm install coredns coredns/coredns \
    -n kube-system \
    --create-namespace \
    -f "${SCRIPT_DIR}/coredns-values.yaml" \
    --wait \
    --timeout 5m
fi

# Note: When isClusterService=true, Helm chart may create ClusterIP service.
# Patch service to LoadBalancer type for external access (reproducible via this script)
# The LoadBalancer IP will be assigned automatically once MetalLB is installed via ArgoCD
kubectl patch svc coredns -n kube-system \
  --type='merge' \
  -p '{"spec":{"type":"LoadBalancer","loadBalancerIP":"172.22.255.2"}}'

echo "✓ CoreDNS service patched to LoadBalancer type"
echo "  LoadBalancer IP (172.22.255.2) will be assigned automatically once MetalLB is installed"
echo "  Check status with: kubectl get svc -n kube-system coredns"
