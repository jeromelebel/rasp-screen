#!/bin/sh

server="$1"

publickey=`cat ~/.ssh/id_rsa.pub`
ssh "pi@${server}" "mkdir -p .ssh ; echo '${publickey}' >> .ssh/authorized_keys"
ssh "pi@${server}" "cat .ssh/authorized_keys | sort | uniq > .ssh/authorized_keys.uniq"
ssh "pi@${server}" "mv .ssh/authorized_keys.uniq .ssh/authorized_keys"
ssh "pi@${server}" sudo cp -r /home/pi/.ssh /root

ssh "root@${server}" "cat /etc/ssh/sshd_config | sed 's/\#PasswordAuthentication/PasswordAuthentication/' | sed 's/PasswordAuthentication yes/PasswordAuthentication no/' > /tmp/ssh "
ssh "root@${server}" "cat /tmp/ssh | sed 's/\#PermitRootLogin/PermitRootLogin/' | sed 's/PermitRootLogin no/PermitRootLogin yes/' > /etc/ssh/sshd_config"

ssh "pi@${server}" sudo apt-get update -y
ssh "pi@${server}" sudo apt-get upgrade -y

if [ "1" = "1" ]; then
    ssh "root@${server}" mkdir -p /tmp/package
    ssh "root@${server}" wget http://adafruit-download.s3.amazonaws.com/libraspberrypi-bin-adafruit.deb
    ssh "root@${server}" wget http://adafruit-download.s3.amazonaws.com/libraspberrypi-dev-adafruit.deb
    ssh "root@${server}" wget http://adafruit-download.s3.amazonaws.com/libraspberrypi-doc-adafruit.deb
    ssh "root@${server}" wget http://adafruit-download.s3.amazonaws.com/libraspberrypi0-adafruit.deb
    ssh "root@${server}" wget http://adafruit-download.s3.amazonaws.com/raspberrypi-bootloader-adafruit-112613.deb
    ssh "root@${server}" dpkg -i -B *.deb
    ssh "root@${server}" rm -f /usr/share/X11/xorg.conf.d/99-fbturbo.conf
    ssh "root@${server}" "grep spi-bcm2708 /etc/modules || echo spi-bcm2708 >> /etc/modules"
    ssh "root@${server}" "grep fbtft_device /etc/modules || echo fbtft_device >> /etc/modules"
    ssh "root@${server}" "echo 'options fbtft_device name=adafruitts rotate=90 frequency=32000000' >> /etc/modprobe.d/adafruit.conf"
    ssh "root@${server}" "mkdir -p /etc/X11/xorg.conf.d"
    ssh "root@${server}" reboot
    sleep 20
fi

ssh "pi@${server}" true 2> /dev/null
while [ "$?" != "0" ]; do
    ssh "pi@${server}" true 2> /dev/null
done

ssh "root@${server}" apt-get install git python-dev python-setuptools avahi