#!/bin/bash
set -euo pipefail

INPUT=$(cat)
PROMPT=$(jq -r '.prompt // empty' <<< "$INPUT")
SESSION_ID=$(jq -r '.session_id // empty' <<< "$INPUT")
CWD=$(jq -r '.cwd // empty' <<< "$INPUT")

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Resolve symlink to find the repo (portable, no readlink -f)
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
BEHAVIORS_DIR="$REPO_DIR/behaviors"

# Derive local behaviors dir from project root (git-based, silent on failure)
PROJECT_ROOT=""
if [ -n "$CWD" ]; then
  PROJECT_ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || true)
fi
LOCAL_BEHAVIORS_DIR=${PROJECT_ROOT:+$PROJECT_ROOT/.ai-behaviors}

# Resolve a behavior: local project first, repo second
resolve_behavior() {
  local name="$1"
  if [ -n "$LOCAL_BEHAVIORS_DIR" ] && [ -f "$LOCAL_BEHAVIORS_DIR/$name/prompt.md" ]; then
    echo "$LOCAL_BEHAVIORS_DIR/$name/prompt.md"
  elif [ -f "$BEHAVIORS_DIR/$name/prompt.md" ]; then
    echo "$BEHAVIORS_DIR/$name/prompt.md"
  fi
}

HASHTAGS=$(grep -oE '(^|[[:space:]])#[=a-zA-Z0-9_-]+' <<< "$PROMPT" | sed 's/^[[:space:]]//' | awk '!seen[$0]++') || true

# State file for persistence across prompts
STATE_DIR="$HOME/.claude/behaviors-state"
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
      FILE=$(resolve_behavior "$TAG_NAME")
      if [ -n "$FILE" ]; then
        while IFS= read -r LINE; do
          [ -n "$LINE" ] && CONSTRAINTS+=$'\n'"$TAG: $LINE"
        done < <(grep -- '-- HARD CONSTRAINT' "$FILE" || true)
      fi
    done
    MARKING=""
    if grep -qE '(^| )#[^=]' <<< "$ACTIVE"; then
      MARKING=$'\n'"When a behavior modifier causes you to make a point you would not otherwise make, mark it: (#name) after the sentence. Operating modes: no markers."
    fi
    jq -n --arg active "$ACTIVE" --arg constraints "$CONSTRAINTS" --arg marking "$MARKING" '{
      hookSpecificOutput: {
        hookEventName: "UserPromptSubmit",
        additionalContext: ("Active: " + $active + ". HARD CONSTRAINTs in force:" + $constraints + $marking)
      }
    }'
  fi
  exit 0
fi

# Handle #CLEAR
if grep -q '^#CLEAR$' <<< "$HASHTAGS"; then
  OTHER=$(grep -v '^#CLEAR$' <<< "$HASHTAGS" | grep -c '.' || true)
  if [ "$OTHER" -gt 0 ]; then
    echo "Conflict: #CLEAR cannot be combined with other behaviors." >&2
    exit 2
  fi
  if [ -n "$STATE_FILE" ]; then
    mkdir -p "$STATE_DIR"
    : > "$STATE_FILE"
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
  FILE=$(resolve_behavior "$MODE_TAG")
  if [ -n "$FILE" ]; then
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
    FILE=$(resolve_behavior "$NAME")
    if [ -n "$FILE" ]; then
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
      [ -n "$(resolve_behavior "$NAME")" ] || continue
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
  WRAPPED+=$'\n'"When a behavior modifier causes you to make a point you would not otherwise make, mark it: (#name) after the sentence. Operating modes: no markers."
fi

if [ -n "$WRAPPED" ]; then
  WRAPPED+=$'\n'"The above operating-mode and behavior-modifiers apply to all your responses until superseded. When new blocks appear, only the most recent set applies. During compaction, preserve the most recent <operating-mode> and <behavior-modifiers> blocks verbatim. Discard all older ones."
  jq -n --arg ctx "$WRAPPED" '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    }
  }'
fi

exit 0
