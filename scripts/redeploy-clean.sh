#!/bin/bash
set -e

source .deployment-info

echo "🔧 RE-CONFIGURATION DE LA FUNCTION APP"
echo ""

# 1. Récupérer la connection string du Storage
STORAGE_CONN=$(az storage account show-connection-string \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query connectionString -o tsv)

echo "✅ Connection string récupérée"

# 2. Mettre à jour les App Settings
echo "⚙️  Mise à jour des App Settings..."
az functionapp config appsettings set \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "AzureWebJobsStorage=$STORAGE_CONN" \
        "STORAGE_CONNECTION_STRING=$STORAGE_CONN" \
        "FUNCTIONS_WORKER_RUNTIME=python" \
        "FUNCTIONS_EXTENSION_VERSION=~4" \
        "PYTHON_ISOLATE_WORKER_DEPENDENCIES=1" \
    --output none

echo "✅ App Settings mis à jour"

# 3. Redémarrer la Function App
echo "🔄 Redémarrage de la Function App..."
az functionapp restart \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --output none

echo "✅ Function App redémarrée"
echo ""
echo "⏳ Attente de la disponibilité (30 secondes)..."
sleep 30

# 4. Re-déployer le code
echo "📦 Re-déploiement du code..."
cd ~/M2/Gestion-de-conf/Projet/azure-serverless-project/functions/ImageProcessorApp

func azure functionapp publish $FUNCTION_APP --python

echo ""
echo "✅ RE-DÉPLOIEMENT TERMINÉ !"
echo ""
echo "🧪 Test de la function dans 10 secondes..."
sleep 10
