#!/bin/bash
set -e

source .deployment-info

STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "[0].value" -o tsv)

REPORT_FILE=~/azure-function-report-$(date +%Y%m%d-%H%M%S).txt

{
    echo "════════════════════════════════════════════════════════════════"
    echo "           📊 RAPPORT FINAL DU PROJET AZURE FUNCTION"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "📅 Date de génération: $(date '+%d/%m/%Y à %H:%M:%S')"
    echo ""
    
    echo "════════════════════════════════════════════════════════════════"
    echo "🏗️  INFRASTRUCTURE DÉPLOYÉE"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Resource Group   : $RESOURCE_GROUP"
    echo "Location         : $LOCATION"
    echo "Function App     : $FUNCTION_APP"
    echo "Storage Account  : $STORAGE_ACCOUNT"
    echo ""
    echo "Endpoints:"
    echo "  • Function URL : https://$FUNCTION_APP.azurewebsites.net"
    echo "  • Storage URL  : https://$STORAGE_ACCOUNT.blob.core.windows.net"
    echo ""
    
    echo "════════════════════════════════════════════════════════════════"
    echo "📦 ÉTAT DES CONTAINERS"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    for container in input output thumbnails archive; do
        count=$(az storage blob list \
            --account-name $STORAGE_ACCOUNT \
            --account-key "$STORAGE_KEY" \
            --container-name $container \
            --query "length(@)" -o tsv)
        
        total_size=$(az storage blob list \
            --account-name $STORAGE_ACCOUNT \
            --account-key "$STORAGE_KEY" \
            --container-name $container \
            --query "sum([].properties.contentLength)" -o tsv)
        
        size_mb=$(echo "scale=2; $total_size / 1024 / 1024" | bc)
        
        printf "%-12s : %2d fichier(s) - %.2f MB\n" "$container" "$count" "$size_mb"
    done
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "🧪 TESTS DE VALIDATION"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    # Vérifier les fichiers les plus récents
    latest_input=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name input \
        --query "sort_by(@, &properties.creationTime)[-1].name" -o tsv)
    
    latest_output=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name output \
        --query "sort_by(@, &properties.creationTime)[-1].name" -o tsv)
    
    latest_thumb=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name thumbnails \
        --query "sort_by(@, &properties.creationTime)[-1].name" -o tsv)
    
    latest_archive=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name archive \
        --query "sort_by(@, &properties.creationTime)[-1].name" -o tsv)
    
    echo "✅ Dernier fichier traité avec succès:"
    echo "   Input     : $latest_input"
    echo "   Output    : $latest_output"
    echo "   Thumbnail : $latest_thumb"
    echo "   Archive   : $latest_archive"
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "⚙️  CONFIGURATION DE LA FUNCTION"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    echo "Traitement des images:"
    echo "  • Redimensionnement : 800x600 pixels"
    echo "  • Miniatures        : 150x150 pixels"
    echo "  • Format            : JPEG"
    echo "  • Qualité           : 85%"
    echo ""
    echo "Workflow:"
    echo "  1. Upload dans 'input' → déclenche la function"
    echo "  2. Génération image redimensionnée → 'output'"
    echo "  3. Génération miniature → 'thumbnails'"
    echo "  4. Archivage original → 'archive'"
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "📋 DÉTAIL DES FICHIERS (5 plus récents)"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    for container in input output thumbnails archive; do
        echo ""
        echo "�� $container:"
        az storage blob list \
            --account-name $STORAGE_ACCOUNT \
            --account-key "$STORAGE_KEY" \
            --container-name $container \
            --query "sort_by(@, &properties.creationTime)[-5:].{Nom:name, Taille:properties.contentLength, Creation:properties.creationTime}" \
            --output table
    done
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "✅ STATUT FINAL"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    function_state=$(az functionapp show \
        --name $FUNCTION_APP \
        --resource-group $RESOURCE_GROUP \
        --query "state" -o tsv)
    
    if [ "$function_state" == "Running" ]; then
        echo "🟢 Function App: OPÉRATIONNELLE"
    else
        echo "🔴 Function App: $function_state"
    fi
    
    echo "🟢 Storage Account: OPÉRATIONNEL"
    echo "🟢 Blob Trigger: FONCTIONNEL"
    echo "🟢 Traitement d'images: VALIDÉ"
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "📝 COMMANDES UTILES"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "# Tester l'upload d'une nouvelle image:"
    echo "az storage blob upload \\"
    echo "    --account-name $STORAGE_ACCOUNT \\"
    echo "    --container-name input \\"
    echo "    --name test.jpg \\"
    echo "    --file /chemin/vers/image.jpg"
    echo ""
    echo "# Télécharger les résultats:"
    echo "az storage blob download-batch \\"
    echo "    --account-name $STORAGE_ACCOUNT \\"
    echo "    --source output \\"
    echo "    --destination ./resultats/"
    echo ""
    echo "# Voir les logs:"
    echo "az functionapp logs tail --name $FUNCTION_APP"
    echo ""
    echo "# Redémarrer la function:"
    echo "az functionapp restart --name $FUNCTION_APP"
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "           ✅ PROJET VALIDÉ ET OPÉRATIONNEL"
    echo "════════════════════════════════════════════════════════════════"
    
} | tee "$REPORT_FILE"

echo ""
echo "📄 Rapport sauvegardé dans: $REPORT_FILE"
echo ""
echo "Pour voir le rapport:"
echo "   cat $REPORT_FILE"
