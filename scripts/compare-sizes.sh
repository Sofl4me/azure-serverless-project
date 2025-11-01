#!/bin/bash

RESULTS_DIR=$(ls -dt /tmp/azure-function-results-* 2>/dev/null | head -1)

if [ -z "$RESULTS_DIR" ]; then
    echo "❌ Aucun dossier de résultats trouvé"
    echo "   Exécute d'abord: ./scripts/download-all.sh"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     📊 COMPARAISON DES TAILLES D'IMAGES                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Source: $RESULTS_DIR"
echo ""

# Fonction pour obtenir la taille d'un fichier
get_size() {
    if [ -f "$1" ]; then
        stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null
    else
        echo "0"
    fi
}

# Fonction pour formater la taille
format_size() {
    local size=$1
    if [ $size -lt 1024 ]; then
        echo "${size}B"
    elif [ $size -lt 1048576 ]; then
        echo "$((size / 1024))KB"
    else
        echo "$((size / 1048576))MB"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-25s %12s %15s %12s %8s\n" "Image" "Original" "Redimensionné" "Miniature" "Gain"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$RESULTS_DIR/input" || exit 1

# Traiter les fichiers .jpg
shopt -s nullglob
for original in *.jpg; do
    # Obtenir le nom de base sans extension
    base="${original%.jpg}"
    
    # Chemins des différentes versions
    orig_path="$RESULTS_DIR/input/$original"
    resized_path="$RESULTS_DIR/output/${base}_resized.jpg"
    thumb_path="$RESULTS_DIR/thumbnails/${base}_thumb.jpg"
    
    # Tailles
    orig_size=$(get_size "$orig_path")
    resized_size=$(get_size "$resized_path")
    thumb_size=$(get_size "$thumb_path")
    
    # Calcul du gain (en %)
    if [ "$orig_size" -gt 0 ] && [ "$resized_size" -gt 0 ]; then
        gain=$(( (orig_size - resized_size) * 100 / orig_size ))
    else
        gain=0
    fi
    
    # Affichage formaté
    printf "%-25s %12s %15s %12s %7d%%\n" \
        "$base" \
        "$(format_size "$orig_size")" \
        "$(format_size "$resized_size")" \
        "$(format_size "$thumb_size")" \
        "$gain"
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Totaux
total_orig=$(du -sb "$RESULTS_DIR/input" 2>/dev/null | cut -f1)
total_resized=$(du -sb "$RESULTS_DIR/output" 2>/dev/null | cut -f1)
total_thumb=$(du -sb "$RESULTS_DIR/thumbnails" 2>/dev/null | cut -f1)

echo "📊 Totaux:"
echo "   Original:      $(format_size "$total_orig")"
echo "   Redimensionné: $(format_size "$total_resized")"
echo "   Miniatures:    $(format_size "$total_thumb")"
echo ""

if [ "$total_orig" -gt 0 ]; then
    total_gain=$(( (total_orig - total_resized) * 100 / total_orig ))
    echo "💾 Gain total de stockage: ${total_gain}%"
    echo "🎯 Économie: $(format_size $((total_orig - total_resized)))"
fi
