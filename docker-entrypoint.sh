#!/bin/sh
set -e

# Répertoire des multitrack
MULTITRACK_DIR="/usr/src/app/client/multitrack"
DEMO_SONGS_DIR="/usr/src/app/.multitrack-demo"

# Fonction pour vérifier si le répertoire est vide
is_empty_dir() {
    [ -z "$(ls -A "$1" 2>/dev/null)" ]
}

echo "MT5 Docker Entrypoint - Initialisation..."

# Vérifier si le répertoire multitrack existe
if [ ! -d "$MULTITRACK_DIR" ]; then
    echo "Création du répertoire multitrack..."
    mkdir -p "$MULTITRACK_DIR"
fi

# Si le répertoire multitrack est vide ET que les chansons de démo existent
if is_empty_dir "$MULTITRACK_DIR" && [ -d "$DEMO_SONGS_DIR" ]; then
    echo "Le volume multitrack est vide."
    echo "Initialisation avec les chansons de démonstration..."

    # Copier les chansons de démo
    cp -r "$DEMO_SONGS_DIR"/* "$MULTITRACK_DIR/"

    echo "✓ Chansons de démonstration copiées avec succès."
    echo "  Nombre de chansons: $(ls -1 "$MULTITRACK_DIR" | wc -l)"
else
    if ! is_empty_dir "$MULTITRACK_DIR"; then
        echo "✓ Volume multitrack déjà initialisé."
        echo "  Nombre de chansons: $(ls -1 "$MULTITRACK_DIR" | wc -l)"
    else
        echo "⚠ Volume multitrack vide et aucune chanson de démo disponible."
        echo "  Vous pouvez ajouter vos propres chansons dans le volume."
    fi
fi

echo "Démarrage du serveur MT5..."
echo ""

# Exécuter la commande passée au container (node server.js par défaut)
exec "$@"
