# Use the latest Alpine Linux for a minimal base image
FROM alpine:3.18

# Install Tor, Privoxy, and Socat
RUN apk --no-cache add tor privoxy socat

# Avoid running services as root for security reasons
RUN adduser -D -g '' privoxyuser && \
    adduser -D -g '' toruser && \
    chown privoxyuser /etc/privoxy && \
    chown toruser /etc/tor

# Create Tor data directory and set proper ownership
RUN mkdir -p /var/lib/tor && chown toruser:toruser /var/lib/tor

## Set up OpenRC
RUN mkdir /run/openrc && \
    touch /run/openrc/softlevel

# Add custom configurations for Tor and Privoxy
COPY torrc /etc/tor/torrc
COPY privoxy-config /etc/privoxy/config

# Expose Tor SOCKS, Privoxy, and Tor Control ports
EXPOSE 9050 9051 8118

CMD socat TCP-LISTEN:9052,fork TCP:127.0.0.1:9050 & \
    socat TCP-LISTEN:8119,fork TCP:127.0.0.1:8118 & \
    socat TCP-LISTEN:9053,fork TCP:127.0.0.1:9051 & \
    tor & privoxy --no-daemon /etc/privoxy/config
