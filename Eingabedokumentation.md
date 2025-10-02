1. Container starten:
```bash
docker compose up -d
```
2. GlusterFS in jeden Container installieren
```bash
docker exec -it node1 bash
apt update && apt install -y glusterfs-server
systemctl start glusterd
```
3. 