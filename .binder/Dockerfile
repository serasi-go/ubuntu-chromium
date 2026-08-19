# Menggunakan base image resmi Jupyter yang sudah mendukung visual desktop
FROM jupyter/base-notebook:latest

USER root

# Instal Chromium dan server display virtual
RUN apt-get update && apt-get install -y \
    chromium-browser \
    xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instal ekstensi untuk memunculkan layar Linux Desktop di browser Jupyter
RUN pip install jupyter-remote-desktop-proxy

# Kembalikan user ke user default MyBinder demi keamanan
USER ${NB_USER}

