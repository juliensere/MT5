# Guide Docker pour MT5

## Fichiers Docker

### Structure des fichiers
- `Dockerfile` - Image Docker de l'application
- `compose.yml` - Configuration Docker Compose pour la PRODUCTION
- `compose.dev.yml` - Configuration Docker Compose pour le DÉVELOPPEMENT
- `.env.example` - Exemple de variables d'environnement

## Utilisation

### Production

```bash
# Build et démarrage
docker compose up -d

# Avec variables d'environnement personnalisées
PORT=8080 docker compose up -d

# Arrêt
docker compose down

# Rebuild après modifications
docker compose up -d --build
```

### Développement

```bash
# Utilisation de la configuration de développement
docker compose -f compose.yml -f compose.dev.yml up

# En mode détaché
docker compose -f compose.yml -f compose.dev.yml up -d

# Rebuild
docker compose -f compose.yml -f compose.dev.yml up --build
```

### Configuration avec .env

```bash
# 1. Copier le fichier exemple
cp .env.example .env

# 2. Modifier les valeurs
nano .env  # ou votre éditeur préféré

# 3. Docker Compose utilisera automatiquement le fichier .env
docker compose up -d
```

## Fonctionnalités

### Health Checks

Le container inclut un health check qui vérifie toutes les 30 secondes (15s en dev) que l'application répond correctement.

```bash
# Vérifier l'état de santé
docker ps
# La colonne STATUS affichera "healthy" ou "unhealthy"

# Logs du health check
docker inspect mt5-multitrack | grep -A 10 Health
```

### Limites de ressources

**Production :**
- CPU : 1 core max, 0.25 core réservé
- RAM : 512 MB max, 128 MB réservé

**Développement :**
- CPU : 2 cores max
- RAM : 1 GB max

```bash
# Vérifier l'utilisation des ressources
docker stats mt5-multitrack
```

### Gestion des logs

Les logs sont configurés avec rotation automatique :
- Taille max par fichier : 10 MB (production) / 50 MB (dev)
- Nombre de fichiers : 3 (production) / 5 (dev)

```bash
# Voir les logs
docker compose logs -f

# Logs avec horodatage
docker compose logs -f --timestamps

# Dernières 100 lignes
docker compose logs --tail=100
```

## Volumes

### Volume des chansons multitrack (Docker Named Volume)

MT5 utilise un **volume Docker nommé** (`mt5-multitrack-data`) pour stocker les chansons multitrack. Ce système offre plusieurs avantages :

- **Indépendance du code source** : Les chansons sont séparées de l'application
- **Persistance garantie** : Les données survivent aux suppressions de containers
- **Meilleure portabilité** : Facile à sauvegarder/restaurer avec les commandes Docker
- **Performance optimale** : Meilleures performances que les bind mounts sur Windows/Mac
- **Initialisation automatique** : Au premier démarrage, le volume est automatiquement peuplé avec les chansons de démonstration

#### Initialisation automatique

Au premier lancement, si le volume est vide, l'entrypoint Docker copie automatiquement les chansons de démonstration :

```bash
# Premier démarrage
docker compose up -d

# Logs montrent l'initialisation :
# MT5 Docker Entrypoint - Initialisation...
# Le volume multitrack est vide.
# Initialisation avec les chansons de démonstration...
# ✓ Chansons de démonstration copiées avec succès.
#   Nombre de chansons: 8
```

#### Ajouter une nouvelle chanson dans le volume

```bash
# Méthode 1 : Copier depuis l'hôte vers le container
docker cp ~/music/MaNouvelleChanson mt5-multitrack:/usr/src/app/client/multitrack/

# Méthode 2 : Créer un répertoire temporaire et copier
docker compose exec mt5-multitrack mkdir -p /usr/src/app/client/multitrack/MaNouvelleChanson
docker cp ~/music/*.mp3 mt5-multitrack:/usr/src/app/client/multitrack/MaNouvelleChanson/

# Rafraîchir le navigateur - la chanson apparaît immédiatement
```

### Volumes de développement

En mode développement (avec `compose.dev.yml`), les fichiers source sont montés pour le hot-reload :

**Fichiers serveur (lecture seule) :**
- `./server.js` → `/usr/src/app/server.js`
- `./package.json` → `/usr/src/app/package.json`

**Fichiers client (lecture seule) :**
- `./client/index.html` → `/usr/src/app/client/index.html`
- `./client/css` → `/usr/src/app/client/css`
- `./client/js` → `/usr/src/app/client/js`
- `./client/img` → `/usr/src/app/client/img`

**Chansons (volume Docker partagé) :**
- `mt5-multitrack-data` → `/usr/src/app/client/multitrack` (même volume que production)

Par défaut, le mode développement utilise le **même volume Docker nommé** que la production, permettant de partager les chansons.

**Option : Utiliser le répertoire local en développement**

Si vous préférez utiliser votre répertoire local `./client/multitrack` en développement :

1. Éditez `compose.dev.yml`
2. Commentez la ligne `- mt5-multitrack-data:/usr/src/app/client/multitrack`
3. Décommentez la ligne `- ./client/multitrack:/usr/src/app/client/multitrack`

Toute modification des fichiers source sera immédiatement visible après un rafraîchissement du navigateur.

### Gestion et backup des volumes Docker

#### Inspection du volume

```bash
# Informations sur le volume
docker volume inspect mt5-multitrack-data

# Lister les fichiers dans le volume
docker compose exec mt5-multitrack ls -la /usr/src/app/client/multitrack

# Vérifier l'espace utilisé
docker compose exec mt5-multitrack du -sh /usr/src/app/client/multitrack
```

