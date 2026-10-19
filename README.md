# Rapports vocaux CVC

[![Télécharger le projet](https://img.shields.io/badge/T%C3%A9l%C3%A9charger-le%20projet%20ZIP-2b2b2b?style=for-the-badge)](https://github.com/issaMrt/rapport-cvc/archive/refs/heads/main.zip)

Application web privée pour un technicien d'intégration CVC. Le technicien dicte son compte rendu d'intervention depuis son téléphone. Le PC qui héberge le site transcrit la voix, réécrit le texte dans un style professionnel et génère un fichier Word daté avec la liste détaillée des activités.

Tout tourne en local sur le PC : aucune API payante, aucune donnée envoyée à un service externe.

## Fonctionnement

1. Le technicien se connecte au site (mot de passe) depuis son téléphone.
2. Il dicte son rapport, avec possibilité de mettre en pause et de reprendre.
3. La voix est transcrite par Whisper (`faster-whisper`), en local.
4. L'IA locale Ollama (modèle `mistral`) reformule le texte : suppression des tournures orales, style professionnel, classement chronologique, sans rien inventer.
5. Un fichier Word est généré : date, horaires, chantier, technicien, résumé, activités détaillées, matériel, anomalies, reste à faire, et transcription brute en annexe.

Sans Ollama, l'application reste utilisable mais ne fait qu'un nettoyage simple de la dictée, sans reformulation.

## Installation (Windows, Python 3.10 ou plus)

Le plus simple : double-cliquer sur `installer-dependances.bat`. Il installe les paquets Python, Ollama (via `winget`) et télécharge le modèle `mistral` (environ 4 Go).

Installation manuelle :

```
python -m pip install -r requirements.txt
```

puis installer Ollama (https://ollama.com) et lancer `ollama pull mistral`.

Ensuite, lancer la configuration : mot de passe (6 caractères minimum) et nom du technicien affiché par défaut dans les rapports. Le script peut être relancé sans risque : le mot de passe n'est modifié que si on le demande.

```
python setup.py
```

## Lancement

Double-cliquer sur `demarrer-rapports.bat`, ou lancer `python app.py`. Le serveur écoute uniquement sur `127.0.0.1:8000`. Test local sans HTTPS : définir `INSECURE_LOCAL=1` avant de lancer.

Variables optionnelles : `WHISPER_MODEL` (`base`, `small` par défaut, `medium`), `OLLAMA_MODEL` (`mistral` par défaut), `OLLAMA_URL`.

## Accès depuis le téléphone, hors du réseau local

L'accès distant passe par Tailscale (gratuit), un réseau privé chiffré. Le HTTPS est nécessaire pour que le micro fonctionne.

1. Installer Tailscale sur le PC et sur le téléphone, avec le même compte.
2. Dans la console d'administration Tailscale, activer MagicDNS et HTTPS.
3. Lancer `tailscale serve --bg 8000` sur le PC (fait automatiquement par `demarrer-rapports.bat`).
4. Ouvrir sur le téléphone l'adresse `https://nom-du-pc.xxxx.ts.net`.

Sur Android, si l'accès échoue avec un message de DNS privé, régler le DNS privé du téléphone sur Désactivé.

Le PC doit rester allumé, éveillé, avec le serveur lancé.

## Sécurité

- Mot de passe haché, 6 caractères minimum, blocage de 5 minutes après 5 échecs.
- Session par cookie sécurisé (HttpOnly, SameSite Strict, HTTPS), 12 heures.
- Aucun accès aux rapports sans connexion, protection contre les requêtes intersites.
- Serveur en écoute locale uniquement, accès distant via le réseau privé Tailscale.
- Ne jamais ouvrir le port 8000 sur la box ni utiliser la fonction Funnel de Tailscale.
- Le dossier `data/` (mot de passe haché, clé secrète, rapports) est exclu de Git. Ne jamais le publier.

## Structure

```
app.py                      serveur Flask (transcription, reformulation, export Word)
setup.py                    configuration (mot de passe, nom du technicien)
templates/                  pages de connexion et de dictée
requirements.txt            paquets Python
installer-dependances.bat   installation complète sous Windows
demarrer-rapports.bat       lancement du serveur et de Tailscale
exemples/dictee-test.md     texte fictif pour tester la dictée
data/                       créé au premier lancement, jamais versionné
```

## Licence

MIT, voir le fichier `LICENSE`.
