#!/bin/dash
set -e

## Variables
dir=$(dirname "$0")
cfg="$dir/$(basename -s .sh $0).cfg"
list="$dir/$(basename -s .sh $0).lst"

## Verification de l'OS
if [ ! -f /usr/bin/apt ]; then
    echo "OS incompatible !"
    exit 0
fi

## User
if [ "$USER" != "root" ] ; then
    echo "Droits root nécessaires"
    exit 0
fi

## Vérification de la présence des fichiers
if [ -f $cfg ] ; then
    . $cfg
else
    echo "Fichier $cfg introuvable"
    exit 0
fi
if [ ! -f $list ] ; then
    echo "Fichier $list introuvable"
    exit 0
fi

## Installation des paquets
apt update && apt -y dist-upgrade
apt -y install $(cat $list | grep -v '#')

## Activation de locate
if [ -f /usr/bin/locate ] ; then
    updatedb
fi

## Activation des mises à jour automatiques
if [ -f /usr/bin/unattended-upgrades ] ; then
    dpkg-reconfigure unattended-upgrades
fi

## Sécurisation de ssh (check sur https://www.ssh-audit.com/#)
if [ ! -f /etc/ssh/sshd_config.old ] ; then
    cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.old
    echo "" >> /etc/ssh/sshd_config 
    echo "# Secure Config\nX11Forwarding no\nAllowUsers $user\nHostKey /etc/ssh/ssh_host_ed25519_key\nPasswordAuthentication yes\nKexAlgorithms curve25519-sha256@libssh.org\nMACs hmac-sha2-512,hmac-sha2-256,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com\nCiphers -chacha20-poly1305@openssh.com" >> /etc/ssh/sshd_config
    systemctl restart sshd
fi

## Activation du Firewall
if [ -f /usr/sbin/ufw ] ; then
    for ufwallow in $ufwlist ; do
        ufw allow $ufwallow
    done
    ufw enable
fi
