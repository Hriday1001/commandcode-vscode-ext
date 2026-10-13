#!/usr/bin/env bash
set -euo pipefail

HOOK_INPUT=$(cat)
# SESSION_ID=$(jq -r '.session_id // empty' <<<"$HOOK_INPUT" 2>/dev/null || true)
# if [ -n "$SESSION_ID" ]; then
#   SESSION_ID=$(tr -cs 'A-Za-z0-9._-' '-' <<<"$SESSION_ID" | sed 's/^-*//; s/-*$//')
#   SESSION_BRANCH="session-${SESSION_ID:-session}"
# else
#   SESSION_BRANCH="session"
# fi

SESSION_BRANCH="session"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -q
fi

if git show-ref --verify --quiet "refs/heads/${SESSION_BRANCH}"; then
  git switch --quiet "$SESSION_BRANCH"
else
  git switch --quiet -c "$SESSION_BRANCH"
fi

BRANCH=$(git branch --show-current)
CHANGES=$(git status --porcelain | head -20)

SUMMARY="Switched to session branch: ${BRANCH}."
if [ -n "$CHANGES" ]; then
  SUMMARY="${SUMMARY}"$'\n'"Uncommitted changes:"$'\n'"${CHANGES}"
else
  SUMMARY="${SUMMARY} Working tree is clean."
fi

printf '0' > /tmp/commandcode_first_tool_flag

jq -n --arg ctx "$SUMMARY" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
