#!/usr/bin/env bash
# Print the unresolved review threads on PR <n> as JSON, or [] when there are none.
# Pass each thread's id and replyTo to resolve-thread.sh.
set -euo pipefail

n=$1
read -r owner repo < <(gh repo view --json owner,name -q '"\(.owner.login) \(.name)"')

gh api graphql -f owner="$owner" -f repo="$repo" -F n="$n" -f query='
  query($owner: String!, $repo: String!, $n: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $n) {
        reviewThreads(first: 100) {
          nodes {
            id isResolved path line
            comments(first: 20) { nodes { databaseId author { login } body } }
          }
        }
      }
    }
  }' \
  | jq '[.data.repository.pullRequest.reviewThreads.nodes[]
      | select(.isResolved | not)
      | {id, path, line,
         replyTo: .comments.nodes[0].databaseId,
         comments: [.comments.nodes[] | {author: .author.login, body}]}]'
