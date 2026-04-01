---
name: cold-start
type: guide
---

# Cold Start — Premier demarrage du brain

> Guide pour demarrer un brain fraichement clone.

## Etape 1 — Cloner le template

```bash
# Depuis GitHub (template public)
git clone https://github.com/Tetardtek/Cortex-template.git ~/Dev/Brain

# Ou depuis votre Gitea prive
git clone git@your-gitea.com:YourOrg/brain.git ~/Dev/Brain
```

## Etape 2 — Configuration machine

```bash
cd ~/Dev/Brain
bash scripts/brain-setup.sh prod ~/Dev/Brain
```

Le script :
1. Detecte la source git (Gitea ou GitHub)
2. Met a jour PATHS.md avec les chemins reels
3. Cree brain-compose.local.yml (instance locale)
4. Clone les satellites (toolkit, profil, todo, etc.)

## Etape 3 — CLAUDE.md global

```bash
cp profil/CLAUDE.md.example ~/.claude/CLAUDE.md
# Remplacer <BRAIN_ROOT> par le chemin reel
sed -i "s|<BRAIN_ROOT>|$HOME/Dev/Brain|g" ~/.claude/CLAUDE.md
```

## Etape 4 — Secrets

```bash
mkdir -p "$(dirname "$(pwd)")/BrainSecrets"
cp MYSECRETS.example "$(dirname "$(pwd)")/BrainSecrets/MYSECRETS"
# Remplir les valeurs dans votre editeur
```

## Etape 5 — BSI init

```bash
bash scripts/bsi-claim.sh init
```

## Etape 6 — Lancer brain-engine

```bash
bash scripts/brain-engine.sh start
```

Le moteur demarre en background : installe les deps Python, cree brain.db, indexe le corpus si Ollama est present, et lance le serveur sur le port 7700.

> **Optionnel** — Installer [Ollama](https://ollama.ai) + `ollama pull nomic-embed-text` active la recherche semantique et le Cosmos 3D.

## Etape 7 — Premier boot

Ouvrir Claude Code dans `~/Dev/Brain` et taper :

```
brain boot
```

Le brain se presente, lit l'etat, ouvre un claim BSI, et demande quelle session lancer.

---

## Premiers projets — onboarding

Le template inclut des exemples de projets generiques :
- `my-saas-app` — exemple SaaS multi-tenant
- `my-game` — exemple projet jeu
- `my-website` — exemple vitrine/portfolio

Ces exemples guident le brain pour detecter les scopes non couverts.
Remplacez-les par vos vrais projets au fur et a mesure.

---

## Multi-instance

Pour configurer un deuxieme poste (laptop) :
1. Cloner le brain sur le laptop
2. Adapter PATHS.md et brain-compose.local.yml
3. Configurer SSH bidirectionnel (voir `wiki/multi-instance.md`)

## Historique machines

| Machine | OS | `brain/` | brain_name | Actif |
|---------|----|----------|------------|-------|
| my-machine | Linux | `~/Dev/Brain/` | `mybrain` | ✅ |
