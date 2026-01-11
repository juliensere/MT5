# MT5 - Multitrack HTML5 Audio Player

## Vue d'ensemble

MT5 est un **lecteur audio multitrack basé sur le Web** conçu pour les musiciens. Il permet de charger, lire et manipuler des enregistrements multi-pistes où chaque instrument/piste peut être contrôlé indépendamment. L'application est spécifiquement construite pour aider les musiciens à étudier des morceaux piste par piste ou à pratiquer avec des instruments sélectionnés.

## Architecture

### Architecture Client-Serveur

```
Server Node.js (Express)
    ↓
    ├─ Serveur de fichiers statiques (/client)
    ├─ API REST /track (liste des chansons disponibles)
    └─ API REST /track/:id (instruments d'une chanson spécifique)

Client (Navigateur)
    ↓
    ├─ Web Audio API (traitement audio en temps réel)
    ├─ Canvas (visualisation des formes d'onde)
    ├─ Bootstrap (interface utilisateur)
    └─ jQuery (manipulation DOM)
```

### Flux de données

1. Le serveur Express sert les fichiers statiques depuis `/client`
2. Le navigateur charge `index.html` et initialise le contexte Web Audio
3. Le client récupère la liste des pistes via XHR
4. Les buffers audio sont téléchargés et décodés de manière asynchrone
5. Le graphe Web Audio est construit dynamiquement
6. Lecture en temps réel avec visualisation Canvas

### Graphe Web Audio

```
AudioBufferSource → TrackVolumeGain → MasterVolumeGain → Analyser → Destination
                                                    ↓
                                          RecorderNode (optionnel)
```

## Technologies principales

### Backend
- **Node.js** (v8+) - Environnement d'exécution
- **Express.js** (v4.16.4+) - Framework serveur web
- **File System (fs)** - Lecture de répertoires et fichiers

### Frontend
- **Web Audio API** - Traitement et lecture audio
- **HTML5 Canvas** - Visualisation des formes d'onde et fréquences
- **Bootstrap 3.0** - Framework UI et composants
- **jQuery** - Manipulation DOM
- **Recorder.js** - Enregistrement audio et export WAV

### Formats audio supportés
MP3, OGG, WAV, M4A

## Fonctionnalités principales

### Contrôle de lecture
- Boutons Play, Pause, Stop
- Navigation/saut à n'importe quelle position
- Contrôle du volume maître avec mise à l'échelle quadratique (x²)
- Affichage du temps en temps réel

### Gestion des pistes
- Curseurs de volume par piste (plage 0-100)
- Mute/unmute des pistes individuelles
- Fonctionnalité Solo (une ou plusieurs pistes)
- Génération dynamique de l'UI selon la chanson chargée

### Fonctionnalités avancées
- **Boucle** - Définir des points de boucle (marqueurs A/B) avec sélection visuelle
- **Visualisation de fréquences** - Spectre de fréquences FFT en temps réel
- **Rendu des formes d'onde** - Représentation visuelle de l'audio de chaque piste
- **Enregistrement du mix** - Enregistrer le mix de sortie maître et exporter en WAV
- **Barres de progression** - Indicateurs de chargement par piste

### Interface utilisateur
- Menu déroulant de sélection des morceaux avec chargement dynamique
- Interface à onglets (Console, Visualisation des ondes, Aide)
- Visualisation basée sur Canvas avec marqueur de timeline
- Boutons et contrôles Bootstrap modal

## Structure des fichiers

```
MT5/
├── server.js                          # Serveur Express principal
├── package.json                       # Dépendances et métadonnées
├── package-lock.json                  # Verrouillage des dépendances
├── Dockerfile                         # Conteneurisation Docker
├── compose.yml                        # Configuration Docker Compose
├── README.md                          # Documentation
├── LICENSE                            # Licence du projet

client/
├── index.html                         # Point d'entrée HTML principal
├── css/
│   ├── bootstrap.min.css              # Framework Bootstrap
│   ├── bootstrap-responsive.min.css   # Grille responsive
│   └── style.css                      # Styles personnalisés (217 lignes)
├── js/
│   ├── sound.js                       # Logique de contrôle principale (796 lignes)
│   ├── song.js                        # Modèle Song (276 lignes)
│   ├── track.js                       # Modèle Track (23 lignes)
│   ├── view.js                        # Couche d'abstraction UI (84 lignes)
│   ├── buffer-loader.js               # Décodage audio asynchrone (79 lignes)
│   ├── waveformDrawer.js              # Visualisation des formes d'onde (121 lignes)
│   ├── utils.js                       # Utilitaire de formatage du temps (13 lignes)
│   ├── knob.js                        # Widget de bouton de volume
│   ├── canvasArrows.js                # Utilitaires de dessin Canvas
│   ├── range-touch.js                 # Support des curseurs tactiles
│   ├── jquery.min.js                  # Bibliothèque jQuery
│   ├── jquery.knob.js                 # Plugin jQuery knob
│   ├── bootstrap.min.js               # Bootstrap JS
│   └── recorderjs/
│       ├── recorder.js                # Implémentation de l'enregistrement audio
│       └── recorderWorker.js          # Web Worker pour l'enregistrement
├── img/                               # Icônes et images UI
│   ├── play.png, pause.png, stop.png
│   ├── earphones.png, noearphones.png
│   ├── solo.png, sound.png
│   └── Imagerie des boutons de contrôle
└── multitrack/                        # Stockage des fichiers audio
    ├── AdmiralCrumple_KeepsFlowing/
    ├── Big Stone Culture - Fragile Thoughts/
    ├── How To Kill A Conversation - HeartOnMyThumb/
    ├── John McKay - Daisy Daisy/
    ├── Londres Appelle/
    ├── Street Noise - Revelations/
    ├── Tarte a la cerise/
    └── Wesley Morgan - Flesh And Bone/
        (Chacun contient plusieurs fichiers de piste .mp3/.ogg/.wav)
```

