# Raspberry Pi Cluster Setup Documentation

This project sets up a distributed, fault-tolerant storage system using GlusterFS on a Raspberry Pi cluster. It includes both Docker Compose and Kubernetes configurations for flexibility.

---

## Project Structure

### **Docker Compose Setup**
- **`docker-compose.yml`**: Defines four GlusterFS nodes (`node1`, `node2`, `node3`, `node4`) with their respective volumes and network.
- **`Dockerfile`**: Builds the GlusterFS image for ARM64 architecture.
- **`setup.sh`**: Configures the GlusterFS cluster, creates a RAID10-style volume, and mounts it on the nodes.
- **`test_raid.sh`**: Tests the RAID10 setup by writing files, verifying replication, and simulating node failures.

### **Kubernetes Setup (in `pi-k8/`)**
- **`1.namespace.yaml`**: Creates a namespace (`glusterfs-cluster`) to isolate the GlusterFS resources.
- **`2.glusterfs-daemonset.yaml`**: Deploys GlusterFS on all nodes using a DaemonSet.
- **`3.glusterfs-setup-job.yaml`**: Runs a one-time Job to configure the GlusterFS cluster (peer probes, volume creation, etc.).
- **`4.glusterfs-pv-pvc.yaml`**: Defines a PersistentVolume (PV) and PersistentVolumeClaim (PVC) for the shared GlusterFS storage.
- **`5.app-deployment.yaml`**: Deploys an example application that mounts the shared GlusterFS volume.


---

## How to Run

### **Using Docker Compose (Containers on Laptop)**
1. Build the Docker image:
   ```bash
   docker-compose build
   ```
2. Start the containers:
  ```bash
    docker-compose up -d
   ```
3. Configure GlusterFS cluster:
    ```bash
    ./setup.sh
    ```

4. Test the RAID1 setup:
    ```bash
    ./testraid.sh
    ```
### **Using Kubernetes (Containers on Pis)**

1. Apply the namespace
    ```bash
    kubectl apply -f pi-k8/1.namespace.yaml
    ```

2. Deploy the GlusterFS 
    ```bash
    kubectl apply -f pi-k8/2.glusterfs-daemonset.yaml
    ```

3. Run the setup Job (peer probes)
    ```bash
    kubectl apply -f pi-k8/3.glusterfs-setup-job.yaml
    ```

4. Create the RAID10 style Volumes
    ```bash
    kubectl apply -f pi-k8/4.glusterfs-pv-pvc.yaml
    ```

5. Deploy the application:
    ```bash
    kubectl apply -f pi-k8/5.app-deployment.yaml
    ```

For Kubernetes, monitor the setup using:
    ```bash
    kubectl get pods -n glusterfs-cluster
    ```