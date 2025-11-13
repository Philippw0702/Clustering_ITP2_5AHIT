# 🐧 Raspberry Pi: Docker & Kubernetes (k3s) Setup Guide

## 🧩 Voraussetzungen
- Raspberry Pi mit Raspberry Pi OS (64-bit, Debian-basiert)
- SSH-Zugang
- `sudo`-Rechte
- Internetverbindung

---

## 🐳 Docker installieren (ohne Swarm)

```bash
# Docker installieren
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Benutzer zur Docker-Gruppe hinzufügen
sudo usermod -aG docker $USER

# Änderungen aktivieren (Session neu starten oder)
newgrp docker

# Testen
docker run hello-world

# Docker beim Systemstart aktivieren
d sudo systemctl enable docker
d sudo systemctl start docker
```

## ☸️ Kubernetes (k3s) installieren 
1. Memory-Cgroups aktivieren:
   ```bash 
   sudo nano /boot/firmware/cmdline.txt 
   ```
   Am Ende der einzigen Zeile hinzufügen (nicht umbrechen):
   ```ini 
cgroup_memory=1 cgroup_enable=memory 
   ```
   Dann speichern und neu starten:
   ```bash 
sudo reboot 
   ```
2. k3s installieren:
   ```bash 
curl -sfL https://get.k3s.io | sh -
   ```
3. Status prüfen:
   ```bash 
sudo systemctl status k3s 
   ```
4. kubectl als normaler Benutzer verwenden:
   ```bash 
mkdir -p ~/.kube 
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config 
sudo chown $(id -u):$(id -g) ~/.kube/config 
   ```
5. Cluster testen:
   ```bash 
kubectl get nodes 
kubectl get pods -A 
   ```
✅ Fertig!
Du hast nun auf deinem Raspberry Pi sowohl Docker (Standalone) als auch Kubernetes (k3s) installiert.
Jetzt kannst du Container direkt mit `docker run` oder über YAML-Manifeste mit `kubectl apply -f` deployen.
