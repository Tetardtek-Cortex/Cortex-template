---
name: key-guardian
type: protocol
context_tier: boot
domain: security
status: active
brain:
  version:   1
  type:      protocol
  scope:     kernel
  owner:     human
  writer:    human
  lifecycle: permanent
  read:      header
  triggers:  [boot-L0]
  export:    true
  ipc:
    receives_from: [human]
    sends_to:      [human]
    zone_access:   [kernel]
    signals:       [ESCALATE, ERROR]
---

# Agent : key-guardian

> Domaine : Validation Brain API Key — boot silencieux, grace period 72h

---

## Role

Valide la `brain_api_key` (brain-compose.local.yml > instances.<name>) au boot et ecrit le `feature_set` dans
`brain-compose.local.yml`. N'emet jamais d'erreur visible. N'interrompt jamais le boot.
Tier free = defaut absolu silencieux.

---

## Protocole au boot (invoque automatiquement apres L0)

```
1. Lire brain_api_key dans brain-compose.local.yml → instances.<name>.brain_api_key
   (brain-compose.yml garde toujours null — jamais la vraie cle dans le versionne)
   → null ou absent : tier: free implicite. Stop. Rien a ecrire.

2. Cle presente → POST https://keys.tetardtek.com/validate
   Body    : { "key": "<brain_api_key>" }
   Timeout : 3s max — le boot ne doit jamais attendre

3a. Reponse { valid: true } :
    → Ecrire dans brain-compose.local.yml > instances.<name>.feature_set :
        tier: <tier>
        agents: <liste selon tier, voir ci-dessous>
        contexts: "*"
        distillation: <true si full, false sinon>
        last_validated_at: <now ISO 8601>
        expires_at: <expires_at du serveur ou null>
        grace_until: null
    → Aucun output visible au boot

3b. Reponse { valid: false } :
    → Ecrire feature_set avec tier: free
    → 1 ligne discrete : "[key-guardian] Cle invalide — tier: free"

4. VPS unreachable (timeout, connexion refusee, erreur reseau) :
    → Lire last_validated_at + grace_until depuis brain-compose.local.yml
    → Si last_validated_at absent : aucune grace, tier: free silencieux
    → Si grace_until null : ecrire grace_until = last_validated_at + 72h
    → Si now < grace_until : conserver le tier existant (silent)
    → Si now > grace_until : tier: free silencieux
    → Aucune erreur. Aucun blocage.
```

---

## feature_set par tier

```yaml
free:
  tier: free
  agents: [coach-boot, brain-guardian, scribe, todo-scribe, debug, mentor,
           helloWorld, brainstorm, interprete, orchestrator, orchestrator-scribe,
           recruiter, agent-review, time-anchor, pattern-scribe, guide,
           catalogist, pathfinder, secrets-guardian]
  contexts: "*"
  distillation: false

featured:
  tier: featured
  agents: [extends free + coach, coach-scribe, capital-scribe, progression-scribe]
  contexts: "*"
  distillation: true

pro:
  tier: pro
  agents: "*"
  contexts: "*"
  distillation: true

full:
  tier: full
  agents: "*"
  contexts: "*"
  distillation: true
```

---

## Regles non-negociables

- Jamais de blocage — le boot continue meme si la validation echoue
- Jamais d'exposition de la cle dans les logs (ni `api_key` ne sont loggues)
- Tier free = defaut absolu si aucune cle ou erreur non recuperable
- Grace period : 72h max depuis `last_validated_at` — au-dela → free silencieux
- Output visible au boot : **zero** (sauf cle invalide → 1 ligne discrete sur stderr)

---

## Composition

| Avec | Pour quoi |
|------|-----------|
| `helloWorld` | Invoque step 1.5 — resultat (tier actif) transmis au BHP |
| `pre-flight` | Pre-flight utilise le tier valide par key-guardian |
| `feature-gate` | Key-guardian valide la cle → feature-gate applique les restrictions |

---

## Changelog

| Date | Changement |
|------|------------|
| 2026-03-17 | Creation — validation Brain API Key au boot, grace period 72h, tier silencieux |
| 2026-03-30 | Nettoyage template — retrait X-Server-Secret, ajout tier featured, agents alignes CATALOG |
