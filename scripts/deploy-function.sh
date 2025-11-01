#!/bin/bash
set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo "════════════════════════════════════════════════════════"
echo "🚀 DÉPLOIEMENT AZURE FUNCTION"
echo "════════════════════════════════════════════════════════"
echo ""

# Configuration
TIMESTAMP=$(date +%s)
RESOURCE_GROUP="rg-img-proc-$(echo $TIMESTAMP | tail -c 7)"
LOCATION="norwayeast"  # ← Ta région qui fonctionne !
STORAGE_ACCOUNT="stimg$(echo $TIMESTAMP | tail -c 11)"
FUNCTION_APP="func-img-$(echo $TIMESTAMP | tail -c 9)"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "   Resource Group  : $RESOURCE_GROUP"
echo "   Location        : $LOCATION"
echo "   Storage Account : $STORAGE_ACCOUNT"
echo "   Function App    : $FUNCTION_APP"
echo ""

# 1. Créer le Resource Group
echo -e "${YELLOW}📦 Création du Resource Group...${NC}"
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION \
    --output none
echo -e "${GREEN}✅ Resource Group créé${NC}"

# 2. Créer le Storage Account
echo -e "${YELLOW}💾 Création du Storage Account...${NC}"
az storage account create \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --output none
echo -e "${GREEN}✅ Storage Account créé${NC}"

# 3. Récupérer la connection string
echo -e "${YELLOW}🔑 Récupération de la connection string...${NC}"
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query connectionString \
    --output tsv)
echo -e "${GREEN}✅ Connection string récupérée${NC}"

# 4. Créer les containers
echo -e "${YELLOW}📂 Création des containers...${NC}"
for container in input output thumbnails archive; do
    az storage container create \
        --name $container \
        --account-name $STORAGE_ACCOUNT \
        --connection-string "$STORAGE_CONNECTION_STRING" \
        --output none
    echo "   ✅ Container '$container' créé"
done

# 5. Créer le Function App avec paramètres adaptés pour Spain Central
echo -e "${YELLOW}⚡ Création de la Function App...${NC}"
az functionapp create \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --storage-account $STORAGE_ACCOUNT \
    --consumption-plan-location $LOCATION \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --os-type Linux \
    --disable-app-insights \
    --output none

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Échec avec Python 3.11, essai avec 3.10...${NC}"
    az functionapp create \
        --name $FUNCTION_APP \
        --resource-group $RESOURCE_GROUP \
        --storage-account $STORAGE_ACCOUNT \
        --consumption-plan-location $LOCATION \
        --runtime python \
        --runtime-version 3.10 \
        --functions-version 4 \
        --os-type Linux \
        --disable-app-insights \
        --output none
fi

echo -e "${GREEN}✅ Function App créée${NC}"

# 6. Configurer les variables d'environnement
echo -e "${YELLOW}⚙️  Configuration des variables...${NC}"
az functionapp config appsettings set \
    --name $FUNCTION_APP \
    --resource-group $RESOURCE_GROUP \
    --settings \
        "AzureWebJobsStorage=$STORAGE_CONNECTION_STRING" \
        "FUNCTIONS_WORKER_RUNTIME=python" \
    --output none
echo -e "${GREEN}✅ Variables configurées${NC}"

# 7. Déployer le code
echo -e "${YELLOW}📦 Déploiement du code...${NC}"
cd ../function
func azure functionapp publish $FUNCTION_APP --python --build remote
cd ../scripts

echo ""
echo "════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📊 Informations:"
echo "   Resource Group  : $RESOURCE_GROUP"
echo "   Function App    : $FUNCTION_APP"
echo "   Storage Account : $STORAGE_ACCOUNT"
echo ""
echo "🔗 URL: https://$FUNCTION_APP.azurewebsites.net"
echo ""

# Sauvegarder les infos
cat > .deployment-info << DEPLOY_EOF
RESOURCE_GROUP=$RESOURCE_GROUP
FUNCTION_APP=$FUNCTION_APP
STORAGE_ACCOUNT=$STORAGE_ACCOUNT
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
DEPLOY_EOF

echo "💾 Infos sauvegardées dans .deployment-info"
