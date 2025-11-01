

# Dry Run Client-Side
kubectl apply --dry-run=client -f ./namespaces
kubectl apply --dry-run=client -f ./rapi
kubectl apply --dry-run=client -f ./monitoring
kubectl apply --dry-run=client -k ./gitops

# Dry Run Server-Side
kubectl apply --dry-run=server -f ./namespaces
kubectl apply --dry-run=server -f ./rapi
kubectl apply --dry-run=server -f ./monitoring
kubectl apply --dry-run=server -k ./gitops


# Consider also using
# - kubeconform
# - yamllint
