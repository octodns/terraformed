FROM ghcr.io/opentofu/opentofu:1.13-minimal AS tofu
FROM alpine:3

# Copy the tofu binary from the minimal image
COPY --from=tofu /usr/local/bin/tofu /usr/local/bin/tofu

WORKDIR /terraformed
