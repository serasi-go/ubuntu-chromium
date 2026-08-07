FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instal dependensi: Ubuntu GUI, Chromium, OpenJDK 17, dan Net-tools (untuk cek port)
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

# Salin seluruh isi repositori (termasuk file .jar dan config python)
COPY . ${HOME}
RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}

# Instal Jupyter dan komponen Web Proxy resmi
RUN pip3 install --no-cache-dir jupyterlab notebook websockify
RUN pip3 install --no-cache-dir jupyter-remote-desktop-proxy jupyter-server-proxy
