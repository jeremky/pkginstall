# aptinstall

Script automatisant l'installation et le paramétrage de Debian/Ubuntu.

## Fonctionnalités

- `install_packages` : met à jour le système et installe les applications présentes dans le fichier `config/<distribution>.cfg`

- `enable_locate` : installe `plocate` et crée la base pour l'utiliser directement

- `enable_unattended` : installe `unattended-upgrades` et vous ouvre l'outil de configuration

- `configure_ufw` : installe et configure le firewall `ufw` avec les ports suivants :
  - 22/tcp
  - 80/tcp
  - 443/tcp

- `configure_sshd` : crée un fichier pour `sshd` (`/etc/ssh/sshd_config.d/<user>.conf`) avec les éléments suivants :
  - Restreint l'accès à l'utilisateur principal (UID 1000)
  - Désactive le forwarding X11
  - Force l'utilisation de la clé `ed25519` uniquement
  - Limite les tentatives d'authentification à 3
  - Restreint les algorithmes aux recommandations modernes :
    - **Kex** : `curve25519-sha256`
    - **Ciphers** : `aes256-gcm`, `aes256-ctr`, `aes192-ctr`, `aes128-gcm`, `aes128-ctr`
    - **MACs** : `hmac-sha2-512-etm`, `hmac-sha2-256-etm`

> **Attention** : `PasswordAuthentication` reste activé par défaut. Penser à le désactiver dans `/etc/ssh/sshd_config.d/<user>.conf` après avoir configuré les clés SSH.

## Configuration

Un fichier de configuration `aptinstall.cfg` permet de paramétrer l'exécution du script selon vos préférences :

```txt
# aptinstall config

install_packages=on

enable_locate=on
enable_unattended=off

configure_sshd=on
configure_ufw=off
```

Sous `config`, le fichier correspondant à votre OS doit contenir une liste de paquets à installer. Pour connaître le nom de votre distribution :

```bash
grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"'
```

Exemple avec le fichier `config/debian.cfg` :

```txt
# aptinstall debian list

colordiff
curl
duf
fail2ban
fd-find
fzf
git
htop
make
ncdu
net-tools
pipes-sh
ripgrep
rsync
shfmt
ssh-audit
sysstat
tree
tty-clock
unzip
vim
zip
zoxide
```

## Utilisation

Une fois le fichier `aptinstall.cfg` et le fichier `config/<distribution>.cfg` modifiés, lancez le script avec les droits root :

```bash
sudo ./aptinstall.sh
```

Il est possible, en cas de problème ou d'oubli, d'exécuter une action spécifique, en passant le processus en paramètre. Par exemple, si vous voulez seulement installer le firewall ufw :

```bash
sudo ./aptinstall.sh configure_ufw
```
