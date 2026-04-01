# Brain

> Un systeme de contexte persistant pour Claude. Fork, boot, code.

Le brain est un **cerveau externalise** : 56 agents specialises, un protocole de sessions type, et une memoire qui persiste entre les conversations. Chaque session repart d'un etat connu. Chaque agent sait ce qu'il fait et ce qu'il ne fait pas.

```bash
# Prerequis (Ubuntu/Debian)
sudo apt install -y git python3 python3-pip python3-venv
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs
npm install -g @anthropic-ai/claude-code

# Clone + setup
git clone https://github.com/Tetardtek/Cortex-template.git ~/Dev/Cortex-template
cd ~/Dev/Cortex-template && bash scripts/brain-setup.sh mon-brain ~/Dev/Brain

# Demarrage
cd ~/Dev/Brain && bash scripts/brain-engine.sh start
```

Ouvre Claude Code dans `~/Dev/Brain` et tape `brain boot`. C'est tout.

> Guide complet : [docs/getting-started.md](docs/getting-started.md)

---

## Ce que tu as

### Sans cle API — tier free

- **19 agents** : coach, debug, scribe, brainstorm, mentor, recruiter, game-designer, onboarding-guide...
- **6 types de sessions** : navigate, work, debug, brainstorm, brain, handoff
- **Coach** en observation — intervient sur risque critique
- **Protection secrets** permanente — le brain ne fuit jamais
- **Protocole BSI** — sessions tracees, multi-instances sans conflit
- **Dashboard web** Svelte avec Cosmos 3D et documentation interactive
- **Brain-engine** — API locale, search semantique, embeddings

### Avec cle API — tiers pro et full

Le brain a 3 niveaux au-dessus du free. Chaque niveau debloque des agents et des capacites :

**featured** — Le brain te connait. Coach complet, documentation, progression tracee, content writing. 26 agents.

**pro** — L'atelier complet. Code review, audit securite, tests automatises, deploy VPS + CI/CD + SSL. 48 agents specialises.

**full** — Ton brain, tes regles. Modification du kernel, copilotage long, supervision avancee, distillation locale. 56 agents.

> Detail complet : ouvre le dashboard et va dans l'onglet Docs

---

## Installation

### Prerequis

```bash
# Ubuntu / Debian
sudo apt install -y git python3 python3-pip python3-venv
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs
npm install -g @anthropic-ai/claude-code
```

- **Ollama** (recommande — active la recherche semantique et le RAG au boot)

### 1. Cloner le template

```bash
git clone https://github.com/Tetardtek/Cortex-template.git ~/Dev/Cortex-template
cd ~/Dev/Cortex-template
```

### 2. Setup — cree ton brain

```bash
bash scripts/brain-setup.sh mon-brain ~/Dev/Brain
```

Le script copie le template, clone les satellites, configure CLAUDE.md et PATHS.md.
Ton brain personnel est dans `~/Dev/Brain/` — le template reste intact.

### 3. Lancer brain-engine

```bash
cd ~/Dev/Brain
bash scripts/brain-engine.sh start
```

### 4. Premier boot

Ouvre Claude Code dans le dossier brain :

```
brain boot
```

Le brain charge le contexte, fait le briefing, et te demande ce que tu veux faire.

---

## Structure

```
brain/
  agents/          56 agents specialises (boot-summary + detail)
  contexts/        6 sessions predefinies (work, explore, brain, pilote, kernel, edit-brain)
  docs/            16 guides humains (getting-started, architecture, workflows...)
  brain-engine/    moteur local (API, search, RAG, MCP, embeddings)
  brain-ui/        dashboard Svelte (docs, dashboard, cosmos 3D)
  scripts/         25 scripts (BSI, feature-gate, setup, engine...)
  wiki/            concepts, vocabulaire, patterns
  profil/          identite, collaboration
  brain-compose.yml   config, tiers, agents autorises
  KERNEL.md        loi des zones — ce qui est protege
```

---

## Comment ca marche

**Les agents se chargent tout seuls.** Tu parles de "bug" → `debug` arrive. Tu dis "deploy" → `vps` + `ci-cd` se chargent.

**Chaque session est isolee.** Un claim BSI trace ce que tu fais. Plusieurs fenetres Claude Code peuvent travailler en parallele sans conflit.

**Le brain se documente.** Les scribes capturent les metriques, mettent a jour les todos, et maintiennent la documentation a chaque session.

**Le kernel est protege.** Les fichiers critiques (KERNEL.md, agents/, profil/) ne se modifient qu'avec confirmation humaine.

**Le tier gate controle l'acces.** Sans cle : 19 agents free. Avec cle : jusqu'a 48 agents (pro) ou 56 (full). Grace period 72h si le serveur est injoignable.

---

## Documentation

Ouvre le dashboard et va dans l'onglet Documentation :

- **Getting Started** — les 5 premieres minutes
- **Architecture** — comment les pieces s'assemblent
- **Sessions** — types, permissions, metabolisme
- **Workflows** — recettes d'agents par situation
- **Agents** — catalogue par famille + comparatif tiers
- **Vues par tier** — ce qui est disponible a chaque niveau

---

## Roadmap

- [x] 56 agents avec boot-summary/detail (chargement optimise)
- [x] 4 tiers (free → featured → pro → full) avec feature gate
- [x] Protocole BSI multi-instances
- [x] brain-engine standalone (API + search + RAG)
- [x] Dashboard Svelte avec Cosmos 3D
- [x] Sessions V2 — 6 types free, jusqu'a 17 en full
- [ ] Synapse — interface desktop native (Tauri + Svelte)
- [ ] brain-engine hosted (distillation managee)
- [ ] BaaS multi-tenant

---

## Communaute

[Discord — Le Brain](https://discord.gg/nqAVHMphXc) — support, showcase, discussions.

---

## Licence

[BSL 1.1](LICENSE.md) — Business Source License 1.1

Usage libre pour un usage personnel et interne.
Usage commercial de hosting/revente soumis a licence.
Conversion automatique en Apache 2.0 le 2028-04-01.
