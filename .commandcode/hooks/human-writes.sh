#!/usr/bin/env bash
set -euo pipefail

FLAG_FILE=/tmp/commandcode_first_tool_flag
FLAG_VALUE=$(cat "$FLAG_FILE" 2>/dev/null || true)

if [[ "$FLAG_VALUE" == "0" ]]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    BRANCH=$(git branch --show-current)
    HUMAN_CHANGES=$(git status --short)

    if [[ -n "$HUMAN_CHANGES" ]]; then
      git add -A
      git commit -m "human changes" >/dev/null
      SUMMARY="Committed human changes on session branch: ${BRANCH}."
      SUMMARY+=$'\n'"Human changes:"$'\n'"${HUMAN_CHANGES}"
    else
      SUMMARY="No human changes were present on session branch: ${BRANCH}."
    fi
  else
    SUMMARY="No Git repository was available to commit human changes."
  fi

  printf '1' > "$FLAG_FILE"

  jq -n --arg ctx "$SUMMARY" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: $ctx
    }
  }'
else
  jq -n '{}'
fi
