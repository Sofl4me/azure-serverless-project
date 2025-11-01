#!/bin/bash
source scripts/correct-env-vars.sh

echo "📊 Création d'Application Insights (robuste)..."

# Liste des régions à essayer (par ordre de préférence)
LOCATIONS=("westeurope" "francecentral" "northeurope" "uksouth")

# Fonction pour tester une région
try_create_appinsights() {
    local location=$1
    echo "  Essai avec la région: $location"
    
    az monitor app-insights component create \
        --app $APP_INSIGHTS \
        --location $location \
        --resource-group $RESOURCE_GROUP \
        --application-type web \
        --retention-time 30 \
        --tags Environment=$ENVIRONMENT Project=Image-Processor \
        --output none 2>/dev/null
    
    return $?
}

# Vérifier si App Insights existe déjà
echo "  Vérification de l'existence..."
EXISTS=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP \
    --query name \
    --output tsv 2>/dev/null)

if [ ! -z "$EXISTS" ]; then
    echo "✅ Application Insights '$APP_INSIGHTS' existe déjà"
    LOCATION=$(az monitor app-insights component show \
        --app $APP_INSIGHTS \
        --resource-group $RESOURCE_GROUP \
        --query location \
        --output tsv)
    echo "   Région: $LOCATION"
else
    echo "  Création d'Application Insights..."
    
    # Essayer chaque région
    SUCCESS=false
    for loc in "${LOCATIONS[@]}"; do
        if try_create_appinsights "$loc"; then
            echo "✅ Application Insights créé dans la région: $loc"
            SUCCESS=true
            break
        else
            echo "   ❌ Échec avec $loc, essai suivant..."
        fi
    done
    
    if [ "$SUCCESS" = false ]; then
        echo "❌ Impossible de créer Application Insights dans aucune région"
        echo "   Vérifiez votre quota ou créez-le manuellement dans le portail Azure"
        exit 1
    fi
fi

# Récupérer l'Instrumentation Key
echo ""
echo "  Récupération de la clé d'instrumentation..."
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey \
    --output tsv)

if [ -z "$INSTRUMENTATION_KEY" ]; then
    echo "❌ Impossible de récupérer la clé d'instrumentation"
    exit 1
fi

echo "🔑 Instrumentation Key: $INSTRUMENTATION_KEY"

# Récupérer la Connection String
CONNECTION_STRING=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)

echo "🔗 Connection String: $CONNECTION_STRING"

# Sauvegarder dans un fichier
cat > .env.local << ENVEOF
# Application Insights
APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY
APPLICATIONINSIGHTS_CONNECTION_STRING=$CONNECTION_STRING

# Storage Account
STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT
RESOURCE_GROUP=$RESOURCE_GROUP
AZURE_STORAGE_ACCOUNT=$STORAGE_ACCOUNT

# Containers
INPUT_CONTAINER=input
OUTPUT_CONTAINER=output
THUMBNAILS_CONTAINER=thumbnails
METADATA_CONTAINER=metadata
ENVEOF

echo ""
echo "✅ Configuration sauvegardée dans .env.local"
echo ""
echo "📋 Résumé:"
echo "   App Insights : $APP_INSIGHTS"
echo "   Storage      : $STORAGE_ACCOUNT"
echo "   Resource Group: $RESOURCE_GROUP"
