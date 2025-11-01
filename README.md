# 🎨 Azure Serverless Image Processing

Système automatisé de traitement d'images avec Azure Functions et Blob Storage.

## ✨ Fonctionnalités

- 📤 Upload d'image → déclenchement automatique
- 📐 Redimensionnement 800x600
- 🖼️ Miniatures 150x150
- 📦 Archivage des originaux

## 🚀 Déploiement

```bash
cd scripts
./deploy.sh

🧪 Test
./test-complete.sh

📁 Structure
azure-serverless-project/
├── src/
│   ├── function_app.py      # Code Azure Function
│   ├── requirements.txt     # Dépendances
│   └── host.json
├── scripts/
│   ├── deploy.sh            # Déploiement
│   └── test-complete.sh     # Tests
└── README.md

🛠️ Stack technique

Azure Functions (Python 3.11)
Azure Blob Storage
Pillow (traitement d'images)

👤 Auteur
Sonny - M2 DevOps IPI Paris (2025)
