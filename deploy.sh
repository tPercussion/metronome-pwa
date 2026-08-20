#!/usr/bin/env bash
# Publie ce dossier sur GitHub + active GitHub Pages, pour que tu puisses
# ouvrir l'app directement depuis ton smartphone via une URL.
#
# Usage :
#   bash deploy.sh                     # nom de repo par défaut : metronome-pwa
#   bash deploy.sh mon-nom-de-repo     # nom de repo personnalisé
#
# Pourquoi ce script existe plutôt qu'un simple "voici les commandes" : parce
# que je (Claude) n'ai pas pu le faire à ta place. L'environnement cloud où je
# tourne a son accès réseau vers l'API GitHub restreint à des dépôts
# pré-configurés (pas de création libre de repo depuis là-bas), et le contrôle
# à distance de Terminal sur ton Mac est en mode "clic seul" — je peux pas
# taper de commande. Donc : toi, ici, une fois.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME="${1:-metronome-pwa}"

cd "$SCRIPT_DIR"

if ! command -v gh >/dev/null 2>&1; then
  echo "ERREUR : GitHub CLI ('gh') introuvable." >&2
  echo "Installe-le avec :  brew install gh" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "==> Pas encore connecté à GitHub — lancement de l'authentification."
  echo "    Un code va s'afficher : va sur github.com/login/device et entre-le."
  gh auth login --hostname github.com --git-protocol https --web
fi

OWNER="$(gh api user --jq .login)"
echo "==> Connecté en tant que : $OWNER"

if [ ! -d .git ]; then
  echo "==> git init"
  git init -b main
fi

git add -A
if ! git diff --cached --quiet; then
  git commit -m "Métronome PWA — moteur Web Audio (lookahead scheduler), grille de pas, presets"
else
  echo "==> Rien de nouveau à committer."
fi

if gh repo view "$OWNER/$REPO_NAME" >/dev/null 2>&1; then
  echo "==> Le repo $OWNER/$REPO_NAME existe déjà — je pousse dessus."
  git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" 2>/dev/null || true
  git push -u origin main
else
  echo "==> Création du repo $OWNER/$REPO_NAME (public) + push"
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
fi

echo "==> Activation de GitHub Pages (branche main, racine /)"
if gh api "repos/$OWNER/$REPO_NAME/pages" -X POST --input - <<< '{"source":{"branch":"main","path":"/"}}' >/dev/null 2>&1; then
  echo "    Pages activé."
else
  echo "    Déjà activé, ou à activer à la main : Settings > Pages sur le repo GitHub."
fi

echo ""
echo "==================================================================="
echo "Repo    : https://github.com/$OWNER/$REPO_NAME"
echo "App PWA : https://$OWNER.github.io/$REPO_NAME/"
echo "(la publication Pages peut prendre 1-2 minutes la première fois)"
echo ""
echo "Sur ton smartphone : ouvre l'URL ci-dessus dans Safari/Chrome, puis"
echo "'Partager' > 'Sur l'écran d'accueil' pour l'installer comme une app."
echo "==================================================================="
