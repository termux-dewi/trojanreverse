# --- Stage 1: base ---
FROM alpine:3.18

# Set timezone & env
ENV TZ=Asia/Jakarta

# Install dependencies
RUN apk add --no-cache \
    curl \
    bash \
    tzdata \
    ca-certificates \
    nginx \
    supervisor \
    openssl \
    unzip \
    curl \
    wget \
    && mkdir -p /run/nginx

# --- Stage 2: install Xray ---
RUN XRAY_VER=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f4) \
    && echo "Downloading Xray version: $XRAY_VER" \
    && wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VER}/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm -rf /tmp/xray.zip

# --- Stage 3: copy configs ---
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY xray/config.json /etc/xray/config.json
COPY certs /etc/ssl/certs

# --- Stage 4: supervisord config ---
RUN mkdir -p /etc/supervisor.d
RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisord.conf

RUN echo "[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autorestart=true
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
" > /etc/supervisor.d/nginx.ini

RUN echo "[program:xray]
command=/usr/local/bin/xray run -c /etc/xray/config.json
autorestart=true
stdout_logfile=/dev/stdout
stderr_logfile=/dev/stderr
" > /etc/supervisor.d/xray.ini

# --- Stage 5: expose port ---
EXPOSE 443

# --- Stage 6: start supervisord ---
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
