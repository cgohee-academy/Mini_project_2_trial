# Dockerfile for Mini Project 1
FROM debian:bookworm-slim
 
# Install bash & jq
RUN apt-get update && apt-get install -y --no-install-recommends bash jq && rm -rf /var/lib/apt/lists/*
 
# App files
WORKDIR /app
COPY tests/shift_scheduler.sh /app/shift_scheduler.sh
RUN chmod +x /app/shift_scheduler.sh
 
# Data directory (to be mounted as a volume)
VOLUME ["/data"]
ENV DATA_FILE=/data/shifts.json
 
ENTRYPOINT ["/app/shift_scheduler.sh"]
