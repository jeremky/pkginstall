#!/bin/bash -e

# Messages en couleur
error() { echo -e "\033[0;31m====> $*\033[0m"; }
message() { echo -e "\033[0;32m====> $*\033[0m"; }
warning() { echo -e "\033[0;33m====> $*\033[0m"; }

# Vérification des droits root
if [[ "$EUID" -ne 0 ]]; then
  error "Droits root nécessaires"
  exit 1
fi

# Fonctions
install_packages() {
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
  if apt -y install plocate; then
    updatedb
  fi
}

enable_unattended() {
  if apt -y install unattended-upgrades; then
    dpkg-reconfigure unattended-upgrades
  fi
}

disable_tty1() {
  warning "Désactivation du tty1..."
  systemctl disable getty@tty1
  message "tty1 désactivé"
}

disable_sudofile() {
  warning "Désactivation du fichier .sudo_as_admin_successful..."
  echo 'Defaults !admin_flag' | tee /etc/sudoers.d/010_sudofile
  chmod 440 /etc/sudoers.d/010_sudofile
  message "Fichier .sudo_as_admin_successful désactivé"
}

configure_ufw() {
  if apt -y install ufw; then
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

# Exécution
case "$1" in
  desktop | server)
    cfg="$(dirname "$0")/config/$1/config.cfg"
    list="$(dirname "$0")/config/$1/packages.list"
    if [[ ! -f "$cfg" ]] || [[ ! -f "$list" ]]; then
      error "Fichier $cfg ou $list introuvable"
      exit 1
    fi
    ;;
  *)
    error "Profil inconnu : $1. Profils disponibles : desktop, server"
    exit 1
    ;;
esac

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
