#!/bin/bash
source scripts/correct-env-vars.sh

echo "🔐 Configuration des permissions RBAC..."

# Obtenir ton User Principal ID
USER_ID=$(az ad signed-in-user show --query id -o tsv)
echo "  User ID: $USER_ID"

# Obtenir le Storage Account ID
STORAGE_ID=$(az storage account show \
    --name $STORAGE_ACCOUNT \
    --resource-group $RESOURCE_GROUP \
    --query id -o tsv)

echo "  Storage ID: $STORAGE_ID"

# Assigner les rôles nécessaires
echo ""
echo "  Attribution des rôles..."

# Storage Blob Data Contributor (lecture/écriture)
az role assignment create \
    --assignee $USER_ID \
    --role "Storage Blob Data Contributor" \
    --scope $STORAGE_ID \
    --output none

echo "    ✅ Storage Blob Data Contributor assigné"

# Storage Blob Data Reader (lecture seule - backup)
az role assignment create \
    --assignee $USER_ID \
    --role "Storage Blob Data Reader" \
    --scope $STORAGE_ID \
    --output none 2>/dev/null || true

echo "    ✅ Storage Blob Data Reader assigné"

echo ""
echo "✅ Permissions RBAC configurées !"
echo ""
echo "⏳ Attendre 1-2 minutes pour la propagation des permissions..."
