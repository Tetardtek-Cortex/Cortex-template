#!/usr/bin/env bash
# bsi-claim.sh — Open/close claims dans brain.db (SQLite)
#
# Usage :
#   bsi-claim.sh open  <sess_id> [--scope X] [--type X] [--zone X] [--mode X] [--project X] [--story "X"]
#   bsi-claim.sh close <sess_id> [--result X] [--energy X] [--intention X] [--tags X] [--deliverables X]
#   bsi-claim.sh close-stale          → ferme tous les claims open > TTL (4h par défaut)
#   bsi-claim.sh exists <sess_id>     → exit 0 si open, exit 1 sinon
#   bsi-claim.sh init                 → vérifie brain.db + table claims
#
# Backend : SQLite (brain.db) — zéro dépendance externe.
# Auto-init : si brain.db absent → créé automatiquement depuis schema.sql.
#
# Exit codes :
#   0 = succès
#   1 = argument manquant / erreur usage
#   2 = erreur Python / DB

set -euo pipefail

BRAIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB_PATH="$BRAIN_ROOT/brain.db"
SCHEMA_PATH="$BRAIN_ROOT/brain-engine/schema.sql"
CMD="${1:-help}"
shift || true

python3 - "$DB_PATH" "$SCHEMA_PATH" "$CMD" "$@" <<'PYEOF'
import sqlite3
import sys
import os
from datetime import datetime, timezone, timedelta

db_path = sys.argv[1]
schema_path = sys.argv[2]
cmd = sys.argv[3] if len(sys.argv) > 3 else "help"
args = sys.argv[4:]

def get_db():
    """Get a SQLite connection, auto-init if needed."""
    need_init = not os.path.exists(db_path)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")
    if need_init:
        if os.path.exists(schema_path):
            conn.executescript(open(schema_path).read())
        else:
            # Minimal claims table if schema.sql absent
            conn.execute("""
                CREATE TABLE IF NOT EXISTS claims (
                    sess_id TEXT PRIMARY KEY, type TEXT NOT NULL, scope TEXT NOT NULL,
                    status TEXT NOT NULL DEFAULT 'open', opened_at TEXT NOT NULL,
                    closed_at TEXT, zone TEXT, mode TEXT, story_angle TEXT,
                    handoff_level TEXT, ttl_hours INTEGER DEFAULT 4, expires_at TEXT,
                    instance TEXT, result_status TEXT, project TEXT,
                    energy TEXT, intention TEXT, tags TEXT, deliverables TEXT,
                    duration_min INTEGER
                )
            """)
        conn.commit()
    return conn

def esc(val):
    """Return value for parameterized queries."""
    return val

def parse_opts(args):
    """Parse --key value pairs from args."""
    opts = {}
    i = 0
    while i < len(args):
        if args[i].startswith("--") and i + 1 < len(args):
            opts[args[i][2:]] = args[i + 1]
            i += 2
        else:
            i += 1
    return opts

def cmd_open():
    if not args:
        print("❌ Usage: bsi-claim.sh open <sess_id> [--scope X] [--type X] ...", file=sys.stderr)
        sys.exit(1)

    sess_id = args[0]
    opts = parse_opts(args[1:])
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
    expires = (datetime.now(timezone.utc) + timedelta(hours=4)).strftime("%Y-%m-%d %H:%M:%S")

    conn = get_db()

    # Vérifier si déjà open
    row = conn.execute("SELECT status FROM claims WHERE sess_id = ?", (sess_id,)).fetchone()
    if row and row["status"] == "open":
        print(f"⚠️  Claim déjà ouvert : {sess_id}")
        conn.close()
        sys.exit(0)

    new_scope = opts.get("scope", "brain/")

    # Scope overlap detection — BSI mutex
    open_claims = conn.execute(
        "SELECT sess_id, scope, zone FROM claims WHERE status = 'open'"
    ).fetchall()

    for oc in open_claims:
        oc_scope = oc["scope"] or ""
        if (new_scope.startswith(oc_scope) or oc_scope.startswith(new_scope)
                or new_scope == oc_scope):
            oc_zone = oc["zone"] or "project"
            if oc_zone == "kernel" or opts.get("zone") == "kernel":
                print(f"🔴 SCOPE CONFLICT — zone kernel verrouillée")
                print(f"   Existant : {oc['sess_id']} → scope: {oc_scope} (zone: {oc_zone})")
                print(f"   Demandé  : {sess_id} → scope: {new_scope}")
                conn.close()
                sys.exit(1)
            print(f"⚠️  SCOPE OVERLAP détecté")
            print(f"   Existant : {oc['sess_id']} → scope: {oc_scope}")
            print(f"   Demandé  : {sess_id} → scope: {new_scope}")

    conn.execute("""
        INSERT OR REPLACE INTO claims
            (sess_id, type, scope, status, opened_at, zone, mode, story_angle,
             handoff_level, instance, ttl_hours, expires_at, project)
        VALUES (?, ?, ?, 'open', ?, ?, ?, ?, ?, ?, 4, ?, ?)
    """, (
        sess_id,
        opts.get("type", "navigate"),
        new_scope,
        now,
        opts.get("zone", "project"),
        opts.get("mode"),
        opts.get("story"),
        opts.get("handoff", "0"),
        opts.get("instance"),
        expires,
        opts.get("project"),
    ))
    conn.commit()
    conn.close()

    project_info = f" (project: {opts['project']})" if opts.get("project") else ""
    print(f"✅ Claim ouvert : {sess_id}{project_info}")