## Architecture du code

### Design Orienté Objet

#### Classe Song (`song.js`)
- Gère l'état complet d'une chanson multitrack
- Construction du graphe Web Audio
- Contrôle de la lecture
- Gestion des états mute/solo/loop

#### Classe Track (`track.js`)
- Métadonnées de piste individuelle
- Nom, URL, volume, états mute/solo

#### Classe View (`view.js`)
- Singleton wrapper pour toutes les références d'éléments DOM
- Contextes Canvas
- Abstraction de l'interface utilisateur

#### Classe BufferLoader (`buffer-loader.js`)
- Chargement audio asynchrone basé sur prototype
- Décodage avec callbacks de progression

#### Classe WaveformDrawer (`waveformDrawer.js`)
- Visualisation des formes d'onde basée sur Canvas
- Calcul des pics et rendu

### Décisions de conception notables

1. **Pas de dépendances de framework** - JavaScript vanilla pour la logique principale ; Bootstrap/jQuery uniquement pour l'UI

2. **Reconstruction dynamique du graphe** - Le graphe Web Audio est reconstruit à chaque pause/reprise en raison de la nature "fire and forget" des nœuds AudioBufferSource

3. **Boucle requestAnimationFrame** - `animateTime()` s'exécute à ~60fps pour une progression temporelle fluide et des mises à jour de visualisation

4. **Mise à l'échelle du volume quadratique** - Le curseur de volume utilise une courbe x² pour un ajustement de volume perçu plus naturel

5. **Visualisation basée sur Canvas** - Deux canvas superposés :
   - Canvas arrière : Formes d'onde statiques et étiquettes de piste
   - Canvas avant : Timeline animée, spectre de fréquences, marqueurs de boucle

6. **Chargement audio asynchrone** - XMLHttpRequest avec callbacks de progression pour le téléchargement des pistes

7. **Analyse de fréquence** - Utilise AnalyserNode avec getByteFrequencyData() pour la visualisation du spectre en temps réel

### Gestion d'état

**Variables globales :**
- `currentSong` - Instance de chanson actuelle
- `context` - Contexte Web Audio
- `selectionForLoop` - État de sélection de boucle
- `currentTime` - Position de lecture actuelle
- `lastTime` - Dernière position connue

**État de l'objet Song :**
- Buffers décodés
- Tableau de pistes
- Nœuds Web Audio
- États mute/solo/loop

### Gestion des événements

- Listeners de clic pour les boutons play/pause/stop/mute/solo
- Glisser-déposer de souris pour la sélection de points de boucle
- Événements d'entrée du curseur de volume
- Événements de changement du menu déroulant des chansons

### Gestion des erreurs

- Vérification de compatibilité du contexte audio (Chrome vs Safari vs Firefox)
- Callbacks d'erreur XHR avec alertes utilisateur
- Journalisation des erreurs de décodage audio
- Gestion HTTP 404 pour les pistes manquantes

### Considérations de performance

- Échantillonnage par pas dans le calcul des formes d'onde
- Pré-calcul du tableau de pics pour un rendu efficace
- Sauvegardes/restaurations du contexte Canvas pour la gestion d'état
- Barres de progression pour le feedback utilisateur pendant le chargement

## Installation et exécution

### Prérequis
- Node.js 8+ (recommandé : Node.js 19+)
- npm

### Installation locale

```bash
# Installation des dépendances
npm install

# Démarrage du serveur (port par défaut : 3000)
node server.js

# Accès à l'application
http://localhost:3000
```

### Déploiement Docker

```bash
# Build et run avec Docker Compose
docker compose up --build

# Accès à l'application
http://localhost:3000
```

### Configuration Docker

**Dockerfile :**
- Image de base : `node:19.0-slim`
- Port exposé : 3000
- Mode production : `npm ci --only=production`
- Entrypoint : `docker-entrypoint.sh` (initialise le volume multitrack)

