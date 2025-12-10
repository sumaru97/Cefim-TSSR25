#!/bin/bash

# Script d'installation minimaliste

# Mise à jour et mise à niveau
apt update && apt upgrade -y

# Installation des utilitaires
apt install ssh -y
apt install zip -y
apt install nmap -y
apt install locate -y
apt install ncdu -y
apt install curl -y
apt install git -y
apt install screen -y
apt install dnsutils -y
apt install net-tools -y
apt install sudo -y
apt install lynx -y

# Installation de bsdgames
apt install bsdgames -y

# Installation de Samba et Winbind
apt install winbind samba -y

# Installation de Webmin
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
echo "y" | ./webmin-setup-repo.sh > /dev/null
apt update
apt install webmin --install-recommends -y

# Nettoyage
rm webmin-setup-repo.sh
