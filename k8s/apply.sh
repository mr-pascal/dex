kubectl apply -f ./namespaces
kubectl apply -k ./gitops
kubectl apply -f ./load-balancer
kubectl apply -f ./metrics-server
kubectl apply -f ./traefik
# kubectl apply -f ./coredns
kubectl apply -f ./rapi
kubectl apply -f ./grpcapi
# kubectl apply -f ./monitoring