**Volume Docker nommé :**
- `mt5-multitrack-data` : Stockage persistant des chansons multitrack
- Initialisation automatique avec chansons de démonstration au premier démarrage
- Indépendant du code source pour faciliter backups et migrations
- Meilleure performance que les bind mounts sur Windows/Mac

### Variables d'environnement

- `PORT` - Port du serveur (défaut : 3000)
- `IP` - Adresse de liaison (défaut : 0.0.0.0)

### Configuration des pistes

**Chemin des pistes (ligne 15 dans server.js) :**
```javascript
TRACKS_PATH = './client/multitrack'
```

**Avec Docker :**
Les chansons sont stockées dans le volume Docker `mt5-multitrack-data`. Pour ajouter des chansons :
```bash
# Copier un répertoire de chanson complet
docker cp ~/music/MaChanson mt5-multitrack:/usr/src/app/client/multitrack/

# Rafraîchir le navigateur - détection automatique
```

**Sans Docker :**
1. Créer un nouveau répertoire dans `client/multitrack/`
2. Ajouter les fichiers audio des pistes (MP3, OGG, WAV, M4A)
3. Aucune configuration supplémentaire nécessaire - détection automatique

Voir `MULTITRACK.md` pour un guide complet d'ajout de chansons.

## Dépendances

### Production
```json
{
  "express": "^4.16.4"
}
```

### Développement
Aucune dépendance de développement

## Historique de développement récent

### Améliorations récentes
- Support du format audio M4A ajouté
- Améliorations Async/ES6
- Intégration Docker Compose pour un déploiement rapide
- Mises à jour de la version Express (modernisation)
- Suppression de la fonctionnalité de chat socket.io héritée
- package-lock.json pour la stabilité des dépendances

### Contributeurs
- **Michel Buffa** - Développeur original, concepteur principal
- **Amine Hallili** - Mise en page HTML/CSS
- **Contributeurs de la communauté** - Docker, support de formats

## API REST

### GET /track
Récupère la liste de toutes les chansons disponibles.

**Réponse :**
```json
[
  "AdmiralCrumple_KeepsFlowing",
  "Big Stone Culture - Fragile Thoughts",
  "Londres Appelle",
  ...
]
```

### GET /track/:id
Récupère la liste des pistes/instruments pour une chanson spécifique.

**Paramètres :**
- `id` - Nom du répertoire de la chanson

**Réponse :**
```json
[
  "01_Kick.mp3",
  "02_Snare.mp3",
  "03_Bass.mp3",
  ...
]
```

## Points techniques clés

### Web Audio API

Le projet utilise intensivement l'API Web Audio pour :
- Création de sources audio à partir de buffers décodés
- Contrôle du gain (volume) par piste et maître
- Analyse de fréquences avec AnalyserNode
- Enregistrement du mix maître avec RecorderNode

### Canvas et visualisation

Deux canvas sont utilisés :
1. **Back canvas** - Dessin statique des formes d'onde et étiquettes
2. **Front canvas** - Animation en temps réel (timeline, spectre, marqueurs)

La visualisation utilise `requestAnimationFrame` pour des mises à jour fluides à ~60fps.

### Chargement asynchrone

Les pistes audio sont chargées de manière asynchrone avec :
- XMLHttpRequest pour le téléchargement
- `context.decodeAudioData()` pour le décodage
- Callbacks de progression pour le feedback utilisateur

## Cas d'usage

1. **Musiciens** - Étudier des arrangements, isoler des instruments, pratiquer avec des pistes backing
2. **Enseignants de musique** - Démontrer des arrangements, analyser des productions
3. **Producteurs audio** - Réviser des mixages, comparer des versions de pistes
4. **Étudiants** - Apprendre l'arrangement et la production musicale

## Limitations connues

1. Les navigateurs nécessitent une interaction utilisateur avant de créer un contexte audio
2. Les nœuds AudioBufferSource sont "fire and forget" - nécessitent une reconstruction du graphe
3. Le chargement de nombreuses pistes peut consommer beaucoup de mémoire
4. Les performances de visualisation dépendent du matériel

## Améliorations futures possibles

- Support du drag & drop de fichiers audio
- Sauvegarde des configurations de mix (volumes, mutes, solos)
- Export de pistes individuelles
- Effets audio (EQ, réverbération, compression)
- Métronome et synchronisation BPM
- Annotations et marqueurs de section
- Support multi-utilisateur pour collaboration en temps réel

## Licence

Voir le fichier LICENSE pour plus de détails.

## Conclusion

MT5 est un **lecteur audio multitrack bien conçu et prêt pour la production** qui exploite efficacement l'API Web Audio. Il démontre des modèles architecturaux solides incluant une séparation claire des responsabilités (modèles Song/Track/View), une visualisation Canvas efficace et une empreinte de dépendances minimale. L'application est conçue pour les musiciens mais applicable à tout scénario audio multitrack. Le support Docker et la configuration Docker Compose le rendent prêt pour le déploiement, tandis que la découverte simple des pistes basée sur les fichiers permet une gestion facile du contenu sans base de données.
