# Use ARM64 Ubuntu 20.04 base
FROM arm64v8/ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install GlusterFS server and client plus utilities
RUN apt-get update && \
    apt-get install -y glusterfs-server glusterfs-client ssh net-tools iproute2 sudo curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create GlusterFS brick directory
RUN mkdir -p /data/brick

# Expose GlusterFS ports
EXPOSE 24007 24008 49152-49156

# Start GlusterFS daemon in non-daemonized mode
CMD ["/usr/sbin/glusterd", "-N"]
