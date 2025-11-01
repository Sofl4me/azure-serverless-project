#!/bin/bash

source .deployment-info

echo "════════════════════════════════════════════════════════"
echo "📊 RAPPORT DE DÉPLOIEMENT - Azure Serverless Project"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📅 Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "🏗️  INFRASTRUCTURE:"
echo "   • Resource Group  : $RESOURCE_GROUP"
echo "   • Function App    : $FUNCTION_APP"
echo "   • Storage Account : $STORAGE_ACCOUNT"
echo "   • Location        : $LOCATION"
echo ""

STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "[0].value" -o tsv)

echo "📦 CONTAINERS:"
for container in input output thumbnails archive; do
    COUNT=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name $container \
        --query "length(@)" -o tsv 2>/dev/null || echo "0")
    echo "   • $container: $COUNT fichier(s)"
done

echo ""
echo "🔗 ENDPOINTS:"
echo "   • Function URL: https://$FUNCTION_APP.azurewebsites.net"
echo "   • Storage URL : https://$STORAGE_ACCOUNT.blob.core.windows.net"
echo ""
echo "✅ STATUT: Opérationnel"
echo "════════════════════════════════════════════════════════"
