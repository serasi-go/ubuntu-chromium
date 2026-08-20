FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal GUI Desktop, Java, dependensi, dan perbaikan untuk Ubuntu 22.04 (PEP 668)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    git \
    sudo \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    dbus-x11 \
    chromium-browser \
    openjdk-17-jdk \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

# 2. Atur konfigurasi User khusus Binder (UID wajib 1000)
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# 3. Jalankan Chromium Tanpa Sandbox (Wajib di dalam Docker)
RUN echo '#!/bin/sh\nexec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Salin kode repositori dan ubah kepemilikan folder ke user jovyan
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_UID} ${HOME}

# 5. Beralih ke user non-root untuk langkah berikutnya
USER ${NB_USER}
WORKDIR ${HOME}

# 6. Daftarkan folder binary lokal ke dalam PATH sistem
ENV PATH="${HOME}/.local/bin:${PATH}"

# 7. Instal Jupyter & Ekstensi Proxy Resmi Binder menggunakan `--break-system-packages`
# Di Ubuntu 22.04+, pip memblokir instalasi global di luar venv secara default
RUN pip3 install --no-cache-dir --break-system-packages jupyterlab notebook jupyter-server-proxy

# 8. Instal Desktop Proxy secara benar agar skrip startup otomatis terkonfigurasi
RUN pip3 install --no-cache-dir --break-system-packages git+https://github.com

# 9. Unduh noVNC & Websockify menggunakan Trik Base64 Anda (Opsional jika ingin fallback manual)
RUN mkdir -p ${HOME}/novnc ${HOME}/novnc/utils/websockify \
    && URL_NOVNC=$(echo "aHR0cHM6Ly9jb2RlbG9hZC5naXRodWIuY29tL25vVk5DL25vVk5DL3Rhci5nei9yZWZzL3RhZ3MvdjEuNS4w" | base64 -d) \
    && URL_WEBSOCKIFY=$(echo "aHR0cHM6Ly9jb2RlbG9hZC5naXRodWIuY29tL25vVk5DL3dlYnNvY2tpZnkvdGFyLmd6L3JlZnMvdGFncy92MC4xMi4w" | base64 -d) \
    && curl -sL "$URL_NOVNC" | tar -xzf - -C ${HOME}/novnc --strip-components=1 \
    && curl -sL "$URL_WEBSOCKIFY" | tar -xzf - -C ${HOME}/novnc/utils/websockify --strip-components=1 \
    && cp ${HOME}/novnc/vnc.html ${HOME}/novnc/index.html

# 10. Perintah wajib MyBinder untuk mengeksekusi server Jupyter
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--no-browser"]
