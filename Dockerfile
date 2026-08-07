FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal semua paket dasar visual, Chromium, dan Java
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

# 3. Jalankan Chromium Tanpa Sandbox
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Salin kode repositori dan kelola permission folder
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

# 5. Kembali ke user jovyan untuk proses Jupyter
USER ${NB_USER}
WORKDIR ${HOME}
ENV PATH="${HOME}/.local/bin:${PATH}"

# 6. Instal pustaka inti Jupyter Hub
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-server-proxy jupyter-remote-desktop-proxy
