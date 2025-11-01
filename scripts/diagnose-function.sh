#!/bin/bash

echo "╔════════════════════════════════════════════════════════════╗"
echo "║            🔍 DIAGNOSTIC COMPLET                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

RESOURCE_GROUP="rg-serverless-img-dev"
FUNCTION_APP="imagefunc-32114"
STORAGE_ACCOUNT="stockage011"

# 1. État de la function app
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  État de la Function App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
az functionapp show \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --query "{State:state, Runtime:linuxFxVersion, Kind:kind}" \
    --output table

# 2. Liste des functions
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Functions Déployées"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
az functionapp function list \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --output table 2>/dev/null || echo "❌ Aucune function trouvée"

# 3. Settings critiques
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Configuration Critique"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
az functionapp config appsettings list \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --query "[?name=='AzureWebJobsStorage' || name=='FUNCTIONS_WORKER_RUNTIME' || name=='AzureWebJobsFeatureFlags' || name=='PYTHON_ENABLE_WORKER_EXTENSIONS'].{Name:name, Value:value}" \
    --output table

# 4. Contenu du storage
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Contenu des Conteneurs"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query '[0].value' -o tsv)

for container in input output thumbnails; do
    COUNT=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name $container \
        --query "length(@)" -o tsv 2>/dev/null || echo "0")
    echo "   📂 $container: $COUNT fichier(s)"
done

# 5. Logs récents (Application Insights)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  Logs Récents (5 dernières minutes)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

APP_INSIGHTS=$(az monitor app-insights component show \
    --resource-group $RESOURCE_GROUP \
    --query "[?contains(name, 'imagefunc')].name" -o tsv)

if [ -n "$APP_INSIGHTS" ]; then
    az monitor app-insights query \
        --app $APP_INSIGHTS \
        --analytics-query "traces | where timestamp > ago(5m) | project timestamp, message | order by timestamp desc | take 10" \
        --offset 5m 2>/dev/null || echo "   ⚠️  Pas de logs dans Application Insights"
else
    echo "   ⚠️  Application Insights non trouvé"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    📊 RECOMMANDATIONS                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Si aucune function n'est listée, le problème vient de function_app.py"
echo "Si les functions sont listées mais ne se déclenchent pas, vérifier:"
echo "  - Les webhooks Event Grid"
echo "  - Les permissions du storage"
echo "  - Les logs en temps réel: az webapp log tail --name $FUNCTION_APP --resource-group $RESOURCE_GROUP"
echo ""
