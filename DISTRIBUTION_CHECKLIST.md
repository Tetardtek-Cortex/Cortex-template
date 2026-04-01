# DISTRIBUTION_CHECKLIST.md — brain-template maintenance

> Référence pour garantir que brain-template reste distribution-ready.
> À exécuter avant chaque release / tag.

---

## Workflow de distribution

```
Gitea (source de verite)          GitHub (miroir public)
git.tetardtek.com:Tetardtek/      github.com:Tetardtek/
Cortex-template.git               Cortex-template.git
        |                                  |
        |  git push gitea                  |  git push origin
        |  (chaque commit)                 |  (quand pret pour le public)
        v                                  v
  branche main trackee              miroir distribution
```

**Workflow quotidien :**
```bash
# 1. Commit normalement
git add <fichiers> && git commit -m "..."

# 2. Push Gitea (toujours)
git push gitea

# 3. Push GitHub (quand c'est pret pour le public)
git push origin
```

**Remotes :**
```bash
gitea   git@git.tetardtek.com:Tetardtek/Cortex-template.git   # source
origin  git@github.com:Tetardtek/Cortex-template.git           # miroir public
```

**Satellites (Tetardtek-Cortex) :**
L'identite `Tetardtek-Cortex` sur GitHub est l'exemple de fork.
Ses repos (Todo, Toolkit, Profil, Progression, Reviews) sont publics et autonomes.
On n'y push pas — c'est l'utilisateur exemple qui gere son propre brain.

---

## Vérification zéro fuite identité

```bash
# Depuis la racine du repo brain-template
grep -ri "tetardtek" . --include="*.md" --include="*.yml" \
  | grep -v ".git" \
  | grep -v "bsi-schema.md"   # bsi-schema: exemple username accepté
```

Attendu : **0 résultats**.

---

## Placeholders en production dans brain-template

| Placeholder | Signification | Fichiers concernés |
|-------------|---------------|-------------------|
| `<OWNER_DOMAIN>` | Domaine de l'owner (ex: `monbrain.com`) | `profil/decisions/006`, `007`, `022`, `README.md` |
| `<BRAIN_ROOT>` | Chemin absolu local du brain (ex: `/home/user/Dev/Brain`) | `ARCHITECTURE.md`, `profil/architecture.md` |
| `<owner>` | Identifiant/username de l'owner | `profil/decisions/008` |
| `l'owner` | Référence générique à l'utilisateur du brain | agents/ (tous) |

---

## Répertoires obligatoires (structure v1.0)

```
brain-template/
  agents/           ← tous les agents dépersonnalisés
  contexts/         ← sessions generiques (6 fichiers — Sessions V2)
  agent-memory/     ← README + _template/
  brain-engine/     ← moteur local (server, embed, search, RAG, MCP)
  brain-ui/         ← dashboard React (docs, workflows, cosmos)
  docs/             ← guides humains (14 pages)
  profil/
    decisions/      ← ADRs (placeholders domaine)
    collaboration.md.example
    CLAUDE.md.example
  handoffs/
  workflows/
  README.md
  KERNEL.md
  ARCHITECTURE.md
  DISTRIBUTION_CHECKLIST.md  ← ce fichier
```

---

## Contextes inclus — Sessions V2 (ADR-047)

4 types de session + 2 variantes kernel :

| Fichier | Usage |
|---------|-------|
| `session-work.yml` | Production — code, deploy, debug, infra |
| `session-explore.yml` | Reflexion — navigate, brainstorm, coach, audit |
| `session-brain.yml` | Travail sur le brain lui-meme |
| `session-pilote.yml` | Co-construction — mode pilote |
| `session-edit-brain.yml` | Ecriture kernel — tier: full (owner) |
| `session-kernel.yml` | Lecture kernel — tier: full (owner) |

> Sessions V2 : les anciens types (navigate, brainstorm, debug, coach, audit) sont absorbes
> par explore et work via le scope (`brain boot explore/brainstorm`).

---

## Docs (guides humains)

**v1.1 : docs/ inclus — 16 pages.**
Guides humains lisibles sans contexte brain : getting-started, architecture, sessions, workflows, agents par famille, vues par tier.

```
docs/
  README.md              ← index
  getting-started.md     ← premiere page — "j'ai forke, quoi maintenant ?"
  architecture.md        ← comment les pieces s'assemblent
  sessions.md            ← types, permissions, metabolisme, close
  workflows.md           ← recettes d'agents par situation
  agents.md              ← vue d'ensemble + comparatif tiers
  agents-code.md         ← review, securite, tests, refacto, perf
  agents-infra.md        ← VPS, CI/CD, monitoring, mail
  agents-brain.md        ← coach, scribes, orchestration, kernel
  vue-tiers.md           ← comparatif tous tiers
  vue-free.md            ← detail tier free
  vue-featured.md        ← detail tier featured
  vue-pro.md             ← detail tier pro
  vue-full.md            ← detail tier full
```

**Audit avant release :** `grep -ri "tetardtek" docs/` → 0 resultats.

## Wiki

**v1.0 : wiki absent.**
Le nouvel utilisateur construit son wiki au fil des sessions.
Le wiki est technique (audience agents) — le docs/ couvre l'onboarding humain.

---

## Checklist avant release

```bash
# 1. Traces perso (hors keys.tetardtek.com et git.tetardtek.com = by-design)
grep -ri "tetardtek" . --include="*.md" --include="*.yml" --include="*.sh" --include="*.py" --include="*.ts" --include="*.svelte" \
  | grep -v ".git/" | grep -v "keys.tetardtek.com" | grep -v "git.tetardtek.com" | grep -v "DISTRIBUTION_CHECKLIST"
# Attendu : 0 resultats

# 2. YAML valide
python3 -c "import yaml; yaml.safe_load(open('brain-compose.yml')); print('ok')"

# 3. Feature gates synchronises
bash scripts/feature-gate-status.sh

# 4. Dashboard a jour
bash scripts/gen-demo-data.sh

# 5. Kernel isolation
bash scripts/kernel-isolation-check.sh
```

- [ ] Traces perso → 0 resultats
- [ ] brain-compose.yml YAML valide
- [ ] feature-gate-status.sh affiche les 4 tiers (free/featured/pro/full) avec 14 features
- [ ] gen-demo-data.sh → demo.ts regenere, chiffres coherents
- [ ] kernel-isolation-check.sh → 0 erreurs
- [ ] README.md quickstart testable sur machine vierge
- [ ] PATHS.md generique — aucun chemin machine reel
- [ ] MYSECRETS.example — que des placeholders
- [ ] Push Gitea puis push GitHub
- [ ] Tag git `vX.Y.Z` cree apres verification

---

*Derniere mise a jour : 2026-03-31 — v1.1 audit pre-publish, tier gate, 46 agents, 16 docs, kernel warn hook*
