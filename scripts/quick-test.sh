#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           🧪 TEST RAPIDE DE LA FUNCTION                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Variables
RESOURCE_GROUP="rg-serverless-img-dev"
STORAGE_ACCOUNT="stockage011"
FUNCTION_APP="imagefunc-32114"

# 1. Créer une image de test
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Création d'une image de test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

python << 'PYTHON'
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os

os.makedirs('test-images', exist_ok=True)

img = Image.new('RGB', (1920, 1080), color='#2196F3')
draw = ImageDraw.Draw(img)

# Texte simple
text = f"Test Azure Function\n{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
draw.text((50, 50), text, fill='white')

# Dessiner quelques formes
draw.rectangle([100, 200, 500, 600], outline='yellow', width=5)
draw.ellipse([600, 200, 1000, 600], outline='red', width=5)

filename = f'test-images/test-{datetime.now().strftime("%Y%m%d_%H%M%S")}.jpg'
img.save(filename, quality=95)
print(f"✅ Image créée: {filename}")
PYTHON

# 2. Récupérer la clé du storage
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Upload vers Azure Storage"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT \
    --query '[0].value' -o tsv)

# 3. Upload
TEST_IMAGE=$(ls -t test-images/*.jpg | head -1)
BASENAME=$(basename $TEST_IMAGE)

echo "📤 Upload: $BASENAME"

az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --container-name input \
    --name $BASENAME \
    --file $TEST_IMAGE \
    --overwrite \
    --output none

echo "✅ Image uploadée dans le conteneur 'input'"

# 4. Attendre
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Attente du traitement (45 secondes)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for i in {45..1}; do
    printf "⏳ %2d secondes...\r" $i
    sleep 1
done
echo ""

# 5. Vérifier les résultats
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Vérification des résultats"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📂 Conteneur 'input':"
INPUT_COUNT=$(az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --container-name input \
    --query "length(@)" -o tsv)
echo "   Fichiers: $INPUT_COUNT"

echo ""
echo "📂 Conteneur 'output':"
OUTPUT_COUNT=$(az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --container-name output \
    --query "length(@)" -o tsv)

if [ "$OUTPUT_COUNT" -gt 0 ]; then
    echo "   ✅ Fichiers traités: $OUTPUT_COUNT"
    az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name output \
        --query "[].{name:name, size:properties.contentLength, created:properties.creationTime}" \
        --output table
else
    echo "   ❌ Aucun fichier (la function n'a pas encore traité)"
fi

echo ""
echo "📂 Conteneur 'thumbnails':"
THUMB_COUNT=$(az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --container-name thumbnails \
    --query "length(@)" -o tsv)

if [ "$THUMB_COUNT" -gt 0 ]; then
    echo "   ✅ Miniatures créées: $THUMB_COUNT"
    az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name thumbnails \
        --query "[].{name:name, size:properties.contentLength, created:properties.creationTime}" \
        --output table
else
    echo "   ❌ Aucune miniature"
fi

# 6. État de la function
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣  État de la Function App"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FUNC_STATE=$(az functionapp show \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --query "state" -o tsv)

echo "État: $FUNC_STATE"

if [ "$FUNC_STATE" != "Running" ]; then
    echo "⚠️  La function n'est pas en cours d'exécution!"
    echo "   Démarrage..."
    az functionapp start \
        --name $FUNCTION_APP \
        --resource-group $RESOURCE_GROUP
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    📊 RÉSUMÉ                               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📥 Input:       $INPUT_COUNT fichier(s)"
echo "📤 Output:      $OUTPUT_COUNT fichier(s)"
echo "🖼️  Thumbnails:  $THUMB_COUNT fichier(s)"
echo ""

if [ "$OUTPUT_COUNT" -gt 0 ] && [ "$THUMB_COUNT" -gt 0 ]; then
    echo "✅ TEST RÉUSSI ! La function fonctionne correctement."
else
    echo "⚠️  PROBLÈME DÉTECTÉ"
    echo ""
    echo "🔍 Actions de diagnostic:"
    echo "1. Voir les logs:"
    echo "   az webapp log tail --name $FUNCTION_APP --resource-group $RESOURCE_GROUP"
    echo ""
    echo "2. Vérifier la configuration:"
    echo "   az functionapp config appsettings list --name $FUNCTION_APP --resource-group $RESOURCE_GROUP"
    echo ""
    echo "3. Portail Azure:"
    echo "   https://portal.azure.com/#resource/.../sites/$FUNCTION_APP"
fi

echo ""
