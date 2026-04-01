#!/bin/bash
# brain-setup.sh — Setup complet d'un brain personnel depuis le template
#
# Usage : bash scripts/brain-setup.sh [brain_name] [brain_root]
# Ex    : bash scripts/brain-setup.sh mon-brain ~/Dev/Brain
#
# Ce script :
#   1. Copie le template vers brain_root (ton brain personnel)
#   2. Clone les 5 satellites (toolkit, profil, progression, reviews, todo)
#   3. Configure CLAUDE.md, PATHS.md, brain-compose.local.yml
#   4. Vérifie les dépendances (Python, Node, Claude Code)
#   5. Commit le tout — prêt pour brain boot
#
# Idempotent — safe à relancer si une étape a échoué.

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
BRAIN_NAME="${1:-mon-brain}"
BRAIN_ROOT="${2:-$HOME/Dev/Brain}"
TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Satellites : repos publics sur Tetardtek-Cortex (override via GITHUB_ORG)
GITEA_HOST="${GITEA_HOST:-}"
GITHUB_ORG="${GITHUB_ORG:-https://github.com/Tetardtek-Cortex}"

if [[ -n "$GITEA_HOST" ]] && ssh -T "git@$GITEA_HOST" -o StrictHostKeyChecking=no -o ConnectTimeout=3 2>&1 | grep -qE "Welcome|Hi there"; then
  GIT_SOURCE="gitea"
  GIT_BASE="git@$GITEA_HOST:$(whoami)"
  SATELLITES=(
    "toolkit:$BRAIN_ROOT/toolkit"
    "progression-coach:$BRAIN_ROOT/progression"
    "brain-agent-review:$BRAIN_ROOT/reviews"
    "brain-profil:$BRAIN_ROOT/profil"
    "brain-todo:$BRAIN_ROOT/todo"
    "brain.wiki:$BRAIN_ROOT/wiki"
  )
else
  GIT_SOURCE="github"
  GIT_BASE="$GITHUB_ORG"
  SATELLITES=(
    "${SATELLITE_TOOLKIT:-Cortex-Template-Toolkit}:$BRAIN_ROOT/toolkit"
    "${SATELLITE_PROGRESSION:-Cortex-Template-Progression}:$BRAIN_ROOT/progression"
    "${SATELLITE_REVIEWS:-Cortex-Template-Reviews}:$BRAIN_ROOT/reviews"
    "${SATELLITE_PROFIL:-Cortex-Template-Profil}:$BRAIN_ROOT/profil"
    "${SATELLITE_TODO:-Cortex-Template-Todo}:$BRAIN_ROOT/todo"
  )
fi

# ── Couleurs ─────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "   $1"; }
step() { echo -e "\n${CYAN}[ $1 ]${NC}"; }

# Tracker les dépendances manquantes
MISSING=()
MISSING_CMDS=()

# ── Vérifications préalables ────────────────────────────────────────────────
if ! command -v git &>/dev/null; then
  err "git non installé — sudo apt install git"
  exit 1
fi

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║         brain-setup.sh — nouveau brain           ║"
echo "║                                                  ║"
echo "║  brain   : $BRAIN_NAME"
echo "║  dossier : $BRAIN_ROOT"
echo "║  source  : $GIT_SOURCE"
echo "╚══════════════════════════════════════════════════╝"

# ═══════════════════════════════════════════════════════════════════════════
# ÉTAPE 1 — Copier le template vers brain_root
# ═══════════════════════════════════════════════════════════════════════════
step "1/5 — Initialisation du brain"

if [[ "$TEMPLATE_DIR" == "$BRAIN_ROOT" ]]; then
  info "Template = brain_root — pas de copie"
elif [[ -f "$BRAIN_ROOT/brain-compose.yml" ]]; then
  info "Brain existant dans $BRAIN_ROOT — skip copie"
else
  mkdir -p "$BRAIN_ROOT"
  rsync -a --exclude='.git' \
           --exclude='toolkit/' --exclude='profil/' \
           --exclude='progression/' --exclude='reviews/' --exclude='todo/' \
           "$TEMPLATE_DIR/" "$BRAIN_ROOT/"
  ok "Template copié → $BRAIN_ROOT"

  cd "$BRAIN_ROOT"
  git init -b main --quiet
  git add -A
  git commit -m "init: mon brain ($BRAIN_NAME)" --quiet
  ok "Repo git initialisé"
fi

# ═══════════════════════════════════════════════════════════════════════════
# ÉTAPE 2 — Cloner les satellites
# ═══════════════════════════════════════════════════════════════════════════
step "2/5 — Satellites"

for entry in "${SATELLITES[@]}"; do
  repo="${entry%%:*}"
  dest="${entry#*:}"
  dest="${dest/#\~/$HOME}"

  if [[ -d "$dest/.git" ]]; then
    info "$repo → déjà cloné"
  else
    if [[ -d "$dest" ]]; then
      rm -f "$dest/README.md"
      rmdir "$dest" 2>/dev/null || true
    fi
    mkdir -p "$(dirname "$dest")"
    git clone "$GIT_BASE/$repo.git" "$dest" --quiet
    ok "$repo"
  fi
