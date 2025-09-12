# Clustering implementation documentation

## Basic Multi-Container Debian Network with Health Checks

This setup runs four Debian containers (8GB memory each) for starters that can communicate with each other via Docker’s internal bridge network.

A healthcheck ensures containers can ping each other.

### Dockerfile :

Defines the Debian image, installs tools (ping, curl), copies the healthcheck script, and sets up the default command and healthcheck.

### Healthcheck : 

Simple script that pings all other containers to confirm network connectivity. If one fails, the container is marked as unhealthy.

### docker-compose : 

Orchestrates four containers (deb1–deb4), applies memory limits (8GB each), sets hostnames, and places them on the same network.