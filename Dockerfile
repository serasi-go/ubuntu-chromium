FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instal GUI Desktop, VNC, dan dependensi sistem
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
    websockify \
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

# 4. SALIN & ATUR SKRIP INARKHIRAN VNC (Memperbaiki layar blank/tidak tampil)
RUN mkdir -p ${HOME}/.vnc && \
    echo "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartxfce4 &" > ${HOME}/.vnc/xstartup && \
    chmod +x ${HOME}/.vnc/xstartup

# 5. Salin kode repositori dan alihkan kepemilikan folder ke jovyan
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}

# 6. Kembali ke user non-root untuk instalasi paket python
USER ${NB_USER}
WORKDIR ${HOME}

# 7. Daftarkan folder binary lokal ke dalam PATH sistem
ENV PATH="${HOME}/.local/bin:${PATH}"

# 8. Instal JupyterLab dan Desktop Extension resmi
RUN pip3 install --no-cache-dir jupyterlab notebook
RUN pip3 install --no-cache-dir jupyter-server-proxy jupyter-remote-desktop-proxy
