@echo off
REM -----------------------------
REM GlusterFS Test Script fuer Docker Container
REM -----------------------------

echo === Starte GlusterFS Test Cluster ===

REM 1. Peers verbinden
echo --- Probiere Peers von node1 aus ---
docker exec node1 gluster peer probe node2
docker exec node1 gluster peer probe node3
docker exec node1 gluster peer probe node4

REM 2. Pruefe Peer Status
echo --- Peer Status ---
docker exec node1 gluster peer status

REM 3. Volume erstellen (Replica 2 Beispiel)
echo --- Volume gv0 erstellen ---
docker exec node1 gluster volume create gv0 replica 2 transport tcp node1:/data/brick node2:/data/brick node3:/data/brick node4:/data/brick force

REM 4. Volume starten
echo --- Volume gv0 starten ---
docker exec node1 gluster volume start gv0

REM 5. Pruefe Volume Info
echo --- Volume Info ---
docker exec node1 gluster volume info

REM 6. Volume in node1 mounten
echo --- Volume in node1 mounten ---
docker exec node1 mkdir -p /mnt/gv0
docker exec node1 mount -t glusterfs node1:/gv0 /mnt/gv0

REM 7. Volume in node2 mounten
echo --- Volume in node2 mounten ---
docker exec node2 mkdir -p /mnt/gv0
docker exec node2 mount -t glusterfs node1:/gv0 /mnt/gv0

REM 8. Testdatei schreiben in node1
echo --- Testdatei in node1 erstellen ---
docker exec node1 sh -c "echo 'Hello from node1' > /mnt/gv0/testfile.txt"

echo --- Testdatei in node2 pruefen ---
docker exec node2 cat /mnt/gv0/testfile.txt

echo === Fertig! Pruefe nun manuell weitere Dateien oder Mounts ===
pause
