#!/bin/bash

echo "🎓 Test des régions Azure for Students..."
echo ""

# Régions typiques pour les comptes étudiants
REGIONS=(
    "eastus"
    "eastus2" 
    "westus"
    "westus2"
    "centralus"
    "northeurope"
    "westeurope"
)

for region in "${REGIONS[@]}"; do
    echo -n "Testing $region... "
    
    # Test avec un storage account temporaire
    TEST_NAME="teststg$(date +%N | cut -c1-6)"
    TEST_RG="test-rg-$region"
    
    # Créer un RG de test
    az group create --name $TEST_RG --location $region --output none 2>/dev/null
    
    # Tester le storage
    if az storage account create \
        --name $TEST_NAME \
        --resource-group $TEST_RG \
        --location $region \
        --sku Standard_LRS \
        --output none 2>/dev/null; then
        echo "✅ FONCTIONNE"
        WORKING_REGION=$region
        # Nettoyer
        az group delete --name $TEST_RG --yes --no-wait
        break
    else
        echo "❌ Bloquée"
        az group delete --name $TEST_RG --yes --no-wait 2>/dev/null
    fi
done

if [ ! -z "$WORKING_REGION" ]; then
    echo ""
    echo "🎯 Région trouvée : $WORKING_REGION"
    echo "   Mise à jour du script..."
    
    cd ~/M2/Gestion-de-conf/Projet/azure-serverless-project/scripts
    sed -i "s/LOCATION=\".*\"/LOCATION=\"$WORKING_REGION\"/" deploy-function.sh
    
    echo "✅ Script mis à jour avec $WORKING_REGION"
    echo ""
    echo "Relance maintenant : ./deploy-function.sh"
else
    echo ""
    echo "❌ Aucune région compatible trouvée"
    echo "   Contacte le support Azure for Students"
fi
