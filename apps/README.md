# README

## Docker

```sh
# Build Docker images
docker build -f Dockerfile -t rapi --build-arg=APP=rapi --build-arg=ARCH=x86_64 .
docker build -f Dockerfile -t grpcapi --build-arg=APP=grpcapi --build-arg=ARCH=x86_64 .
# Use "ARCH=aarch64" for ARM chipset

docker run -d -p 3000:3000 --name rapi rapi
docker exec -it rapi /bin/sh
docker rm -f rapi

# ---

docker tag rapi:latest dex-registry.localhost:32841/rapi:latest
docker push dex-registry.localhost:32841/rapi:latest

docker tag grpcapi:latest dex-registry.localhost:32841/grpcapi:latest
docker push dex-registry.localhost:32841/grpcapi:latest
```

openssl req -x509 -nodes -days 365 \
 -newkey rsa:2048 \
 -keyout grpcapi.key \
 -out grpcapi.crt \
 -subj "/CN=grpcapi.localhost"

kubectl create secret tls grpcapi-tls \
 --cert=grpcapi.crt \
 --key=grpcapi.key \
 -n grpcapi
