---
name: AGENTS
type: index
context_tier: cold
---

# Agents spécialisés

> Index des agents disponibles.
> Charger un agent = lire son fichier en début de session pour injecter son contexte.
> Stratification Chaud/Froid — voir `brain/profil/memory-architecture.md` Pillier 3.

---

## 🔴 Agents chauds — auto-détectés sur trigger domaine

> Chargés automatiquement quand le domaine est détecté.

| Agent | Domaine | Tier | Statut |
|-------|---------|------|--------|
| `helloWorld` | Bootstrap intelligent — briefing + chargement sélectif | free | 🔄 permanent |
| `coach` | Progression — tutorat, suivi, coaching code + agents | featured | 🔄 permanent |
| `key-guardian` | Validation Brain API Key — tier silencieux, grace 72h | free | ✅ |
| `time-anchor` | Conscience temporelle — live-states + git log | free | ✅ |
| `secrets-guardian` | Protection secrets — 4 surfaces, interruption violation | free | ✅ |
| `brain-guardian` | Auto-méfiance structurelle — assertions prouvées | free | ✅ |
| `pattern-scribe` | Détection patterns récurrents inter-sessions | free | ✅ |
| `debug` | Débogage local + prod | free | ✅ |
| `vps` | Infra, Apache, Docker, SSL | pro | ✅ |
| `mail` | DNS, protocoles mail | pro | ✅ |
| `code-review` | Qualité, sécurité, dette technique | pro | ✅ |
| `testing` | Jest, Vitest, DDD, coverage | pro | ✅ |
| `refacto` | Refactorisation — architecture + code | pro | ✅ |
| `monitoring` | Observabilité — logs VPS | pro | ✅ |
| `ci-cd` | Pipelines GitHub Actions + Gitea CI | pro | ✅ |
| `pm2` | Process manager Node.js prod | pro | ✅ |
| `migration` | TypeORM migrations — schéma, deploy safe | pro | ✅ |
| `frontend-stack` | Architecture frontend — stack, libs UI | pro | ✅ |
| `i18n` | Internationalisation — audit traductions | pro | ✅ |
| `doc` | Documentation — README, API Swagger | featured | ✅ |
| `git-analyst` | Historique sémantique, conventions, synthèse commits | featured | ✅ |
| `audit` | Diagnostic brain — cohérence inter-couches, gaps | pro | ✅ |
| `pre-flight` | Gate boot — vérifie tier_required + kerneluser | pro | ✅ |
| `tech-lead` | Leadership technique — gate sprint, contention map | owner | ✅ |
| `architecture-scribe` | Mémoire architecturale — git-analyst → ADR | owner | ✅ |
| `context-broker` | Cycle respiratoire — inhale/expire source map | owner | ✅ |
| `satellite-boot` | Multi-instances — scope unique, zéro overhead | owner | ✅ |
| `integrator` | Absorption multi-agents — validation critères, handoff | owner | ✅ |
| `decision-scribe` | Registre connaissance structurelle | owner | ✅ |
| `kanban-scribe` | Pipeline kanban, transitions état au wrap | owner | ✅ |
| `metabolism-scribe` | Métriques session, health_score, prix par agent | owner | ✅ |

---

## 🔵 Agents stables — invocation manuelle uniquement

> Ne se chargent pas automatiquement. Invoqués explicitement par l'utilisateur ou sur signal d'un agent chaud.

