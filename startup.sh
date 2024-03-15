#!/bin/bash

#for systemd
# set -m

# GREEN='\033[0;32m'
# echo -e "${GREEN}Systemd init system enabled."

# # systemd causes a POLLHUP for console FD to occur
# # on startup once all other process have stopped.
# # We need this sleep to ensure this doesn't occur, else
# # logging to the console will not work.
# sleep infinity &
# for var in $(compgen -e); do
# 	printf '%q=%q\n' "$var" "${!var}"
# done > /etc/docker.env
# exec /lib/systemd/systemd


# mkdir -p /run/dbus
# dbus-daemon --system

# # Remove a file that might be left from previous runs and would block systemd
# rm -f /run/nologin

# # Start systemd
# exec /sbin/init

##########################################################


if [ -n "$VNC_PASSWORD" ]; then
    echo -n "$VNC_PASSWORD" > /.password1
    x11vnc -storepasswd $(cat /.password1) /.password2
    chmod 400 /.password*
    sed -i 's/^command=x11vnc.*/& -rfbauth \/.password2/' /etc/supervisor/conf.d/supervisord.conf
    export VNC_PASSWORD=
fi

if [ -n "$X11VNC_ARGS" ]; then
    sed -i "s/^command=x11vnc.*/& ${X11VNC_ARGS}/" /etc/supervisor/conf.d/supervisord.conf
fi

if [ -n "$RESOLUTION" ]; then
    sed -i "s/1024x768/$RESOLUTION/" /usr/local/bin/xvfb.sh
fi

USER=${USER:-root}
HOME=/root
if [ "$USER" != "root" ]; then
    echo "* enable custom user: $USER"
    useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USER
    if [ -z "$PASSWORD" ]; then
        echo "  set default password to \"ubuntu\""
        PASSWORD=ubuntu
    fi
    HOME=/home/$USER
    echo "$USER:$PASSWORD" | chpasswd
    chown -R $USER:$USER ${HOME}
    [ -d "/dev/snd" ] && chgrp -R adm /dev/snd
fi
sed -i -e "s|%USER%|$USER|" -e "s|%HOME%|$HOME|" /etc/supervisor/conf.d/supervisord.conf

exec /usr/bin/tini -- supervisord -n -c /etc/supervisor/supervisord.conf