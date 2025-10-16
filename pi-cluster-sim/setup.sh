#!/bin/bash
echo "=== Starting GlusterFS RAID10-style Cluster ==="

# 1. Probe peers
docker exec node1 gluster peer probe node2
docker exec node1 gluster peer probe node3
docker exec node1 gluster peer probe node4

# 2. Wait for cluster formation
sleep 5
docker exec node1 gluster peer status

# 3. Create a RAID10 volume:
echo "--- Creating RAID10-style volume gv0 ---"
docker exec node1 gluster volume create gv0 replica 2 transport tcp \
  node1:/data/brick node2:/data/brick \
  node3:/data/brick node4:/data/brick force

# 4. Start volume
docker exec node1 gluster volume start gv0

# 5. Check info
docker exec node1 gluster volume info

# 6. Mount it on node1
docker exec node1 mkdir -p /mnt/gv0
docker exec node1 mount -t glusterfs node1:/gv0 /mnt/gv0

# 7. Mount on node2
docker exec node2 mkdir -p /mnt/gv0
docker exec node2 mount -t glusterfs node1:/gv0 /mnt/gv0

# 8. Test file
docker exec node1 sh -c "echo 'Hello RAID10!' > /mnt/gv0/testfile.txt"
docker exec node2 cat /mnt/gv0/testfile.txt

echo "=== RAID10-style GlusterFS cluster ready ==="
