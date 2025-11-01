#!/bin/bash
set -e

# Créer une image de test colorée
python3 << PYTHON
from PIL import Image, ImageDraw, ImageFont
import io

# Créer une image 800x600 avec dégradé
img = Image.new('RGB', (800, 600))
draw = ImageDraw.Draw(img)

# Dégradé de couleurs
for y in range(600):
    r = int(255 * (y / 600))
    g = int(128 * (1 - y / 600))
    b = int(200 * (y / 600))
    draw.line([(0, y), (800, y)], fill=(r, g, b))

# Texte central
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 60)
except:
    font = ImageFont.load_default()

text = "Azure Test Image"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

x = (800 - text_width) // 2
y = (600 - text_height) // 2

# Ombre
draw.text((x+3, y+3), text, fill=(0, 0, 0), font=font)
# Texte principal
draw.text((x, y), text, fill=(255, 255, 255), font=font)

# Sauvegarder
img.save('/tmp/test_image.jpg', 'JPEG', quality=95)
print("✅ Image créée: /tmp/test_image.jpg")
PYTHON
