FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal Xvfb, Openbox (GUI Standar), Java, dan Chromium
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    htop \
    git \
    sudo \
    openbox \
    dbus-x11 \
    chromium-browser \
    openjdk-17-jdk \
    net-tools \
    xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Atur konfigurasi User khusus Binder (UID wajib 1000)
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

# 3. Jalankan Chromium Tanpa Sandbox secara otomatis saat dipanggil
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Instal pustaka inti Jupyter Hub & Proxy Desktop Resmi
RUN pip3 install --no-cache-dir jupyterlab notebook jupyter-server-proxy jupyter-remote-desktop-proxy

# 5. Salin kode repositori dan kelola permission folder secara menyeluruh
COPY . ${HOME}
RUN chown -R ${NB_UID}:${NB_UID} ${HOME}

# 6. Jalankan environment sebagai user jovyan
USER ${NB_USER}
WORKDIR ${HOME}
ENV PATH="${HOME}/.local/bin:${PATH}"

 

#chromium-browser --no-sandbox
