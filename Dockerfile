FROM ubuntu:18.04

RUN mkdir /home/eqemu && mkdir /home/eqemu/server && mkdir /home/eqemu/server/sql

WORKDIR /home/eqemu

RUN apt-get -y update && \
apt-get install -yqq libstdc++6 build-essential gcc-5 g++-5 libtool cmake curl debconf-utils git git-core \
libio-stringy-perl liblua5.1 liblua5.1-dev libluabind-dev libmysql++ libperl-dev libperl5i-perl libsodium-dev \
libmysqlclient-dev lua5.1 minizip make mariadb-client unzip uuid-dev zlibc wget

RUN wget http://ftp.us.debian.org/debian/pool/main/libs/libsodium/libsodium-dev_1.0.11-2_amd64.deb -O ./libsodium-dev.deb && \
wget http://ftp.us.debian.org/debian/pool/main/libs/libsodium/libsodium18_1.0.11-2_amd64.deb -O ./libsodium18.deb && \
dpkg -i ./libsodium*.deb && \
mv ./libsodium*.deb ./server/

RUN git clone --depth 1 https://github.com/EQEmu/Server.git && \
git clone https://github.com/Akkadius/EQEmuInstall.git --depth 1 && \
mkdir /home/eqemu/Server/build

WORKDIR /home/eqemu/Server/build

RUN cmake -DEQEMU_ENABLE_BOTS=ON -DEQEMU_BUILD_LOGIN=OFF -DEQEMU_BUILD_LUA=ON -G "Unix Makefiles" .. && make -j2

RUN cp -rf /home/eqemu/EQEmuInstall/linux/* /home/eqemu/server && \
cp -rf /home/eqemu/Server/build/bin/* /home/eqemu/server && \
cp -rf /home/eqemu/Server/utils/defaults/* /home/eqemu/server && \
cp -rf /home/eqemu/Server/utils/patches/* /home/eqemu/server && \
rm -rf /home/eqemu/server/Maps /home/eqemu/server/quests /home/eqemu/server/plugins /home/eqemu/server/lua_modules

FROM ubuntu:18.04

MAINTAINER RedZ "rabbired@outlook.com"

COPY --from=build /home/eqemu/server /mnt/eqemu

WORKDIR /mnt/eqemu

RUN apt-get update && \
apt-get install -y -qq mariadb-client liblua5.1 libmysql++ libperl5i-perl lua5.1 \
zlibc wget unzip libjson-perl libswitch-perl libio-stringy-perl iputils-ping curl && \
dpkg -i ./libsodium*.deb && \
rm -rf ./libsodium*.deb && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* ./sql/*

EXPOSE 9080/tcp 9000/udp 7778/udp 7000-7100/udp

COPY server.pl ./

CMD ["perl","./server.pl"]
