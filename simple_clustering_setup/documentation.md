# Simple Clustering Setup

This project demonstrates a basic clustering setup using Docker containers. It includes three nodes (`node1`, `node2`, and `node3`) where `node1` and `node2` are clustered together and write messages to a shared file, while `node3` observes the changes.

---

## Project Structure

### Files and Directories:
- **`Dockerfile`**: Defines the base image, installs required tools, and sets up the environment for the clustering nodes.
- **`docker-compose.yml`**: Orchestrates the three nodes, sets up a shared volume, and defines the network.
- **`mpi_program/write_file.sh`**: A script executed by each node to either write to or read from the shared file.
- **`mpi_program/machines.txt`**: Specifies the nodes and their slots for MPI.
- **`ssh_config/id_rsa` and `id_rsa.pub`**: SSH keys for secure communication between nodes.

---

## How It Works

1. **Node Behavior**:
   - `node1` and `node2` write messages to a shared file (`output.txt`) located in the shared volume.
   - `node3` reads the shared file and displays its contents.

2. **Shared Volume**:
   - A Docker volume (`shared_data`) is used to share the `output.txt` file between the nodes.

3. **Networking**:
   - All nodes are connected via a custom Docker network (`mpi_net`).

---

## Setup and Usage

### Prerequisites:
- Docker and Docker Compose installed on your system.

### Steps:
1. Clone the repository or ensure all files are in the same directory.
2. Build the Docker images:
   ```bash
   docker-compose build
   ```
3. Start the containers:
   ```bash
   docker-compose up
   ```
4. Verify the setup:
   - Attach to `node3` and observe the shared file:
     ```bash
     docker exec -it node3 /bin/bash
     cat /home/mpiuser/shared/output.txt
     ```

---

## File Details

### `Dockerfile`
- **Base Image**: `ubuntu:22.04`
- **Installed Tools**: SSH server, OpenMPI, and other dependencies.
- **Shared Folder**: `/home/mpiuser/shared` is created for file sharing.
- **SSH Keys**: Configured for secure communication between nodes.

### `docker-compose.yml`
- Defines three services:
  - `node1`, `node2`, and `node3`.
- Sets up:
  - A shared volume (`shared_data`).
  - A custom network (`mpi_net`).

### `write_file.sh`
- Behavior:
  - `node1` and `node2`: Write messages to `output.txt`.
  - `node3`: Reads and displays the contents of `output.txt`.

---

## Example Output

When the setup is running, the `output.txt` file will look like this:

```
Clustered Node node1 says hello at Thu Sep 25 10:30:00 UTC 2025
Clustered Node node2 says hello at Thu Sep 25 10:30:05 UTC 2025
```

`node3` will display the file contents when you check its logs or attach to the container.

---

## Troubleshooting

- **Missing `write_file.sh`**:
  Ensure the script exists at `mpi_program/write_file.sh` and is executable.
- **Containers Not Starting**:
  Check the logs:
  ```bash
  docker-compose logs
  ```
- **Shared File Not Updating**:
  Verify the volume is mounted correctly:
  ```bash
  docker volume inspect simple_clustering_setup_shared_data
  ```

---
