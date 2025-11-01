

# Dry Run Client-Side
kubectl apply --dry-run=client -f ./rapi
kubectl apply --dry-run=client -f ./monitoring

# Dry Run Server-Side
kubectl apply --dry-run=server -f ./rapi
kubectl apply --dry-run=server -f ./monitoring


# Consider also using
# - kubeconform
# - yamllint
