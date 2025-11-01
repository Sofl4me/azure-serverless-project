#!/bin/bash
set -e

source scripts/correct-env-vars.sh

echo "╔════════════════════════════════════════════════════════════╗"
echo "║    🚀 DÉPLOIEMENT AZURE FUNCTION - CONSUMPTION PLAN       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

FUNCTION_APP_NAME="imgfunc-${RANDOM}"

echo "📝 Configuration:"
echo "   Function App: $FUNCTION_APP_NAME"
echo "   Plan: Consumption (Y1) - Pay-per-use"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Storage: $STORAGE_ACCOUNT"
echo "   Région: $LOCATION"
echo ""
read -p "❓ Essayer le Consumption Plan ? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Création Function App avec Consumption Plan"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

az functionapp create \
    --resource-group $RESOURCE_GROUP \
    --name $FUNCTION_APP_NAME \
    --storage-account $STORAGE_ACCOUNT \
    --consumption-plan-location $LOCATION \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --os-type Linux \
    --tags project=image-processor environment=production plan=consumption

if [ $? -eq 0 ]; then
    echo "✅ Consumption Plan créé avec succès !"
    echo "FUNCTION_APP_NAME=$FUNCTION_APP_NAME" >> scripts/correct-env-vars.sh
    
    # Continuer avec le reste du déploiement
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "2️⃣  Configuration Managed Identity"
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
    echo "3️⃣  Attribution des permissions Storage"
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
    echo "⏳ Attente propagation (30 secondes)..."
    sleep 30
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "4️⃣  Configuration des variables d'environnement"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    az functionapp config appsettings set \
        --resource-group $RESOURCE_GROUP \
        --name $FUNCTION_APP_NAME \
        --settings \
            "AZURE_STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT" \
            "INPUT_CONTAINER=input" \
            "OUTPUT_CONTAINER=output" \
            "THUMBNAIL_CONTAINER=thumbnails"
    
    echo "✅ Variables configurées"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "5️⃣  Déploiement du code"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    func azure functionapp publish $FUNCTION_APP_NAME --python
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        ✅ DÉPLOIEMENT CONSUMPTION RÉUSSI !                ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "�� Function App: $FUNCTION_APP_NAME"
    echo "💰 Plan: Consumption (Pay-per-use)"
    echo "🌐 Région: $LOCATION"
    
else
    echo ""
    echo "❌ Échec du Consumption Plan"
    echo "💡 Fallback : Utilise ./scripts/deploy-to-azure.sh (Plan F1)"
fi
