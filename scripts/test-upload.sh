#!/bin/bash
source scripts/correct-env-vars.sh

echo "🧪 Test d'upload dans le Storage Account..."
echo ""

# Créer un fichier de test
TEST_FILE="test-$(date +%s).txt"
echo "Fichier de test créé le $(date)" > $TEST_FILE
echo "Storage Account: $STORAGE_ACCOUNT" >> $TEST_FILE
echo "Resource Group: $RESOURCE_GROUP" >> $TEST_FILE

echo "📁 Fichier créé: $TEST_FILE"
echo ""

# Upload dans le container 'input'
echo "📤 Upload vers le container 'input'..."
az storage blob upload \
    --account-name $STORAGE_ACCOUNT \
    --container-name input \
    --name $TEST_FILE \
    --file $TEST_FILE \
    --auth-mode login \
    --overwrite

if [ $? -eq 0 ]; then
    echo "✅ Upload réussi !"
else
    echo "❌ Échec de l'upload"
    echo "   Vérifiez que les permissions RBAC sont propagées (attendre 2 minutes)"
    exit 1
fi

echo ""
echo "📋 Contenu du container 'input':"
az storage blob list \
    --account-name $STORAGE_ACCOUNT \
    --container-name input \
    --auth-mode login \
    --output table

# Nettoyer
rm $TEST_FILE
echo ""
echo "🧹 Fichier local supprimé"
echo "✅ Test terminé avec succès !"
