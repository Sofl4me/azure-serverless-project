#!/bin/bash

echo "🇪🇺 Test des régions européennes..."
echo ""

# Régions européennes à tester
REGIONS=(
    "germanywestcentral"
    "italynorth"
    "polandcentral"
    "norwayeast"
    "spaincentral"
)

WORKING_REGIONS=()

for region in "${REGIONS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Testing: $region"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    TEST_RG="test-rg-$region"
    TEST_STORAGE="teststg$(date +%N | cut -c1-6)"
    TEST_PLAN="testplan$(date +%N | cut -c1-6)"
    TEST_FUNC="testfunc$(date +%N | cut -c1-6)"
    
    # 1. Resource Group
    echo -n "  [1/4] Resource Group... "
    if az group create --name $TEST_RG --location $region --output none 2>/dev/null; then
        echo "✅"
    else
        echo "❌ BLOQUÉ"
        continue
    fi
    
    # 2. Storage Account
    echo -n "  [2/4] Storage Account... "
    if az storage account create \
        --name $TEST_STORAGE \
        --resource-group $TEST_RG \
        --location $region \
        --sku Standard_LRS \
        --output none 2>/dev/null; then
        echo "✅"
    else
        echo "❌ BLOQUÉ"
        az group delete --name $TEST_RG --yes --no-wait 2>/dev/null
        continue
    fi
    
    # 3. Consumption Plan (Function App)
    echo -n "  [3/4] Consumption Plan... "
    if az functionapp create \
        --name $TEST_FUNC \
        --resource-group $TEST_RG \
        --storage-account $TEST_STORAGE \
        --consumption-plan-location $region \
        --runtime python \
        --runtime-version 3.11 \
        --functions-version 4 \
        --os-type Linux \
        --disable-app-insights \
        --output none 2>/dev/null; then
        echo "✅"
        CONSUMPTION_OK="YES"
    else
        echo "❌"
        CONSUMPTION_OK="NO"
    fi
    
    # 4. Si Consumption échoue, tester App Service Plan
    if [ "$CONSUMPTION_OK" = "NO" ]; then
        echo -n "  [4/4] App Service Plan... "
        if az appservice plan create \
            --name $TEST_PLAN \
            --resource-group $TEST_RG \
            --location $region \
            --sku B1 \
            --is-linux \
            --output none 2>/dev/null; then
            
            if az functionapp create \
                --name "${TEST_FUNC}2" \
                --resource-group $TEST_RG \
                --storage-account $TEST_STORAGE \
                --plan $TEST_PLAN \
                --runtime python \
                --runtime-version 3.11 \
                --functions-version 4 \
                --os-type Linux \
                --output none 2>/dev/null; then
                echo "✅"
                APPSERVICE_OK="YES"
            else
                echo "❌"
                APPSERVICE_OK="NO"
            fi
        else
            echo "❌"
            APPSERVICE_OK="NO"
        fi
    fi
    
    # Nettoyer
    az group delete --name $TEST_RG --yes --no-wait 2>/dev/null
    
    # Résultat
    if [ "$CONSUMPTION_OK" = "YES" ]; then
        echo "  🎉 RÉGION COMPATIBLE (Consumption Plan - GRATUIT)"
        WORKING_REGIONS+=("$region:consumption")
    elif [ "$APPSERVICE_OK" = "YES" ]; then
        echo "  ⚠️  RÉGION COMPATIBLE (App Service Plan - PAYANT)"
        WORKING_REGIONS+=("$region:appservice")
    else
        echo "  ❌ RÉGION NON COMPATIBLE"
    fi
    
    echo ""
    sleep 2
done

echo ""
echo "════════════════════════════════════════════════════════"
echo "📊 RÉSUMÉ"
echo "════════════════════════════════════════════════════════"
echo ""

if [ ${#WORKING_REGIONS[@]} -eq 0 ]; then
    echo "❌ Aucune région compatible trouvée"
    echo ""
    echo "💡 Solutions:"
    echo "   1. Contacte le support Azure for Students"
    echo "   2. Utilise un compte Azure standard"
else
    echo "✅ Régions compatibles trouvées:"
    echo ""
    
    BEST_REGION=""
    BEST_TYPE=""
    
    for region_info in "${WORKING_REGIONS[@]}"; do
        region=$(echo $region_info | cut -d: -f1)
        type=$(echo $region_info | cut -d: -f2)
        
        if [ "$type" = "consumption" ]; then
            echo "   🎯 $region (Consumption Plan - GRATUIT) ⭐"
            if [ -z "$BEST_REGION" ]; then
                BEST_REGION=$region
                BEST_TYPE="consumption"
            fi
        else
            echo "   ⚠️  $region (App Service Plan - ~13€/mois)"
            if [ -z "$BEST_REGION" ]; then
                BEST_REGION=$region
                BEST_TYPE="appservice"
            fi
        fi
    done
    
    echo ""
    echo "════════════════════════════════════════════════════════"
    echo "🚀 RECOMMANDATION"
    echo "════════════════════════════════════════════════════════"
    echo ""
    echo "Meilleure région: $BEST_REGION ($BEST_TYPE)"
    echo ""
    
    if [ "$BEST_TYPE" = "consumption" ]; then
        echo "Commande à lancer:"
        echo ""
        echo "  sed -i 's/LOCATION=\".*\"/LOCATION=\"$BEST_REGION\"/' deploy-function.sh"
        echo "  ./deploy-function.sh"
    else
        echo "Commande à lancer:"
        echo ""
        echo "  sed -i 's/LOCATION=\".*\"/LOCATION=\"$BEST_REGION\"/' deploy-function-appservice.sh"
        echo "  ./deploy-function-appservice.sh"
    fi
    echo ""
fi
