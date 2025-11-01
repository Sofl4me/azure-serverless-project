#!/bin/bash
source scripts/correct-env-vars.sh

echo "📥 Téléchargement de toutes les images traitées..."
echo ""

# Créer un dossier pour les résultats
DOWNLOAD_DIR="/tmp/azure-function-results-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DOWNLOAD_DIR"/{input,output,thumbnails}

echo "✅ Dossier créé: $DOWNLOAD_DIR"
echo ""

# Fonction pour télécharger tous les fichiers d'un container
download_container() {
    local container=$1
    local destination=$2
    local label=$3
    
    echo "📂 $label..."
    
    # Lister tous les blobs
    local blobs=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --container-name $container \
        --auth-mode login \
        --query "[].name" -o tsv)
    
    local count=0
    for blob in $blobs; do
        echo "   ⬇️  $blob"
        az storage blob download \
            --account-name $STORAGE_ACCOUNT \
            --container-name $container \
            --name "$blob" \
            --file "$destination/$blob" \
            --auth-mode login \
            --overwrite \
            --only-show-errors
        count=$((count + 1))
    done
    
    echo "   ✅ $count fichier(s) téléchargé(s)"
    echo ""
}

# Télécharger chaque container
download_container "input" "$DOWNLOAD_DIR/input" "Images Originales"
download_container "output" "$DOWNLOAD_DIR/output" "Images Redimensionnées"
download_container "thumbnails" "$DOWNLOAD_DIR/thumbnails" "Miniatures"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Téléchargement terminé!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Statistiques:"
echo "   - Originales: $(ls -1 "$DOWNLOAD_DIR/input" 2>/dev/null | wc -l) fichiers"
echo "   - Redimensionnées: $(ls -1 "$DOWNLOAD_DIR/output" 2>/dev/null | wc -l) fichiers"
echo "   - Miniatures: $(ls -1 "$DOWNLOAD_DIR/thumbnails" 2>/dev/null | wc -l) fichiers"
echo ""
echo "💾 Emplacement: $DOWNLOAD_DIR"
echo ""
echo "🔍 Visualiser avec:"
echo "   cd $DOWNLOAD_DIR"
echo "   ls -lh */"
echo ""
echo "📏 Comparer les tailles:"
echo "   du -sh */"
