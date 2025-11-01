# 🚀 Guide de Déploiement

## Prérequis

### Outils Nécessaires

- Azure CLI (`az`) version 2.50+
- Terraform version 1.5+
- Python 3.11
- Git

### Installation

```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Python
sudo apt install python3.11 python3.11-venv
Déploiement
Étape 1 : Cloner le Projet
git clone <repo-url>
cd azure-serverless-project
Étape 2 : Connexion Azure
az login
az account set --subscription "<subscription-id>"
Étape 3 : Configuration
# Copier le fichier d'exemple
cp .env.example .env.local

# Éditer avec tes valeurs
nano .env.local
Étape 4 : Déploiement Terraform
cd terraform/

# Initialiser
terraform init

# Vérifier le plan
terraform plan

# Appliquer
terraform apply
Étape 5 : Déploiement de la Function
cd ../functions/

# Créer l'environnement virtuel
python3.11 -m venv .venv
source .venv/bin/activate

# Installer les dépendances
pip install -r requirements.txt

# Déployer
func azure functionapp publish <function-app-name>
Étape 6 : Test
# Uploader une image de test
./scripts/test-upload.sh

# Vérifier les logs
func azure functionapp logstream <function-app-name>
Troubleshooting
Voir troubleshooting.md
