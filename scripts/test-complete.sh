#!/bin/bash
set -e

echo "════════════════════════════════════════════════════════"
echo "🧪 TEST COMPLET DE LA FUNCTION APP"
echo "════════════════════════════════════════════════════════"
echo ""

source .deployment-info

STORAGE_KEY=$(az storage account keys list \
    --account-name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query "[0].value" -o tsv)

# Créer une nouvelle image de test
echo "🎨 Création d'une image de test..."
python3 << 'PYTHON'
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import os

img = Image.new('RGB', (1024, 768), color='#2196F3')
draw = ImageDraw.Draw(img)

# Ajouter du texte
text = f"Test Azure Function\n{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 40)
except:
    font = ImageFont.load_default()

draw.text((50, 50), text, fill='white', font=font)
draw.rectangle([50, 150, 974, 618], outline='white', width=5)

os.makedirs('/tmp', exist_ok=True)
img.save('/tmp/test_image_new.jpg', 'JPEG', quality=95)
print("✅ Image créée: /tmp/test_image_new.jpg")
PYTHON

# Upload
TEST_IMAGE="test_$(date +%Y%m%d_%H%M%S).jpg"
echo ""
echo "📤 Upload de $TEST_IMAGE..."
az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --account-key "$STORAGE_KEY" \
    --container-name input \
    --name "$TEST_IMAGE" \
    --file /tmp/test_image_new.jpg \
    --overwrite \
    --output none

echo "✅ Image uploadée"
echo ""
echo "⏳ Attente du traitement (30 secondes)..."

# Barre de progression
for i in {1..30}; do
    echo -n "▓"
    sleep 1
done
echo ""

# Vérifier les résultats
echo ""
echo "════════════════════════════════════════════════════════"
echo "📊 RÉSULTATS DU TRAITEMENT"
echo "════════════════════════════════════════════════════════"

SUCCESS=true

for container in output thumbnails archive; do
    echo ""
    echo "📁 Container '$container':"
    
    # Chercher le fichier spécifique
    if [ "$container" = "output" ]; then
        pattern="resized_$TEST_IMAGE"
    elif [ "$container" = "thumbnails" ]; then
        pattern="thumb_$TEST_IMAGE"
    else
        pattern="archive_$TEST_IMAGE"
    fi
    
    FOUND=$(az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --account-key "$STORAGE_KEY" \
        --container-name $container \
        --prefix "${pattern%%_*}" \
        --query "[?contains(name, '$TEST_IMAGE')].{Name:name, Size:properties.contentLength}" \
        --output table)
    
    if [ -z "$FOUND" ] || [ "$FOUND" = "Name    Size" ]; then
        echo "   ❌ Fichier non trouvé !"
        SUCCESS=false
    else
        echo "$FOUND"
        echo "   ✅ Fichier créé avec succès"
    fi
done

echo ""
echo "════════════════════════════════════════════════════════"
if [ "$SUCCESS" = true ]; then
    echo "✅ TEST RÉUSSI - Tous les fichiers ont été créés !"
else
    echo "❌ TEST ÉCHOUÉ - Certains fichiers manquent"
    exit 1
fi
echo "════════════════════════════════════════════════════════"
