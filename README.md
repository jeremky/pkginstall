# aptinstall.sh

Script automatisant l'installation et le paramétrage de Debian.

## Fonctionnalités

- Installe les paquets présents dans le fichier `aptinstall.lst` 

- Sécurise le serveur SSH et limite l'accès à l'utilisateur par défaut

- Active le par-feu UFW si installé et autorise le port 22

- Configure unattended-upgrades si installé

- Active la commande locate si installée

## Utilisation

Pour exécuter le script, vous devez disposer des droits root :

```bash
sudo ./aptinstall.sh
```
