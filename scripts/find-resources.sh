#!/bin/bash

echo "🔍 Recherche de tes ressources Azure..."
echo ""

# Lister tous les Resource Groups
echo "📦 Resource Groups disponibles :"
az group list --query "[].{Name:name, Location:location}" --output table
echo ""

# Chercher le Storage Account
echo "💾 Recherche du Storage Account 'stockage011'..."
STORAGE_INFO=$(az storage account list --query "[?name=='stockage011'].{Name:name, ResourceGroup:resourceGroup, Location:location, ID:id}" --output json)

if [ -z "$STORAGE_INFO" ] || [ "$STORAGE_INFO" == "[]" ]; then
    echo "❌ Storage Account 'stockage011' introuvable !"
    echo ""
    echo "📋 Tous les Storage Accounts disponibles :"
    az storage account list --output table
else
    echo "✅ Storage Account trouvé !"
    echo "$STORAGE_INFO" | jq -r '.[] | "
  Nom              : \(.Name)
  Resource Group   : \(.ResourceGroup)
  Location         : \(.Location)
  ID               : \(.ID)"'
    
    # Extraire le Resource Group
    RG_NAME=$(echo "$STORAGE_INFO" | jq -r '.[0].ResourceGroup')
    
    echo ""
    echo "🎯 Commandes à exécuter :"
    echo ""
    echo "export RESOURCE_GROUP=\"$RG_NAME\""
    echo "export STORAGE_ACCOUNT=\"stockage011\""
    echo ""
    echo "Ou source ce fichier :"
    
    # Créer un fichier avec les bonnes variables
    cat > scripts/correct-env-vars.sh << EOFINNER
#!/bin/bash
export PROJECT_NAME="generation-img"
export ENVIRONMENT="dev"
export LOCATION="$(echo "$STORAGE_INFO" | jq -r '.[0].Location')"
export RESOURCE_GROUP="$RG_NAME"
export STORAGE_ACCOUNT="stockage011"
export FUNCTION_APP="func-generation-img-dev"
export APP_INSIGHTS="appi-generation-img-dev"

echo "✅ Variables d'environnement corrigées chargées"
EOFINNER
    
    chmod +x scripts/correct-env-vars.sh
    echo "✅ Fichier créé : scripts/correct-env-vars.sh"
fi

echo ""
echo "📊 Résumé de toutes tes ressources :"
az resource list --output table

