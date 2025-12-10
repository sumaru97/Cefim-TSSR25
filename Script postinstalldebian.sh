#!/bin/bash

# =======================================================
# Script d'Installation Automatique (Exécution en une fois)
# =======================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Vérification des privilèges root
if [ "$(id -u)" -ne 0 ]; then
   echo -e "${RED}Erreur : Ce script doit être exécuté en tant que root. Utilisez 'sudo ./full_setup.sh'.${NC}"
   exit 1
fi

echo -e "${YELLOW}Démarrage du script d'installation. Répondez aux questions ci-dessous.${NC}"

# --- Demande d'Entrées Utilisateur ---
read -r -p "1/3. Entrez l'adresse IP du nameserver (ex: 8.8.8.8) : " NAMESERVER_IP
read -r -p "2/3. Installer et configurer NetBIOS (Samba/Winbind) ? (y/N) " NETBIOS_CHOICE
read -r -p "3/3. Voulez-vous redémarrer le système à la fin du script ? (y/N) " REBOOT_CHOICE

echo -e "\n${GREEN}--- Démarrage des Installations ---${NC}"

# 1. Mise à jour et Installation des Outils Essentiels
echo -e "${YELLOW}1. Mise à jour du système et installation des outils...${NC}"
apt update && apt upgrade -y
ESSENTIAL_TOOLS="ssh zip nmap locate ncdu curl git screen dnsutils net-tools sudo lynx"
apt install $ESSENTIAL_TOOLS -y
updatedb

# 2. Configuration DNS (/etc/resolv.conf)
echo -e "${YELLOW}2. Configuration de /etc/resolv.conf...${NC}"
if [[ -n "$NAMESERVER_IP" ]]; then
    echo "nameserver $NAMESERVER_IP" > /etc/resolv.conf
    echo "DNS configuré : $(cat /etc/resolv.conf)"
else
    echo -e "${RED}Adresse IP du nameserver vide. Configuration DNS ignorée.${NC}"
fi

# 3. Personnalisation du BASH (root)
echo -e "${YELLOW}3. Personnalisation du BASH pour root...${NC}"
ROOT_BASHRC="/root/.bashrc"
if [ -f "$ROOT_BASHRC" ]; then
    # Décommenter les lignes 9 à 13 (coloration)
    sed -i '9,13s/^#//' "$ROOT_BASHRC"
else
    echo -e "${RED}Avertissement : Fichier $ROOT_BASHRC non trouvé. Personnalisation BASH ignorée.${NC}"
fi

# 4. Configuration NetBIOS (Optionnel)
if [[ "$NETBIOS_CHOICE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}4. Installation et configuration de NetBIOS (Samba/Winbind)...${NC}"
    apt install winbind samba -y
    # Ajout de 'wins' à la ligne hosts:
    if ! grep -q "hosts:.*wins" /etc/nsswitch.conf; then
        sed -i '/^hosts:/ s/$/ wins/' /etc/nsswitch.conf
    fi
else
    echo -e "${YELLOW}4. Configuration NetBIOS ignorée.${NC}"
fi

# 5. Installation de WebMin
echo -e "${YELLOW}5. Installation de WebMin...${NC}"
WEBMIN_SCRIPT="webmin-setup-repo.sh"
WEBMIN_URL="https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh"

curl -o "$WEBMIN_SCRIPT" "$WEBMIN_URL" 2>/dev/null
if [ -f "$WEBMIN_SCRIPT" ]; then
    sh "$WEBMIN_SCRIPT"
    apt update
    apt upgrade -y
    apt install webmin --install-recommends -y
    echo -e "${GREEN}WebMin installé. Accès via https://IP_DU_SERVEUR:10000${NC}"
else
    echo -e "${RED}Erreur : Échec du téléchargement du script WebMin. Installation WebMin annulée.${NC}"
fi

# 6. Redémarrage
echo -e "\n${YELLOW}6. Finalisation et redémarrage...${NC}"
if [[ "$REBOOT_CHOICE" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${RED}Le système va redémarrer dans 5 secondes...${NC}"
    sleep 5
    reboot
else
    echo -e "${GREEN}Script terminé. Veuillez redémarrer manuellement si nécessaire.${NC}"
fi
echo "Terminé!"
reboot
