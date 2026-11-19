#!/usr/bin/env bash
# Pull Shark Achievement Helper (Linux / macOS)
# Creates and merges a configurable batch of lightweight PRs via the GitHub REST API.
# Requires: curl, jq
# Usage: ./pull-shark.sh <REPO_OWNER> <REPO_NAME> <GITHUB_TOKEN> [COUNT]

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <REPO_OWNER> <REPO_NAME> <GITHUB_TOKEN> [COUNT]"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required. Install it via apt, brew, or pacman."
  exit 1
fi

OWNER="$1"
REPO="$2"
TOKEN="$3"
COUNT="${4:-5}"
API="https://api.github.com/repos/${OWNER}/${REPO}"

auth_curl() {
  curl -sS \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$@"
}

for i in $(seq 1 "${COUNT}"); do
  echo "[${i}/${COUNT}] Processing PR..."

  PARENT_SHA=$(auth_curl "${API}/git/ref/heads/main" | jq -r '.object.sha')
  BLOB_SHA=$(auth_curl -X POST "${API}/git/blobs" \
    -d "{\"content\":\"Pull Shark batch item #${i} - $(date -u +%s)\",\"encoding\":\"utf-8\"}" \
    | jq -r '.sha')

  TREE_SHA=$(auth_curl -X POST "${API}/git/trees" \
    -d "{\"base_tree\":\"${PARENT_SHA}\",\"tree\":[{\"path\":\"prs/bash-batch-${i}-$(date +%s).txt\",\"mode\":\"100644\",\"type\":\"blob\",\"sha\":\"${BLOB_SHA}\"}]}" \
    | jq -r '.sha')

  COMMIT_SHA=$(auth_curl -X POST "${API}/git/commits" \
    -d "{\"message\":\"Pull Shark contribution #${i}\",\"tree\":\"${TREE_SHA}\",\"parents\":[\"${PARENT_SHA}\"]}" \
    | jq -r '.sha')

  BRANCH="ps-bash-${i}-$(date +%s)"
  auth_curl -X POST "${API}/git/refs" \
    -d "{\"ref\":\"refs/heads/${BRANCH}\",\"sha\":\"${COMMIT_SHA}\"}" > /dev/null

  PR_NUMBER=$(auth_curl -X POST "${API}/pulls" \
    -d "{\"title\":\"Pull Shark batch #${i}\",\"head\":\"${BRANCH}\",\"base\":\"main\"}" \
    | jq -r '.number')

  sleep 1

  auth_curl -X PUT "${API}/pulls/${PR_NUMBER}/merge" \
    -d '{"merge_method":"merge"}' > /dev/null

  auth_curl -X DELETE "${API}/git/refs/heads/${BRANCH}" > /dev/null || true

  echo "[${i}/${COUNT}] Merged PR #${PR_NUMBER}!"
  sleep 1
done

echo "Batch complete!"
