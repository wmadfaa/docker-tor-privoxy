# Use the latest Alpine Linux for a minimal base image
FROM alpine:latest

# Install Tor, Privoxy, and Socat
RUN apk --no-cache add tor privoxy socat openrc

# Avoid running services as root for security reasons
RUN adduser -D -g '' privoxyuser && \
    adduser -D -g '' toruser && \
    chown privoxyuser /etc/privoxy && \
    chown toruser /etc/tor

# Set up OpenRC
RUN mkdir /run/openrc && \
    touch /run/openrc/softlevel

# Add custom configurations for Tor and Privoxy
COPY torrc /etc/tor/torrc
COPY privoxy-config /etc/privoxy/config

# Configure OpenRC to start Tor and Privoxy
RUN rc-update add tor default && \
    rc-update add privoxy default

# Expose Tor SOCKS, Privoxy, and Tor Control ports, binding them to localhost
EXPOSE 127.0.0.1:9050 127.0.0.1:8118 127.0.0.1:9051

# Use a non-root user to run the services
USER toruser

# Start OpenRC which will manage the services
CMD ["openrc", "boot"]
