# 🏗️ Architecture du Système

## Vue d'Ensemble

Le système utilise une architecture serverless event-driven basée sur Azure.

### Diagramme d'Architecture
┌─────────────────────────────────────────────────────────┐
│                   Azure Resource Group                   │
│                  rg-serverless-img-dev                   │
│                                                          │
│  ┌──────────────────┐         ┌─────────────────┐      │
│  │  Blob Storage    │         │  Function App   │      │
│  │  stockage011     │─────────│  (Python 3.11)  │      │
│  │                  │ Trigger │                 │      │
│  │  ┌────────────┐  │         │  ┌───────────┐  │      │
│  │  │   input    │──┼────────▶│  │ Processor │  │      │
│  │  └────────────┘  │         │  └─────┬─────┘  │      │
│  │                  │         │        │        │      │
│  │  ┌────────────┐  │         │        ▼        │      │
│  │  │   output   │◀─┼─────────│   Write Back    │      │
│  │  ├────────────┤  │         │        │        │      │
│  │  │ thumbnails │◀─┼─────────│        │        │      │
│  │  ├────────────┤  │         │        │        │      │
│  │  │  metadata  │◀─┼─────────│        │        │      │
│  │  └────────────┘  │         └────────┼────────┘      │
│  └──────────────────┘                  │               │
│                                        │               │
│  ┌──────────────────┐                  │               │
│  │ App Insights     │◀─────────────────┘               │
│  │ Monitoring       │  Telemetry                       │
│  └──────────────────┘                                  │
└─────────────────────────────────────────────────────────┘

## Flux de Données

### 1. Upload d'Image
Utilisateur → Blob Storage (input) → Blob Created Event

### 2. Traitement
Event → Function Trigger → Télécharger Image
                         → Redimensionner (800x600)
                         → Créer Thumbnail (150x150)
                         → Extraire Métadonnées

### 3. Stockage des Résultats
Function → Upload Image redimensionnée (output)
        → Upload Thumbnail (thumbnails)
        → Upload Métadonnées JSON (metadata)

### 4. Monitoring
Toutes les étapes → Logs → Application Insights

## Choix Techniques

### Pourquoi Azure Functions ?

✅ **Serverless** : Pas de gestion de serveurs  
✅ **Auto-scaling** : S'adapte automatiquement à la charge  
✅ **Pay-per-use** : Coût proportionnel à l'utilisation  
✅ **Event-driven** : Réagit aux événements Blob Storage  

### Pourquoi Blob Storage ?

✅ **Optimisé** : Conçu pour stocker des fichiers binaires  
✅ **Économique** : Tarification attractive  
✅ **Intégration** : Trigger natif avec Azure Functions  
✅ **Durable** : Réplication automatique (LRS)  

### Pourquoi Application Insights ?

✅ **Natif** : Intégré à Azure Functions  
✅ **Temps réel** : Monitoring en direct  
✅ **Gratuit** : Jusqu'à 5GB/mois  
✅ **Puissant** : Requêtes Kusto, alertes, dashboards  

## Sécurité

### Authentification

- **Managed Identity** : Pas de credentials en dur
- **RBAC** : Permissions granulaires
- **HTTPS Only** : Chiffrement en transit
- **Private Endpoints** : Isolement réseau (optionnel)

### Réseau

- **No Public Access** : Containers privés par défaut
- **TLS 1.2+** : Protocole de chiffrement moderne

## Résilience

### Haute Disponibilité

- **LRS Storage** : Redondance locale (3 copies)
- **Function Retry** : Retry automatique en cas d'échec
- **Health Checks** : Monitoring automatique

### Scaling

- **Horizontal Scaling** : Instances multiples si besoin
- **Consumption Plan** : Scaling automatique 0 → N instances
