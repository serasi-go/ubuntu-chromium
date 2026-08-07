FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal GUI Desktop, Java, dan dependensi sistem dasar
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
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
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Salin kode repositori dan ubah kepemilikan folder ke user jovyan
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

# 5. Kembali ke user non-root untuk instalasi paket python dan noVNC
USER ${NB_USER}
WORKDIR ${HOME}

# 6. Unduh noVNC & Websockify menggunakan Trik Base64 Anda (Disesuaikan untuk Binder)
RUN mkdir -p ${HOME}/novnc ${HOME}/novnc/utils/websockify \
    && URL_NOVNC=$(echo "aHR0cHM6Ly9jb2RlbG9hZC5naXRodWIuY29tL25vVk5DL25vVk5DL3Rhci5nei9yZWZzL3RhZ3MvdjEuNS4w" | base64 -d) \
    && URL_WEBSOCKIFY=$(echo "aHR0cHM6Ly9jb2RlbG9hZC5naXRodWIuY29tL25vVk5DL3dlYnNvY2tpZnkvdGFyLmd6L3JlZnMvdGFncy92MC4xMi4w" | base64 -d) \
    && curl -sL "$URL_NOVNC" | tar -xzf - -C ${HOME}/novnc --strip-components=1 \
    && curl -sL "$URL_WEBSOCKIFY" | tar -xzf - -C ${HOME}/novnc/utils/websockify --strip-components=1 \
    && cp ${HOME}/novnc/vnc.html ${HOME}/novnc/index.html

# 7. Daftarkan folder binary lokal ke dalam PATH sistem
ENV PATH="${HOME}/.local/bin:${PATH}"

# 8. Instal Jupyter dan Ekstensi Proxy Resmi Binder
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-server-proxy jupyter-remote-desktop-proxy
