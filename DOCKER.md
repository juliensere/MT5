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

### Volume des chansons (Production et Développement)

Le répertoire `client/multitrack` est monté en volume, ce qui permet :
- **Ajouter de nouvelles chansons** sans rebuild de l'image
- **Modifier des chansons existantes** à chaud
- **Persister les chansons** même si le container est supprimé

```bash
# Ajouter une nouvelle chanson
# 1. Créer un dossier dans client/multitrack/
mkdir -p client/multitrack/MaNouvelleChanson

# 2. Copier les fichiers audio (MP3, OGG, WAV, M4A)
cp ~/music/*.mp3 client/multitrack/MaNouvelleChanson/

# 3. Redémarrer le container (ou juste rafraîchir le navigateur)
docker compose restart

# La nouvelle chanson apparaît automatiquement dans l'interface
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

**Chansons (lecture/écriture) :**
- `./client/multitrack` → `/usr/src/app/client/multitrack`

Toute modification des fichiers source sera immédiatement visible après un rafraîchissement du navigateur.

Pour activer le hot-reload en production, décommentez les lignes de volumes dans `compose.yml`.

### Gestion et backup des volumes

**Sauvegarder les chansons :**
```bash
# Créer une archive des chansons
tar -czf multitrack-backup-$(date +%Y%m%d).tar.gz client/multitrack/

# Ou utiliser docker cp
docker cp mt5-multitrack:/usr/src/app/client/multitrack ./multitrack-backup/
```

**Restaurer les chansons :**
```bash
# Depuis une archive
tar -xzf multitrack-backup-20260111.tar.gz

# Ou copier directement dans le container en cours d'exécution
docker cp ./multitrack-backup/ mt5-multitrack:/usr/src/app/client/
docker compose restart
```

**Vérifier l'espace utilisé :**
```bash
# Taille du répertoire multitrack
du -sh client/multitrack/

# Espace utilisé dans le container
docker compose exec mt5-multitrack du -sh /usr/src/app/client/multitrack
```

**Nettoyer les chansons inutilisées :**
```bash
# Supprimer une chanson spécifique
rm -rf client/multitrack/NomDeLaChanson/

# Le changement sera visible après rafraîchissement du navigateur
# Ou redémarrer le container
docker compose restart
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
