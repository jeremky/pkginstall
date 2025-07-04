# pkginstall.sh

Script automatisant l'installation et le paramétrage de Debian/Fedora.

## Fonctionnalités

- Installe les paquets présents dans le fichier `config/<votre_os>.lst` 

- Sécurise le serveur SSH et limite l'accès à l'utilisateur par défaut

- Active le firewall UFW si installé

- Configure unattended-upgrades sur debian si installé

- Active la commande locate si installée

## Configuration

Un fichier de configuration `pkginstall.cfg` est présent pour configurer les éléments du firewall UFW. Vous pouvez spécifier les ports à autoriser (séparés par des espaces), ainsi qu'indiquer si vous désirez désactiver l'ipv6. Le fichier de configuration : 

```txt
# pkginstall config
ipv6=true
ports="22/tcp 80/tcp 443/tcp 25565 21115/tcp 21116 21117/tcp"
```

## Utilisation

Pour exécuter le script, vous devez disposer des droits root :

```bash
sudo ./pkginstall.sh
```
