#!/bin/bash

# Couleurs
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "════════════════════════════════════════════════════════"
echo -e "${RED}⚠️  NETTOYAGE DES RESSOURCES AZURE${NC}"
echo "════════════════════════════════════════════════════════"
echo ""

read -p "📝 Nom du Resource Group à supprimer: " RESOURCE_GROUP

echo ""
echo -e "${YELLOW}⚠️  ATTENTION: Cette action va supprimer:${NC}"
echo "   - La Function App"
echo "   - Le Storage Account (et TOUTES les images)"
echo "   - Tous les containers"
echo "   - Le Resource Group complet"
echo ""
read -p "Êtes-vous sûr ? Tapez 'DELETE' pour confirmer: " CONFIRM

if [ "$CONFIRM" != "DELETE" ]; then
    echo "❌ Annulé"
    exit 1
fi

echo ""
echo -e "${RED}🗑️  Suppression en cours...${NC}"
az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

echo -e "${RED}✅ Suppression lancée (asynchrone)${NC}"
echo ""
