#!/usr/bin/env bash
# Full reset of one character's learned state, the owner's standing preference
# after a tone or personality change: authored card, .env and Telegram pairing
# survive; conversation, memory, goals, journal, traces and artifacts do not.
#
#   deploy/claw/reset-reyna.sh [character-id] [card.png]
#
# Talks to the running host on loopback (no token needed there). The purge is
# the switchboard's own two-step: a challenge, then the delete. Then the card
# is imported fresh and approved, which also starts her.
set -euo pipefail

ID="${1:-reyna}"
CARD="${2:-data/cards/reyna.png}"
PORT="${PORT:-8768}"
BASE="http://127.0.0.1:${PORT}"

cd "$(dirname "$0")/../.."
[ -f "$CARD" ] || { echo "no card at $CARD" >&2; exit 1; }

if curl -sf "$BASE/api/characters" | grep -q "\"id\": *\"$ID\""; then
  challenge=$(curl -sf -X POST "$BASE/api/characters/$ID/purge/prepare" | python3 -c 'import json,sys;print(json.load(sys.stdin)["challenge"])')
  curl -sf -X DELETE "$BASE/api/characters/$ID/purge" -H 'Content-Type: application/json' \
       -d "{\"challenge\": \"$challenge\"}" >/dev/null
  echo "purged $ID"
fi

curl -sf -X POST "$BASE/api/characters/import" -F "file=@$CARD" >/dev/null
echo "imported $CARD"
curl -sf -X POST "$BASE/api/characters/$ID/approve" | python3 -c 'import json,sys;d=json.load(sys.stdin);print("approved:", d["character"]["id"], "| started:", d["started"], "| error:", d["error"])'
