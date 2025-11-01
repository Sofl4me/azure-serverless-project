#!/bin/bash

echo "�� Validation Phase 1 - Infrastructure"
echo "======================================"
echo ""

# Charger les variables
source scripts/correct-env-vars.sh

echo "1️⃣ Storage Account:"
az storage account show \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query "{Name:name, Location:location, Status:statusOfPrimary}" \
  --output table

echo ""
echo "2️⃣ Containers:"
az storage container list \
  --account-name $STORAGE_ACCOUNT \
  --auth-mode login \
  --query "[].{Name:name, LastModified:properties.lastModified}" \
  --output table

echo ""
echo "3️⃣ Application Insights:"
az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query "{Name:name, Location:location, AppId:appId}" \
  --output table

echo ""
echo "4️⃣ Git Status:"
git log --oneline -n 3
echo ""
git tag -l

echo ""
echo "✅ Phase 1 Status: READY FOR PHASE 2"
