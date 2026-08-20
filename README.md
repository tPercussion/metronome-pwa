# Metronome Pro — PWA

Version web (Web Audio API) du métronome, indépendante du projet Flutter
natif construit plus tôt dans cette session. Zéro build, zéro Xcode —
s'ouvre directement dans le navigateur du smartphone.

## Verdict technique rapide sur le code que tu as fourni

- **Le scheduler audio est correct.** Il utilise le pattern standard
  "lookahead scheduling" (boucle `setInterval` qui planifie à l'avance, mais
  déclenche réellement le son via `source.start(time)` sur `AudioContext` —
  c'est `AudioContext` qui garantit la précision d'échantillon, pas le
  timer JS). C'est la bonne façon de faire un métronome en Web Audio.
- **Ce n'est PAS la même chose que le moteur natif Flutter** (accumulateur de
  phase sample-accurate en Swift/Kotlin, résolution 0.01 BPM forcée, boutons
  micro-step ±0.01/±0.10/±1.00). Ici, le BPM peut être une fraction libre
  ("120 2/3") mais n'est jamais forcé à 2 décimales à l'affichage tant que la
  saisie est valide — écart mineur par rapport au cahier des charges initial,
  pas un bug.
- **Manifeste PWA** : je l'ai sorti du `<link rel="manifest" href="data:...">`
  inline vers un vrai fichier `manifest.json` à côté — Safari iOS gère cette
  version de façon plus fiable pour "Ajouter à l'écran d'accueil".
- **Icône hotlinkée sur img.icons8.com** : ça marche, mais c'est une
  dépendance externe pour l'icône d'installation — si ce lien casse un jour,
  l'icône PWA casse avec. Pas corrigé (pas demandé), juste signalé.
- **Pas de service worker** : donc pas d'usage 100% hors-ligne au sens strict
  PWA. Pour un simple test au navigateur sur ton téléphone, aucune
  importance — à ajouter seulement si tu veux l'usage hors-connexion plus
  tard.

## Déploiement sur GitHub

Je n'ai pas pu le faire moi-même : mon accès réseau côté cloud vers l'API
GitHub est restreint aux dépôts déjà configurés (pas de création libre), et
le contrôle à distance de ton Terminal est en mode clic-seul (je ne peux pas
taper). Le fichier `deploy.sh` fait tout le travail — lance-le toi-même :

```bash
bash deploy.sh                  # crée "metronome-pwa" sur ton compte GitHub
# ou : bash deploy.sh mon-nom-perso
```

S'il te demande de t'authentifier, il affichera un code à taper sur
`github.com/login/device` — c'est le "code" que tu as dit vouloir remplir
toi-même.

À la fin, tu auras :
- Le repo : `https://github.com/<toi>/metronome-pwa`
- L'app live : `https://<toi>.github.io/metronome-pwa/`

Ouvre cette dernière URL sur ton smartphone pour tester.
