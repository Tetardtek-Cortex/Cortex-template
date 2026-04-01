#!/usr/bin/env python3
"""
brain-engine/umap-positions.py — Calcul positions UMAP 3D pour Cosmos view
Lit les vecteurs 768D depuis brain.db (SQLite), projette en 3D, stocke x,y,z.

Usage :
  python3 brain-engine/umap-positions.py            → calcul complet
  python3 brain-engine/umap-positions.py --stats     → stats des positions
"""

import sqlite3
import struct
import sys
import time
from pathlib import Path

BRAIN_ROOT = Path(__file__).parent.parent
DB_PATH = BRAIN_ROOT / 'brain.db'


def get_db():
    if not DB_PATH.exists():
        print(f"❌ brain.db introuvable : {DB_PATH}")
        sys.exit(1)
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn


def ensure_columns():
    conn = get_db()
    existing = {row[1] for row in conn.execute("PRAGMA table_info(embeddings)")}
    for col in ("x", "y", "z"):
        if col not in existing:
            conn.execute(f"ALTER TABLE embeddings ADD COLUMN {col} REAL")
    conn.commit()
    conn.close()


def load_vectors():
    conn = get_db()
    rows = conn.execute(
        "SELECT chunk_id, vector FROM embeddings WHERE vector IS NOT NULL"
    ).fetchall()
    conn.close()
    ids = []
    vectors = []
    for row in rows:
        blob = row['vector']
        if blob is None:
            continue
        vec = struct.unpack(f"{len(blob)//4}f", blob)
        ids.append(row['chunk_id'])
        vectors.append(vec)
    return ids, vectors


def compute_umap_3d(vectors):
    import numpy as np
    import umap

    X = np.array(vectors, dtype=np.float32)
    print(f"UMAP : {X.shape[0]} vecteurs x {X.shape[1]}D → 3D")

    reducer = umap.UMAP(
        n_components=3,
        n_neighbors=15,
        min_dist=0.1,
        metric="cosine",
        random_state=42,
    )
    t0 = time.time()
    coords = reducer.fit_transform(X)
    dt = time.time() - t0
    print(f"UMAP termine en {dt:.1f}s")

    for dim in range(3):
        col = coords[:, dim]
        mn, mx = col.min(), col.max()
        if mx - mn > 0:
            coords[:, dim] = 2 * (col - mn) / (mx - mn) - 1

    return coords


def store_positions(ids, coords):
    conn = get_db()
    for i, cid in enumerate(ids):
        conn.execute(
            "UPDATE embeddings SET x = ?, y = ?, z = ? WHERE chunk_id = ?",
            (float(coords[i][0]), float(coords[i][1]), float(coords[i][2]), cid),
        )
    conn.commit()
    conn.close()
    print(f"Positions stockees : {len(ids)} chunks")


def show_stats():
    conn = get_db()
    total = conn.execute("SELECT COUNT(*) FROM embeddings WHERE vector IS NOT NULL").fetchone()[0]
    positioned = conn.execute("SELECT COUNT(*) FROM embeddings WHERE x IS NOT NULL").fetchone()[0]
    print(f"Embeddings avec vecteur : {total}")
    print(f"Embeddings avec position : {positioned}")
    if positioned > 0:
        row = conn.execute(
            "SELECT MIN(x), MAX(x), MIN(y), MAX(y), MIN(z), MAX(z) "
            "FROM embeddings WHERE x IS NOT NULL"
        ).fetchone()
        if row:
            print(f"Ranges : x[{row[0]:.2f}, {row[1]:.2f}] "
                  f"y[{row[2]:.2f}, {row[3]:.2f}] "
                  f"z[{row[4]:.2f}, {row[5]:.2f}]")
    conn.close()


if __name__ == "__main__":
    if "--stats" in sys.argv:
        show_stats()
        sys.exit(0)

    ensure_columns()
    ids, vectors = load_vectors()
    if len(vectors) < 5:
        print(f"Pas assez de vecteurs ({len(vectors)}) — minimum 5 pour UMAP")
        sys.exit(0)

    coords = compute_umap_3d(vectors)
    store_positions(ids, coords)
    show_stats()
