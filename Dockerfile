# Dockerfile - Debian base, includes jq and ttyd for web terminal
FROM debian:bookworm-slim

ARG IMAGE_VERSION=dev

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash jq ca-certificates curl git \
      build-essential \
      # ttyd may not be in minimal repos in some images; try apt first
      ttyd || true && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy your scheduler script (tests/shift_scheduler.sh)
COPY tests/shift_scheduler.sh /app/shift_scheduler.sh
RUN chmod +x /app/shift_scheduler.sh

# record built image version for runtime inspection (used to prove canary vs stable)
ARG IMAGE_VERSION
RUN echo "${IMAGE_VERSION}" > /app/VERSION

VOLUME ["/data"]
EXPOSE 8080

# Start a web-terminal that runs the scheduler (ttyd). If ttyd not available,
# fall back to running the script directly so pod will still run the app.
CMD ["/bin/bash","-lc","if command -v ttyd >/dev/null 2>&1; then exec ttyd -p 8080 -c root:root bash -lc '/app/shift_scheduler.sh'; else exec /app/shift_scheduler.sh; fi"]
