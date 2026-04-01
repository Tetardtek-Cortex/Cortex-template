---
name: vocabulary
type: reference
---

# Vocabulaire du brain

> Definitions partagees entre l'humain et les agents.
> Si un terme n'est pas ici → demander avant de supposer.

---

## ADR
Architecture Decision Record. Document court qui capture une decision technique et son contexte. Stocke dans `decisions/`.

## Agent
Fichier markdown dans `agents/` qui definit un role specialise : regles, triggers, format d'intervention, composition avec d'autres agents.

## BACT
Brain-Assisted Context Transfer. Patron d'enrichissement contextuel : le brain injecte du contexte pertinent avant de deleguer une tache a un agent.

## BaaS
Brain as a Service. Modele ou le brain devient un service multi-tenant : `brain new` clone un brain pour un client, `brain sync` partage un workspace sprint. Prerequis : cockpit solo + auth multi-tenant.

## Boot
Sequence de demarrage d'une session. Lit PATHS.md, brain-compose, KERNEL.md, puis le manifest de session. Produit un briefing et ouvre un claim BSI.

## BSI
Brain State Index. Systeme de claims qui trace l'etat des sessions : qui travaille sur quoi, depuis quand, dans quelle zone.

## Claim
Enregistrement BSI d'une session active. Format : `sess-YYYYMMDD-HHMM-<slug>`. Status : open → closed.

## Cognitive layers
Les 4 couches de donnees du brain : vision (pourquoi) → intention (quoi) → todo (comment) → projet (etat).

## Context engineering
L'art de fournir le bon contexte au bon agent au bon moment. Oppose du "dump everything" — le brain charge chirurgicalement.

## Distillation
Processus de compression : extraire l'essence d'une session, d'un agent, d'un document pour le rendre reutilisable sans le bruit.

## Feature gate
Mecanisme de controle : certains agents/features ne sont disponibles que pour certains tiers (free/pro/full).

## Focus
`focus.md` — direction actuelle du brain : projets actifs, prochaine frontiere, milestones. Cache manuel, source de verite = les projets eux-memes.

## Gate
Point de controle dans un workflow : `gate:human` (decision humaine requise), `gate:bact` (enrichissement contextuel), `gate:test` (tests verts requis).

## Instance
Un brain deploye sur une machine. Format : `brain_name@machine` (ex: `mybrain@desktop`).

## Intention
Fichier YAML dans `intentions/` : objectif mesurable, status, dependances, tags. Ne contient PAS de checkboxes (c'est le role du todo).

## Kernel
Noyau invariant du brain : PATHS.md, KERNEL.md, brain-compose.yml, CLAUDE.md. Jamais modifie sans confirmation explicite.

## Manifest
Fichier de session (`contexts/session-*.yml`) qui declare ce qui doit etre charge : L0 (invariant), L1 (type), L2 (scope), L3 (on demand).

## Now
`now.md` — pont entre les sessions. Ecrit en fin de session : done, next, decisions. Lu au boot suivant.

## Plateforme
Vision mini-game/app platform — auth centrale, plusieurs projets comme tuiles. Spec : `projets/plateforme.md`.

## Satellite
Repo git autonome clone dans le brain (toolkit, profil, todo, etc.). Chacun a son propre remote. Liste dans PATHS.md.

## Scope
Perimetre de travail d'une session : un projet, un sous-systeme, un fichier. Le scope determine quels agents et contextes sont charges.

## Session
Unite de travail avec le brain. 4 types (Sessions V2) : work, brain, explore, pilote. Chaque type a son manifest.

## Tier
Niveau de fonctionnalites : free (sans cle), pro (cle valide), full (cle + distillation). Enforce par feature-gate-check.sh.

## Vision
Fichier markdown dans `workspace/backlog/X/vision.md` : north star d'un projet, jalons sans deadline, le "pourquoi".

## Zone
Perimetre BSI d'un claim : kernel, project, infra, deploy. Les drifts de zone (ex: code→deploy) declenchent des gates.
