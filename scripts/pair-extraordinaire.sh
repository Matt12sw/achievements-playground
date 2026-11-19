#!/usr/bin/env bash
# Pair Extraordinaire Achievement Helper (Linux / macOS)
# Creates a branch, commits with a Git Co-authored-by trailer, and pushes to origin.
# Usage: ./pair-extraordinaire.sh "<COAUTHOR_NAME>" "<COAUTHOR_EMAIL>" [BRANCH_NAME]

set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 \"<COAUTHOR_NAME>\" \"<COAUTHOR_EMAIL>\" [BRANCH_NAME]"
  exit 1
fi

COAUTHOR_NAME="$1"
COAUTHOR_EMAIL="$2"
BRANCH_NAME="${3:-feature/pair-achievement-$(date +%s)}"

echo "Creating branch ${BRANCH_NAME}..."
git checkout -b "${BRANCH_NAME}"

FILE_PATH="pair-collaboration.txt"
echo "Co-author contribution timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "${FILE_PATH}"
git add "${FILE_PATH}"

git commit -m "Add co-authored contribution

Collaboration with ${COAUTHOR_NAME}.

Co-authored-by: ${COAUTHOR_NAME} <${COAUTHOR_EMAIL}>"

echo "Pushing branch ${BRANCH_NAME} to origin..."
git push -u origin "${BRANCH_NAME}"

echo ""
echo "Branch pushed! Next steps:"
echo "1. Open a Pull Request from '${BRANCH_NAME}' into your default branch (main)."
echo "2. Merge the Pull Request using a standard merge commit."
echo "3. Both the author and co-author will qualify for Pair Extraordinaire."
