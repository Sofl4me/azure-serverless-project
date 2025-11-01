#!/bin/bash
set -e

# Charger les variables d'environnement
source scripts/correct-env-vars.sh

echo "🚀 Test en batch de traitement d'images"
echo ""

# Créer 3 images de test avec des tailles différentes
# Utiliser le python du venv au lieu de python3
python << 'PYTHON'
from PIL import Image, ImageDraw
import random

configs = [
    ("portrait", 600, 900, "Portrait"),
    ("square", 800, 800, "Carré"),
    ("panorama", 1800, 600, "Panorama")
]

for name, width, height, label in configs:
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    # Couleur aléatoire
    color = (random.randint(100, 255), random.randint(100, 255), random.randint(100, 255))
    draw.rectangle([(0, 0), (width, height)], fill=color)
    
    # Ajouter le label
    draw.text((width//2 - 50, height//2), label, fill='white')
    
    filename = f'/tmp/test-{name}.jpg'
    img.save(filename, 'JPEG')
    print(f"✅ Créé: {filename}")
PYTHON

echo ""
echo "📤 Upload des images..."

for image in portrait square panorama; do
    echo "   Uploading test-$image.jpg..."
    az storage blob upload \
        --account-name $STORAGE_ACCOUNT \
        --container-name input \
        --name test-$image.jpg \
        --file /tmp/test-$image.jpg \
        --auth-mode login \
        --overwrite \
        --only-show-errors
done

echo ""
echo "⏳ Attente du traitement (15 secondes)..."
sleep 15

echo ""
echo "📊 Résultats du traitement:"
echo ""
echo "=== Images Redimensionnées ==="
az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --container-name output \
    --auth-mode login \
    --query "[].{Name:name, Size:properties.contentLength}" \
    --output table

echo ""
echo "=== Thumbnails ==="
az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --container-name thumbnails \
    --auth-mode login \
    --query "[].{Name:name, Size:properties.contentLength}" \
    --output table

echo ""
echo "=== Métadonnées ==="
az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --container-name metadata \
    --auth-mode login \
    --query "[].name" \
    --output table

echo ""
echo "✅ Test batch terminé !"
