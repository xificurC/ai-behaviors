#!/bin/bash
set -euo pipefail

INPUT=$(cat)
PROMPT=$(jq -r '.prompt // empty' <<< "$INPUT")
SESSION_ID=$(jq -r '.chat_id // empty' <<< "$INPUT")

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Resolve symlink to find the repo
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
BEHAVIORS_DIR="$REPO_DIR/behaviors"

HASHTAGS=$(grep -oE '#[=a-zA-Z0-9_-]+' <<< "$PROMPT" | sort -u) || true

# State file for persistence across prompts
STATE_DIR="$HOME/.config/eca/.behaviors"
STATE_FILE=""
if [ -n "$SESSION_ID" ]; then
  STATE_FILE="$STATE_DIR/$SESSION_ID"
fi

if [ -z "$HASHTAGS" ]; then
  if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
    ACTIVE=$(sed 's/#op-/#=/g' < "$STATE_FILE")
    CONSTRAINTS=""
    for TAG in $ACTIVE; do
      TAG_NAME="${TAG#\#}"
      FILE="$BEHAVIORS_DIR/$TAG_NAME/prompt.md"
      if [ -f "$FILE" ]; then
        while IFS= read -r LINE; do
          [ -n "$LINE" ] && CONSTRAINTS+=$'\n'"$TAG: $LINE"
        done < <(grep -- '-- HARD CONSTRAINT' "$FILE" || true)
      fi
    done
    jq -n --arg active "$ACTIVE" --arg constraints "$CONSTRAINTS" '{
        additionalContext: ("Active: " + $active + ". HARD CONSTRAINTs in force:" + $constraints)
    }'
  fi
  exit 0
fi

# Reject multiple operating modes
MODE_COUNT=$(grep -c '^#=' <<< "$HASHTAGS") || true
if [ "$MODE_COUNT" -gt 1 ]; then
  MODE_TAGS=$(grep '^#=' <<< "$HASHTAGS" | tr '\n' ' ')
  echo "Conflict: multiple operating modes: ${MODE_TAGS%. }. Use one at a time." >&2
  exit 2
fi

# Separate mode from modifiers
MODE_TAG=$(grep '^#=' <<< "$HASHTAGS" | head -1) || true
MODE_TAG="${MODE_TAG#\#}"
MOD_TAGS=$(grep -v '^#=' <<< "$HASHTAGS") || true

# Read mode content
MODE_CONTEXT=""
MISSING=""
if [ -n "$MODE_TAG" ]; then
  FILE="$BEHAVIORS_DIR/$MODE_TAG/prompt.md"
  if [ -f "$FILE" ]; then
    MODE_CONTEXT="$(cat "$FILE")"
  else
    MISSING+=" #$MODE_TAG"
  fi
fi

# Read modifier content
MOD_CONTEXT=""
if [ -n "$MOD_TAGS" ]; then
  while IFS= read -r TAG; do
    [ -z "$TAG" ] && continue
    NAME="${TAG#\#}"
    FILE="$BEHAVIORS_DIR/$NAME/prompt.md"
    if [ -f "$FILE" ]; then
      if [ -n "$MOD_CONTEXT" ]; then
        MOD_CONTEXT+=$'\n\n'
      fi
      MOD_CONTEXT+="$(cat "$FILE")"
    else
      MISSING+=" $TAG"
    fi
  done <<< "$MOD_TAGS"
fi

if [ -n "$MISSING" ]; then
  echo "Unknown behaviors:$MISSING" >&2
fi

# Write active hashtags to state file for status line
if [ -n "$STATE_FILE" ]; then
  mkdir -p "$STATE_DIR"
  ACTIVE=""
  [ -n "$MODE_TAG" ] && [ -n "$MODE_CONTEXT" ] && ACTIVE+="#$MODE_TAG"
  if [ -n "$MOD_TAGS" ]; then
    while IFS= read -r TAG; do
      [ -z "$TAG" ] && continue
      NAME="${TAG#\#}"
      [ -f "$BEHAVIORS_DIR/$NAME/prompt.md" ] || continue
      [ -n "$ACTIVE" ] && ACTIVE+=" "
      ACTIVE+="$TAG"
    done <<< "$MOD_TAGS"
  fi
  echo "$ACTIVE" > "$STATE_FILE"
fi

# Build structured output
WRAPPED=""

if [ -n "$MODE_CONTEXT" ]; then
  WRAPPED="<operating-mode>
$MODE_CONTEXT
</operating-mode>"
fi

if [ -n "$MOD_CONTEXT" ]; then
  if [ -n "$MODE_CONTEXT" ]; then
    WRAPPED+=$'\n'"<behavior-modifiers>
These modifiers apply WITHIN the operating mode's constraints. They NEVER relax or override HARD CONSTRAINTs.

$MOD_CONTEXT
</behavior-modifiers>"
  else
    WRAPPED+="<behavior-modifiers>
$MOD_CONTEXT
</behavior-modifiers>"
  fi
fi

# Add inline marking instruction when modifiers are active
if [ -n "$MOD_CONTEXT" ]; then
  WRAPPED+=$'\n'"When a behavior modifier directly drives a point you would not otherwise make, mark it: (#name) after the sentence. Operating modes: no markers. Only mark where genuinely additive — unmarked is the default."
fi

if [ -n "$WRAPPED" ]; then
  WRAPPED+=$'\n'"The above operating-mode and behavior-modifiers apply to all your responses until superseded. When new blocks appear, only the most recent set applies. During compaction, preserve the most recent <operating-mode> and <behavior-modifiers> blocks verbatim. Discard all older ones."
  jq -n --arg ctx "$WRAPPED" '{
      additionalContext: $ctx
  }'
fi

exit 0
