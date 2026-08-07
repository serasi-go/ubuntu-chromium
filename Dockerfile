FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal semua dependensi OS
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

# 2. Konfigurasi User khusus Binder (UID wajib 1000)
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook

# 3. Trik Agar Chromium bisa dibuka Tanpa Sandbox
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 4. Salin isi repositori dan kelola permission
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

# 5. Pindah ke user jovyan untuk eksekusi pip
USER ${NB_USER}
WORKDIR ${HOME}

# 6. WAJIB: Daftarkan Path python lokal ke Environment Variable Binder
ENV PATH="${HOME}/.local/bin:${PATH}"

# 7. Instal paket Jupyter dan Extension Desktop Proxy resmi
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-server-proxy jupyter-remote-desktop-proxy
