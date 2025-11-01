#!/bin/bash
source scripts/correct-env-vars.sh

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           💰 ANALYSE DES COÛTS AZURE                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Ressources déployées"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az resource list \
    --resource-group $RESOURCE_GROUP \
    --query "[].{Type:type, Name:name, Location:location}" \
    --output table

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Estimation des coûts mensuels"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📦 App Service Plan (B1):"
echo "   Coût: ~13€/mois (~0.017€/heure)"
echo "   État: $(az appservice plan show --resource-group $RESOURCE_GROUP --name $APP_SERVICE_PLAN --query 'properties.status' -o tsv)"

echo ""
echo "💾 Storage Account (LRS):"
echo "   Coût: ~0.02€/GB/mois + transactions"
echo "   Usage: $(az storage account show --name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --query 'primaryEndpoints.blob' -o tsv)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Crédit Azure Students restant"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "💳 Crédit initial: 100$"
echo "📅 Durée du projet: 1 mois"
echo "💰 Coût estimé total: ~13-15€"
echo "✅ Crédit restant prévu: ~85€"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     ℹ️  Pour voir les coûts réels en temps réel          ║"
echo "║     👉 https://portal.azure.com/#blade/Microsoft_Azure_CostManagement/Menu/costanalysis"
echo "╚════════════════════════════════════════════════════════════╝"
