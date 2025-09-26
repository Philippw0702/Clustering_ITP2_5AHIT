FROM debian:stable-slim

# Install ping and curl (for healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping curl \
    && rm -rf /var/lib/apt/lists/*

# Copy healthcheck script
COPY healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

CMD ["sleep", "infinity"]

HEALTHCHECK --interval=10s --timeout=5s --retries=3 CMD /usr/local/bin/healthcheck.sh
