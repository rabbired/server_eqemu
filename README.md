# EQEmu Server for Docker

docker run -p 9080:9080 -p 9000:9000/udp -p 7000-7100:7000-7100/udp -v [you_eqemu_config] -d rabbired/server_eqemu

# Requirements

docker run --restart=always --name [name] -v [you_eqemu_data]:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=[root_pass] \
-e MYSQL_USER=[eqemu_user] -e MYSQL_PASSWORD=[eqemu_pass] -d mariadb:latest

# Optional
--restart=always
Added automatic startup setting to [docker run] line.
