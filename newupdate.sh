#!/usr/bin/env bash
set -euo pipefail
set -x

# Paths
META_DIR="meta"
UPSTREAM_DIR="${META_DIR}/upstream"
LAUNCHER_DIR="${META_DIR}/launcher"
CACHE_DIR="${CACHE_DIRECTORY:-./.cache/meta}"

mkdir -p "$UPSTREAM_DIR" "$LAUNCHER_DIR" "$CACHE_DIR"

export META_CACHE_DIR="$CACHE_DIR"
export META_UPSTREAM_DIR="$UPSTREAM_DIR"
export META_LAUNCHER_DIR="$LAUNCHER_DIR"

currentDate=$(date -Iseconds)

# -------- upstream (raw) --------
python -m meta.run.update_mojang
python -m meta.run.update_forge
python -m meta.run.update_neoforge
python -m meta.run.update_fabric
python -m meta.run.update_quilt
python -m meta.run.update_liteloader
python -m meta.run.update_java

# -------- launcher (generated) --------
python -m meta.run.generate_mojang
python -m meta.run.generate_forge
python -m meta.run.generate_neoforge
python -m meta.run.generate_fabric
python -m meta.run.generate_quilt
python -m meta.run.generate_liteloader
python -m meta.run.generate_java
python -m meta.run.index

# -------- commit only if meta changed --------
if git status --porcelain meta/ | grep .; then
  git add meta/
  git commit -m "meta: automated update (${currentDate})"
  git push
else
  echo "No meta changes"
fi
