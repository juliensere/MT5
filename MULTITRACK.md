# Guide d'ajout de chansons multitrack

## Structure des fichiers

Chaque chanson doit être dans son propre répertoire sous `client/multitrack/`.

```
client/multitrack/
├── MaChanson/
│   ├── 01_Kick.mp3
│   ├── 02_Snare.mp3
│   ├── 03_Bass.mp3
│   ├── 04_Guitar.mp3
│   └── 05_Vocals.mp3
└── AutreChanson/
    ├── Drums.mp3
    ├── Bass.mp3
    └── Guitar.mp3
```

## Formats supportés

- MP3 (recommandé)
- OGG
- WAV
- M4A

## Nomenclature des fichiers

### Convention recommandée

Utilisez des préfixes numériques pour contrôler l'ordre d'affichage :

```
01_Kick.mp3
02_Snare.mp3
03_Bass.mp3
04_Guitar.mp3
05_Vocals.mp3
```

Les fichiers apparaîtront dans l'ordre alphabétique dans l'interface.

### Noms descriptifs

Utilisez des noms clairs et descriptifs :
- ✅ `01_Kick.mp3`, `02_Snare.mp3`, `03_Bass.mp3`
- ✅ `Drums.mp3`, `Bass.mp3`, `Guitar.mp3`
- ❌ `track1.mp3`, `audio.mp3`, `file.mp3`

## Ajouter une nouvelle chanson

### Méthode 1 : Ajout direct dans le répertoire

```bash
# 1. Créer le répertoire de la chanson
mkdir -p client/multitrack/MaNouvelleChanson

# 2. Copier les fichiers audio
cp ~/music/stems/*.mp3 client/multitrack/MaNouvelleChanson/

# 3. Vérifier que les fichiers sont bien présents
ls -lh client/multitrack/MaNouvelleChanson/

# 4. Rafraîchir le navigateur ou redémarrer l'application
```

### Méthode 2 : Avec Docker en cours d'exécution

```bash
# 1. Créer le répertoire localement
mkdir -p client/multitrack/MaNouvelleChanson

# 2. Copier les fichiers
cp ~/music/stems/*.mp3 client/multitrack/MaNouvelleChanson/

# 3. Le volume est monté, donc les fichiers sont immédiatement disponibles
# Juste rafraîchir le navigateur ou redémarrer le container
docker compose restart
```

### Méthode 3 : Copie directe dans le container

```bash
# Copier un répertoire complet dans le container
docker cp ~/music/MaNouvelleChanson mt5-multitrack:/usr/src/app/client/multitrack/

# Redémarrer le container
docker compose restart
```

## Préparer des fichiers multitrack

### Depuis une session d'enregistrement

Si vous avez des stems d'une session DAW (Digital Audio Workstation) :

1. **Exporter chaque piste séparément** depuis votre DAW
   - Assurez-vous que toutes les pistes ont la même longueur
   - Utilisez le même format audio pour toutes (MP3 recommandé)
   - Exportez avec la même fréquence d'échantillonnage

2. **Normaliser les noms de fichiers**
   - Renommez avec des préfixes numériques
   - Utilisez des noms descriptifs

3. **Créer le répertoire et copier les fichiers**

### Depuis des sources externes

Pour utiliser des chansons multitrack existantes :