#### Sauvegarder le volume

**Méthode 1 : Backup complet du volume (recommandé)**

```bash
# Créer une sauvegarde complète du volume dans une archive
docker run --rm \
  -v mt5-multitrack-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mt5-multitrack-backup-$(date +%Y%m%d).tar.gz -C /data .

# Vérifier la sauvegarde
ls -lh mt5-multitrack-backup-*.tar.gz
```

**Méthode 2 : Copier depuis le container**

```bash
# Copier toutes les chansons vers l'hôte
docker cp mt5-multitrack:/usr/src/app/client/multitrack ./multitrack-backup

# Créer une archive
tar -czf multitrack-backup-$(date +%Y%m%d).tar.gz multitrack-backup/
```

#### Restaurer le volume

**Méthode 1 : Restauration complète depuis une archive**

```bash
# Arrêter le container
docker compose down

# Restaurer le volume depuis l'archive
docker run --rm \
  -v mt5-multitrack-data:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/mt5-multitrack-backup-20260111.tar.gz"

# Redémarrer
docker compose up -d
```

**Méthode 2 : Copier vers le container en cours**

```bash
# Copier des chansons dans le container
docker cp ./multitrack-backup/MaChanson mt5-multitrack:/usr/src/app/client/multitrack/

# Pas besoin de redémarrer, rafraîchir le navigateur suffit
```

#### Nettoyer les chansons

```bash
# Supprimer une chanson spécifique
docker compose exec mt5-multitrack rm -rf /usr/src/app/client/multitrack/NomDeLaChanson

# Ou depuis l'hôte avec docker cp (plus complexe)
docker compose exec mt5-multitrack sh -c "cd /usr/src/app/client/multitrack && rm -rf NomDeLaChanson"

# Rafraîchir le navigateur pour voir les changements
```

#### Réinitialiser le volume (recommencer avec les chansons de démo)

```bash
# Arrêter et supprimer le container
docker compose down

# Supprimer le volume
docker volume rm mt5-multitrack-data

# Redémarrer (le volume sera recréé et initialisé automatiquement)
docker compose up -d
```

#### Migrer le volume vers un autre serveur

```bash
# Sur le serveur source
docker run --rm \
  -v mt5-multitrack-data:/data \
  alpine tar czf - -C /data . > mt5-data.tar.gz

# Transférer le fichier vers le serveur destination
scp mt5-data.tar.gz user@destination:/path/

# Sur le serveur destination
docker volume create mt5-multitrack-data
docker run --rm \
  -v mt5-multitrack-data:/data \
  -v /path:/backup \
  alpine tar xzf /backup/mt5-data.tar.gz -C /data
```

## Commandes utiles

### Debugging

```bash
# Entrer dans le container
docker compose exec mt5-multitrack /bin/sh

# Exécuter une commande
docker compose exec mt5-multitrack node --version

# Voir les processus
docker compose top
```

### Nettoyage

```bash
# Arrêter et supprimer les containers
docker compose down

# ATTENTION : Cette commande supprime aussi le volume des chansons !
# Sauvegarder d'abord si nécessaire (voir section "Gestion et backup des volumes")
docker compose down -v

# Supprimer les images
docker compose down --rmi all

# Nettoyage complet du système Docker
docker system prune -a
```

### Build

```bash
# Build sans cache (force rebuild complet)
docker compose build --no-cache

# Build avec arguments
docker compose build --build-arg NODE_ENV=production

# Build d'un service spécifique
docker compose build mt5-multitrack
```

## Variables d'environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `PORT` | `3000` | Port d'écoute du serveur |
| `NODE_ENV` | `production` | Environnement Node.js |
| `IP` | `0.0.0.0` | Adresse d'écoute |

## Troubleshooting

### Le container ne démarre pas

```bash
# Vérifier les logs
docker compose logs mt5-multitrack

# Vérifier l'état
docker ps -a
```

### Port déjà utilisé

```bash
# Changer le port dans .env ou en ligne de commande
PORT=8080 docker compose up -d
```

### Health check échoue

```bash
# Vérifier que l'application répond
curl http://localhost:3000

# Augmenter le start_period dans compose.yml si l'app met du temps à démarrer
```

### Performance lente

```bash
# Augmenter les limites de ressources dans compose.yml
# Vérifier l'utilisation
docker stats mt5-multitrack
```

## Intégration CI/CD

### GitHub Actions exemple

```yaml
- name: Build and test
  run: |
    docker compose build
    docker compose up -d
    # Attendre que le service soit healthy
    timeout 60 bash -c 'until docker ps | grep healthy; do sleep 2; done'
    # Tests
    curl -f http://localhost:3000 || exit 1
    docker compose down
```

### GitLab CI exemple

```yaml
test:
  script:
    - docker compose build
    - docker compose up -d
    - sleep 10
    - curl -f http://localhost:3000
    - docker compose down
```

## Sécurité

### Bonnes pratiques appliquées

1. Image Node.js slim (réduit la surface d'attaque)
2. Dépendances production uniquement (`npm ci --only=production`)
3. Volumes en lecture seule (`:ro`) en développement pour les fichiers source
4. Volume dédié pour les chansons (facile à sauvegarder/restaurer)
5. Limites de ressources pour éviter les DoS
6. Health checks pour détection rapide des problèmes
7. Rotation des logs pour éviter la saturation disque

### Améliorations possibles

- Utiliser un utilisateur non-root dans le Dockerfile
- Scanner les vulnérabilités avec `docker scan`
- Implémenter des secrets Docker pour les données sensibles
- Ajouter un reverse proxy (nginx) devant l'application
