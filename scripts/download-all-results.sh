#!/bin/bash
set -e

source .deployment-info

STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "[0].value" -o tsv)

DEST_DIR=~/azure-results-$(date +%Y%m%d-%H%M%S)
mkdir -p $DEST_DIR/{input,output,thumbnails,archive}

echo "════════════════════════════════════════════════════════"
echo "📥 TÉLÉCHARGEMENT DE TOUS LES RÉSULTATS"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📁 Destination: $DEST_DIR"
echo ""

for container in input output thumbnails archive; do
    echo "📂 Téléchargement de '$container'..."
    
    az storage blob download-batch \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --source $container \
        --destination $DEST_DIR/$container \
        --pattern "*.jpg" \
        --output none 2>/dev/null || true
    
    count=$(ls -1 $DEST_DIR/$container/*.jpg 2>/dev/null | wc -l)
    size=$(du -sh $DEST_DIR/$container 2>/dev/null | cut -f1)
    echo "   ✅ $count fichier(s) - $size"
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅ Téléchargement terminé !"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📁 Fichiers dans: $DEST_DIR"
echo ""
echo "Pour voir les images:"
echo "   cd $DEST_DIR"
echo "   ls -lh */*.jpg"
echo ""

# Créer un fichier index HTML pour visualiser facilement
cat > $DEST_DIR/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Résultats Azure Function</title>
    <style>
        body { font-family: Arial; margin: 20px; background: #f5f5f5; }
        h1 { color: #0078d4; }
        .container { display: flex; flex-wrap: wrap; gap: 20px; }
        .section { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .section h2 { color: #333; border-bottom: 2px solid #0078d4; padding-bottom: 10px; }
        img { max-width: 300px; border: 1px solid #ddd; border-radius: 4px; }
        .file-info { font-size: 12px; color: #666; margin-top: 5px; }
    </style>
</head>
<body>
    <h1>🎨 Résultats du traitement d'images Azure Function</h1>
    <div class="container">
        <div class="section">
            <h2>📥 Images originales (input)</h2>
HTML

for img in $DEST_DIR/input/*.jpg; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    size=$(du -h "$img" | cut -f1)
    cat >> $DEST_DIR/index.html << HTML
            <div>
                <img src="input/$filename" alt="$filename">
                <div class="file-info">$filename - $size</div>
            </div>
HTML
done

cat >> $DEST_DIR/index.html << 'HTML'
        </div>
        <div class="section">
            <h2>📤 Images redimensionnées (output)</h2>
HTML

for img in $DEST_DIR/output/*.jpg; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    size=$(du -h "$img" | cut -f1)
    cat >> $DEST_DIR/index.html << HTML
            <div>
                <img src="output/$filename" alt="$filename">
                <div class="file-info">$filename - $size</div>
            </div>
HTML
done

cat >> $DEST_DIR/index.html << 'HTML'
        </div>
        <div class="section">
            <h2>🖼️ Miniatures (thumbnails)</h2>
HTML

for img in $DEST_DIR/thumbnails/*.jpg; do
    [ -f "$img" ] || continue
    filename=$(basename "$img")
    size=$(du -h "$img" | cut -f1)
    cat >> $DEST_DIR/index.html << HTML
            <div>
                <img src="thumbnails/$filename" alt="$filename">
                <div class="file-info">$filename - $size</div>
            </div>
HTML
done

cat >> $DEST_DIR/index.html << 'HTML'
        </div>
    </div>
</body>
</html>
HTML

echo "📄 Index HTML créé: $DEST_DIR/index.html"
echo "   Ouvre ce fichier dans un navigateur pour voir toutes les images"
