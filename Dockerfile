# Default base image - multi-arch capable
FROM --platform=$TARGETPLATFORM alpine:latest

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG BUILDTIME
ARG VERSION
ARG REVISION

# Install basic utilities
RUN apk add --no-cache \
    curl \
    wget \
    ca-certificates \
    tzdata \
    && rm -rf /var/cache/apk/*

# Add labels
LABEL org.opencontainers.image.created="${BUILDTIME}"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.revision="${REVISION}"
LABEL org.opencontainers.image.platform="${TARGETPLATFORM}"

# Create a non-root user
RUN adduser -D -u 1000 appuser
USER appuser
WORKDIR /home/appuser

CMD ["sh"]