**Sources recommandées :**
- [Cambridge Music Technology Multitrack Library](https://www.cambridge-mt.com/ms/mtk/)
- Sessions d'enregistrement open source
- Vos propres sessions d'enregistrement

## Bonnes pratiques

### Qualité audio

- **MP3** : 192 kbps minimum (320 kbps recommandé)
- **OGG** : Q5 minimum (Q8 recommandé)
- **WAV** : 16-bit/44.1kHz minimum

### Organisation

```
NomArtiste_NomChanson/
├── 01_Kick.mp3
├── 02_Snare.mp3
├── 03_Overheads.mp3
├── 04_Bass.mp3
├── 05_Guitar_Left.mp3
├── 06_Guitar_Right.mp3
└── 07_Vocals.mp3
```

### Synchronisation

**IMPORTANT** : Toutes les pistes d'une chanson DOIVENT :
- Commencer exactement au même moment
- Avoir exactement la même durée
- Utiliser la même fréquence d'échantillonnage

Sinon, les pistes ne seront pas synchronisées lors de la lecture.

## Supprimer une chanson

```bash
# Supprimer le répertoire complet
rm -rf client/multitrack/NomDeLaChanson/

# Rafraîchir le navigateur
# La chanson disparaît automatiquement de la liste
```

## Vérification

### Tester localement (sans Docker)

```bash
# Démarrer le serveur
node server.js

# Ouvrir dans le navigateur
http://localhost:3000

# La nouvelle chanson devrait apparaître dans le menu déroulant
```

### Tester avec Docker

```bash
# Démarrer le container
docker compose up -d

# Ouvrir dans le navigateur
http://localhost:3000

# Vérifier les logs si la chanson n'apparaît pas
docker compose logs -f
```

## Dépannage

### La chanson n'apparaît pas

1. **Vérifier le nom du répertoire**
   ```bash
   ls -la client/multitrack/
   ```

2. **Vérifier les permissions**
   ```bash
   chmod -R 755 client/multitrack/MaNouvelleChanson/
   ```

3. **Vérifier les formats de fichiers**
   ```bash
   file client/multitrack/MaNouvelleChanson/*.mp3
   ```

4. **Redémarrer l'application**
   ```bash
   # Sans Docker
   # Ctrl+C puis node server.js

   # Avec Docker
   docker compose restart
   ```

### Les pistes ne sont pas synchronisées

Toutes les pistes doivent avoir exactement la même durée. Vérifier avec :

```bash
# Installer ffprobe (partie de ffmpeg)
# Puis vérifier la durée
ffprobe -i client/multitrack/MaNouvelleChanson/01_Kick.mp3 2>&1 | grep Duration
ffprobe -i client/multitrack/MaNouvelleChanson/02_Snare.mp3 2>&1 | grep Duration
```

Si les durées diffèrent, ré-exporter depuis votre DAW en vous assurant que toutes les pistes commencent et finissent au même moment.

### Erreurs de lecture

1. **Vérifier le format audio**
   - Tous les navigateurs ne supportent pas tous les formats
   - MP3 est le plus compatible

2. **Vérifier la console du navigateur**
   - Ouvrir les outils de développement (F12)
   - Onglet Console
   - Chercher les erreurs de décodage audio

3. **Tester avec un autre navigateur**
   - Chrome/Edge (recommandé)
   - Firefox
   - Safari

## Exemples de chansons incluses

Le projet inclut plusieurs chansons de démonstration :

- **Admiral Crumple - Keeps Flowing** : 9 pistes (batterie, samples, voix)
- **Big Stone Culture - Fragile Thoughts** : 7 pistes (batterie, basse, guitare, voix)
- **John McKay - Daisy Daisy** : 12 pistes (batterie complète, basse, guitares, voix)
- **Street Noise - Revelations** : 11 pistes (batterie, basse, congas, guitares, voix, Hammond)

Vous pouvez utiliser ces chansons comme référence pour comprendre la structure attendue.

## Ressources

### Obtenir des chansons multitrack

- [Cambridge Music Technology](https://www.cambridge-mt.com/ms/mtk/) - Large collection gratuite
- [Open Multitrack Testbed](https://www.lti.ei.tum.de/en/research/datasets/open-multitrack-testbed/)
- Vos propres enregistrements

### Outils de conversion

- [ffmpeg](https://ffmpeg.org/) - Conversion de format audio
- [Audacity](https://www.audacityteam.org/) - Édition audio gratuite
- Votre DAW préféré (Reaper, Logic, Pro Tools, etc.)

### Normalisation avec ffmpeg

```bash
# Convertir WAV en MP3
ffmpeg -i input.wav -codec:a libmp3lame -qscale:a 2 output.mp3

# Normaliser le volume
ffmpeg -i input.mp3 -filter:a loudnorm output_normalized.mp3

# Convertir par lot
for file in *.wav; do
  ffmpeg -i "$file" -codec:a libmp3lame -qscale:a 2 "${file%.wav}.mp3"
done
```