def cmd_close():
    if not args:
        print("❌ Usage: bsi-claim.sh close <sess_id> [--result X]", file=sys.stderr)
        sys.exit(1)

    sess_id = args[0]
    opts = parse_opts(args[1:])
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    conn = get_db()

    row = conn.execute(
        "SELECT sess_id, opened_at FROM claims WHERE sess_id = ? AND status = 'open'",
        (sess_id,)
    ).fetchone()

    if not row:
        print(f"⚠️  Claim non trouvé ou déjà fermé : {sess_id}")
        conn.close()
        return

    # Calculer duration_min
    duration = None
    if row["opened_at"]:
        try:
            opened = datetime.strptime(row["opened_at"], "%Y-%m-%d %H:%M:%S")
            closed = datetime.strptime(now, "%Y-%m-%d %H:%M:%S")
            duration = int((closed - opened).total_seconds() / 60)
        except Exception:
            pass

    conn.execute("""
        UPDATE claims
        SET status = 'closed', closed_at = ?, result_status = ?,
            duration_min = ?, energy = ?, intention = ?, tags = ?, deliverables = ?
        WHERE sess_id = ? AND status = 'open'
    """, (
        now,
        opts.get("result", "success"),
        duration,
        opts.get("energy"),
        opts.get("intention"),
        opts.get("tags"),
        opts.get("deliverables"),
        sess_id,
    ))
    conn.commit()
    conn.close()
    print(f"✅ Claim fermé : {sess_id}")

def cmd_close_stale():
    conn = get_db()

    stale = conn.execute("""
        SELECT sess_id FROM claims
        WHERE status = 'open'
          AND julianday('now') > julianday(opened_at, '+' || COALESCE(ttl_hours, 4) || ' hours')
    """).fetchall()

    if not stale:
        print("ℹ️  Aucun claim stale")
        conn.close()
        return

    conn.execute("""
        UPDATE claims
        SET status = 'closed', closed_at = datetime('now'), result_status = 'stale-auto-closed'
        WHERE status = 'open'
          AND julianday('now') > julianday(opened_at, '+' || COALESCE(ttl_hours, 4) || ' hours')
    """)
    conn.commit()
    n = len(stale)
    conn.close()
    print(f"✅ {n} claim(s) stale fermé(s)")

def cmd_exists():
    if not args:
        print("❌ Usage: bsi-claim.sh exists <sess_id>", file=sys.stderr)
        sys.exit(1)

    conn = get_db()
    row = conn.execute(
        "SELECT status FROM claims WHERE sess_id = ? AND status = 'open'",
        (args[0],)
    ).fetchone()
    conn.close()
    sys.exit(0 if row else 1)

def cmd_init():
    conn = get_db()
    row = conn.execute("SELECT COUNT(*) as n FROM claims").fetchone()
    n = row["n"] if row else 0
    conn.close()
    print(f"✅ brain.db prêt — table claims ({n} entrées)")

def cmd_help():
    print("Usage: bsi-claim.sh <open|close|close-stale|exists|init>")
    print("  open  <sess_id> [--scope X] [--type X] [--zone X] [--mode X] [--project X]")
    print("  close <sess_id> [--result X] [--energy X] [--tags X] [--deliverables X]")
    print("  close-stale       — ferme les claims open > TTL")
    print("  exists <sess_id>  — exit 0 si open, exit 1 sinon")
    print("  init              — vérifie brain.db + table claims")

commands = {
    "open": cmd_open,
    "close": cmd_close,
    "close-stale": cmd_close_stale,
    "exists": cmd_exists,
    "init": cmd_init,
    "help": cmd_help,
}

fn = commands.get(cmd, cmd_help)
fn()
PYEOF
