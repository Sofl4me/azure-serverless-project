#!/bin/bash
set -e

source scripts/correct-env-vars.sh

echo "╔════════════════════════════════════════════════════════════╗"
echo "║       🏗️  CRÉATION INFRASTRUCTURE - PLAN F1              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📍 Configuration:"
echo "   Région: $LOCATION"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Storage: $STORAGE_ACCOUNT"
echo "   Plan: Free (F1)"
echo ""
read -p "❓ Continuer ? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Création Resource Group"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --tags project=image-processor environment=$ENVIRONMENT plan=f1

echo "✅ Resource Group créé"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Création Storage Account"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false \
    --tags project=image-processor environment=$ENVIRONMENT

echo "✅ Storage Account créé"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Récupération de la clé d'accès"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query '[0].value' -o tsv)

echo "✅ Clé récupérée"
echo "export STORAGE_KEY='$STORAGE_KEY'" >> scripts/correct-env-vars.sh

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Création des conteneurs Blob"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for container in input output thumbnails; do
    echo "📦 Création: $container"
    az storage container create \
        --name $container \
        --account-name $STORAGE_ACCOUNT \
        --account-key $STORAGE_KEY \
        --auth-mode key
done

echo "✅ Conteneurs créés"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           ✅ INFRASTRUCTURE CRÉÉE !                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🚀 Prochaine étape: Déployer la Function App"
echo "   ./scripts/deploy-to-azure.sh"
