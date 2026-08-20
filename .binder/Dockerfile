# 1. Gunakan Base Image resmi Jupyter (Sudah include Ubuntu, Python, Bash, dan JupyterLab)
FROM quay.io/jupyter/base-notebook:latest

USER root

# 2. Instal XFCE Desktop, VNC, Java, htop, dan perkakas jaringan (curl & wget)
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    dbus-x11 \
    chromium-browser \
    openjdk-17-jdk \
    net-tools \
    htop \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 3. Jalankan Chromium Tanpa Sandbox (Wajib di dalam kontainer Docker)
RUN echo '#!/bin/sh\nexec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Salin kode repositori Anda dan pastikan kepemilikannya dipegang oleh user jovyan
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_UID} ${HOME}

# 5. Kembali ke user non-root bawaan Jupyter (jovyan)
USER ${NB_USER}
WORKDIR ${HOME}

# 6. Jalankan instalasi Ekstensi Proxy Desktop Binder langsung ke lingkungan Python bawaan
RUN pip install --no-cache-dir jupyter-server-proxy git+https://github.com

# 7. Unduh noVNC & Websockify menggunakan Trik Base64 Anda (Aman menggunakan curl yang baru diinstal)
RUN mkdir -p ${HOME}/novnc ${HOME}/novnc/utils/websockify \
    && URL_NOVNC=$(echo "aHR0cHM6Ly9jb2RlbG9hZC5naXRodWIuY29tL25vVk5DL25vVk5DL3Rhci5nei9yZWZzL3RhZ3MvdjEuNS4w" | base64 -d) \
    && URL_WEBSOCKIFY=$(echo "aHR0cHM6Ly9jb2RlbG9hZC5naXRodWIuY29tL25vVk5DL3dlYnNvY2tpZnkvdGFyLmd6L3JlZnMvdGFncy92MC4xMi4w" | base64 -d) \
    && curl -sL "$URL_NOVNC" | tar -xzf - -C ${HOME}/novnc --strip-components=1 \
    && curl -sL "$URL_WEBSOCKIFY" | tar -xzf - -C ${HOME}/novnc/utils/websockify --strip-components=1 \
    && cp ${HOME}/novnc/vnc.html ${HOME}/novnc/index.html
