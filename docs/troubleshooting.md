# 🆘 Guide de Résolution de Problèmes

## Problèmes Courants

### 1. Permission Denied sur Storage

**Symptôme** :
ERROR: This request is not authorized to perform this operation using this permission.

**Solution** :
```bash
# Vérifier les rôles RBAC
az role assignment list --scope /subscriptions/.../resourceGroups/rg-serverless-img-dev

# Re-configurer si nécessaire
./scripts/setup-rbac.sh
sleep 60  # Attendre la propagation
2. Function ne se Déclenche Pas
Symptôme : Aucune exécution après upload
Vérifications :
# 1. Vérifier que la Function est déployée
func azure functionapp list-functions <function-app-name>

# 2. Vérifier les logs
func azure functionapp logstream <function-app-name>

# 3. Vérifier l'Event Grid Subscription
az eventgrid event-subscription list --output table
3. Application Insights ne reçoit pas de Logs
Solution :
# Vérifier la connection string
az monitor app-insights component show \
  --app appi-generation-img-dev \
  --resource-group rg-serverless-img-dev \
  --query connectionString
Commandes de Diagnostic
# Vérifier l'état des ressources
source scripts/correct-env-vars.sh

# Logs de la Function
az functionapp logs tail --name <function-name> --resource-group rg-serverless-img-dev

# Métriques du Storage
az storage account show-usage --account-name stockage011
Ressources Utiles

Documentation Azure Functions
Troubleshooting Blob Triggers
Application Insights
