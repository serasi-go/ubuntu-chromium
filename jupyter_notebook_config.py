import os

c = get_config()  # noqa

# Konfigurasi proxy otomatis untuk Webserver Jetty
c.ServerProxy.servers = {
    'jetty-server': {
        # Ganti 'nama_file_jetty_anda.jar' sesuai nama asli file JAR Anda
        'command': ['java', '-jar', f'{os.environ["HOME"]}/nama_file_jetty_anda.jar'],
        'port': 8099,
        'launcher_entry': {
            'enabled': True,
            'title': 'Buka Server Jetty',
            'icon_path': None
        }
    }
}


#netstat -tuln | grep 8099
#java -jar nama_file_jetty_anda.jar
