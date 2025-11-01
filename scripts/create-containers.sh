#!/bin/bash
source scripts/correct-env-vars.sh

echo "📦 Création des containers dans $STORAGE_ACCOUNT..."

# Liste des containers nécessaires
CONTAINERS=("input" "output" "thumbnails" "metadata")

for container in "${CONTAINERS[@]}"; do
    echo "  Création du container: $container"
    
    # Vérifier si le container existe déjà
    EXISTS=$(az storage container exists \
        --account-name $STORAGE_ACCOUNT \
        --name $container \
        --auth-mode login \
        --query exists \
        --output tsv)
    
    if [ "$EXISTS" = "true" ]; then
        echo "    ℹ️  Container '$container' existe déjà"
    else
        az storage container create \
            --account-name $STORAGE_ACCOUNT \
            --name $container \
            --auth-mode login \
            --public-access off
        
        echo "    ✅ Container '$container' créé"
    fi
done

echo ""
echo "📋 Liste des containers :"
az storage container list \
    --account-name $STORAGE_ACCOUNT \
    --auth-mode login \
    --output table

echo ""
echo "✅ Tous les containers sont prêts !"
