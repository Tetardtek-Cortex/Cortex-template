#!/usr/bin/env bash
# install-brain-hooks.sh — Installe les hooks git brain
#
# Usage :
#   scripts/install-brain-hooks.sh          → installe dans .git/hooks/
#   scripts/install-brain-hooks.sh --check  → vérifie si les hooks sont installés
#
# Hooks installés :
#   pre-commit  → warn si des fichiers zone:kernel sont modifiés (informatif, ne bloque pas)
#   post-commit → déclenche brain-db-sync.sh si handoffs/ agents/ ou BRAIN-INDEX.md changent
#
# Idempotent — peut être relancé sans risque.
# À relancer sur chaque clone frais (hooks non versionnés dans git).

set -euo pipefail

BRAIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_DIR="$BRAIN_ROOT/.git/hooks"
CHECK_ONLY=false

[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

hooks_installed() {
    local ok=true
    [[ -f "$HOOKS_DIR/pre-commit" ]]  && grep -q "brain-kernel-warn" "$HOOKS_DIR/pre-commit" 2>/dev/null  || ok=false
    [[ -f "$HOOKS_DIR/post-commit" ]] && grep -q "brain-db-sync"     "$HOOKS_DIR/post-commit" 2>/dev/null || ok=false
    $ok
}

if $CHECK_ONLY; then
    if hooks_installed; then
        echo "✅ Hooks brain installés (pre-commit + post-commit)"
        exit 0
    else
        echo "⚠️  Hooks brain incomplets — lancer: scripts/install-brain-hooks.sh"
        exit 1
    fi
fi

mkdir -p "$HOOKS_DIR"

# ── pre-commit (kernel zone warn) ─────────────────────────────────────────────

PRE_COMMIT="$HOOKS_DIR/pre-commit"

install_pre_commit() {
    local marker="brain-kernel-warn"

    # Si le hook existe déjà avec notre marker, skip
    if [[ -f "$PRE_COMMIT" ]] && grep -q "$marker" "$PRE_COMMIT" 2>/dev/null; then
        echo "✅ Hook pre-commit déjà présent"
        return
    fi

    # Préserver un hook pre-commit existant non-brain (append)
    if [[ -f "$PRE_COMMIT" ]] && ! grep -q "$marker" "$PRE_COMMIT"; then
        echo "" >> "$PRE_COMMIT"
        echo "# ── $marker (ajouté par install-brain-hooks.sh) ──" >> "$PRE_COMMIT"
    else
        cat > "$PRE_COMMIT" <<'PREHOOK'
#!/usr/bin/env bash
# brain pre-commit hook — installé par scripts/install-brain-hooks.sh
PREHOOK
        chmod +x "$PRE_COMMIT"
    fi

    cat >> "$PRE_COMMIT" <<'PREHOOK'

# brain-kernel-warn — avertit si des fichiers zone:kernel sont modifiés
_kernel_files=$(git diff --cached --name-only 2>/dev/null \
    | grep -E '^(KERNEL\.md|PATHS\.md|brain-compose\.yml|brain-constitution\.md|BRAIN-INDEX\.md|agents/|profil/|scripts/)' || true)

if [[ -n "$_kernel_files" ]]; then
    echo ""
    echo "  ╭──────────────────────────────────────────────────────────╮"
    echo "  │  🧠 Heads up — you're modifying kernel zone files       │"
    echo "  │                                                          │"
    echo "  │  These files define the brain's core behavior.           │"
    echo "  │  Modifying them may break compatibility with upstream    │"
    echo "  │  updates and tier-gated features.                        │"
    echo "  │                                                          │"
    echo "  │  Want to contribute or need help?                        │"
    echo "  │  → https://discord.gg/nqAVHMphXc                        │"
    echo "  ╰──────────────────────────────────────────────────────────╯"
    echo ""
    echo "  Files: $_kernel_files"
    echo ""
fi
PREHOOK
    echo "✅ Hook pre-commit installé"
}

install_pre_commit

# ── post-commit ────────────────────────────────────────────────────────────────

POST_COMMIT="$HOOKS_DIR/post-commit"

# Préserver un hook post-commit existant non-brain (append)
if [[ -f "$POST_COMMIT" ]] && ! grep -q "brain-db-sync" "$POST_COMMIT"; then
    echo "" >> "$POST_COMMIT"
    echo "# ── brain-db-sync (ajouté par install-brain-hooks.sh) ──" >> "$POST_COMMIT"
    cat >> "$POST_COMMIT" <<'HOOK'
# Déclenche brain-db-sync.sh si claims, handoffs ou BRAIN-INDEX ont changé
_brain_changed=$(git diff HEAD~1 --name-only 2>/dev/null \
    | grep -qE '^(handoffs/|agents/|BRAIN-INDEX\.md)' && echo yes || echo no)
if [[ "$_brain_changed" == "yes" ]]; then
    BRAIN_ROOT="$(git rev-parse --show-toplevel)"
    bash "$BRAIN_ROOT/scripts/brain-db-sync.sh" --quiet || true
fi
HOOK
    echo "✅ Hook post-commit existant complété"
else
    # Créer from scratch
    cat > "$POST_COMMIT" <<'HOOK'
#!/usr/bin/env bash
# brain post-commit hook — installé par scripts/install-brain-hooks.sh

# Sync brain.db si claims, handoffs ou BRAIN-INDEX ont changé
_brain_changed=$(git diff HEAD~1 --name-only 2>/dev/null \
    | grep -qE '^(handoffs/|agents/|BRAIN-INDEX\.md)' && echo yes || echo no)
if [[ "$_brain_changed" == "yes" ]]; then
    BRAIN_ROOT="$(git rev-parse --show-toplevel)"
    bash "$BRAIN_ROOT/scripts/brain-db-sync.sh" --quiet || true
fi
HOOK
    chmod +x "$POST_COMMIT"
    echo "✅ Hook post-commit installé"
fi

echo ""
echo "Hooks brain actifs :"
echo "  pre-commit  → kernel zone warn (informatif — ne bloque pas)"
echo "  post-commit → brain-db-sync.sh (déclenché sur handoffs/ agents/ BRAIN-INDEX.md)"
echo ""
echo "Pour vérifier : scripts/install-brain-hooks.sh --check"
