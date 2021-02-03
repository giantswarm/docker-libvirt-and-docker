FROM fedora:32
MAINTAINER Roman Sokolkov <roman@giantswarm.io>

# docker run \
#   --privileged -d \
#   --device /dev/kvm:/dev/kvm \
#   -v /sys/fs/cgroup:/sys/fs/cgroup:rw
#   -v ${HIVE_PATH}:/hive:rw
#   rsokolkov/libvirt-and-docker

ENV container docker

RUN dnf -y update && dnf clean all

### SYSTEMD ###
RUN dnf -y install systemd && dnf clean all && \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

### LIBVIRT ###
RUN dnf -y install \
    libvirt \
    qemu \
    qemu-kvm \
    virt-install \
    python3-gobject \
    jq \
    && dnf clean all

# Enable libvirtd and virtlockd services.
RUN systemctl enable libvirtd
RUN systemctl enable virtlockd

# Add configuration for "default" storage pool.
RUN mkdir -p /etc/libvirt/storage
COPY pool-default.xml /etc/libvirt/storage/default.xml

### DOCKER ###
RUN dnf -y install docker

# enable docker
RUN systemctl enable docker

# Disable unnecessary docker-storage-setup
RUN ln -sf /bin/true /usr/bin/container-storage-setup

VOLUME /var/lib/docker

### OTHER REQUIREMENTS ###
RUN dnf -y install \
        sudo \
        which \
        git \
        docker-compose \
        python3-pip \
        wget \
        xfs \
        xfsprogs

### Latest ansible ###
RUN pip3 install --upgrade ansible

# The entrypoint.sh script runs before services start up to ensure that
# critical directories and permissions are correct.
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/sbin/init"]

