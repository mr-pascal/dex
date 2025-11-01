# README

## Docker

```sh
# Build Docker images
docker build -f Dockerfile -t rapi --build-arg=APP=rapi --build-arg=ARCH=x86_64 .
# Use "ARCH=aarch64" for ARM chipset

docker run -d -p 3000:3000 --name rapi rapi
docker exec -it rapi /bin/sh
docker rm -f rapi
```
