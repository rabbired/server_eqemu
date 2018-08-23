# EQEmu Server for Docker

docker run -p 9080:9080 -p 9000:9000/udp -p 7000-7100:7000-7100/udp -v [your_eqemu_config]:/mnt/eqemu/eqemu_config.json \
-v [your_data]:/mnt/data -v [your_backups]:/mnt/eqemu/backups -d rabbired/server_eqemu

# Requirements

docker run --restart=always --name [name] -v [your_eqemu_data]:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=[root_pass] -d mariadb:latest

# Optional

--restart=always
Added automatic startup setting to [docker run] line.

-v /etc/timezone:/etc/timezone -v /etc/localtime:/etc/localtime
