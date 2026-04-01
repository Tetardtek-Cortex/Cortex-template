# Le brain en 30 secondes

## Pourquoi un brain plutot que Claude seul ?

Claude est puissant. Mais a chaque session, il repart de zero. Tu re-expliques ton projet, ta stack, tes conventions. Tu repetes les memes consignes. Tu perds du contexte a chaque compaction.

Le brain resout ca : **un systeme de specialistes IA qui persistent entre sessions.** Chaque specialiste (agent) fait une chose bien — debugger, reviewer du code, deployer, ecrire des tests. Ils connaissent tes regles, ta stack, tes decisions passees. Tu n'en charges jamais plus de 5 a la fois — le brain sait lesquels activer selon ce que tu fais.

Tu forkes le brain, tu codes. Les agents se chargent automatiquement. Ton contexte survit aux sessions.

---

## Les 4 tiers

> 🟢 **free — Tu forkes, ca marche**
>
> **19 agents. 6 types de sessions.** Pas de cle API, pas de config.
>
> Debug, brainstorm, scribes automatiques, protection secrets, creation d'agents custom. Le coach observe en arriere-plan.

> 🔵 **featured — Le brain te connait**
>
> **26 agents. 8 types de sessions.** Le coach se reveille.
>
> Bilans de session, objectifs concrets, progression tracee. Le brain se souvient de tes acquis entre sessions grace a la distillation RAG.

> 🟠 **pro — L'atelier complet**
>
> **48 agents. 14 types de sessions.** Tu ship en prod.
>
> Code review (7 priorites), audit securite, tests automatises, deploy VPS + CI/CD + SSL, sessions urgence et infra.

> 🟣 **full — Ton brain, tes regles**
>
> **56 agents (tous). Toutes les sessions.** Tu es owner.
>
> Modification du kernel, copilotage long (mode pilote), supervision avancee, coach proactif qui anticipe.

---

## Ce qui change quand tu montes

> 🟢 → 🔵 **free vers featured**
>
> Le coach passe de spectateur a mentor. Il fait un bilan a chaque session, fixe des objectifs, et trace ta progression. Le brain apprend de toi — il se souvient entre sessions.

> 🔵 → 🟠 **featured vers pro**
>
> Tu recois une equipe complete : review code, audit securite, tests, refacto, optimizer perf, deploy prod, monitoring, pipelines CI/CD. Plus besoin d'improviser — le brain fait le travail metier.

> 🟠 → 🟣 **pro vers full**
>
> Tu deviens owner. Tu modifies le brain lui-meme (kernel, agents, profil). Sessions longues en copilote proactif. Supervision avancee, scribes specialises.

---

## Comment ca marche en pratique

**Les agents se chargent tout seuls.** Tu parles de "bug" → `debug` arrive. Tu dis "deploy" → `vps` + `ci-cd` se chargent. Tu peux aussi les appeler :

```
Charge l'agent testing
Charge les agents security et code-review
```

**Ils se delegent entre eux.** Chaque agent connait ses limites :
- `debug` detecte un probleme infra → passe a `vps`
- `code-review` trouve une faille → passe a `security`
- `optimizer` identifie un goulot DB vs backend → adapte son diagnostic

**Ils ne chargent que l'essentiel.** Un agent de 200 lignes → ~25 lignes au boot. Le reste se charge quand tu en as besoin.

**Premier fork ?** L'`onboarding-guide` detecte le fresh fork et te guide — 5 etapes, zero friction. Il disparait quand tu es autonome.

---

## Explore les agents par famille

**Code & Qualite** — review, securite, tests, refacto, optimizer, API design

**Infra & Deploy** — VPS, pipelines CI/CD, monitoring, process manager, mail

**Brain & Systeme** — coach, scribes, orchestration, protection, kernel

→ Chaque famille est accessible dans la sidebar.

---

## Pour aller plus loin

**L'histoire du projet** — Documentez votre parcours et vos decisions sur un blog ou site dedie. Les utilisateurs qui forkent apprecieront le contexte.

---

## Nouveautes

| Date | Quoi de neuf |
|------|-------------|
| 2026-03-31 | 10 agents forges — onboarding-guide, game-designer, product-strategist, learning-journal, content-writer, api-designer, release-manager, security, optimizer, database-architect |
| 2026-03-31 | Tier rebalance — free(19) featured(26) pro(48) full(56) |
| 2026-03-21 | Docs live — git pull = docs a jour, zero rebuild |
| 2026-03-21 | VPS scission — vitrine template publique separee du brain prod |
| 2026-03-20 | Agents 87% plus legers au boot |
| 2026-03-20 | Coach adaptatif — 5 comportements selon la session |
| 2026-03-20 | Fermeture fiable — sequence deterministe |
| 2026-03-18 | Auto-mefiance — le brain se verifie quand il s'edite |
| 2026-03-17 | Supervision avancee — hypervisor + circuit breaker |
