#!/bin/bash
set -euo pipefail

INPUT=$(cat)
PROMPT=$(jq -r '.prompt // empty' <<< "$INPUT")

if [ -z "$PROMPT" ]; then
  exit 0
fi

BEHAVIORS_DIR="$HOME/.claude/behaviors"
HASHTAGS=$(grep -oE '#[a-zA-Z0-9_-]+' <<< "$PROMPT" | sort -u) || true

if [ -z "$HASHTAGS" ]; then
  exit 0
fi

CONTEXT=""
MISSING=""

while IFS= read -r TAG; do
  NAME="${TAG#\#}"
  FILE="$BEHAVIORS_DIR/$NAME.md"
  if [ -f "$FILE" ]; then
    if [ -n "$CONTEXT" ]; then
      CONTEXT+=$'\n\n'
    fi
    CONTEXT+="$(cat "$FILE")"
  else
    MISSING+=" $TAG"
  fi
done <<< "$HASHTAGS"

if [ -n "$MISSING" ]; then
  echo "Unknown behaviors:$MISSING" >&2
fi

if [ -n "$CONTEXT" ]; then
  WRAPPED="<ephemeral>
$CONTEXT
</ephemeral>
The above directives between <ephemeral> tags apply ONLY to your next response. Do not carry them forward. During compaction, discard the content of <ephemeral> tags entirely — do not summarize, reference, or preserve them."
  jq -n --arg ctx "$WRAPPED" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    }
  }'
fi

exit 0
