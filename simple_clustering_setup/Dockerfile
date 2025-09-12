FROM ubuntu:22.04

# Install SSH and MPI
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        openssh-server openmpi-bin libopenmpi-dev sudo && \
    rm -rf /var/lib/apt/lists/*

# Create SSH runtime folder
RUN mkdir -p /var/run/sshd

# Create mpiuser
RUN useradd -m mpiuser && echo "mpiuser:mpiuser" | chpasswd && adduser mpiuser sudo

# Setup SSH keys for mpiuser
RUN mkdir -p /home/mpiuser/.ssh && chown -R mpiuser:mpiuser /home/mpiuser/.ssh
COPY ssh_config/id_rsa /home/mpiuser/.ssh/id_rsa
COPY ssh_config/id_rsa.pub /home/mpiuser/.ssh/authorized_keys
RUN chmod 600 /home/mpiuser/.ssh/id_rsa /home/mpiuser/.ssh/authorized_keys && chmod 700 /home/mpiuser/.ssh

# Create shared folder
RUN mkdir -p /home/mpiuser/shared && chown -R mpiuser:mpiuser /home/mpiuser/shared

# Expose SSH port
EXPOSE 22

# Generate host keys at container startup and run SSH daemon in foreground
CMD ["/bin/bash", "-c", "ssh-keygen -A && /usr/sbin/sshd -D -e"]
