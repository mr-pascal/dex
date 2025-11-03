# README

docker run -it --rm --network k3d-dex-cluster alpine/curl:8.14.1 curl http://rapi.cluster.local

docker run --rm --network k3d-dex-cluster --dns 172.22.255.2 alpine/curl:8.14.1 curl http://rapi.cluster.local
