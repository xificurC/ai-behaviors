#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOK="$REPO_DIR/hooks/inject-behaviors.sh"

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
      '{prompt: $p, session_id: $s, cwd: $c}' \
      | "$HOOK" 2>"$STDERR_FILE"
  else
    jq -n --arg p "$prompt" --arg s "$session_id" \
      '{prompt: $p, session_id: $s}' \
      | "$HOOK" 2>"$STDERR_FILE"
  fi
}

invoke_no_session() {
  local prompt="$1"
  jq -n --arg p "$prompt" '{prompt: $p}' \
    | "$HOOK" 2>"$STDERR_FILE"
}

context_of() { jq -r '.hookSpecificOutput.additionalContext // empty'; }

reset_state() { rm -rf "$TEST_HOME/.claude/behaviors-state"; }

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

assert_empty() {
  if [ -n "$1" ]; then
    fail "expected empty output, got: ${1:0:80}"
  else
    pass
  fi
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

# === Input gating ===

echo "Input gating:"

run_test "empty_prompt_produces_no_output"
OUT=$(invoke "")
assert_empty "$OUT"

run_test "no_hashtags_no_state_produces_no_output"
OUT=$(invoke "hello world")
assert_empty "$OUT"

run_test "no_hashtags_empty_state_file_produces_no_output"
mkdir -p "$TEST_HOME/.claude/behaviors-state"
touch "$TEST_HOME/.claude/behaviors-state/test-session"
OUT=$(invoke "hello world")
assert_empty "$OUT"

# === Validation ===

echo ""
echo "Validation:"

run_test "multiple_op_modes_exits_2_with_error"
invoke "#=code #=design" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "multiple operating modes" && \
  assert_eq "$EXIT_CODE" "2" && pass

# === Full injection: structure ===

echo ""
echo "Full injection — structure:"

run_test "op_mode_wraps_in_operating_mode_tags"
OUT=$(invoke "do stuff #=code" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "</operating-mode>" && \
  assert_not_contains "$OUT" "</behavior-modifiers>" && pass

run_test "modifiers_wrap_in_behavior_modifiers_tags"
OUT=$(invoke "do stuff #deep" | context_of)
assert_contains "$OUT" "</behavior-modifiers>" && \
  assert_not_contains "$OUT" "</operating-mode>" && pass

run_test "framework_block_present_with_mode_and_modifiers"
OUT=$(invoke "do stuff #=code #deep" | context_of)
assert_contains "$OUT" "<framework>" && \
  assert_contains "$OUT" "</framework>" && pass

run_test "framework_block_present_with_modifiers_only"
OUT=$(invoke "do stuff #deep" | context_of)
assert_contains "$OUT" "<framework>" && pass

run_test "framework_block_present_with_mode_only"
OUT=$(invoke "do stuff #=code" | context_of)
assert_contains "$OUT" "<framework>" && pass

run_test "framework_contains_transition_rule"
OUT=$(invoke "do stuff #=code" | context_of)
assert_contains "$OUT" "Only the user switches modes" && pass

run_test "framework_contains_marker_instruction"
OUT=$(invoke "do stuff #deep" | context_of)
assert_contains "$OUT" "mark it: (#name)" && pass

run_test "framework_contains_compaction_instruction"
OUT=$(invoke "do stuff #=code" | context_of)
assert_contains "$OUT" "During compaction, preserve" && \
  assert_contains "$OUT" "<framework>" && pass

run_test "no_final_reminder_in_output"
OUT=$(invoke "do stuff #=code #deep" | context_of)
assert_not_contains "$OUT" "FINAL REMINDER" && pass

# === Full injection: unknown behaviors ===

echo ""
echo "Full injection — unknown behaviors:"

run_test "unknown_hashtag_warns_on_stderr"
invoke "do stuff #nonexistent" >/dev/null || true
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "Unknown behaviors" && \
  assert_contains "$STDERR" "#nonexistent" && pass

run_test "mixed_known_unknown_injects_known_warns_unknown"
OUT=$(invoke "do stuff #=code #nonexistent" | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$STDERR" "#nonexistent" && pass

# === State persistence ===

echo ""
echo "State persistence:"

run_test "persists_valid_hashtags"
invoke "do stuff #=code #deep" >/dev/null
STATE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_contains "$STATE" "#=code" && \
  assert_contains "$STATE" "#deep" && pass

run_test "excludes_unknown_from_state"
invoke "do stuff #=code #nonexistent" >/dev/null 2>/dev/null
STATE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_contains "$STATE" "#=code" && \
  assert_not_contains "$STATE" "#nonexistent" && pass

run_test "no_session_id_skips_state_file"
rm -rf "$TEST_HOME/.claude/behaviors-state"
invoke_no_session "do stuff #=code" >/dev/null
if [ -d "$TEST_HOME/.claude/behaviors-state" ]; then
  fail "state dir should not exist"
else
  pass
fi

# === Continuation path ===

echo ""
echo "Continuation path:"

run_test "continuation_attributes_constraints_to_hashtags"
invoke "do stuff #=code #deep" >/dev/null
OUT=$(invoke "next question" | context_of)
assert_contains "$OUT" "Active: " && \
  assert_contains "$OUT" "HARD CONSTRAINTs in force:" && \
  assert_contains "$OUT" "#=code:" && \
  assert_contains "$OUT" "#deep:" && pass

run_test "continuation_includes_constraint_text"
invoke "do stuff #=code" >/dev/null
OUT=$(invoke "next question" | context_of)
assert_contains "$OUT" "-- HARD CONSTRAINT" && pass

run_test "continuation_skips_deleted_behavior"
invoke "do stuff #=code" >/dev/null
echo "#=code #deleted-fake" > "$TEST_HOME/.claude/behaviors-state/test-session"
OUT=$(invoke "next question" | context_of)
assert_contains "$OUT" "#=code:" && \
  assert_not_contains "$OUT" "#deleted-fake:" && pass

run_test "continuation_migrates_op_prefix_in_state"
reset_state
mkdir -p "$TEST_HOME/.claude/behaviors-state"
echo "#op-code #deep" > "$TEST_HOME/.claude/behaviors-state/test-session"
OUT=$(invoke "next question" | context_of)
assert_contains "$OUT" "#=code:" && \
  assert_contains "$OUT" "#deep:" && pass

run_test "continuation_with_modifiers_includes_marker_instruction"
invoke "do stuff #=code #deep" >/dev/null
OUT=$(invoke "next question" | context_of)
assert_contains "$OUT" "mark it: (#name)" && pass

run_test "continuation_mode_only_still_has_constraints"
invoke "do stuff #=code" >/dev/null
OUT=$(invoke "next question" | context_of)
assert_contains "$OUT" "HARD CONSTRAINT" && pass

# === Local behaviors search ===

echo ""
echo "Local behaviors search:"

LOCAL_PROJECT="$TEST_HOME/project"
git init -q "$LOCAL_PROJECT"

run_test "local_behavior_takes_precedence_over_repo"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/deep"
echo "LOCAL-DEEP-UNIQUE-CONTENT" > "$LOCAL_PROJECT/.ai-behaviors/deep/prompt.md"
OUT=$(invoke "do stuff #deep" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "LOCAL-DEEP-UNIQUE-CONTENT" && pass

run_test "repo_behavior_used_when_local_dir_absent"
rm -rf "$LOCAL_PROJECT/.ai-behaviors"
OUT=$(invoke "do stuff #deep" test-session "$LOCAL_PROJECT" | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_contains "$OUT" "<behavior-modifiers>" && \
  assert_not_contains "$STDERR" "Unknown behaviors" && pass

run_test "repo_behavior_used_when_tag_absent_from_local_dir"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/other"
echo "other content" > "$LOCAL_PROJECT/.ai-behaviors/other/prompt.md"
OUT=$(invoke "do stuff #deep" test-session "$LOCAL_PROJECT" | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_not_contains "$OUT" "other content" && \
  assert_contains "$OUT" "<behavior-modifiers>" && \
  assert_not_contains "$STDERR" "Unknown behaviors" && pass

run_test "no_cwd_in_input_uses_repo_only_no_error"
OUT=$(invoke "do stuff #deep" | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_contains "$OUT" "<behavior-modifiers>" && \
  assert_not_contains "$STDERR" "Unknown behaviors" && pass

# === User-local behaviors search ===

echo ""
echo "User-local behaviors search:"

USER_BEHAVIORS="$TEST_HOME/.config/ai-behaviors/behaviors"

run_test "user_local_behavior_resolves"
mkdir -p "$USER_BEHAVIORS/ulocal-test"
echo "ULOCAL-UNIQUE-CONTENT" > "$USER_BEHAVIORS/ulocal-test/prompt.md"
OUT=$(invoke "do stuff #ulocal-test" | context_of)
rm -rf "$USER_BEHAVIORS/ulocal-test"
assert_contains "$OUT" "ULOCAL-UNIQUE-CONTENT" && pass

run_test "project_local_beats_user_local"
mkdir -p "$USER_BEHAVIORS/precedence-test"
echo "USER-LOCAL-CONTENT" > "$USER_BEHAVIORS/precedence-test/prompt.md"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/precedence-test"
echo "PROJECT-LOCAL-CONTENT" > "$LOCAL_PROJECT/.ai-behaviors/precedence-test/prompt.md"
OUT=$(invoke "do stuff #precedence-test" test-session "$LOCAL_PROJECT" | context_of)
rm -rf "$USER_BEHAVIORS/precedence-test" "$LOCAL_PROJECT/.ai-behaviors/precedence-test"
assert_contains "$OUT" "PROJECT-LOCAL-CONTENT" && \
  assert_not_contains "$OUT" "USER-LOCAL-CONTENT" && pass

run_test "user_local_beats_repo"
mkdir -p "$USER_BEHAVIORS/deep"
echo "USER-LOCAL-DEEP-OVERRIDE" > "$USER_BEHAVIORS/deep/prompt.md"
OUT=$(invoke "do stuff #deep" | context_of)
rm -rf "$USER_BEHAVIORS/deep"
assert_contains "$OUT" "USER-LOCAL-DEEP-OVERRIDE" && pass

run_test "user_local_composite_expands_repo_behaviors"
mkdir -p "$USER_BEHAVIORS/ulocal-macro"
echo "#=code #deep" > "$USER_BEHAVIORS/ulocal-macro/compose"
OUT=$(invoke "do stuff #ulocal-macro" | context_of)
rm -rf "$USER_BEHAVIORS/ulocal-macro"
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "<behavior-modifiers>" && pass

run_test "xdg_config_home_override"
XDG_ALT="$TEST_HOME/custom-xdg"
mkdir -p "$XDG_ALT/ai-behaviors/behaviors/xdg-test"
echo "XDG-OVERRIDE-CONTENT" > "$XDG_ALT/ai-behaviors/behaviors/xdg-test/prompt.md"
OUT=$(XDG_CONFIG_HOME="$XDG_ALT" invoke "do stuff #xdg-test" | context_of)
rm -rf "$XDG_ALT"
assert_contains "$OUT" "XDG-OVERRIDE-CONTENT" && pass

# === Word boundary (S2) ===

echo ""
echo "Word boundary:"

run_test "hashtag_in_url_not_captured"
OUT=$(invoke "see https://example.com#deep for info" | context_of)
assert_empty "$OUT"

run_test "hashtag_after_space_captured"
OUT=$(invoke "do stuff #deep" | context_of)
assert_contains "$OUT" "<behavior-modifiers>" && pass

run_test "hashtag_at_start_of_prompt_captured"
OUT=$(invoke "#deep do stuff" | context_of)
assert_contains "$OUT" "<behavior-modifiers>" && pass

# === Order preservation (S3) ===

echo ""
echo "Order preservation:"

run_test "modifier_order_preserved_in_state"
invoke "do stuff #wide #deep #challenge" >/dev/null
STATE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_eq "$STATE" "#wide #deep #challenge" && pass

run_test "mode_first_then_modifiers_in_order"
invoke "do stuff #wide #=code #deep" >/dev/null
STATE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_eq "$STATE" "#=code #wide #deep" && pass

# === CLEAR (S7) ===

echo ""
echo "CLEAR:"

run_test "clear_empties_state"
invoke "do stuff #=code #deep" >/dev/null
invoke "#CLEAR" >/dev/null
STATE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_eq "$STATE" "" && pass

run_test "clear_produces_no_output"
invoke "do stuff #=code #deep" >/dev/null
OUT=$(invoke "#CLEAR")
assert_empty "$OUT"

run_test "clear_with_other_hashtags_exits_2"
invoke "#CLEAR #deep" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "#CLEAR" && \
  assert_eq "$EXIT_CODE" "2" && pass

run_test "continuation_after_clear_produces_no_output"
invoke "do stuff #=code #deep" >/dev/null
invoke "#CLEAR" >/dev/null
OUT=$(invoke "next question")
assert_empty "$OUT"

run_test "lowercase_clear_not_treated_as_clear"
OUT=$(invoke "#clear" 2>/dev/null | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "Unknown behaviors" && pass

# === EXPLAIN ===

echo ""
echo "EXPLAIN:"

run_test "explain_with_companions_produces_explain_output"
OUT=$(invoke "#EXPLAIN #=code #deep" | context_of)
assert_contains "$OUT" "<explain-instruction>" && \
  assert_contains "$OUT" "<explain-behaviors>" && pass

run_test "explain_contains_behavior_content_in_labeled_tags"
OUT=$(invoke "#EXPLAIN #=code #deep" | context_of)
assert_contains "$OUT" 'name="#=code"' && \
  assert_contains "$OUT" 'role="mode"' && \
  assert_contains "$OUT" 'name="#deep"' && \
  assert_contains "$OUT" 'role="modifier"' && pass

run_test "explain_does_not_use_active_directive_tags"
OUT=$(invoke "#EXPLAIN #=code #deep" | context_of)
assert_not_contains "$OUT" "<operating-mode>" && \
  assert_not_contains "$OUT" "<behavior-modifiers>" && pass

run_test "explain_alone_reads_from_state"
invoke "#=code #deep" >/dev/null
OUT=$(invoke "#EXPLAIN" | context_of)
assert_contains "$OUT" "<explain-instruction>" && \
  assert_contains "$OUT" 'name="#=code"' && \
  assert_contains "$OUT" 'name="#deep"' && pass

run_test "explain_alone_no_state_exits_2"
invoke "#EXPLAIN" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "No active behaviors to explain" && \
  assert_eq "$EXIT_CODE" "2" && pass

run_test "explain_does_not_write_state"
invoke "#=code #deep" >/dev/null
STATE_BEFORE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
invoke "#EXPLAIN #=frame" >/dev/null
STATE_AFTER=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_eq "$STATE_AFTER" "$STATE_BEFORE" && pass

run_test "explain_with_multiple_modes_exits_2"
invoke "#EXPLAIN #=code #=design" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "multiple operating modes" && \
  assert_eq "$EXIT_CODE" "2" && pass

run_test "explain_with_unknown_warns_and_explains_known"
OUT=$(invoke "#EXPLAIN #=code #nonexistent" | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_contains "$OUT" 'name="#=code"' && \
  assert_contains "$STDERR" "#nonexistent" && pass

run_test "explain_prompt_contains_output_sections"
OUT=$(invoke "#EXPLAIN #=code" | context_of)
assert_contains "$OUT" "Will do" && \
  assert_contains "$OUT" "Won't do" && \
  assert_contains "$OUT" "Hard constraints" && \
  assert_contains "$OUT" "Interactions" && \
  assert_contains "$OUT" "Example" && pass

run_test "explain_modifiers_only_no_mode_tag"
OUT=$(invoke "#EXPLAIN #deep #challenge" | context_of)
assert_contains "$OUT" 'name="#deep"' && \
  assert_contains "$OUT" 'name="#challenge"' && \
  assert_not_contains "$OUT" 'role="mode"' && pass

run_test "lowercase_explain_not_treated_as_explain"
OUT=$(invoke "#explain #deep" 2>/dev/null | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_not_contains "$OUT" "<explain-instruction>" && \
  assert_contains "$STDERR" "Unknown behaviors" && pass

run_test "clear_with_explain_exits_2"
invoke "#CLEAR #EXPLAIN" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "#CLEAR" && \
  assert_eq "$EXIT_CODE" "2" && pass

# === Composite tests ===

echo ""
echo "Composite expansion:"

# Setup test composite directories
rm -rf "$LOCAL_PROJECT/.ai-behaviors"

# Pure macro (T1)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-macro"
echo "#=code #deep" > "$LOCAL_PROJECT/.ai-behaviors/test-macro/compose"

# Composite with custom text (T2)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-custom"
echo "#deep #challenge" > "$LOCAL_PROJECT/.ai-behaviors/test-custom/compose"
cat > "$LOCAL_PROJECT/.ai-behaviors/test-custom/prompt.md" << 'EOF'
# #test-custom — Test Custom Composite
UNIQUE-CUSTOM-PERSONA-CONTENT-XYZ
EOF

# Nested (T3)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-inner"
echo "#=review #deep" > "$LOCAL_PROJECT/.ai-behaviors/test-inner/compose"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-outer"
echo "#test-inner #challenge" > "$LOCAL_PROJECT/.ai-behaviors/test-outer/compose"

# Cycle (T4)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-cycle-a"
echo "#test-cycle-b" > "$LOCAL_PROJECT/.ai-behaviors/test-cycle-a/compose"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-cycle-b"
echo "#test-cycle-a" > "$LOCAL_PROJECT/.ai-behaviors/test-cycle-b/compose"

# Deep nesting — 9 levels to exceed depth 8 (T5)
for i in $(seq 1 9); do
  mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-depth-$i"
  if [ "$i" -lt 9 ]; then
    echo "#test-depth-$((i+1))" > "$LOCAL_PROJECT/.ai-behaviors/test-depth-$i/compose"
  else
    echo "#deep" > "$LOCAL_PROJECT/.ai-behaviors/test-depth-$i/compose"
  fi
done

# Unknown in compose (T6)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-with-unknown"
echo "#=code #nonexistent-xyz-test" > "$LOCAL_PROJECT/.ai-behaviors/test-with-unknown/compose"

# Empty compose (T7)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-empty-compose"
touch "$LOCAL_PROJECT/.ai-behaviors/test-empty-compose/compose"

# Mode-bearing composites for conflict tests (T10, T11)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-mode-a"
echo "#=code #deep" > "$LOCAL_PROJECT/.ai-behaviors/test-mode-a/compose"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-mode-b"
echo "#=review #challenge" > "$LOCAL_PROJECT/.ai-behaviors/test-mode-b/compose"

# Composite with HARD CONSTRAINT in custom text (T14)
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-constrained"
echo "#deep" > "$LOCAL_PROJECT/.ai-behaviors/test-constrained/compose"
cat > "$LOCAL_PROJECT/.ai-behaviors/test-constrained/prompt.md" << 'EOF'
# #test-constrained — Constrained Composite
test-constrained :: always verify    -- HARD CONSTRAINT
EOF

# --- T1: Pure macro expands ---
run_test "composite_pure_macro_expands"
OUT=$(invoke "#test-macro" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "<behavior-modifiers>" && pass

# --- T2: Custom text in modifiers alongside composed behaviors ---
run_test "composite_custom_text_in_modifiers"
OUT=$(invoke "#test-custom" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "UNIQUE-CUSTOM-PERSONA-CONTENT-XYZ" && \
  assert_contains "$OUT" "Go beneath the surface" && \
  assert_contains "$OUT" "counterargument" && pass

# --- T3: Nested composite fully expands ---
run_test "nested_composite_expands"
OUT=$(invoke "#test-outer" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "<behavior-modifiers>" && pass

# --- T4: Cycle detected ---
run_test "composite_cycle_detected"
invoke "#test-cycle-a" test-session "$LOCAL_PROJECT" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "Cycle" && \
  assert_eq "$EXIT_CODE" "2" && pass

# --- T5: Depth limit exceeded ---
run_test "composite_depth_limit_exceeded"
invoke "#test-depth-1" test-session "$LOCAL_PROJECT" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "depth" && \
  assert_eq "$EXIT_CODE" "2" && pass

# --- T6: Unknown in compose warns, expands known ---
run_test "composite_unknown_in_compose_warns"
OUT=$(invoke "#test-with-unknown" test-session "$LOCAL_PROJECT" | context_of)
STDERR=$(cat "$STDERR_FILE")
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$STDERR" "#nonexistent-xyz-test" && pass

# --- T7: Empty compose errors ---
run_test "composite_empty_compose_errors"
invoke "#test-empty-compose" test-session "$LOCAL_PROJECT" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "Empty compose" && \
  assert_eq "$EXIT_CODE" "2" && pass

# --- T8: Stacking composite + extra modifier ---
run_test "composite_stacked_with_extra_modifier"
OUT=$(invoke "#test-macro #challenge" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "Write production code" && \
  assert_contains "$OUT" "counterargument" && pass

# --- T9: Duplicate deduplicated ---
run_test "composite_duplicate_deduplicated"
OUT=$(invoke "#test-macro #deep" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "Write production code" && \
  COUNT=$(grep -o "Go beneath the surface" <<< "$OUT" | wc -l | tr -d ' ') && \
  assert_eq "$COUNT" "1" && pass

# --- T10: Composite mode + explicit mode = error ---
run_test "composite_mode_plus_explicit_mode_errors"
invoke "#test-mode-a #=review" test-session "$LOCAL_PROJECT" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "multiple operating modes" && \
  assert_eq "$EXIT_CODE" "2" && pass

# --- T11: Two mode composites = error ---
run_test "two_mode_composites_error"
invoke "#test-mode-a #test-mode-b" test-session "$LOCAL_PROJECT" >/dev/null && EXIT_CODE=$? || EXIT_CODE=$?
STDERR=$(cat "$STDERR_FILE")
assert_contains "$STDERR" "multiple operating modes" && \
  assert_eq "$EXIT_CODE" "2" && pass

# --- T12: Composite with mode + extra modifiers = ok ---
run_test "composite_mode_with_extra_modifiers_ok"
OUT=$(invoke "#test-mode-a #challenge" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "Write production code" && \
  assert_contains "$OUT" "counterargument" && pass

# --- T13: State stores composite name, not expanded ---
run_test "state_stores_composite_name"
invoke "#test-macro #challenge" test-session "$LOCAL_PROJECT" >/dev/null
STATE=$(cat "$TEST_HOME/.claude/behaviors-state/test-session")
assert_contains "$STATE" "#test-macro" && \
  assert_contains "$STATE" "#challenge" && \
  assert_not_contains "$STATE" "#=code" && \
  assert_not_contains "$STATE" "#deep" && pass

# --- T14: Continuation re-expands composite ---
run_test "continuation_reexpands_composite"
invoke "#test-constrained" test-session "$LOCAL_PROJECT" >/dev/null
OUT=$(invoke "next question" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "Active: #test-constrained" && \
  assert_contains "$OUT" "#test-constrained:" && \
  assert_contains "$OUT" "#deep:" && pass

# --- T15: EXPLAIN composite shows tree ---
run_test "explain_composite_shows_tree"
OUT=$(invoke "#EXPLAIN #test-outer" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<expansion-tree>" && \
  assert_contains "$OUT" "#test-outer" && \
  assert_contains "$OUT" "#test-inner" && pass

# --- T16: EXPLAIN with active composite from state ---
run_test "explain_active_composite_from_state"
invoke "#test-macro" test-session "$LOCAL_PROJECT" >/dev/null
OUT=$(invoke "#EXPLAIN" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<explain-instruction>" && \
  assert_contains "$OUT" "<expansion-tree>" && pass

# --- T19: Local composite overrides repo ---
run_test "local_composite_overrides_repo"
mkdir -p "$REPO_DIR/behaviors/test-override-zzz"
echo "#deep" > "$REPO_DIR/behaviors/test-override-zzz/compose"
echo "REPO-OVERRIDE-ZZZ" > "$REPO_DIR/behaviors/test-override-zzz/prompt.md"
mkdir -p "$LOCAL_PROJECT/.ai-behaviors/test-override-zzz"
echo "#deep" > "$LOCAL_PROJECT/.ai-behaviors/test-override-zzz/compose"
echo "LOCAL-OVERRIDE-ZZZ" > "$LOCAL_PROJECT/.ai-behaviors/test-override-zzz/prompt.md"
OUT=$(invoke "#test-override-zzz" test-session "$LOCAL_PROJECT" | context_of)
rm -rf "$REPO_DIR/behaviors/test-override-zzz"
assert_contains "$OUT" "LOCAL-OVERRIDE-ZZZ" && \
  assert_not_contains "$OUT" "REPO-OVERRIDE-ZZZ" && \
  assert_contains "$OUT" "Go beneath the surface" && pass

# --- T20: Local composite composes repo behaviors ---
run_test "local_composite_composes_repo_behaviors"
OUT=$(invoke "#test-macro" test-session "$LOCAL_PROJECT" | context_of)
assert_contains "$OUT" "<operating-mode>" && \
  assert_contains "$OUT" "<behavior-modifiers>" && pass

# === Summary ===

echo ""
TOTAL=$((PASS + FAIL))
echo "$PASS/$TOTAL passed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
