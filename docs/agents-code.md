# Agents Code & Qualite

> Les specialistes qui analysent, reviewent, testent et optimisent ton code.

---

## Review & Securite

### code-review

> 🟠 **pro**

Analyse tout code soumis selon 7 priorites, de la plus critique a la moins urgente :

1. **Securite** — injections, secrets exposes, tokens mal geres
2. **Edge cases** — entrees inattendues, etats limites
3. **Performance** — boucles inutiles, N+1, fuites memoire
4. **Async & erreurs** — promesses, try/catch, rejets non geres
5. **Typage** — pas de `any` sauvage
6. **Clean code** — lisible, maintenable
7. **Obsolescence** — patterns deprecies

Format adaptatif : inline sur un snippet court, rapport structure sur un fichier long.

Si un finding est critique → delegue a `security`. Apres review → suggere `testing`.

---

### security

> 🟠 **pro**

Audite la securite applicative selon 8 priorites :

1. Secrets exposes
2. Auth & tokens (JWT, OAuth2, refresh)
3. Injections (SQL, shell)
4. CSRF / CORS
5. XSS
6. Rate limiting
7. Headers securite
8. Exposition de donnees

Couvre la couche applicative. Pour la couche infra (Apache, SSL, ports) → delegue a `vps`.

---

## Tests

### testing

> 🟠 **pro**

Ecrit les tests et definit la strategie de coverage. Adaptatif :

- **Nouveau code** → TDD : tests d'abord, implementation ensuite
- **Code existant non couvert** → Retroactif : tests sur le comportement constate
- **Refacto prevue** → TDD : les tests guident la refacto

Strategie par couche : tests unitaires purs sur le domaine, mocks sur l'application, integration vraie sur l'infra et les routes.

---

### refacto

> 🟠 **pro**

Restructure le code sans perdre une seule ligne de logique metier. Methode en 5 etapes :

```
1. DIAGNOSTIC   — identifier le probleme
2. PLAN         — lister les etapes (moins risquee → plus risquee)
3. VALIDATION   — confirmer avec toi avant d'agir
4. EXECUTION    — une etape a la fois, tests verts a chaque fois
5. VERIFICATION — comportement identique avant/apres
```

3 niveaux de risque : code local (faible) → module (moyen) → architecture (eleve).

Pas de tests existants ? → `testing` les ecrit avant la refacto.

---

## Performance

### optimizer

> 🟠 **pro**

Agent unifie pour les 3 couches — backend, database, frontend. Mesurer d'abord, optimiser ensuite. Un goulot a la fois.

- **Backend** — async, memoire, event loop, caching
- **Database** — N+1, index manquants, EXPLAIN, denormalisation
- **Frontend** — re-renders, bundle size, lazy loading, images

Framework : mesurer → localiser → corriger → verifier. Pas d'optimisation prematuree.

---

## API & Architecture

### api-designer

> 🟠 **pro**

Design API-first — conventions, nommage, pagination, erreurs, versionning. Le schema avant le code. REST par defaut, GraphQL si justifie. Review les endpoints existants contre les bonnes pratiques.

### database-architect

> 🟠 **pro**

Schema, normalisation, indexes, migrations. 3NF par defaut, denormalise uniquement si la perf le justifie. Planifie les migrations zero-downtime avec rollback.

---

## Release

### release-manager

> 🟠 **pro**

Lit le git log, categorise les commits, propose le bon increment semver, redige le changelog et les release notes. Tu tag, il fait le reste.

---

## Qui delegue a qui

- `code-review` → `security` (faille trouvee) · `testing` (couvrir le fix) · `refacto` (structure)
- `security` → `vps` (infra) · `ci-cd` (secrets pipeline)
- `testing` → `security` (tests auth) · `code-review` (review des tests)
- `refacto` → `testing` (tests avant refacto) · `debug` (bugs trouves)
- `optimizer` → `code-review` (qualite) · `vps` (config serveur) · `ci-cd` (config build)
