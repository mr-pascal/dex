# dex

## Setup

### Lens

```sh
curl -fsSL https://downloads.k8slens.dev/keys/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/lens-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/lens-archive-keyring.gpg] https://downloads.k8slens.dev/apt/debian stable main" | sudo tee /etc/apt/sources.list.d/lens.list > /dev/null
sudo apt update && sudo apt install lens

# Launch
lens-desktop
```

### k3d

install k3d:

```sh
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Set up multi-node cluster:

```sh
k3d cluster create dex-cluster \
  --servers 1 \
  --agents 2 \
  --port 80:80@loadbalancer \
  --port 443:443@loadbalancer \
  --registry-create dex-registry:0.0.0.0:5000

# Tag and push images directly to cluster ("--registry-create")
docker tag myservice:latest localhost:5000/myservice:latest
docker push localhost:5000/myservice:latest

# Start cluster
k3d cluster start dex-cluster
# Stop cluster
k3d cluster stop dex-cluster
# Delete cluster
k3d cluster delete dex-cluster
# List cluster
k3d cluster list
```
