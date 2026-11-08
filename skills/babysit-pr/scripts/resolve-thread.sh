#!/usr/bin/env bash
# Reply to a review thread on PR <n>, then resolve it.
# Usage: resolve-thread.sh <n> <thread-id> <reply-to> <body>
set -euo pipefail

n=$1 thread=$2 reply_to=$3 body=$4
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)

gh api "repos/$repo/pulls/$n/comments/$reply_to/replies" -f body="$body" >/dev/null

gh api graphql -f id="$thread" -f query='
  mutation($id: ID!) {
    resolveReviewThread(input: {threadId: $id}) { thread { isResolved } }
  }' \
  -q '"resolved: \(.data.resolveReviewThread.thread.isResolved)"'
