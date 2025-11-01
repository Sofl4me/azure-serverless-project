#!/bin/bash
set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "════════════════════════════════════════════════════════"
echo "🧪 TEST DE LA FUNCTION DÉPLOYÉE"
echo "════════════════════════════════════════════════════════"
echo ""

# Demander les infos
read -p "📝 Nom du Resource Group: " RESOURCE_GROUP
read -p "📝 Nom du Storage Account: " STORAGE_ACCOUNT

echo ""
echo -e "${BLUE}📥 Créer une image de test...${NC}"

# Créer une image de test avec ImageMagick ou Python
python3 << 'PYEOF'
from PIL import Image, ImageDraw, ImageFont

# Créer une image 800x600
img = Image.new('RGB', (800, 600), color='#3498db')
draw = ImageDraw.Draw(img)

# Dessiner du texte
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
except:
    font = ImageFont.load_default()

text = "TEST IMAGE"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

position = ((800 - text_width) // 2, (600 - text_height) // 2)
draw.text(position, text, fill='white', font=font)

# Sauvegarder
img.save('test-image.jpg', 'JPEG', quality=95)
print("✅ Image de test créée: test-image.jpg")
PYEOF

echo ""
echo -e "${YELLOW}📤 Upload de l'image...${NC}"
az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --container-name input \
    --name "test-$(date +%s).jpg" \
    --file test-image.jpg \
    --auth-mode login

echo ""
echo -e "${GREEN}✅ Image uploadée !${NC}"
echo ""
echo -e "${BLUE}⏳ Attendre 10 secondes...${NC}"
sleep 10

echo ""
echo -e "${YELLOW}📊 Vérification des containers...${NC}"

for container in output thumbnails archive; do
    echo ""
    echo "📂 Container: $container"
    az storage blob list \
        --account-name $STORAGE_ACCOUNT \
        --container-name $container \
        --auth-mode login \
        --output table
done

echo ""
echo -e "${BLUE}🗑️  Supprimer l'image de test locale ?${NC}"
read -p "Supprimer test-image.jpg ? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm test-image.jpg
    echo "✅ Image supprimée"
fi

echo ""
echo "════════════════════════════════════════════════════════"
