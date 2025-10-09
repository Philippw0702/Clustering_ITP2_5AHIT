#!/bin/bash
# ===============================
# GlusterFS RAID10 Test Script
# Demonstrates striping and redundancy
# ===============================

set -e  # Exit on any error
echo "=== GlusterFS RAID10 Test Script ==="

# 1. Check cluster and volume
echo "--- Cluster Info ---"
docker exec node1 gluster peer status
docker exec node1 gluster volume info gv0

# 2. Create mount points
for node in node1 node2 node3 node4; do
  docker exec $node mkdir -p /mnt/gv0
  docker exec $node mount -t glusterfs node1:/gv0 /mnt/gv0 || true
done

# 3. Write multiple test files on node1 to show striping
echo "--- Writing test files on node1 ---"
for i in $(seq 1 8); do
  docker exec node1 sh -c "echo 'File $i from node1' > /mnt/gv0/file$i.txt"
done

# 4. Verify files exist on all nodes (demonstrates replication)
echo "--- Verifying replicated files on all nodes ---"
for node in node2 node3 node4; do
  echo "--- Contents on $node ---"
  docker exec $node sh -c "ls -l /mnt/gv0; cat /mnt/gv0/file1.txt /mnt/gv0/file2.txt"
done

# 5. Demonstrate redundancy: simulate failure of a node in each replica set
echo "--- Simulating node failure for redundancy test ---"
docker stop node2
docker stop node4
sleep 3

echo "--- Reading files after node failures ---"
docker exec node1 sh -c "ls -l /mnt/gv0; cat /mnt/gv0/file1.txt /mnt/gv0/file8.txt"

# 6. Bring nodes back online
docker start node2 node4
sleep 3
echo "--- Nodes restored, verifying all files ---"
docker exec node1 sh -c "ls -l /mnt/gv0"

echo "=== Test Complete: Striping and Redundancy Demonstrated ==="
