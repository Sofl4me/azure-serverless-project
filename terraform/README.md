# Infrastructure Terraform - Azure Serverless

Infrastructure as Code pour le traitement d'images serverless sur Azure.

## Architecture

Resource Group (rg-serverless-img-dev)
├── Storage Account (stserverlessimg*)
│   ├── Container: input
│   ├── Container: output
│   ├── Container: thumbnails
│   └── Container: archive
├── Function App (func-serverless-img-dev)
│   └── Runtime: Python 3.11
├── App Service Plan (Consumption Y1)
└── Application Insights (monitoring)

## Prérequis

```bash
# Vérifier les outils
terraform --version  # >= 1.0
az --version        # >= 2.50

# Se connecter à Azure
az login
az account show

Démarrage rapide
# 1. Initialiser
terraform init

# 2. Voir le plan (sans déployer)
terraform plan -out=tfplan

# 3. Appliquer (optionnel)
terraform apply tfplan

Configuration
Fichier terraform.tfvars :
project_name     = "serverless-img"
environment      = "dev"
location         = "spaincentral"
python_version   = "3.11"

tags = {
  Project     = "ServerlessImageProcessing"
  ManagedBy   = "Terraform"
  Environment = "Development"
}

Variables principales



Variable
Défaut
Description



project_name
serverless-img
Nom du projet


environment
dev
Environnement


location
spaincentral
Région Azure


python_version
3.11
Version Python


Ressources créées

1 Resource Group
1 Storage Account (avec suffixe aléatoire)
4 Storage Containers (input, output, thumbnails, archive)
1 Application Insights
1 App Service Plan (Consumption Y1)
1 Function App (Linux + Python 3.11)

Total : 10 ressources
Outputs disponibles
# Lister tous les outputs
terraform output

# Récupérer un output sensible
terraform output -raw storage_account_primary_connection_string
terraform output -raw application_insights_connection_string

Commandes utiles
# Voir l'état
terraform state list
terraform state show azurerm_storage_account.main

# Mettre à jour
terraform plan -out=tfplan
terraform apply tfplan

# Détruire (ATTENTION)
terraform destroy

Coûts estimés



Service
Coût mensuel



Function App
~0€ (gratuit)


Storage
~0.50€


App Insights
~5€


TOTAL
~5.50€


Structure des fichiers
terraform/
├── providers.tf       # Configuration providers
├── variables.tf       # Définition variables
├── terraform.tfvars   # Valeurs variables
├── main.tf           # Ressources principales
├── outputs.tf        # Outputs exposés
└── README.md         # Cette doc

Troubleshooting
Erreur : Storage account name exists
Troubleshooting
Erreur : Storage account name exists
Erreur : Subscription not found
az login
az account set --subscription "Azure for Students"

Documentation

Terraform Azure Provider
Azure Functions
Documentation principale : ../README.md


Projet M2 Gestion de Configuration - Novembre 2025
