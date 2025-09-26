# Raspberry Pi Cluster with Shared Storage – Theoretical Overview

## Goal

The goal of this project is to create a cluster of four Raspberry Pi devices in which **half of each device’s storage is shared across the cluster**. This shared storage should ensure that:

- Data remains available even if one Raspberry Pi fails.
- Multiple nodes can access and write to the same storage simultaneously.
- The system provides redundancy and fault tolerance for critical data.

Essentially, we want to design a **distributed, highly available storage system** for a small-scale Raspberry Pi cluster.

---

## Key Components

### Docker Swarm

- **Role:** Orchestrates containers across multiple Raspberry Pi devices, treating them as a single virtual system.
- **Purpose in this setup:** Ensures that services and applications can run reliably across the cluster, even if one node fails.
- **Relevance:** Facilitates the deployment of containerized workloads that depend on the shared storage.

### GlusterFS

- **Role:** A distributed filesystem that aggregates storage from multiple nodes into a single namespace.
- **Purpose in this setup:** Makes a portion of storage from each Raspberry Pi available to all others in the cluster.
- **Relevance:** Provides **replication and redundancy**, ensuring that the data is mirrored across all nodes.

---

## Theoretical Workflow

1. **Storage Contribution**: Each Raspberry Pi contributes a defined portion of its local storage to a global, shared volume.
2. **Replication**: GlusterFS replicates data across multiple nodes, so every file exists on multiple devices.  
3. **Fault Tolerance**: If one Raspberry Pi fails, the data remains accessible from the other nodes.
4. **Access by Services**: Docker Swarm services can mount the shared volume and read/write data as if it were local.

---

## Why This Should Work

- **Redundancy**: With replication, data exists on multiple nodes. Losing a single Raspberry Pi does not result in data loss.
- **High Availability**: Services can continue to operate on remaining nodes without interruption.
- **Unified Namespace**: GlusterFS provides a single, shared filesystem view, simplifying access for applications.
- **Scalability**: Additional Raspberry Pis can be added to the cluster to increase both compute and storage capacity.
- **Networked Coordination**: Docker Swarm handles orchestration, ensuring that services are aware of all nodes in the cluster.

---

## Assumptions

- Each Raspberry Pi has a stable network connection to the others.
- The network is fast enough to handle replication traffic without significant latency.
- Each node has sufficient free storage to contribute to the shared volume.
- The applications accessing the shared storage can tolerate network latency typical of a distributed filesystem.

---

## Summary

By combining **Docker Swarm** and **GlusterFS**, we create a **small-scale, fault-tolerant storage cluster** using Raspberry Pis. The theoretical design ensures that:

- Data is replicated and highly available.
- Containerized services can seamlessly access shared storage.
- The cluster can survive individual node failures while maintaining access to critical data.

This approach provides a practical introduction to distributed storage and container orchestration concepts on low-power hardware.

## Source:

https://www.youtube.com/watch?v=Has6lUPdzzY&t=268s 


