#!/bin/bash

# Couleurs
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo ""
echo "════════════════════════════════════════════════════════"
echo "📊 MONITORING FUNCTION APP"
echo "════════════════════════════════════════════════════════"
echo ""

read -p "📝 Nom du Resource Group: " RESOURCE_GROUP
read -p "📝 Nom de la Function App: " FUNCTION_APP

echo ""
echo -e "${BLUE}📋 Logs en temps réel (Ctrl+C pour arrêter):${NC}"
echo ""

az functionapp log tail \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP
