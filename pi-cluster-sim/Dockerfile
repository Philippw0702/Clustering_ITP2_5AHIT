# Use ARM64 CentOS base
FROM arm64v8/centos:7

# Install GlusterFS server and client
RUN yum install -y centos-release-gluster && \
    yum install -y glusterfs-server glusterfs-client && \
    yum clean all

# Create brick directory
RUN mkdir -p /data/brick

# Expose GlusterFS ports
EXPOSE 24007 24008 49152-49156

# Start GlusterFS daemon
CMD ["/usr/sbin/glusterd", "-N"]
