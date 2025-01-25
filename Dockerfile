# Use the official HAProxy image as the base image
FROM haproxy:latest

# Copy the custom haproxy.cfg into the container
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg


