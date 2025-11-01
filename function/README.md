# Azure Function - Image Processor

Traitement automatique d'images uploadées dans Azure Storage.

## Fonctionnalités

- ✅ **Déclenchement automatique** : Dès qu'une image arrive dans `input/`
- 🖼️ **Création de thumbnail** : Redimensionnement 200x200 pixels
- 📤 **Copie dans output** : Image originale
- 📦 **Archivage** : Avec timestamp dans `archive/`

## Formats supportés

- JPEG / JPG
- PNG
- GIF
- BMP
- TIFF

## Architecture

input/           →  Déclencheur (nouvelle image)
    ↓
Function App     →  Traitement (Pillow)
    ↓
├── thumbnails/  →  Miniature 200x200
├── output/      →  Image originale
└── archive/     →  Backup avec timestamp

## Variables d'environnement

| Variable | Description | Défaut |
|----------|-------------|--------|
| STORAGE_CONNECTION_STRING | Connexion au Storage | Obligatoire |
| THUMBNAIL_WIDTH | Largeur thumbnail | 200 |
| THUMBNAIL_HEIGHT | Hauteur thumbnail | 200 |

## Installation locale

```bash
# Créer un environnement virtuel
python3 -m venv .venv
source .venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Installer Azure Functions Core Tools
# (si pas déjà fait)

Test en local
# Démarrer la Function
func start

# Dans un autre terminal, uploader une image
az storage blob upload \
  --account-name <storage-name> \
  --container-name input \
  --name test.jpg \
  --file /path/to/image.jpg

Logs
logging.info(f"🎯 Traitement de l'image: {filename}")
logging.info(f"📏 Taille: {size} bytes")
logging.info(f"🖼️  Format: {format}")
logging.info(f"✅ Thumbnail créée")
logging.info(f"✅ Image copiée dans output")
logging.info(f"✅ Image archivée")

Déploiement
Voir ../scripts/deploy-function.sh
Troubleshooting
Erreur : Module PIL not found

pip install Pillow==10.3.0

Erreur : Connection string not found
# Vérifier local.settings.json
cat local.settings.json

Projet M2 - Novembre 2025
