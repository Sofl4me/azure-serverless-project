#!/bin/bash
source scripts/correct-env-vars.sh

echo "📊 Création d'Application Insights..."

# Vérifier si App Insights existe déjà
EXISTS=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP 2>/dev/null)

if [ ! -z "$EXISTS" ]; then
    echo "ℹ️  Application Insights '$APP_INSIGHTS' existe déjà"
else
    az monitor app-insights component create \
        --app $APP_INSIGHTS \
        --location $LOCATION \
        --resource-group $RESOURCE_GROUP \
        --application-type web \
        --retention-time 30 \
        --tags Environment=$ENVIRONMENT Project=Image-Processor
    
    echo "✅ Application Insights créé: $APP_INSIGHTS"
fi

# Récupérer l'Instrumentation Key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
    --app $APP_INSIGHTS \
    --resource-group $RESOURCE_GROUP \
    --query instrumentationKey \
    --output tsv)

echo ""
echo "🔑 Instrumentation Key: $INSTRUMENTATION_KEY"

# Sauvegarder dans un fichier
cat > .env.local << ENVEOF
# Application Insights
APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$INSTRUMENTATION_KEY

# Storage Account
STORAGE_ACCOUNT_NAME=$STORAGE_ACCOUNT
RESOURCE_GROUP=$RESOURCE_GROUP
ENVEOF

echo "✅ Configuration sauvegardée dans .env.local"
