# MetalLB Setup

```sh
# for metallb-ip-pool:
docker network inspect <NETWORK_NAME> | jq -r '.[0].IPAM.Config[0].Subnet'

docker network inspect k3d-dex-cluster | jq -r '.[0].IPAM.Config[0].Subnet'
# 172.22.0.0/16

```

Apply the 12adv and ip-pool only after metallb is fully initalized!

---

resource mapping not found for name: "default" namespace: "metallb" from "load-balancer/metallb-12adv.yaml": no matches for kind "L2Advertisement" in version "metallb.io/v1beta1"
ensure CRDs are installed first
resource mapping not found for name: "default" namespace: "metallb" from "load-balancer/metallb-ip-pool.yaml": no matches for kind "IPAddressPool" in version "metallb.io/v1beta1"
ensure CRDs are installed first
