#!/bin/bash -e

# Messages en couleur
error() { echo -e "\033[0;31m====> $*\033[0m"; }
message() { echo -e "\033[0;32m====> $*\033[0m"; }
warning() { echo -e "\033[0;33m====> $*\033[0m"; }

# Config
dir=$(dirname "$0")
cfg="$dir/aptinstall.cfg"
if [[ ! -f "$cfg" ]]; then
  error "Fichier $cfg introuvable"
  exit 1
fi

# Vérification des droits root
if [[ "$USER" != "root" ]]; then
  error "Droits root nécessaires"
  exit 1
fi

# Fonctions
install_packages() {
  list="$dir/config/$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"').cfg"
  warning "Mise à jour des paquets..."
  apt update && apt -y full-upgrade
  if [[ -f "$list" ]]; then
    warning "Installation des paquets..."
    grep -v '#' "$list" | xargs apt -y install || {
      error "Problème lors de l'installation des paquets"
      exit 1
    }
    message "Installation des paquets terminée"
  fi
}

enable_locate() {
  if apt install -y plocate; then
    updatedb
  fi
}

enable_unattended() {
  if apt install -y unattended-upgrades; then
    dpkg-reconfigure unattended-upgrades
  fi
}

configure_ufw() {
  if apt install -y ufw; then
    warning "Activation du firewall ufw..."
    sed -i "s,IPV6=yes,IPV6=no," /etc/default/ufw
    for port in 22/tcp 80/tcp 443/tcp; do
      ufw allow $port
    done
    ufw enable
    message "ufw activé"
  fi
}

configure_sshd() {
  if [[ -d /etc/ssh/sshd_config.d ]] && [[ ! -f /etc/ssh/sshd_config.d/$(id -un 1000).conf ]]; then
    warning "Sécurisation de SSH..."
    echo -e "# Secure Config\nX11Forwarding no\nAllowUsers $(id -un 1000)\nHostKey /etc/ssh/ssh_host_ed25519_key\nPasswordAuthentication yes\nKbdInteractiveAuthentication yes\nMaxAuthTries 3\nClientAliveInterval 300\nClientAliveCountMax 2\nKexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org\nMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com\nCiphers aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr" >"/etc/ssh/sshd_config.d/$(id -un 1000).conf"
    systemctl restart sshd
    message "SSH sécurisé. Modifiez le fichier /etc/ssh/sshd_config.d/$(id -un 1000).conf pour désactiver la connexion par mot de passe après avoir importé votre clé ed25519."
  fi
}

# Exécution des fonctions
if [[ -n "$1" ]]; then
  if declare -f "$1" >/dev/null; then
    "$1"
  else
    error "Aucune fonction ne correspond au paramètre $1"
    exit 1
  fi
else
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" == \#* ]] && continue
    if [[ "$value" == "on" ]]; then
      if declare -f "$key" >/dev/null; then
        "$key"
      else
        error "Aucune fonction ne correspond au paramètre $key"
        exit 1
      fi
    fi
  done <"$cfg"
fi
