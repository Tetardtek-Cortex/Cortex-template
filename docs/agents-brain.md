# Agents Brain & Systeme

> Les agents qui font vivre le brain — documentation, coaching, orchestration, protection.

---

## Coach — ta progression

### coach

> 🟢 **free** : `coach-boot` (observation legere)
> 🔵 **featured+** : `coach` complet (mentorat, bilans, objectifs)

Le coach est toujours present. Ce qui change selon ton tier :

> 🟢 **free** — Observe en silence. Intervient uniquement sur un risque critique.

> 🔵 **featured** — Bilans de session, objectifs SMART, progression tracee.

> 🟠 **pro** — Idem + contexte projet (review code, patterns, architecture).

> 🟣 **full** — Mentorat long terme — anticipe, challenge les decisions, milestones.

Le coach adapte aussi son comportement au type de session :

- **Silencieux** (navigate, deploy, infra, urgence, audit) — pas de rapport, risque critique uniquement
- **Standard** (work, debug) — actif sur les patterns d'erreur
- **Engage** (brain, brainstorm) — challenge les decisions
- **Complet** (coach, capital) — mentorat structure
- **Copilote** (pilote) — proactif, anticipe

---

## Scribes — la memoire

Les scribes ecrivent pour que rien ne se perde. Chacun a son territoire :

### scribe

> 🟢 **free**

Gardien principal du brain. Met a jour `focus.md`, les fiches projets, l'index des agents. Detecte ce qui est obsolete et le signale.

S'active en fin de session significative (commits, agents forges, decisions prises).

---

### todo-scribe

> 🟢 **free**

Ecrit dans `brain/todo/`. Capture les intentions non realisees, les taches a planifier. Ne priorise pas — il structure et persiste.

---

### metabolism-scribe

> 🟣 **full**

Mesure la sante de chaque session : tokens, duree, commits, context peak. Calcule le `health_score` et le ratio use-brain/build-brain sur 7 jours.

Il ne juge pas — il mesure. Les tendances parlent d'elles-memes.

---

### coach-scribe

> 🔵 **featured**

Persiste la progression dans `progression/` : journal de session, competences, milestones. Separe du coach — le coach observe, le scribe ecrit.

---

### toolkit-scribe

> 🟠 **pro**

Capture les patterns valides en prod dans `toolkit/`. Chaque pattern reussi en session devient un template reutilisable.

---

## Orchestration — le systeme nerveux

### helloWorld

> 🟢 **free**

Le majordome. Premier agent au reveil : lit l'etat du systeme, produit le briefing, ouvre le claim BSI, passe la main a session-orchestrator.

---

### session-orchestrator

> 🟠 **pro**

Proprietaire du cycle de vie. Decide ce qui est charge au boot, route le travail, declenche les scribes a la fermeture. Ne produit rien — il orchestre.

---

### secrets-guardian

> 🟢 **free**

Surveille les secrets en permanence. Silencieux quand tout va bien — fracassant des qu'une fuite est detectee. Session suspendue, zero exception.

4 surfaces surveillees : code source, chat, commandes shell, outputs d'outils.

---

### brain-guardian

> 🟢 **free**

Auto-mefiance structurelle. Quand le brain travaille sur lui-meme, cet agent exige des preuves pour chaque assertion. Empeche le brain de se convaincre qu'il fonctionne bien sans verification.

---

## Agents systeme — le boot

### key-guardian

> 🟢 **free**

Valide la Brain API Key au boot. Pas de cle → tier free (silencieux, pas d'erreur). Cle valide → ecrit le tier dans la config. Cache le resultat 24h. VPS down → grace period 72h.

### pre-flight

> 🟠 **pro**

Gate de boot — verifie que le tier actif autorise la session demandee, que le kerneluser est correct, et que le write_lock est respecte. Bloque si les conditions ne sont pas remplies.

---

## Agents full — supervision avancee

> 🟣 **full** — supervision pour le proprietaire du brain

### tech-lead

Decisions architecturales, gate validation. Intervient quand une decision structurante est detectee.

### integrator

Integration multi-systemes. Coordonne les interactions entre brain, satellites, et services externes.

---

## Tous les agents de cette page

> 🟢 **free** — `coach-boot` · `scribe` · `todo-scribe` · `helloWorld` · `secrets-guardian` · `brain-guardian` · `key-guardian` · `onboarding-guide`

> 🔵 **featured** — `coach` (complet) · `coach-scribe` · `learning-journal` · `product-strategist` · `content-writer` · `doc` · `git-analyst`

> 🟠 **pro** — `toolkit-scribe` · `session-orchestrator` · `pre-flight` · `release-manager`

> 🟣 **full** — `architecture-scribe` · `context-broker` · `satellite-boot` · `integrator` · `tech-lead` · `decision-scribe` · `kanban-scribe` · `metabolism-scribe` · `bact-scribe`