| Agent | Domaine | Statut |
|-------|---------|--------|
| `orchestrator` | Coordination — diagnostic et délégation multi-agents | ✅ 2026-03-12 |
| `scribe` | Maintenance du brain | ✅ 2026-03-12 |
| `mentor` | Pédagogie — explication, garde-fou | ✅ 2026-03-12 |
| `recruiter` | Meta-agent — conception d'agents | 🔄 |
| `agent-review` | Audit du système d'agents — gaps, patches, vue système | ✅ 2026-03-13 |
| `interprete` | Clarification d'intention — demandes ambiguës, scope drift | 🧪 forgé 2026-03-13 |
| `brainstorm` | Exploration et structuration de décisions — avocat du diable | 🧪 forgé 2026-03-13 |
| `toolkit-scribe` | Persistance patterns — gardien du toolkit/ | 🧪 forgé 2026-03-13 |
| `coach-scribe` | Persistance progression — journal/skills/milestones | 🧪 forgé 2026-03-13 |
| `todo-scribe` | Persistance intentions — gardien de brain/todo/ | 🧪 forgé 2026-03-13 |
| `kanban-scribe` | Pipeline kanban — transitions d'état au wrap, détection autonomie | 🧪 forgé 2026-03-15 |
| `helloWorld` | Bootstrap intelligent — briefing + chargement sélectif | 🧪 forgé 2026-03-13 |
| `decision-scribe` | Registre connaissance structurelle — stack, capacités, politiques constantes — gate:human.DEFINE | 🧪 forgé 2026-03-17 |
| `git-analyst` | Historique git sémantique — conventions, synthèse commits | 🧪 forgé 2026-03-13 |
| `config-scribe` | Configuration brain — wizard first run, hydration Sources | 🧪 forgé 2026-03-13 |
| `brain-compose` | Multi-instances brain — symlinks kernel, registre machine | 🧪 forgé 2026-03-13 |
| `orchestrator-scribe` | Bus inter-sessions — Signals BSI, cycles coworking, HANDOFF | 🧪 forgé 2026-03-14 |
| `session-orchestrator` | Lifecycle de session — boot 4 couches, close séquencé, rapport coach | 🧪 forgé 2026-03-14 |
| `metabolism-scribe` | Métriques session — health_score, agents_loaded, prix par agent | 🧪 forgé 2026-03-14 |
| `architecture-scribe` | Mémoire architecturale — git-analyst → ADR → profil/decisions/ | 🧪 forgé 2026-03-15 |
| `integrator` | Intégration multi-agents — absorption, validation critères, handoff next team | 🧪 forgé 2026-03-14 |
| `context-broker` | Cycle respiratoire de contexte — inhale source map + expire release map + breath metrics | 🧪 forgé 2026-03-15 |
| `satellite-boot` | Boot loader satellite — Pattern 10, scope unique, zéro overhead, signal retour pilote | 🧪 forgé 2026-03-16 |

---

## ⚙️ Agents kernel — protocole & supervision

> Agents de protocole système — scope:kernel. Ne se chargent pas automatiquement.

| Agent | Domaine | Tier | Statut |
|-------|---------|------|--------|
| `coach-boot` | Présence permanente — boot-summary coach, chargé L0 | free | ✅ |

> Agents **full** additionnels prevus en post-launch.

---

## Workflows multi-agents connus

| Workflow | Agents | Description |
|----------|--------|-------------|
| Nouveau service VPS | `vps` | Deploy Docker + Apache + SSL |
| Audit infra + code | `vps` + `code-review` | Vérification complète avant mise en prod |
| Déploiement mail | `vps` + `mail` | Setup mail depuis zéro |
| Validation avant prod | `code-review` + `ci-cd` | Review code + pipeline avant déploiement |
| Nouveau projet complet | `vps` + `ci-cd` | Déploiement serveur + pipeline CI/CD |
| Problème non identifié | `orchestrator` → agents détectés | Diagnostic + délégation automatique |
| Audit système d'agents | `agent-review` → `recruiter` | Review + détection gaps → forge si besoin |
| Exploration / décision archi | `brainstorm` → `recruiter` ou agent métier | Explorer + challenger → construire |
| Coordination multi-instances | `orchestrator-scribe` | Signals BSI + cycles coworking inter-brains |
| Fin de session complète | `session-orchestrator` → `metabolism-scribe` + `scribe` + `coach` | Séquence close : métriques → brain → rapport coach → BSI |
| Projet multi-langue | `i18n` + `frontend-stack` | Audit traductions + intégration lib |
| Release / PR importante | `doc` + `code-review` | Doc à jour + code validé |
| Bug prod complexe | `debug` + `vps` | Isolation + infra |
| Refacto sécurisée | `refacto` + `testing` + `code-review` | Tests avant, refacto, review après |
| Incident prod | `monitoring` + `vps` + `debug` | Alerte → diagnostic infra → debug applicatif |
| Nouveau déploiement | `ci-cd` + `monitoring` | Pipeline + sondes de surveillance |
