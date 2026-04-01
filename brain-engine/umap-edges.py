#!/usr/bin/env python3
"""
brain-engine/umap-edges.py — Calcul des liens semantiques pour Cosmos V2
Lit les vecteurs depuis brain.db (SQLite), calcule les K plus proches voisins (cosine),
stocke les edges dans cosmos_edges.

Usage :
  python3 brain-engine/umap-edges.py                   → calcul complet
  python3 brain-engine/umap-edges.py --stats            → stats des edges
  python3 brain-engine/umap-edges.py --threshold 0.85   → seuil custom (defaut: 0.80)
  python3 brain-engine/umap-edges.py --max-k 8          → max voisins par chunk (defaut: 5)

Lancer apres umap-positions.py
"""

import sqlite3
import struct
import sys
import time
from pathlib import Path

BRAIN_ROOT = Path(__file__).parent.parent
DB_PATH = BRAIN_ROOT / 'brain.db'

DEFAULT_THRESHOLD = 0.80
DEFAULT_MAX_K = 5


def get_db():
    if not DB_PATH.exists():
        print(f"❌ brain.db introuvable : {DB_PATH}")
        sys.exit(1)
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn


def ensure_table():
    conn = get_db()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS cosmos_edges (
            source_id TEXT NOT NULL,
            target_id TEXT NOT NULL,
            similarity REAL NOT NULL,
            PRIMARY KEY (source_id, target_id)
        )
    """)
    conn.commit()
    conn.close()


def load_vectors():
    conn = get_db()
    rows = conn.execute(
        "SELECT chunk_id, vector, filepath FROM embeddings "
        "WHERE vector IS NOT NULL AND x IS NOT NULL"
    ).fetchall()
    conn.close()
    ids = []
    vectors = []
    filepaths = []
    for row in rows:
        blob = row['vector']
        if blob is None:
            continue
        vec = struct.unpack(f"{len(blob)//4}f", blob)
        ids.append(row['chunk_id'])
        vectors.append(vec)
        filepaths.append(row['filepath'])
    return ids, vectors, filepaths


def compute_edges(ids, vectors, filepaths, threshold, max_k):
    import numpy as np

    X = np.array(vectors, dtype=np.float32)
    n = X.shape[0]
    print(f"Edges : {n} vecteurs, seuil={threshold}, max_k={max_k}")

    norms = np.linalg.norm(X, axis=1, keepdims=True)
    norms[norms == 0] = 1
    X_norm = X / norms

    edges = []
    t0 = time.time()

    batch_size = 500
    for start in range(0, n, batch_size):
        end = min(start + batch_size, n)
        sim_matrix = X_norm[start:end] @ X_norm.T

        for i_local in range(end - start):
            i_global = start + i_local
            sims = sim_matrix[i_local]
            top_indices = sims.argsort()[::-1]

            count = 0
            for j in top_indices:
                if j == i_global:
                    continue
                if sims[j] < threshold:
                    break
                if filepaths[i_global] == filepaths[j]:
                    continue
                edges.append((ids[i_global], ids[j], float(sims[j])))
                count += 1
                if count >= max_k:
                    break

    dt = time.time() - t0
    print(f"Edges calcules : {len(edges)} en {dt:.1f}s")
    return edges


def store_edges(edges):
    conn = get_db()
    conn.execute("DELETE FROM cosmos_edges")
    conn.executemany(
        "INSERT OR REPLACE INTO cosmos_edges (source_id, target_id, similarity) VALUES (?, ?, ?)",
        edges,
    )
    conn.commit()
    conn.close()
    print(f"Edges stockes : {len(edges)}")


def show_stats():
    conn = get_db()
    try:
        cnt = conn.execute("SELECT COUNT(*) FROM cosmos_edges").fetchone()[0]
        print(f"Cosmos edges : {cnt}")
        if cnt > 0:
            row = conn.execute(
                "SELECT MIN(similarity), AVG(similarity), MAX(similarity) FROM cosmos_edges"
            ).fetchone()
            print(f"Similarity : min={row[0]:.3f} avg={row[1]:.3f} max={row[2]:.3f}")
    except Exception as e:
        print(f"cosmos_edges : {e}")
    conn.close()


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--stats", action="store_true")
    parser.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    parser.add_argument("--max-k", type=int, default=DEFAULT_MAX_K)
    args = parser.parse_args()

    if args.stats:
        show_stats()
        sys.exit(0)

    ensure_table()
    ids, vectors, filepaths = load_vectors()
    if len(vectors) < 5:
        print(f"Pas assez de vecteurs positionnes ({len(vectors)}) — lancer umap-positions.py d'abord")
        sys.exit(0)

    edges = compute_edges(ids, vectors, filepaths, args.threshold, args.max_k)
    store_edges(edges)
    show_stats()
