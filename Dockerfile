FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal dependensi OS, XFCE Desktop, dan Java OpenJDK
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

# 3. Jalankan Chromium Tanpa Sandbox (Wajib agar bisa dibuka di container)
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Salin kode repositori dan ubah kepemilikan folder ke user jovyan
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

# 5. Kembali ke user non-root untuk instalasi paket python
USER ${NB_USER}
WORKDIR ${HOME}

# 6. Daftarkan folder binary lokal ke dalam PATH sistem
ENV PATH="${HOME}/.local/bin:${PATH}"

# 7. Instal Jupyter dan Ekstensi Proxy Resmi Binder
# (Paket jupyter-remote-desktop-proxy ini akan mengurus noVNC secara otomatis dan aman)
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-server-proxy jupyter-remote-desktop-proxy
