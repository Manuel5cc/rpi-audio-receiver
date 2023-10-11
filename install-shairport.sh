#!/bin/bash -e

SHAIRPORT_VERSION=3.3.1

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

echo
echo -n "Do you want to install Shairport Sync AirPlay 1 Audio Receiver (shairport-sync)? [y/N] "
read REPLY
if [[ ! "$REPLY" =~ ^(yes|y|Y)$ ]]; then exit 0; fi

# install packages needed by shairport
apt install --no-install-recommends -y build-essential git xmltoman autoconf automake libtool libpopt-dev libconfig-dev libasound2-dev avahi-daemon libavahi-client-dev libssl-dev libsoxr-dev

# install shairport-sync
git clone https://github.com/mikebrady/shairport-sync.git
cd shairport-sync
autoreconf -fi
./configure --sysconfdir=/etc --with-alsa --with-avahi --with-ssl=openssl --with-systemd
make
sudo make install
cd ..
rm -rf shairport-sync

# set some important settings
PRETTY_HOSTNAME=$(hostnamectl status --pretty)
PRETTY_HOSTNAME=${PRETTY_HOSTNAME:-$(hostname)}

sed -i '0,/%H/{s://\tname = "%H:\tname = "'"${PRETTY_HOSTNAME}"':}' /etc/shairport-sync.conf
sed -i 's://\tinterpolation = "auto:\tinterpolation = "basic:' /etc/shairport-sync.conf

systemctl enable --now shairport-sync
