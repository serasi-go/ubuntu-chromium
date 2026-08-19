FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal Openbox (Desktop minimalis penangkal crash) + Java + Chromium
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    htop \
    git \
    sudo \
    openbox \
    xterm \
    tigervnc-standalone-server \
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

# 3. Konfigurasi inisialisasi Desktop Openbox yang anti-disconnect
RUN mkdir -p ${HOME}/.vnc && \
    echo "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nopenbox-session &\nxterm -geometry 80x24+10+10 &" > ${HOME}/.vnc/xstartup && \
    chmod +x ${HOME}/.vnc/xstartup

# 4. Jalankan Chromium Tanpa Sandbox
RUN echo 'exec chromium-browser --no-sandbox "$@"' > /usr/local/bin/chromium && \
    chmod +x /usr/local/bin/chromium

# 5. Salin kode repositori dan kelola permission folder
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}



# 7. Instal pustaka inti Jupyter Hub & Proxy Desktop Resmi
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-server-proxy jupyter-remote-desktop-proxy



# 6. Kembali ke user jovyan untuk proses Jupyter
USER ${NB_USER}
WORKDIR ${HOME}
ENV PATH="${HOME}/.local/bin:${PATH}"
