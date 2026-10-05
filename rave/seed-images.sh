#!/usr/bin/env bash
#
# Upload the placeholder product images in rave/seed/images/ to the images R2 bucket
# under the keys rave/seed.sql expects (products/seed-<slug>.webp).
#
#   bash rave/seed-images.sh            # LOCAL R2 (default; safe)
#   bash rave/seed-images.sh --remote   # PRODUCTION bucket — touches real Cloudflare
#                                     # resources; run only after provisioning.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUCKET="ravecreations-store-images"
TARGET="--local"
PERSIST="--local --persist-to .wrangler/state"
if [[ "${1:-}" == "--remote" ]]; then TARGET="--remote"; PERSIST="--remote"; fi

shopt -s nullglob
files=(rave/seed/images/*.webp)
[[ ${#files[@]} -gt 0 ]] || { echo "✗ no rave/seed/images/*.webp — run: node rave/gen-seed-images.mjs" >&2; exit 1; }

for f in "${files[@]}"; do
  name="$(basename "$f")"
  echo "▸ ${BUCKET}/products/seed-${name} (${TARGET#--})"
  npx --yes wrangler r2 object put "${BUCKET}/products/seed-${name}" \
    --file "$f" --content-type image/webp \
    --cache-control "public, max-age=31536000, immutable" \
    $PERSIST >/dev/null
done
echo "✓ uploaded ${#files[@]} images"