done

# ═══════════════════════════════════════════════════════════════════════════
# ÉTAPE 3 — Configuration
# ═══════════════════════════════════════════════════════════════════════════
step "3/5 — Configuration"

# CLAUDE.md
CLAUDE_TARGET="$HOME/.claude/CLAUDE.md"
CLAUDE_EXAMPLE="$BRAIN_ROOT/profil/CLAUDE.md.example"
mkdir -p "$HOME/.claude"

if [[ -f "$CLAUDE_TARGET" ]]; then
  cp "$CLAUDE_TARGET" "$CLAUDE_TARGET.bak"
  info "CLAUDE.md existant → backup .bak"
fi

if [[ -f "$CLAUDE_EXAMPLE" ]]; then
  cp "$CLAUDE_EXAMPLE" "$CLAUDE_TARGET"
  sed -i "s|<BRAIN_ROOT>|$BRAIN_ROOT|g" "$CLAUDE_TARGET"
  sed -i "s|<BRAIN_NAME>|$BRAIN_NAME|g" "$CLAUDE_TARGET"
  ok "~/.claude/CLAUDE.md"
else
  warn "profil/CLAUDE.md.example absent — configurer manuellement"
fi

# brain-compose.local.yml
LOCAL_COMPOSE="$BRAIN_ROOT/brain-compose.local.yml"
if [[ -f "$LOCAL_COMPOSE" ]]; then
  info "brain-compose.local.yml existe — skip"
else
  KERNEL_VERSION=$(grep '^version:' "$BRAIN_ROOT/brain-compose.yml" 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "0.0.0")
  cat > "$LOCAL_COMPOSE" << EOF
kernel_path: $BRAIN_ROOT
kernel_version: "$KERNEL_VERSION"
last_kernel_sync: "$(date +%Y-%m-%d)"
machine: $BRAIN_NAME

instances:
  $BRAIN_NAME:
    path: $BRAIN_ROOT
    brain_name: $BRAIN_NAME
    # Coller votre cle API ici pour debloquer les tiers (featured/pro/full)
    # Sans cle = tier free (toutes les fonctions de base)
    brain_api_key: null
    feature_set:
      tier: free
      agents: fondamentaux
      contexts: brain, handoff
      distillation: false
      last_validated_at: null
      expires_at: null
      grace_until: null
    mode: prod
    docs_fetch: ask
    config_status: hydrated
    active: true
EOF
  ok "brain-compose.local.yml"
fi

# PATHS.md
if grep -q '<BRAIN_ROOT>' "$BRAIN_ROOT/PATHS.md" 2>/dev/null; then
  sed -i "s|<BRAIN_ROOT>|$BRAIN_ROOT|g" "$BRAIN_ROOT/PATHS.md"
  sed -i "s|<HOME>|$HOME|g" "$BRAIN_ROOT/PATHS.md"
  ok "PATHS.md"
else
  info "PATHS.md déjà configuré"
fi

# MYSECRETS
SECRETS_DIR="$(dirname "$BRAIN_ROOT")/BrainSecrets"
MYSECRETS="$SECRETS_DIR/MYSECRETS"
if [[ -f "$MYSECRETS" ]]; then
  ok "MYSECRETS présent"
else
  info "MYSECRETS absent — optionnel, requis pour les sessions secrets"
  info "  mkdir -p $SECRETS_DIR"
  info "  cp $BRAIN_ROOT/MYSECRETS.example $MYSECRETS"
fi

# ═══════════════════════════════════════════════════════════════════════════
# ÉTAPE 4 — Vérification des dépendances
# ═══════════════════════════════════════════════════════════════════════════
step "4/5 — Dépendances"

# Python
if command -v python3 &>/dev/null; then
  ok "Python $(python3 --version 2>&1 | awk '{print $2}')"

  if python3 -m venv --help &>/dev/null; then
    ok "python3-venv"
  else
    PY_VER=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1-2)
    VENV_PKG="python${PY_VER}-venv"
    warn "python3-venv manquant"
    MISSING+=("$VENV_PKG  →  sudo apt install $VENV_PKG")
    MISSING_CMDS+=("sudo apt install $VENV_PKG")
  fi

  if command -v pip3 &>/dev/null; then
    ok "pip $(pip3 --version 2>&1 | awk '{print $2}')"
  else
    warn "pip3 manquant"
    MISSING+=("python3-pip   →  sudo apt install python3-pip")
    MISSING_CMDS+=("sudo apt install python3-pip")
  fi
else
  warn "Python 3 absent"
  MISSING+=("python3       →  sudo apt install python3 python3-pip python3-venv")
  MISSING_CMDS+=("sudo apt install python3 python3-pip python3-venv")
fi

