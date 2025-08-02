#!/bin/bash -e

# Messages en couleur
error()    { echo -e "\033[0;31m====> $*\033[0m" ;}
message()  { echo -e "\033[0;32m====> $*\033[0m" ;}
warning()  { echo ; echo -e "\033[0;33m====> $*\033[0m" ;}

# Chargement du fichier de config
cfg="$(dirname "$(realpath "$0")")/gnomeconf.cfg"
if [[ ! -f $cfg ]]; then
  error "Fichier $cfg introuvable"
  exit 1
else
  . $cfg
fi

# Exécution
warning "Application des paramètres..."

if [[ $dynamic = false ]]; then
  gsettings set org.gnome.mutter dynamic-workspaces false
  gsettings set org.gnome.desktop.wm.preferences num-workspaces $desktop
else
  gsettings set org.gnome.mutter dynamic-workspaces true
fi

if [[ $screenlock = true ]]; then
  gsettings set org.gnome.desktop.screensaver lock-enabled true
else
  gsettings set org.gnome.desktop.screensaver lock-enabled false
fi

if [[ $screenidle = true ]]; then
  gsettings set org.gnome.desktop.session idle-delay $idledelay
else
  gsettings set org.gnome.desktop.session idle-delay 0
fi

if [[ $darkmode = true ]]; then
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
else
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
fi

if [[ $papicon = true ]]; then
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
else
  gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
fi

if [[ $alert = false ]]; then
  gsettings set org.gnome.SessionManager logout-prompt false
else
  gsettings set org.gnome.SessionManager logout-prompt true
fi

if [[ $mouse = natural ]]; then
  gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
else
  gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false
fi

message "Paramètres activés"
echo
