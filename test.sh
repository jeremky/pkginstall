#!/bin/bash -e

# Messages en couleur
error()    { echo -e "\033[0;31m====> $*\033[0m" ;}
message()  { echo -e "\033[0;32m====> $*\033[0m" ;}
warning()  { echo ; echo -e "\033[0;33m====> $*\033[0m" ;}

# Vérification des droits root
if [[ "$USER" != "root" ]]; then
  error "Droits root nécessaires"
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

# Installation de NerdFont
if [[ $nerdfont = true ]]; then
  warning "Installation de NerdFont..."
  version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)
  rm -fr /usr/share/fonts/jetbrains-mono-nerd-fonts
  mkdir -p /usr/share/fonts/jetbrains-mono-nerd-fonts
  wget -P /usr/share/fonts/jetbrains-mono-nerd-fonts https://github.com/ryanoasis/nerd-fonts/releases/download/$version/JetBrainsMono.zip
  cd /usr/share/fonts/jetbrains-mono-nerd-fonts
  unzip JetBrainsMono.zip
  rm JetBrainsMono.zip
  fc-cache -fv
  message "NerdFont installé"
fi
