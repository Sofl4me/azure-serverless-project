# 📚 Documentation - Image Processor Serverless

Documentation technique du projet de traitement d'images serverless sur Azure.

## 📖 Table des Matières

1. [Architecture](./architecture.md) - Vue d'ensemble de l'architecture
2. [Infrastructure](./infrastructure.md) - Ressources Azure déployées
3. [Deployment](./deployment.md) - Guide de déploiement


---

## 🎯 Vue d'Ensemble Rapide

**Projet** : Système serverless de traitement d'images  
**Technologie** : Azure Functions, Blob Storage, Application Insights  
**Langage** : Python 3.11  
**Infrastructure as Code** : Terraform  

### Fonctionnalités

- ✅ Upload d'images via Blob Storage
- ✅ Traitement automatique (redimensionnement)
- ✅ Génération de thumbnails
- ✅ Extraction de métadonnées
- ✅ Monitoring avec Application Insights

### Architecture Simplifiée
Upload Image → Blob Storage → Function App → Process → Output
                    ↓
              Event Grid
                    ↓
           Application Insights

---

## 🚀 Quick Start

```bash
# Cloner le projet
git clone <repo-url>
cd azure-serverless-project

# Charger la configuration
source scripts/correct-env-vars.sh

# Déployer l'infrastructure
terraform init
terraform plan
terraform apply

# Tester
./scripts/test-upload.sh

📞 Support
Pour toute question : Ouvrir une issue
