# MetalLB Setup

```sh
# for metallb-ip-pool:
docker network inspect <NETWORK_NAME> | jq -r '.[0].IPAM.Config[0].Subnet'

docker network inspect k3d-dex-cluster | jq -r '.[0].IPAM.Config[0].Subnet'
# 172.22.0.0/16


```
