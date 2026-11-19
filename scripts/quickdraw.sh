#!/usr/bin/env bash
# Quickdraw Achievement Helper (Linux / macOS)
# Opens an issue and closes it within seconds (< 5 minutes).
# Usage: ./quickdraw.sh <REPO_OWNER> <REPO_NAME> <GITHUB_TOKEN>

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <REPO_OWNER> <REPO_NAME> <GITHUB_TOKEN>"
  exit 1
fi

OWNER="$1"
REPO="$2"
TOKEN="$3"

echo "Creating temporary issue in ${OWNER}/${REPO}..."
ISSUE_NUMBER=$(curl -sS -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${OWNER}/${REPO}/issues" \
  -d '{"title":"Quickdraw Achievement Trigger","body":"Automatically created and closed within 5 minutes."}' \
  | grep -o '"number": *[0-9]*' | head -n 1 | grep -o '[0-9]*')

if [ -z "${ISSUE_NUMBER}" ]; then
  echo "Failed to create issue. Check your token permissions (issues:write / repo)."
  exit 1
fi

echo "Issue #${ISSUE_NUMBER} created. Waiting 3 seconds..."
sleep 3

echo "Closing issue #${ISSUE_NUMBER}..."
curl -sS -X PATCH \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${OWNER}/${REPO}/issues/${ISSUE_NUMBER}" \
  -d '{"state":"closed","state_reason":"completed"}' > /dev/null

echo "Done! Issue #${ISSUE_NUMBER} closed in under 5 minutes."
