#!/usr/bin/env bash
# key-guardian.sh — Valide la Brain API Key au boot, écrit feature_set dans brain-compose.local.yml
# Appelé par helloWorld step 1.5 — exit 0 toujours, jamais bloquer le boot
# Usage : bash scripts/key-guardian.sh [BRAIN_ROOT]

BRAIN_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

python3 - "$BRAIN_ROOT" << 'PYEOF'
import sys, json, subprocess
from pathlib import Path
from datetime import datetime, timezone, timedelta

BRAIN_ROOT   = Path(sys.argv[1])
LOCAL_YML    = BRAIN_ROOT / "brain-compose.local.yml"
VALIDATE_URL = "https://keys.tetardtek.com/validate"
CACHE_TTL_H  = 24

try:
    import yaml
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "pyyaml", "-q"],
                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    import yaml

def now_iso():
    return datetime.now(timezone.utc).isoformat()

def load_yaml(path):
    try:
        return yaml.safe_load(path.read_text()) or {}
    except Exception:
        return {}

def save_local(data):
    LOCAL_YML.write_text(yaml.dump(data, allow_unicode=True, default_flow_style=False))

def write_feature_set(local, fs):
    instances = local.get("instances", {})
    name = next(iter(instances), None)
    if not name:
        return
    instances[name].setdefault("feature_set", {}).update(fs)

TIER_AGENTS = {
    "free": "fondamentaux",
    "featured": "fondamentaux, coach, progression",
    "pro": "fondamentaux, coach, progression, metier",
    "full": "*",
    "owner": "*",
}

TIER_CONTEXTS = {
    "free": "brain, handoff",
    "featured": "brain, handoff, coach, capital",
    "pro": "brain, handoff, coach, capital, refacto, migration",
    "full": "*",
    "owner": "*",
}

def tier_free():
    return {
        "tier": "free", "agents": TIER_AGENTS["free"], "contexts": TIER_CONTEXTS["free"],
        "distillation": False, "last_validated_at": None,
        "expires_at": None, "grace_until": None,
    }

def run():
    # 1. Lire brain_api_key depuis brain-compose.local.yml (instance active)
    local = load_yaml(LOCAL_YML)
    instances = local.get("instances", {})
    name = next(iter(instances), None)
    inst = instances.get(name, {}) if name else {}
    api_key = inst.get("brain_api_key") or ""
    if not api_key or api_key == "null":
        sys.exit(0)  # tier: free silencieux

    # 2. Vérifier cache (< 24h) — bypass si la clé a changé
    instances = local.get("instances", {})
    name = next(iter(instances), None)
    cached_fs = (instances.get(name) or {}).get("feature_set", {}) if name else {}
    cached_key_prefix = cached_fs.get("validated_key_prefix", "")
    current_key_prefix = api_key[:12] if len(api_key) > 12 else api_key
    key_changed = cached_key_prefix != current_key_prefix
    last_str  = cached_fs.get("last_validated_at")
    if last_str and not key_changed:
        try:
            last_dt = datetime.fromisoformat(str(last_str))
            if (datetime.now(timezone.utc) - last_dt) < timedelta(hours=CACHE_TTL_H):
                sys.exit(0)  # cache valide, même clé
        except Exception:
            pass

    # 3. POST /validate (public — pas de secret requis)
    try:
        result = subprocess.run(
            ["curl", "-s", "--max-time", "3",
             "-H", "Content-Type: application/json",
             "-d", json.dumps({"key": api_key}),
             VALIDATE_URL],
            capture_output=True, text=True, timeout=5,
        )
        resp = json.loads(result.stdout)
    except Exception:
        resp = None

    if resp is None:
        # VPS unreachable — grace period
        grace_str = cached_fs.get("grace_until")
        last_str2 = cached_fs.get("last_validated_at")
        if not last_str2:
            sys.exit(0)  # pas de cache → free silencieux
        if not grace_str:
            # Première fois unreachable — écrire grace_until
            try:
                last_dt2 = datetime.fromisoformat(str(last_str2))
                grace = (last_dt2 + timedelta(hours=72)).isoformat()
                cached_fs["grace_until"] = grace
                write_feature_set(local, cached_fs)
                save_local(local)
            except Exception:
                pass
        else:
            try:
                grace_dt = datetime.fromisoformat(str(grace_str))
                if datetime.now(timezone.utc) > grace_dt:
                    # Grace expirée — downgrade free
                    write_feature_set(local, tier_free())
                    save_local(local)
            except Exception:
                pass
        sys.exit(0)

    if not resp.get("valid"):
        # Clé invalide
        write_feature_set(local, tier_free())
        save_local(local)
        print("[key-guardian] Clé invalide — tier: free", file=sys.stderr)
        sys.exit(0)

    # 4. Succès — écrire feature_set
    tier = resp.get("tier", "free")
    fs = {
        "tier":              tier,
        "agents":            TIER_AGENTS.get(tier, TIER_AGENTS["free"]),
        "contexts":          TIER_CONTEXTS.get(tier, TIER_CONTEXTS["free"]),
        "distillation":      tier in ("full", "featured"),
        "last_validated_at": now_iso(),
        "expires_at":        resp.get("expires_at"),
        "grace_until":       None,
        "validated_key_prefix": current_key_prefix,
    }
    write_feature_set(local, fs)
    save_local(local)
    sys.exit(0)

run()
PYEOF
