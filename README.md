# pkginstall.sh

Script automatisant l'installation et le paramétrage de Debian/Fedora.

## Fonctionnalités

- Installe les paquets présents dans le fichier `config/<votre_os>.lst` 

- Sécurise le serveur SSH et limite l'accès à l'utilisateur par défaut

- Active le par-feu UFW si installé et autorise le port 22

- Configure unattended-upgrades sur debian si installé

- Active la commande locate si installée

## Utilisation

Pour exécuter le script, vous devez disposer des droits root :

```bash
sudo ./pkginstall.sh
```
