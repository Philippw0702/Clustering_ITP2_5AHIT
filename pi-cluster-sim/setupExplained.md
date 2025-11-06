# Raspberry Pi Cluster Setup Guide

Complete step-by-step guide to set up a Kubernetes cluster on Raspberry Pi devices.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Part 1: Connect to a Single Raspberry Pi](#part-1-connect-to-a-single-raspberry-pi)
3. [Part 2: Initial System Setup on Each Pi](#part-2-initial-system-setup-on-each-pi)
4. [Part 3: Install Docker on Each Pi](#part-3-install-docker-on-each-pi)
5. [Part 4: Install Kubernetes on Each Pi](#part-4-install-kubernetes-on-each-pi)
6. [Part 5: Initialize Kubernetes Master Node](#part-5-initialize-kubernetes-master-node)
7. [Part 6: Join Worker Nodes to Cluster](#part-6-join-worker-nodes-to-cluster)
8. [Part 7: Deploy Your Application](#part-7-deploy-your-application)

---

## Prerequisites

### Hardware
- 3+ Raspberry Pi 4 (4GB RAM recommended)
- MicroSD cards (32GB+ recommended)
- Network switch and Ethernet cables
- Power supplies for each Pi

### Software
- Raspberry Pi OS Lite (64-bit) installed on each SD card
- SSH client on your computer (PuTTY for Windows, built-in Terminal for macOS/Linux)

### Network Setup
- All Raspberry Pis connected to the same network
- Static IP addresses assigned to each Pi (recommended)

---

## Part 1: Connect to a Single Raspberry Pi

### Step 1: Enable SSH on Raspberry Pi

If you haven't already enabled SSH during the OS installation:

1. Insert the SD card into your computer
2. Create an empty file named `ssh` (no extension) in the boot partition
3. Eject the SD card and insert it into the Raspberry Pi
4. Power on the Raspberry Pi

### Step 2: Find Your Pi's IP Address

**Option A: Check your router's admin panel**
- Log into your router
- Look for connected devices
- Find devices named "raspberrypi"

**Option B: Use network scanning tools**
```bash
# On Linux/macOS
sudo nmap -sn 192.168.1.0/24

# On Windows (install Advanced IP Scanner)
# Scan your local network range
```

**Option C: Connect a monitor and keyboard**
```bash
hostname -I
```

### Step 3: Connect via SSH

```bash
# Default credentials:
# Username: pi
# Password: raspberry

ssh pi@<IP_ADDRESS>
# Example: ssh pi@192.168.1.100
```

When prompted, type `yes` to accept the fingerprint, then enter the password.

### Step 4: Change Default Password (IMPORTANT!)

```bash
passwd
```

Enter the current password, then set a new secure password.

---

## Part 2: Initial System Setup on Each Pi

Perform these steps on **EACH** Raspberry Pi.

### Step 1: Update the System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### Step 2: Set Static IP Address (Recommended)

Edit the dhcpcd configuration:
```bash
sudo nano /etc/dhcpcd.conf
```

Add at the end (adjust to your network):
```
interface eth0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

**Note:** Use different IP addresses for each Pi:
- Master: 192.168.1.100
- Worker1: 192.168.1.101
- Worker2: 192.168.1.102
- etc.

Reboot to apply:
```bash
sudo reboot
```

### Step 3: Set Hostname

SSH back in and set unique hostnames for each Pi:

```bash
# On Master node:
sudo hostnamectl set-hostname k8s-master

# On Worker nodes:
sudo hostnamectl set-hostname k8s-worker1
sudo hostnamectl set-hostname k8s-worker2
# etc.
```

### Step 4: Update /etc/hosts

Edit the hosts file:
```bash
sudo nano /etc/hosts
```

Add all nodes (on EACH Pi):
```
192.168.1.100 k8s-master
192.168.1.101 k8s-worker1
192.168.1.102 k8s-worker2
```

### Step 5: Disable Swap

Kubernetes requires swap to be disabled:
```bash
sudo dphys-swapfile swapoff
sudo dphys-swapfile uninstall
sudo systemctl disable dphys-swapfile
```

### Step 6: Enable cgroups

Edit boot configuration:
```bash
sudo nano /boot/firmware/cmdline.txt
```

Add to the end of the existing line (do NOT create a new line):
```
cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory
```

Reboot:
```bash
sudo reboot
```

---

## Part 3: Install Docker on Each Pi

Perform on **EACH** Raspberry Pi.

### Step 1: Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Step 2: Add Pi User to Docker Group

```bash
sudo usermod -aG docker pi
```

Log out and log back in for the group change to take effect:
```bash
exit
# SSH back in
ssh pi@<IP_ADDRESS>
```

### Step 3: Verify Docker Installation

```bash
docker --version
docker run hello-world
```

### Step 4: Configure Docker Daemon

Create daemon configuration:
```bash
sudo nano /etc/docker/daemon.json
```

Add the following:
```json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
```

Restart Docker:
```bash
sudo systemctl restart docker
sudo systemctl enable docker
```

---

## Part 4: Install Kubernetes on Each Pi

Perform on **EACH** Raspberry Pi.

### Step 1: Add Kubernetes Repository

```bash
# Add GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### Step 2: Install Kubernetes Components

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### Step 3: Enable kubelet Service

```bash
sudo systemctl enable kubelet
```

---

## Part 5: Initialize Kubernetes Master Node

Perform **ONLY on the MASTER** node.

### Step 1: Initialize the Cluster

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=<MASTER_IP>
# Example: sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.1.100
```

**IMPORTANT:** Save the `kubeadm join` command that appears at the end of the output. You'll need it for worker nodes.

Example output:
```
kubeadm join 192.168.1.100:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### Step 2: Configure kubectl for Pi User

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Step 3: Install Pod Network (Flannel)

```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

### Step 4: Verify Master Node Status

```bash
kubectl get nodes
```

Wait until the master node shows `Ready` status (may take 1-2 minutes).

---

## Part 6: Join Worker Nodes to Cluster

Perform on **EACH WORKER** node.

### Step 1: Join the Cluster

Use the `kubeadm join` command from Step 5.1:

```bash
sudo kubeadm join 192.168.1.100:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

### Step 2: Verify from Master Node

SSH back to the master node and check:

```bash
kubectl get nodes
```

You should see all nodes listed. Wait until all show `Ready` status.

### Troubleshooting: Token Expired

If your token expired, generate a new one on the master:

```bash
# On master node
kubeadm token create --print-join-command
```

---

## Part 7: Deploy Your Application

From the **MASTER** node.

### Step 1: Create a Namespace (Optional)

```bash
kubectl create namespace glusterfs-cluster
```

### Step 2: Apply Your Deployment

Assuming you have your deployment YAML files:

```bash
# Deploy GlusterFS
kubectl apply -f glusterfs-deployment.yaml

# Deploy services
kubectl apply -f glusterfs-service.yaml
```

### Step 3: Verify Deployment

```bash
# Check pods
kubectl get pods -n glusterfs-cluster

# Check services
kubectl get svc -n glusterfs-cluster

# Check detailed pod info
kubectl describe pod <pod-name> -n glusterfs-cluster
```

### Step 4: View Logs

```bash
kubectl logs <pod-name> -n glusterfs-cluster
```

### Step 5: Access Your Services

```bash
# Get service details
kubectl get svc -n glusterfs-cluster

# If using NodePort, access via:
http://<any-node-ip>:<node-port>
```

---

## Common Commands Reference

### Cluster Management
```bash
# View all nodes
kubectl get nodes

# View all pods in all namespaces
kubectl get pods --all-namespaces

# View cluster info
kubectl cluster-info

# View all resources
kubectl get all -n <namespace>
```

### Troubleshooting
```bash
# Describe a pod
kubectl describe pod <pod-name> -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>

# Execute command in pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash

# Delete and recreate a pod
kubectl delete pod <pod-name> -n <namespace>
```

### Reset Cluster (if needed)
```bash
# On each node
sudo kubeadm reset
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config

# Then re-initialize from master
```

---

## Network Diagram

```
Internet
    |
Router (192.168.1.1)
    |
    +-- Switch
         |
         +-- k8s-master  (192.168.1.100)
         +-- k8s-worker1 (192.168.1.101)
         +-- k8s-worker2 (192.168.1.102)
```

---

## Security Recommendations

1. Change default passwords on all Pis
2. Set up SSH key authentication
3. Disable password authentication in SSH
4. Enable firewall (ufw)
5. Keep systems updated regularly
6. Use network policies in Kubernetes
7. Enable RBAC (Role-Based Access Control)

---

Raspberry IPs:
- 192.168.88.195
- 192.168.88.196
- 192.168.88.98 -> Main Raspberry; offene Ports: 80,443
- 192.168.88.99

## Next Steps

1. Set up persistent storage (GlusterFS, NFS, etc.)
2. Install Kubernetes Dashboard for web UI
3. Set up Ingress controller for HTTP routing
4. Configure monitoring (Prometheus, Grafana)
5. Set up automatic backups

---

## Useful Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Raspberry Pi Documentation](https://www.raspberrypi.org/documentation/)
- [Docker Documentation](https://docs.docker.com/)
- [Flannel Networking](https://github.com/flannel-io/flannel)

---

**Good luck with your Raspberry Pi Kubernetes cluster!**