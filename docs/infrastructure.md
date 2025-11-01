# 📦 Infrastructure Azure

## Ressources Déployées

### Resource Group

- **Nom** : `rg-serverless-img-dev`
- **Région** : Spain Central
- **Tags** : Environment=dev, Project=Image-Processor

### Storage Account : `stockage011`

**Configuration** :
- **Type** : StorageV2 (General Purpose v2)
- **Réplication** : LRS (Locally Redundant Storage)
- **Performance** : Standard
- **TLS Version** : 1.2 minimum
- **HTTPS Only** : Activé

**Containers** :

| Container    | Usage                     |
|--------------|---------------------------|
| `input`      | Images sources            |
| `output`     | Images redimensionnées    |
| `thumbnails` | Miniatures (150x150)      |
| `metadata`   | Métadonnées JSON          |

### Application Insights : `appi-generation-img-dev`

**Configuration** :
- **Type** : Web Application
- **Retention** : 30 jours
- **Sampling** : Activé (pour réduire les coûts)

**Métriques surveillées** :
- Nombre de requêtes
- Temps de traitement
- Taux d'erreur
- Utilisation mémoire/CPU

## Sécurité & Permissions

### Managed Identity

**Rôles assignés à la Function App** :
- `Storage Blob Data Contributor` : Lecture/écriture dans les containers
- `Application Insights Component Contributor` : Envoi de télémétrie

### Network Security

- **Public Access** : Désactivé sur les containers
- **TLS** : Version 1.2 minimum requise
- **HTTPS Only** : Forcé sur le Storage Account

## Coûts

**Estimation mensuelle (usage dev)** :

| Ressource            | Coût estimé    |
|----------------------|----------------|
| Storage Account      | < 0.50 USD     |
| Application Insights | Gratuit*       |
| Azure Functions      | Gratuit**      |
| **TOTAL**            | **< 1 USD**    |

*5GB/mois gratuits  
**1 million d'exécutions gratuites/mois
