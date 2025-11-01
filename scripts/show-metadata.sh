#!/bin/bash
source scripts/correct-env-vars.sh

echo "�� Métadonnées Extraites des Images"
echo "===================================="
echo ""

# Liste des fichiers metadata
metadata_files=$(az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --container-name metadata \
    --auth-mode login \
    --query "[].name" -o tsv)

for file in $metadata_files; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 $file"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    az storage blob download \
        --account-name $STORAGE_ACCOUNT \
        --container-name metadata \
        --name "$file" \
        --file "/tmp/$file" \
        --auth-mode login \
        --overwrite \
        --only-show-errors
    
    cat "/tmp/$file" | jq '.'
    echo ""
done

echo "✅ Toutes les métadonnées affichées !"
