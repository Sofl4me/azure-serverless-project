#!/bin/bash

echo "🔍 Recherche de région disponible pour ton abonnement..."

# Régions à tester (ordre de préférence)
REGIONS=("francecentral" "northeurope" "uksouth" "westeurope" "eastus" "westus2")

RESOURCE_GROUP="rg-test-region-check"
STORAGE_TEST="sttest$(date +%s | tail -c 10)"

# Créer un RG temporaire
az group create --name $RESOURCE_GROUP --location "francecentral" --output none

for REGION in "${REGIONS[@]}"; do
    echo ""
    echo "🧪 Test de la région : $REGION"
    
    # Tenter de créer un Storage Account
    az storage account create \
        --name "${STORAGE_TEST}" \
        --resource-group $RESOURCE_GROUP \
        --location $REGION \
        --sku Standard_LRS \
        --kind StorageV2 \
        --output none 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ RÉGION DISPONIBLE : $REGION"
        echo ""
        echo "🎯 Utilise cette région pour ton projet :"
        echo "   export LOCATION=\"$REGION\""
        
        # Nettoyer
        az group delete --name $RESOURCE_GROUP --yes --no-wait --output none
        exit 0
    else
        echo "❌ Région $REGION non disponible"
    fi
    
    # Incrémenter le nom pour le prochain test
    STORAGE_TEST="sttest$(date +%s | tail -c 10)"
done

# Nettoyer
az group delete --name $RESOURCE_GROUP --yes --no-wait --output none

echo ""
echo "❌ Aucune région trouvée automatiquement"
echo "📞 Contacte le support Azure Student ou vérifie ton portail Azure"
