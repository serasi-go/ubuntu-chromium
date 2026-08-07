# Memaksa agar server proxy Binder mengizinkan jembatan WebSocket VNC tetap menyala
c.ServerApp.allow_remote_xul = True
c.ServerApp.tornado_settings = {
    'headers': {
        'Content-Security-Policy': "frame-ancestors 'self' https://*.mybinder.org https://*.gesis.org;"
    }
}
