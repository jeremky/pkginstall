#!/bin/bash -e

# Vérification des droits root
if [[ "$USER" != "root" ]]; then
  echo "Droits root nécessaires"
  exit 0
fi

# Config selon la distribution
dist=$(cat /etc/os-release | grep "^ID=" | cut -d= -f2,2)
list="$(dirname "$0")/config/$dist.lst"

# Installation des paquets
case $dist in
  debian)
    apt update && apt -y full-upgrade
    if [[ -f $list ]]; then
      apt -y install $(cat $list | grep -v '#')
      # Activation des mises à jour automatiques
      if [[ -f /usr/bin/unattended-upgrades ]]; then
        dpkg-reconfigure unattended-upgrades
      fi
    fi
    ;;
  fedora)
    dnf upgrade -y
    if [[ -f $list ]]; then
      dnf -y install $(cat $list | grep -v '#')
    fi
    ;;
esac

# Activation de locate
if [[ -f /usr/bin/locate ]]; then
  updatedb
fi

# Sécurisation de ssh (check sur https://www.ssh-audit.com/#)
if [[ ! -f /etc/ssh/sshd_config.old && -f /etc/ssh/sshd_config ]]; then
  cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.old
  echo "" >> /etc/ssh/sshd_config 
  echo -e "# Secure Config\nX11Forwarding no\nAllowUsers $(id -un 1000)\nHostKey /etc/ssh/ssh_host_ed25519_key\nPasswordAuthentication yes\nKexAlgorithms curve25519-sha256@libssh.org\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com\nCiphers aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr" >> /etc/ssh/sshd_config
  systemctl restart sshd
fi

# Correction du bug fail2ban
if [[ -f /etc/fail2ban/jail.conf ]]; then
  sed -i "s,backend = %(sshd_backend)s,backend = systemd," /etc/fail2ban/jail.conf
  systemctl restart fail2ban
fi

# Activation du Firewall (avec désactivation de l'IP v6)
if [[ -f /usr/sbin/ufw ]]; then
  sed -i "s,IPV6=yes,IPV6=no," /etc/default/ufw
  ufw allow ssh
  ufw enable
fi
