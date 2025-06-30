#!/bin/bash -e

# Vérification des droits root
if [[ "$USER" != "root" ]]; then
  echo "Droits root nécessaires"
  exit 0
fi

# Chargement du fichier de config
cfg="$(dirname "$(realpath "$0")")/pkginstall.cfg"
if [[ ! -f $cfg ]]; then
  error "Fichier $cfg introuvable"
  exit 1
else
  . $cfg
fi

# Activation du Firewall (avec désactivation de l'IP v6)
if [[ -f /usr/sbin/ufw ]]; then
  if [[ $ipv6 = "false" ]]; then
    sed -i "s,IPV6=yes,IPV6=no," /etc/default/ufw
  fi
  if [[ -n "$(ufw status | grep SSH)" ]]; then
    ufw delete 1
  fi
  for port in $ports; do
    ufw allow $port
  done
  ufw enable
fi
