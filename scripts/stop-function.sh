#!/bin/bash
source scripts/correct-env-vars.sh

echo "⏸️  Arrêt de la Function App pour économiser du crédit..."

az functionapp stop \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME

echo "✅ Function App arrêtée (pas de frais)"
echo "💡 Pour redémarrer: az functionapp start --resource-group $RESOURCE_GROUP --name $FUNCTION_APP_NAME"
