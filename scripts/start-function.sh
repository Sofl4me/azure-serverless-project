#!/bin/bash
source scripts/correct-env-vars.sh

echo "▶️  Démarrage de la Function App..."

az functionapp start \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME

echo "✅ Function App démarrée"
