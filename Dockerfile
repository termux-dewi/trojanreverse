FROM alpine:3.18

# Install dependencies
RUN apk add --no-cache bash curl wget unzip nginx screen ca-certificates tzdata

# Set timezone
ENV TZ=Asia/Jakarta

# --- Install Xray ---
RUN XRAY_VER=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f4) \
    && echo "Downloading Xray version: $XRAY_VER" \
    && wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm -rf /tmp/xray.zip

# Copy configs
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY xray/config.json /etc/xray/config.json
COPY certs /etc/ssl/certs

# Create folders for nginx
RUN mkdir -p /run/nginx /var/log/nginx

# Expose port
EXPOSE 443

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
