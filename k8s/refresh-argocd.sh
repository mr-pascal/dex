#!/bin/bash
set -euo pipefail

# Refresh all ArgoCD applications programmatically
# This script triggers a refresh of all ArgoCD applications in the cluster

# Method 1: Using kubectl to patch all applications (no ArgoCD CLI required)
refresh_via_kubectl() {
  echo "Refreshing all ArgoCD applications via kubectl..."

  # Get all applications in argocd namespace
  apps=$(kubectl get applications -n argocd -o name 2>/dev/null || echo "")

  if [ -z "$apps" ]; then
    echo "⚠ No ArgoCD applications found in argocd namespace"
    return 1
  fi

  # Refresh each application by adding a refresh annotation
  for app in $apps; do
    app_name=$(echo "$app" | cut -d'/' -f2)
    echo "  Refreshing: $app_name"
    kubectl patch application "$app_name" -n argocd \
      --type merge \
      -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}' \
      >/dev/null 2>&1 || echo "    ⚠ Failed to refresh $app_name"
  done

  echo "✓ Refresh triggered for all applications"
  echo "  Applications will refresh automatically. Check status with:"
  echo "    kubectl get applications -n argocd"
}

# Main execution
METHOD="${1:-kubectl}"

case "$METHOD" in
  kubectl)
    refresh_via_kubectl
    ;;
  cli)
    refresh_via_cli
    ;;
  api)
    refresh_via_api
    ;;
  *)
    echo "Usage: $0 [kubectl|cli|api]"
    echo ""
    echo "Methods:"
    echo "  kubectl  - Refresh via kubectl patch (default, no external dependencies)"
    echo "  cli      - Refresh via ArgoCD CLI (requires argocd CLI installed)"
    echo "  api      - Refresh via ArgoCD REST API (requires curl and jq)"
    echo ""
    echo "Environment variables:"
    echo "  ARGOCD_SERVER   - ArgoCD server address (default: argocd-server.argocd.svc.cluster.local:443)"
    echo "  ARGOCD_USERNAME - ArgoCD username (default: admin)"
    echo "  ARGOCD_PASSWORD - ArgoCD password (auto-retrieved from secret if not set)"
    exit 1
    ;;
esac
