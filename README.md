# Docker image with libvirt and docker inside

Based on Fedora official [systemd docker image](https://github.com/fedora-cloud/Fedora-Dockerfiles/tree/master/systemd) (Not maintained).

## Build

```
docker build . -t libvirt-and-docker
```

## Run

```
docker run --name c1 --privileged -d --device /dev/kvm:/dev/kvm -v /sys/fs/cgroup:/sys/fs/cgroup:rw libvirt-and-docker
docker exec -ti c1 /bin/bash

# Check libvirt
virsh list

# Give 1 min for docker service to start
# Try to run container
docker run busybox
```