# Node.js
if command -v node &>/dev/null && command -v npm &>/dev/null; then
  NODE_VER=$(node --version | tr -d 'v' | cut -d. -f1)
  if [[ "$NODE_VER" -ge 20 ]]; then
    ok "Node.js $(node --version) / npm $(npm --version)"
  else
    warn "Node.js $(node --version) trop ancien (20+ requis)"
    MISSING+=("nodejs 20+    →  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs")
    MISSING_CMDS+=("curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs")
  fi
else
  warn "Node.js absent (requis pour dashboard + Claude Code)"
  MISSING+=("nodejs 20+    →  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs")
  MISSING_CMDS+=("curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs")
fi

# Claude Code
if command -v claude &>/dev/null; then
  ok "Claude Code $(claude --version 2>/dev/null || echo '')"
else
  warn "Claude Code absent"
  MISSING+=("claude-code   →  npm install -g @anthropic-ai/claude-code")
  MISSING_CMDS+=("npm install -g @anthropic-ai/claude-code")
fi

# brain-ui (build si possible)
BRAIN_UI="$BRAIN_ROOT/brain-ui"
if [[ -f "$BRAIN_UI/package.json" ]]; then
  if command -v npm &>/dev/null && [[ ! -d "$BRAIN_UI/dist" ]]; then
    info "Build brain-ui (dashboard)..."
    (cd "$BRAIN_UI" && npm install --silent 2>/dev/null && npm run build --silent 2>/dev/null) \
      && ok "Dashboard buildé" \
      || warn "Build dashboard échoué — relancer après install Node.js"
  elif [[ -d "$BRAIN_UI/dist" ]]; then
    ok "Dashboard déjà buildé"
  fi
  # .env.local
  if [[ ! -f "$BRAIN_UI/.env.local" ]]; then
    cat > "$BRAIN_UI/.env.local" << 'ENVEOF'
VITE_USE_MOCK=true
VITE_BRAIN_API=
ENVEOF
  fi
fi

# ═══════════════════════════════════════════════════════════════════════════
# ÉTAPE 5 — Commit config + résumé
# ═══════════════════════════════════════════════════════════════════════════
step "5/5 — Finalisation"

if [[ -d "$BRAIN_ROOT/.git" ]]; then
  cd "$BRAIN_ROOT"
  git add -A 2>/dev/null
  git diff --cached --quiet 2>/dev/null || {
    git commit -m "config: setup $BRAIN_NAME" --quiet
    ok "Configuration commitée"
  }
fi

# ── Résumé ────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║              Setup terminé                       ║"
echo "╚══════════════════════════════════════════════════╝"

# Dépendances manquantes (si il y en a)
if [[ ${#MISSING[@]} -gt 0 ]]; then
  echo ""
  echo -e "  ${RED}Dépendances manquantes :${NC}"
  echo ""
  for dep in "${MISSING[@]}"; do
    echo -e "    ${YELLOW}•${NC} $dep"
  done
  echo ""
  echo "  One-liner pour tout installer :"
  echo ""
  # Combiner les commandes apt en une seule si possible
  APT_PKGS=""
  OTHER_CMDS=()
  for cmd in "${MISSING_CMDS[@]}"; do
    if [[ "$cmd" == "sudo apt install "* ]]; then
      APT_PKGS+=" ${cmd#sudo apt install }"
    else
      OTHER_CMDS+=("$cmd")
    fi
  done
  if [[ -n "$APT_PKGS" ]]; then
    echo "    sudo apt install -y$APT_PKGS"
  fi
  for cmd in "${OTHER_CMDS[@]}"; do
    echo "    $cmd"
  done
  echo ""
  echo -e "  ${YELLOW}Relance le setup après installation pour finaliser.${NC}"
fi

# MYSECRETS
if [[ ! -f "$MYSECRETS" ]]; then
  echo ""
  echo -e "  ${YELLOW}Secrets (optionnel) :${NC}"
  echo ""
  echo "    mkdir -p $SECRETS_DIR"
  echo "    cp $BRAIN_ROOT/MYSECRETS.example $MYSECRETS"
  echo "    → Editer et remplir les valeurs (DB, JWT, API keys...)"
  echo ""
  echo "    Le brain fonctionne sans, mais les sessions deploy/secrets"
  echo "    seront bloquées tant que MYSECRETS est absent."
fi

# ── Git hooks ────────────────────────────────────────────────────────────────
if [[ -d "$BRAIN_ROOT/.git" ]]; then
  bash "$BRAIN_ROOT/scripts/install-brain-hooks.sh" 2>/dev/null || true
fi

echo ""
echo "  brain : $BRAIN_ROOT"
echo "  nom   : $BRAIN_NAME"
echo ""
echo "  Prochaines étapes :"
echo ""
echo "    1. cd $BRAIN_ROOT"
echo "    2. bash scripts/brain-engine.sh start"
echo "    3. claude → brain boot"
echo ""
echo "  Sauvegarder ton brain (recommandé) :"
echo "    gh repo create $BRAIN_NAME --private --source=$BRAIN_ROOT --push"
echo ""
