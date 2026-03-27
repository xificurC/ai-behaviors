#!/bin/bash
set -euo pipefail

INPUT=$(cat)
PROMPT=$(jq -r '.prompt // empty' <<< "$INPUT")
SESSION_ID=$(jq -r '.chat_id // empty' <<< "$INPUT")
CWD=$(jq -r '.workspaces[0] // empty' <<< "$INPUT")

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

# User-local behaviors (XDG-compliant, cross-project)
USER_BEHAVIORS_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ai-behaviors/behaviors"

# Resolve a behavior directory: project-local first, user-local second, repo third
resolve_dir() {
  local name="$1"
  if [ -n "$LOCAL_BEHAVIORS_DIR" ] && [ -d "$LOCAL_BEHAVIORS_DIR/$name" ]; then
    if [ -f "$LOCAL_BEHAVIORS_DIR/$name/compose" ] || [ -f "$LOCAL_BEHAVIORS_DIR/$name/prompt.md" ]; then
      echo "$LOCAL_BEHAVIORS_DIR/$name"
      return
    fi
  fi
  if [ -d "$USER_BEHAVIORS_DIR/$name" ]; then
    if [ -f "$USER_BEHAVIORS_DIR/$name/compose" ] || [ -f "$USER_BEHAVIORS_DIR/$name/prompt.md" ]; then
      echo "$USER_BEHAVIORS_DIR/$name"
      return
    fi
  fi
  if [ -d "$BEHAVIORS_DIR/$name" ]; then
    if [ -f "$BEHAVIORS_DIR/$name/compose" ] || [ -f "$BEHAVIORS_DIR/$name/prompt.md" ]; then
      echo "$BEHAVIORS_DIR/$name"
      return
    fi
  fi
}

# Expand hashtags, resolving composites recursively
EXPAND_LEAF_TAGS=""
EXPAND_MISSING=""
_CUSTOM_DIR=""

expand_tags() {
  local tags="$1"
  local depth="${2:-0}"
  local seen="${3:-}"
  for tag in $tags; do
    local name="${tag#\#}"
    local dir
    dir=$(resolve_dir "$name")
    if [ -z "$dir" ]; then
      EXPAND_MISSING+=" $tag"
      continue
    fi
    if [ -f "$dir/compose" ]; then
      if [[ " $seen " == *" $name "* ]]; then
        echo "Cycle detected: $tag" >&2
        exit 2
      fi
      if [ "$depth" -ge 8 ]; then
        echo "Nesting too deep at $tag (max depth 8)" >&2
        exit 2
      fi
      local composed
      composed=$(cat "$dir/compose")
      if [ -z "$composed" ]; then
        echo "Empty compose file: $dir/compose" >&2
        exit 2
      fi
      expand_tags "$composed" $((depth + 1)) "$seen $name"
      if [ -f "$dir/prompt.md" ]; then
        cp "$dir/prompt.md" "$_CUSTOM_DIR/$name"
      fi
    elif [ -f "$dir/prompt.md" ]; then
      if [[ " $EXPAND_LEAF_TAGS " != *" $tag "* ]]; then
        EXPAND_LEAF_TAGS+=" $tag"
      fi
    fi
  done
}

# Build ASCII expansion tree for EXPLAIN
TREE_OUTPUT=""

