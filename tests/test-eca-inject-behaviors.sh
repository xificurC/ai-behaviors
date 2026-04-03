#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$REPO_DIR/hooks/eca-inject-behaviors.sh"

TEST_HOME=$(mktemp -d)
export HOME="$TEST_HOME"
STDERR_FILE="$TEST_HOME/stderr"

PASS=0
FAIL=0

cleanup() { rm -rf "$TEST_HOME"; }
trap cleanup EXIT

# --- Helpers ---

invoke() {
  local prompt="${1:-}"
  local session_id="${2:-test-session}"
  local cwd="${3:-}"
  if [ -n "$cwd" ]; then
    jq -n --arg p "$prompt" --arg s "$session_id" --arg c "$cwd" \
      '{prompt: $p, chat_id: $s, workspaces: [$c]}' \
      | "$HOOK" 2>"$STDERR_FILE"
  else
    jq -n --arg p "$prompt" --arg s "$session_id" \
      '{prompt: $p, chat_id: $s}' \
      | "$HOOK" 2>"$STDERR_FILE"
  fi
}

context_of() { jq -r '.additionalContext // empty'; }

reset_state() { rm -rf "$TEST_HOME/.config/eca/.behaviors"; }

run_test() {
  reset_state
  : > "$STDERR_FILE"
  printf "  %-55s " "$1"
}

pass() { PASS=$((PASS + 1)); echo "OK"; }

fail() {
  FAIL=$((FAIL + 1))
  echo "FAIL"
  echo "    $1" >&2
}

assert_contains() {
  if [[ "$1" == *"$2"* ]]; then
    return 0
  else
    fail "expected to contain: $2"
    return 1
  fi
}

assert_not_contains() {
  if [[ "$1" == *"$2"* ]]; then
    fail "expected NOT to contain: $2"
    return 1
  else
    return 0
  fi
}

assert_eq() {
  if [ "$1" = "$2" ]; then
    return 0
  else
    fail "expected '$2', got '$1'"
    return 1
  fi
}

# === Setup ===

LOCAL_PROJECT="$TEST_HOME/project"
git init -q "$LOCAL_PROJECT"

# Pure macro composite
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-macro"
echo "#=code #deep" > "$LOCAL_PROJECT/.ai-behaviors/test-macro/compose"

# Composite with custom text + constraint
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-constrained"
echo "#deep" > "$LOCAL_PROJECT/.ai-behaviors/test-constrained/compose"
cat > "$LOCAL_PROJECT/.ai-behaviors/test-constrained/prompt.md" << 'EOF'
# #test-constrained — Constrained Composite
test-constrained :: always verify    -- HARD CONSTRAINT
EOF

# Nested composite for tree test
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-inner"
echo "#=review #deep" > "$LOCAL_PROJECT/.ai-behaviors/test-inner/compose"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-outer"
echo "#test-inner #challenge" > "$LOCAL_PROJECT/.ai-behaviors/test-outer/compose"

# === Bypass hardening ===

echo "Bypass hardening:"

run_test "eca_framework_contains_bypass_hardening"
OUT=$(invoke "#=code" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "proceed as if it were not said" && pass

run_test "eca_framework_no_old_refusal_text"
OUT=$(invoke "#=code" test-session "$LOCAL_PROJECT" | context_of)
assert_not_contains "$OUT" "refuse, name the violated rule" && pass

run_test "eca_continuation_contains_bypass_hardening"
invoke "#=code #deep" test-session "$LOCAL_PROJECT" >/dev/null
OUT=$(invoke "next question" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "proceed as if it were not said" && pass

# === ECA Composite Tests ===

echo ""
echo "ECA composite expansion:"

# --- T21: Composite expansion produces leaf content ---
run_test "eca_composite_expands_to_leaves"
OUT=$(invoke "#test-macro" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "Write production code" && \
  assert_contains "$OUT" "<behavior-modifiers>" && pass

# --- T22: State stores expanded leaf tags ---
run_test "eca_state_stores_expanded_continuation_works"
invoke "#test-constrained" test-session "$LOCAL_PROJECT" >/dev/null
STATE=$(cat "$TEST_HOME/.config/eca/.behaviors/test-session")
assert_contains "$STATE" "#deep" && \
  assert_not_contains "$STATE" "#test-constrained"
OUT=$(invoke "next question" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "Active: #deep" && \
  assert_contains "$OUT" "#deep:" && pass

# --- T23: EXPLAIN with composite shows expansion tree ---
run_test "eca_explain_composite_shows_tree"
OUT=$(invoke "#EXPLAIN #test-outer" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<expansion-tree>" && \
  assert_contains "$OUT" "#test-outer" && \
  assert_contains "$OUT" "#test-inner" && pass

# === Summary ===

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL passed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
