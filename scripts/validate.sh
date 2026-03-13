#!/usr/bin/env bash
set -euo pipefail

# Standard Conventional Commits types
BASE_TYPES="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"

# Append extra types if provided
if [[ -n "${EXTRA_TYPES:-}" ]]; then
  EXTRA=$(echo "$EXTRA_TYPES" | tr ',' '|' | tr -d ' ')
  ALL_TYPES="${BASE_TYPES}|${EXTRA}"
else
  ALL_TYPES="${BASE_TYPES}"
fi

# Build scope pattern
if [[ -n "${ALLOWED_SCOPES:-}" ]]; then
  SCOPE_LIST=$(echo "$ALLOWED_SCOPES" | tr ',' '|' | tr -d ' ')
  SCOPE_PATTERN="(\($SCOPE_LIST\))?"
else
  SCOPE_PATTERN="(\([a-zA-Z0-9_/.-]+\))?"
fi

PATTERN="^(${ALL_TYPES})${SCOPE_PATTERN}(!)?:[[:space:]].+"

# Collect commits: PR context vs push context
if [[ -n "${GITHUB_EVENT_NAME:-}" && "$GITHUB_EVENT_NAME" == "pull_request" ]]; then
  COMMITS=$(gh pr view "$GITHUB_REF_NAME" --json commits --jq '.commits[].messageHeadline' 2>/dev/null ||             git log --format="%s" origin/${GITHUB_BASE_REF}..HEAD)
else
  COMMITS=$(git log --format="%s" -n 20)
fi

INVALID=()
VALID_COUNT=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Conventional Commits Validator"
echo "  Pattern: type(scope)!: description"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

while IFS= read -r msg; do
  [[ -z "$msg" ]] && continue
  if echo "$msg" | grep -qP "$PATTERN"; then
    echo "✅  $msg"
    VALID_COUNT=$((VALID_COUNT + 1))
  else
    echo "❌  $msg"
    INVALID+=("$msg")
  fi
done <<< "$COMMITS"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Valid: ${VALID_COUNT} | Invalid: ${#INVALID[@]}"

# Set outputs
INVALID_JSON=$(printf '%s
' "${INVALID[@]}" | jq -R . | jq -s . 2>/dev/null || echo "[]")
if [[ ${#INVALID[@]} -eq 0 ]]; then
  echo "valid=true" >> "$GITHUB_OUTPUT"
  echo "invalid_commits=[]" >> "$GITHUB_OUTPUT"
  echo ""
  echo "🎉 All commits follow Conventional Commits!"
else
  echo "valid=false" >> "$GITHUB_OUTPUT"
  echo "invalid_commits=${INVALID_JSON}" >> "$GITHUB_OUTPUT"
  echo ""
  echo "📖 Reference: https://www.conventionalcommits.org"
  if [[ "${FAIL_ON_ERROR}" == "true" ]]; then
    exit 1
  fi
fi