build_tree() {
  local name="$1"
  local prefix="${2:-}"
  local dir
  dir=$(resolve_dir "$name")
  [ -n "$dir" ] || return
  [ -f "$dir/compose" ] || return
  local composed
  composed=$(cat "$dir/compose")
  local items=($composed)
  local count=${#items[@]}
  local i=0
  for item in "${items[@]}"; do
    i=$((i + 1))
    local connector="├── "
    local child_prefix="${prefix}│   "
    if [ "$i" -eq "$count" ]; then
      connector="└── "
      child_prefix="${prefix}    "
    fi
    TREE_OUTPUT+="${prefix}${connector}${item}"$'\n'
    local child_name="${item#\#}"
    local child_dir
    child_dir=$(resolve_dir "$child_name")
    if [ -n "$child_dir" ] && [ -f "$child_dir/compose" ]; then
      build_tree "$child_name" "$child_prefix"
    fi
  done
}

HASHTAGS=$(grep -oE '(^|[[:space:]])#[=a-zA-Z0-9_-]+' <<< "$PROMPT" | sed 's/^[[:space:]]//' | awk '!seen[$0]++') || true

# State file for persistence across prompts
STATE_DIR="$HOME/.config/eca/.behaviors"
STATE_FILE=""
if [ -n "$SESSION_ID" ]; then
  STATE_FILE="$STATE_DIR/$SESSION_ID"
fi

if [ -z "$HASHTAGS" ]; then
  if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
    ACTIVE=$(sed 's/#op-/#=/g' < "$STATE_FILE")
    EXPAND_LEAF_TAGS=""
    EXPAND_MISSING=""
    _CUSTOM_DIR=$(mktemp -d)
    trap 'rm -rf "$_CUSTOM_DIR"' EXIT
    expand_tags "$ACTIVE" 0 ""
    CONSTRAINTS=""
    for TAG in $EXPAND_LEAF_TAGS; do
      TAG_NAME="${TAG#\#}"
      DIR=$(resolve_dir "$TAG_NAME")
      if [ -n "$DIR" ] && [ -f "$DIR/prompt.md" ]; then
        while IFS= read -r LINE; do
          [ -n "$LINE" ] && CONSTRAINTS+=$'\n'"$TAG: $LINE"
        done < <(grep -- '-- HARD CONSTRAINT' "$DIR/prompt.md" || true)
      fi
    done
    for CFILE in "$_CUSTOM_DIR"/*; do
      [ -f "$CFILE" ] || continue
      CNAME=$(basename "$CFILE")
      while IFS= read -r LINE; do
        [ -n "$LINE" ] && CONSTRAINTS+=$'\n'"#$CNAME: $LINE"
      done < <(grep -- '-- HARD CONSTRAINT' "$CFILE" || true)
    done
    MARKING=""
    if echo "$EXPAND_LEAF_TAGS" | grep -qE '(^| )#[^=]'; then
      MARKING=$'\n'"When a behavior modifier causes you to make a point you would not otherwise make, mark it: (#name) after the sentence. Operating modes: no markers."
    fi
    if [ -z "$MARKING" ] && ls "$_CUSTOM_DIR"/* >/dev/null 2>&1; then
      MARKING=$'\n'"When a behavior modifier causes you to make a point you would not otherwise make, mark it: (#name) after the sentence. Operating modes: no markers."
    fi
    jq -n --arg active "$ACTIVE" --arg constraints "$CONSTRAINTS" --arg marking "$MARKING" '{
        additionalContext: ("Active: " + $active + ". HARD CONSTRAINTs in force:" + $constraints + $marking)
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

# Handle #EXPLAIN
if grep -q '^#EXPLAIN$' <<< "$HASHTAGS"; then
  EXPLAIN_TAGS=$(grep -v '^#EXPLAIN$' <<< "$HASHTAGS" | grep '.' || true)

  # No companions — read from state file
  if [ -z "$EXPLAIN_TAGS" ]; then
    if [ -n "$STATE_FILE" ] && [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
      EXPLAIN_TAGS=$(sed 's/#op-/#=/g' < "$STATE_FILE" | tr ' ' '\n')
    else
      echo "No active behaviors to explain." >&2
      exit 2
    fi
  fi

  # Expand composites
  EXPAND_LEAF_TAGS=""
  EXPAND_MISSING=""
  _CUSTOM_DIR=$(mktemp -d)
  trap 'rm -rf "$_CUSTOM_DIR"' EXIT
  expand_tags "$(echo "$EXPLAIN_TAGS" | tr '\n' ' ')" 0 ""

  # Reject multiple operating modes (post-expansion)
  E_MODE_COUNT=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep -c '^#=' || true)
  if [ "$E_MODE_COUNT" -gt 1 ]; then
    E_MODE_TAGS=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep '^#=' | tr '\n' ' ')
    echo "Conflict: multiple operating modes: ${E_MODE_TAGS%. }. Use one at a time." >&2
    exit 2
  fi

  # Build expansion trees for composite tags
  TREES=""
  while IFS= read -r TAG; do
    [ -z "$TAG" ] && continue
    NAME="${TAG#\#}"
    DIR=$(resolve_dir "$NAME")
    if [ -n "$DIR" ] && [ -f "$DIR/compose" ]; then
      TREE_OUTPUT="$TAG"$'\n'
      build_tree "$NAME" ""
      [ -n "$TREES" ] && TREES+=$'\n'
      TREES+="$TREE_OUTPUT"
    fi
  done <<< "$EXPLAIN_TAGS"

  # Separate mode from modifiers in expanded leaf list
  E_MODE_TAG=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep '^#=' | head -1 || true)
  E_MODE_TAG="${E_MODE_TAG#\#}"
  E_MOD_TAGS=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep -v '^#=' | grep '.' || true)

  # Build explain content from expanded leaves
  EXPLAIN_CONTENT=""

  if [ -n "$E_MODE_TAG" ]; then
    DIR=$(resolve_dir "$E_MODE_TAG")
    if [ -n "$DIR" ] && [ -f "$DIR/prompt.md" ]; then
      EXPLAIN_CONTENT+="<behavior name=\"#$E_MODE_TAG\" role=\"mode\">
$(cat "$DIR/prompt.md")
</behavior>"
    fi
  fi

  if [ -n "$E_MOD_TAGS" ]; then
    while IFS= read -r TAG; do
      [ -z "$TAG" ] && continue
      NAME="${TAG#\#}"
      DIR=$(resolve_dir "$NAME")
      if [ -n "$DIR" ] && [ -f "$DIR/prompt.md" ]; then
        [ -n "$EXPLAIN_CONTENT" ] && EXPLAIN_CONTENT+=$'\n'
        EXPLAIN_CONTENT+="<behavior name=\"$TAG\" role=\"modifier\">
$(cat "$DIR/prompt.md")
</behavior>"
      fi
    done <<< "$E_MOD_TAGS"
  fi

  # Composite custom texts
  for CFILE in "$_CUSTOM_DIR"/*; do
    [ -f "$CFILE" ] || continue
    CNAME=$(basename "$CFILE")
    [ -n "$EXPLAIN_CONTENT" ] && EXPLAIN_CONTENT+=$'\n'
    EXPLAIN_CONTENT+="<behavior name=\"#$CNAME\" role=\"composite\">
$(cat "$CFILE")
</behavior>"
  done

  if [ -n "$EXPAND_MISSING" ]; then
    echo "Unknown behaviors:$EXPAND_MISSING" >&2
  fi

  TREE_SECTION=""
  if [ -n "$TREES" ]; then
    TREE_SECTION="<expansion-tree>
$TREES</expansion-tree>
"
  fi

  if [ -n "$EXPLAIN_CONTENT" ] || [ -n "$TREE_SECTION" ]; then
    EXPLAIN_OUTPUT="<explain-instruction>
Explain what this behavior combination would do. Do NOT follow these behaviors — analyze them.
Be terse. Bullet points, not paragraphs. Plain language — no formal notation in output.
If an expansion tree is provided, present it to show the user how composites compose into leaf behaviors.

## Will do — obligations and actions, one bullet each.
## Won't do — boundaries and exclusions.
## Hard constraints — non-negotiable rules.
## Interactions — how behaviors reinforce, tension, or scope each other. Only notable ones.
## Example — brief: given a task, how would the response differ from default? Use the user's prompt as context if it contains a task, otherwise pick a hypothetical.
</explain-instruction>
${TREE_SECTION}<explain-behaviors>
$EXPLAIN_CONTENT
</explain-behaviors>"
    jq -n --arg ctx "$EXPLAIN_OUTPUT" '{
        additionalContext: $ctx
    }'
  fi

  exit 0
fi

# Expand all hashtags (composites → leaf behaviors)
EXPAND_LEAF_TAGS=""
EXPAND_MISSING=""
_CUSTOM_DIR=$(mktemp -d)
trap 'rm -rf "$_CUSTOM_DIR"' EXIT
expand_tags "$(echo "$HASHTAGS" | tr '\n' ' ')" 0 ""

# Reject multiple operating modes (post-expansion)
MODE_COUNT=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep -c '^#=' || true)
if [ "$MODE_COUNT" -gt 1 ]; then
  MODE_TAGS=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep '^#=' | tr '\n' ' ')
  echo "Conflict: multiple operating modes: ${MODE_TAGS%. }. Use one at a time." >&2
  exit 2
fi

# Separate mode from modifiers (post-expansion)
MODE_TAG=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep '^#=' | head -1 || true)
MODE_TAG="${MODE_TAG#\#}"
MOD_TAGS=$(echo "$EXPAND_LEAF_TAGS" | tr ' ' '\n' | grep -v '^#=' | grep '.' || true)

# Read mode content
MODE_CONTEXT=""
if [ -n "$MODE_TAG" ]; then
  DIR=$(resolve_dir "$MODE_TAG")
  if [ -n "$DIR" ] && [ -f "$DIR/prompt.md" ]; then
    MODE_CONTEXT="$(cat "$DIR/prompt.md")"
  fi
fi

# Read modifier content
MOD_CONTEXT=""
if [ -n "$MOD_TAGS" ]; then
  while IFS= read -r TAG; do
    [ -z "$TAG" ] && continue
    NAME="${TAG#\#}"
    DIR=$(resolve_dir "$NAME")
    if [ -n "$DIR" ] && [ -f "$DIR/prompt.md" ]; then
      if [ -n "$MOD_CONTEXT" ]; then
        MOD_CONTEXT+=$'\n\n'
      fi
      MOD_CONTEXT+="$(cat "$DIR/prompt.md")"
    fi
  done <<< "$MOD_TAGS"
fi

# Append composite custom texts to modifier content
for CFILE in "$_CUSTOM_DIR"/*; do
  [ -f "$CFILE" ] || continue
  if [ -n "$MOD_CONTEXT" ]; then
    MOD_CONTEXT+=$'\n\n'
  fi
  MOD_CONTEXT+="$(cat "$CFILE")"
done

if [ -n "$EXPAND_MISSING" ]; then
  echo "Unknown behaviors:$EXPAND_MISSING" >&2
fi

# Write state — original hashtags (pre-expansion), filtered to resolved
if [ -n "$STATE_FILE" ]; then
  mkdir -p "$STATE_DIR"
  ACTIVE=""
  ORIG_MODES=$(grep '^#=' <<< "$HASHTAGS" || true)
  ORIG_OTHERS=$(grep -v '^#=' <<< "$HASHTAGS" || true)
  for TAG in $ORIG_MODES; do
    NAME="${TAG#\#}"
    [ -n "$(resolve_dir "$NAME")" ] || continue
    [ -n "$ACTIVE" ] && ACTIVE+=" "
    ACTIVE+="$TAG"
  done
  while IFS= read -r TAG; do
    [ -z "$TAG" ] && continue
    NAME="${TAG#\#}"
    [ -n "$(resolve_dir "$NAME")" ] || continue
    [ -n "$ACTIVE" ] && ACTIVE+=" "
    ACTIVE+="$TAG"
  done <<< "$ORIG_OTHERS"
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
$MOD_CONTEXT
</behavior-modifiers>"
  else
    WRAPPED+="<behavior-modifiers>
$MOD_CONTEXT
</behavior-modifiers>"
  fi
fi

if [ -n "$WRAPPED" ]; then
  WRAPPED+=$'\n'"<framework>
When an operating mode is active, behavior modifiers apply within its constraints and NEVER relax or override HARD CONSTRAINTs.
When a behavior modifier causes you to make a point you would not otherwise make, mark it: (#name) after the sentence. Operating modes: no markers.
⊣ {#=X} means: suggest #=X to the user. Only the user switches modes via #=hashtag — never self-transition.
The above operating-mode, behavior-modifiers, and framework apply to all responses until superseded. When new blocks appear, only the most recent set applies. During compaction, preserve the most recent <operating-mode>, <behavior-modifiers>, and <framework> blocks verbatim. Discard all older ones.
</framework>"
  jq -n --arg ctx "$WRAPPED" '{
      additionalContext: $ctx
  }'
fi

exit 0
