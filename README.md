# EQEmu Server for Docker

docker run -p 9080:9080 -p 9000:9000/udp -p 7000-7100:7000-7100/udp --volumes-from [you_emudata_containers_name] -d rabbired/emuserver

# Requirements

docker run -p 3306:3306 -v [your_config_path]:/mnt/eqemu/emucfg -v /mnt/eqemu -e MYSQL_ROOT_PASSWORD=[your_password] -d rabbired/emudata

# Optional
--restart=always
Added automatic startup setting to [docker run] line.
