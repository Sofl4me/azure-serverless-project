#!/bin/bash
set -e

source scripts/correct-env-vars.sh

# Générer des noms uniques
FUNCTION_APP_NAME="imagefunc-${RANDOM}"
APP_SERVICE_PLAN="imageplan-${RANDOM}"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║       🚀 DÉPLOIEMENT AZURE FUNCTION EN PRODUCTION         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📝 Configuration:"
echo "   Function App: $FUNCTION_APP_NAME"
echo "   Plan: $APP_SERVICE_PLAN (Free Tier)"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Storage: $STORAGE_ACCOUNT"
echo "   Région: $LOCATION"
echo ""
read -p "❓ Continuer ? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Création du plan App Service (Free Tier)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az appservice plan create \
    --resource-group $RESOURCE_GROUP \
    --name $APP_SERVICE_PLAN \
    --location $LOCATION \
    --sku F1 \
    --is-linux \
    --tags project=image-processor environment=production plan=f1

echo "✅ App Service Plan créé"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Création de la Function App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az functionapp create \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME \
    --storage-account $STORAGE_ACCOUNT \
    --plan $APP_SERVICE_PLAN \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --os-type Linux \
    --tags project=image-processor environment=production

echo "✅ Function App créée"

# Sauvegarder les noms pour usage futur
echo "export FUNCTION_APP_NAME='$FUNCTION_APP_NAME'" >> scripts/correct-env-vars.sh
echo "export APP_SERVICE_PLAN='$APP_SERVICE_PLAN'" >> scripts/correct-env-vars.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Configuration Managed Identity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az functionapp identity assign \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME

PRINCIPAL_ID=$(az functionapp identity show \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME \
    --query principalId -o tsv)

echo "✅ Managed Identity: $PRINCIPAL_ID"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Attribution des permissions Storage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

STORAGE_ID=$(az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query id -o tsv)

az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee $PRINCIPAL_ID \
    --scope $STORAGE_ID

echo "✅ Permissions accordées"
echo "⏳ Attente propagation des permissions (30 secondes)..."
sleep 30

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  Configuration des variables d'environnement"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az functionapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME \
    --settings \
        "AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT" \
        "INPUT_CONTAINER=input" \
        "OUTPUT_CONTAINER=output" \
        "THUMBNAIL_CONTAINER=thumbnails" \
        "PYTHON_ENABLE_WORKER_EXTENSIONS=1" \
        "FUNCTIONS_WORKER_RUNTIME=python"

echo "✅ Variables configurées"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣  Déploiement du code de la Function"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Vérifier que func est installé
if ! command -v func &> /dev/null; then
    echo "❌ Azure Functions Core Tools non installé"
    echo "💡 Installation: npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    exit 1
fi

# Déployer
func azure functionapp publish $FUNCTION_APP_NAME --python

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              ✅ DÉPLOIEMENT RÉUSSI !                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Function App: $FUNCTION_APP_NAME"
echo "🔗 URL: https://${FUNCTION_APP_NAME}.azurewebsites.net"
echo "📊 Portal: https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_APP_NAME"
echo ""
echo "🧪 Test:"
echo "   ./scripts/test-function.sh"
