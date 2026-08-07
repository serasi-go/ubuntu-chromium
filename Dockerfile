FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Tambahkan dependensi websockify langsung lewat apt agar binary/library C-nya stabil
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:xtradeb/apps -y && \
    apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    git \
    sudo \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    dbus-x11 \
    chromium-browser \
    openjdk-17-jdk \
    net-tools \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Konfigurasi User khusus Binder (UID wajib 1000)
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook

# Trik Agar Chromium bisa dibuka di dalam container (Tanpa Sandbox)
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 2. Salin isi repositori dan WAJIB pastikan permission root dialihkan ke user jovyan
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

# 3. Pindah kembali ke user jovyan untuk proses instalasi pip
USER ${NB_USER}
WORKDIR ${HOME}

# 4. Tambahkan path Python lokal ke dalam Environment Variable Binder
ENV PATH="${HOME}/.local/bin:${PATH}"

# 5. Instal paket Jupyter dan komponen proxy
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-remote-desktop-proxy jupyter-server-proxy
