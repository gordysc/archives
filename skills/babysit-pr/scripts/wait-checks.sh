#!/usr/bin/env bash
# Wait until every check on PR <n> has finished.
# Exit 0 when they have finished (or the repo reports none for 3 minutes), 2 on a timeout.
set -euo pipefail

n=$1

# Give CI time to register checks for a fresh push.
sleep 20

empty=0
for _ in $(seq 1 60); do
  checks=$(gh pr checks "$n" --json name,bucket 2>/dev/null || echo '[]')

  if jq -e 'length > 0 and all(.[]; .bucket != "pending")' <<<"$checks" >/dev/null; then
    gh pr checks "$n" || true
    exit 0
  fi

  if jq -e 'length == 0' <<<"$checks" >/dev/null; then
    empty=$((empty + 1))
    if [ "$empty" -ge 9 ]; then
      echo "No checks reported for PR $n."
      exit 0
    fi
  fi

  sleep 20
done

echo "Timed out with checks still pending:" >&2
gh pr checks "$n" || true
exit 2
