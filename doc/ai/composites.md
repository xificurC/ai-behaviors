# Composites — Problem Frame

## Problem

Users repeatedly type the same hashtag combinations for recurring interaction styles. A reviewer who always wants `#=review #deep #challenge` types those three tags every time. There is no mechanism to name and reuse a composition of behaviors.

## Motivation

- **Repetition tax**: frequent combos are 3–6 hashtags long; retyping is friction.
- **Shareability**: teams cannot distribute curated interaction profiles (e.g., "use `#security-reviewer` for security reviews") the way they distribute custom behaviors today.
- **Discoverability**: a named composite communicates intent ("security reviewer") where a hashtag list communicates mechanism (`#=review #deep #challenge #simulate #contract`).
- **Custom glue text**: some interaction styles need prose directives that don't map to any existing behavior. Today the only option is a full custom behavior — but the directive only makes sense in combination with specific other behaviors, not standalone. (#ground)

## What a composite IS

A named, reusable macro that expands to:
1. Zero or more hashtag references (behaviors or other composites).
2. Optional custom directive text (prose injected alongside the expanded behaviors).

A composite occupies the same namespace as behaviors — invoked as `#composite-name`, no special syntax. (#first-principles)

## Non-goals

- Composite-specific invocation syntax (no `#@`, `#:`, `#+`).
- Parameterized composites (no `#reviewer(strict=true)`).
- Overriding or relaxing HARD CONSTRAINTs from composed behaviors.
- Runtime composite creation (composites are files, not commands).

## Constraints

1. **Same namespace**: a composite is resolved the same way as a behavior — local `.ai-behaviors/` first, then repo `behaviors/`. Reuse `prompt.md` if the definition format permits it. (#first-principles)
2. **One operating mode**: after full recursive expansion, exactly zero or one `#=` mode. Multiple modes → error. Same rule as today, applied post-expansion.
3. **Nesting**: composites may reference other composites. Cycles must be detected and rejected.
4. **Stacking**: extra hashtags in the prompt merge with the expanded set. `#reviewer #concise` = expand `#reviewer` + add `#concise`.
5. **State persistence**: the state file stores the composite name (and any extra stacked tags), not the expanded set. Re-expansion happens on every continuation prompt.
6. **Scope**: composites can be defined in the repo (`behaviors/`) or locally (`.ai-behaviors/`). Same resolution precedence as behaviors.
7. **`#EXPLAIN` support**: `#EXPLAIN #reviewer` shows the expanded behaviors, custom text, and interaction analysis.
8. **Distinguishable**: the hook must reliably distinguish a composite from a leaf behavior at resolution time — without requiring the user to use different invocation syntax.
9. **Custom text placement**: the composite's definition file controls where custom prose appears in the injection. It is additional modifier content, authored by the composite definer.
10. **`prompt.md` reuse preferred**: avoid introducing a new filename if possible. The distinction between composite and leaf should be expressible within `prompt.md`'s content. (#ground)

## Open Questions

1. **Detection mechanism**: how does the hook distinguish composite from leaf inside `prompt.md`? Options: a marker line (e.g., `compose: #=review #deep`), frontmatter, content heuristics. Tradeoff: explicitness vs. parsing complexity in bash.
2. **Depth limit**: should recursive expansion have a max depth? Practical defense against deep nesting even without cycles.
3. **Duplicate handling**: composite A includes `#deep`, user also types `#deep` — deduplicate silently? (Probably yes, consistent with today's `awk '!seen[$0]++'`.)
4. **Expansion order**: when a composite includes `#ground` and the user stacks `#concise`, does order of injection matter? Today modifiers are concatenated in prompt order — what's the right order post-expansion?
5. ~~**Custom text vs. custom behavior**~~: resolved — custom text IS an anonymous inlined behavior. Same terse-directive format as any `prompt.md`. Marking rule applies under the composite's name (e.g., `(#reviewer)`).
6. **Composite README**: should composites have their own `README.md` for human docs, like behaviors do?
7. **Naming convention**: should composites be visually distinguishable in the catalog (e.g., prefix convention like `rev-` for review composites), or is the flat namespace fine?

---

# Design

## Central tension

Constraint #8 (distinguishable) vs #10 (`prompt.md` reuse). The hook must know whether a resolved `prompt.md` is a leaf (inject as-is) or a composite (expand hashtags, then inject custom text). The question is: what's the distinguishing signal? (#ground)

## Candidate A — Marker line in `prompt.md`

A `compose:` line in `prompt.md` signals "this is a composite." Everything else in the file is custom directive text (the anonymous inlined behavior).

```markdown
# #reviewer — Security Reviewer
Deep, adversarial code review focused on security.

compose: #=review #deep #challenge #simulate

Always check error handling and input validation first.
Flag any use of `unsafe` or raw pointer manipulation.
```

**Hook logic**: `grep -q '^compose:' "$FILE"`. If match → composite. Extract hashtags from that line, recursively resolve each. Collect remaining lines as custom text.

**Pure macro** (no custom text):
```markdown
# #quick-review — Quick Review
Fast review with depth.

compose: #=review #deep #concise
```

| Aspect | Assessment                                                                                                                                                                |
|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Pros   | One file. Natural to read. Compose line uses the same syntax users type in prompts.                                                                                       |
| Cons   | `prompt.md` gains dual semantics — "inject this" vs "expand this." Every `resolve_behavior` call now needs a content check, not just a file-existence check. (#challenge) |
| Gaps   | What if a leaf behavior has a line starting with `compose:` in its prose? Unlikely but not impossible. (#ground)                                                          |
| Fit    | Satisfies constraint #10 (reuse). Simple bash parsing.                                                                                                                    |

## Candidate B — Sibling `compose` file

A separate file named `compose` (no extension) in the behavior directory lists the hashtags. `prompt.md` retains its original semantics — if present, it's custom directive text.

```
behaviors/reviewer/
├── compose        # #=review #deep #challenge #simulate
├── prompt.md      # custom directives (optional)
└── README.md      # human docs (optional)
```

`compose` file contents — a single line:
```
#=review #deep #challenge #simulate
```

**Hook logic**: `[ -f "$DIR/compose" ]`. If yes → composite. Read hashtags from `compose`, recursively resolve. If `prompt.md` also exists, read it as custom text.

**Pure macro**: directory has `compose` but no `prompt.md`.

| Aspect | Assessment                                                                                                                                                    |
|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Pros   | `prompt.md` always means the same thing — zero ambiguity. Detection is file-existence, not content parsing. Clean separation of concerns. (#first-principles) |
| Cons   | Two files for composites with custom text. New filename to know about.                                                                                          |
| Gaps   | Should `compose` support comments? Multiple lines? Or strictly one line of hashtags?                                                                          |
| Fit    | Violates soft preference in constraint #10 but satisfies constraint #8 cleanly.                                                                               |

## Candidate C — Hashtag-first content line

After the title and description lines, if the first "content" line starts with `#` followed by a known behavior name, treat it as a composition list. No explicit marker keyword.

```markdown
# #reviewer — Security Reviewer
Deep, adversarial code review focused on security.

#=review #deep #challenge #simulate

Always check error handling and input validation first.
```

| Aspect | Assessment |
|---|---|
| Pros | No new keyword or file. Visually clean. |
| Cons | Fragile — relies on positional convention. A leaf behavior's formal notation could start with `#` accidentally. Requires the hook to parse line position, not just content. The detection rule ("first content line after title") is harder to express in bash than `grep '^compose:'`. (#challenge) (#ground) |
| Gaps | What counts as the "first content line"? After how many blank lines? |
| Fit | Weakest on constraint #8 (distinguishable). Saves no files over A, adds fragility. |

**REJECTED: fragility and positional dependence make this strictly worse than A.** Candidate A provides the same one-file benefit with an explicit, grep-able signal. (#first-principles)

## Comparison

|                                  | A (marker line)                  | B (sibling file)                       |
|----------------------------------|----------------------------------|----------------------------------------|
| Files per composite                | 1                                | 1–2                                    |
| `prompt.md` semantics            | dual (leaf or composite)           | unchanged (always leaf/custom text)    |
| Detection mechanism              | content grep                     | file existence                         |
| Parsing complexity               | `grep` + `sed`                   | `cat`                                  |
| False positive risk              | near-zero (`compose:` is unique) | zero                                   |
| Consistency with existing design | `prompt.md` gains new meaning    | new file, but existing files unchanged |

## Recommendation

**Candidate B.** (#first-principles)

The decisive argument: `prompt.md` currently has exactly one meaning — "inject this text." Every behavior, every custom behavior, every project-local behavior relies on this. Candidate A makes that meaning conditional on content inspection. The user doesn't see this complexity, but the hook does — on every resolution, for every behavior, including leaves. Candidate B keeps the unconditional path for all existing behaviors and adds the new path only where it's needed. (#challenge)

The "two files" cost is real but small: composites with custom text need `compose` + `prompt.md`. Composites without custom text need only `compose`. Leaf behaviors need only `prompt.md`. No behavior needs both unless it's a composite with custom directives. (#ground)

## Open questions resolution (from frame)

| # | Question            | Proposed resolution                                                                                                                                                                                                                     |
|---|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | Detection mechanism | Resolved by candidate choice — file existence (`compose`).                                                                                                                                                                              |
| 2 | Depth limit         | Max depth 8. Exceeding → error. Practical: no legitimate use case for deeper nesting. (#ground)                                                                                                                                         |
| 3 | Duplicate handling  | Deduplicate silently after full expansion. Consistent with existing `awk '!seen[$0]++'`.                                                                                                                                                |
| 4 | Expansion order     | Composite's composed tags first (in listed order), then stacked tags from prompt. Custom text appended after all modifier content. Rationale: the composite defines the base; the user's stacked tags override/augment. (#first-principles) |
| 6 | Composite README      | Yes, same convention as behaviors. Optional.                                                                                                                                                                                            |
| 7 | Naming convention   | Flat namespace, no prefix convention enforced. Users may adopt their own.                                                                                                                                                               |

## Choice

**Candidate B** — sibling `compose` file.

- `compose` file: single line of space-separated hashtags (e.g., `#=review #deep #challenge`).
- `prompt.md`: custom directive text (optional, only for composites that need it).
- Depth limit: 8. Error on exceed. Bump if a real use case appears.
- **REJECTED: Candidate A** — dual `prompt.md` semantics not worth the one-file savings.
- **REJECTED: Candidate C** — fragile positional detection, strictly worse than A.

---

# Spec

Restating the chosen approach: **Candidate B** — a sibling `compose` file in the behavior directory signals "this is a composite." `prompt.md` retains its existing semantics (inject-as-is) and, when present alongside `compose`, provides custom directive text for the composite.

## Scope

### S1: `compose` file contract

- **Location**: `behaviors/<name>/compose` or `.ai-behaviors/<name>/compose`.
- **Format**: single line of space-separated hashtags. Same syntax as user prompt input.
- **Example**: `#=review #deep #challenge #simulate`
- **Validation**: must contain ≥1 hashtag matching `#[=a-zA-Z0-9_-]+`. Empty file or file with zero hashtags → error.
- **No comments, no multi-line.** One line, hashtags only.

### S2: Directory resolution

Current `resolve_behavior()` returns a `prompt.md` path. Replace with directory-level resolution:

- **Input**: behavior name (without `#`).
- **Resolution order**: local `.ai-behaviors/<name>/` first, then repo `behaviors/<name>/`.
- **Valid directory**: contains `compose` (composite) OR `prompt.md` (leaf) OR both (composite with custom text).
- **Invalid**: directory exists but contains neither → treated as unknown.
- **No directory found** → unknown (existing behavior, unchanged).

A directory with both `compose` and `prompt.md`:
- `compose` → this is a composite, expand its hashtags.
- `prompt.md` → custom directive text, injected as modifier content.

A directory with only `prompt.md` → leaf behavior (status quo, zero change).
A directory with only `compose` → composite, pure macro, no custom text.

### S3: Expansion algorithm

Central function, used by main path (S4), continuation path (S5), and `#EXPLAIN` (S6).

**Input**: list of hashtags, depth counter (initially 0), seen set (initially empty).
**Output**: `(leaf_tags[], custom_texts[], missing[])`.

```
expand(tags, depth, seen):
  leaf_tags = []
  custom_texts = []
  missing = []

  for tag in tags:
    name = strip_hash(tag)
    dir = resolve_dir(name)

    if dir is empty:
      missing += tag
      continue

    if dir/compose exists:
      if name in seen → error: "Cycle: <seen path> → #name"
      if depth >= 8 → error: "Nesting too deep (max 8)"
      composed = parse_hashtags(dir/compose)
      (sub_leaves, sub_custom, sub_missing) =
        expand(composed, depth + 1, seen ∪ {name})
      leaf_tags += sub_leaves
      custom_texts += sub_custom
      missing += sub_missing
      if dir/prompt.md exists:
        custom_texts += (tag, content_of(dir/prompt.md))
    elif dir/prompt.md exists:
      leaf_tags += tag
    else:
      missing += tag

  return (deduplicate(leaf_tags), custom_texts, missing)
```

**Properties**:
- Deduplication: if `#deep` appears from both a composite and user stacking, keep one. (#ground)
- Custom texts are ordered: innermost composite first, outermost last. (#first-principles — this matches the dependency direction: base behaviors first, specializations layer on top.)
- Cycle detection uses the `seen` set — a tag appearing twice in the expansion path is a cycle.
- Depth limit is enforced pre-recursion (check before descending).

### S4: Main path integration

Current flow (hook lines 177–277). New flow:

1. Extract hashtags from prompt (existing regex, unchanged).
2. **Expand** all hashtags via S3 → `(leaf_tags, custom_texts, missing)`.
3. Reject multiple `#=` modes in `leaf_tags` (existing logic, applied to expanded list).
4. Separate mode from modifiers in `leaf_tags` (existing logic).
5. Load mode content from `prompt.md` (existing).
6. Load modifier content from `prompt.md` for each modifier (existing).
7. **Append custom texts** to modifier content. Each custom text block separated by `\n\n`, same as modifier-to-modifier separation.
8. Report missing (existing).
9. **Write state** — original hashtags from the prompt (pre-expansion), filtered to resolved-only. Not the expanded set.
10. Build XML output (existing structure, unchanged).

**Custom text placement**: always in `<behavior-modifiers>`, never in `<operating-mode>`. Even if the composite composes a mode, the composite's custom text is supplementary directives, not a mode definition. (#first-principles)

**Marking rule**: custom text from composite `#reviewer` triggers marking as `(#reviewer)`. The LLM sees the custom text in the modifiers block and attributes it to the composite name.

### S5: Continuation path integration

Current flow (hook lines 49–73): read state file → extract HARD CONSTRAINTs → emit. New flow:

1. Read state file → ACTIVE (may contain composite names + leaf names).
2. **Expand** all tags in ACTIVE via S3 → `(leaf_tags, custom_texts, missing)`.
3. For each tag in `leaf_tags`: find `prompt.md`, extract `-- HARD CONSTRAINT` lines.
4. For each entry in `custom_texts`: extract `-- HARD CONSTRAINT` lines.
5. Emit `"Active: " + ACTIVE` (original names, not expanded) + constraints + marking rule.

Key change: "Active:" displays the original names (e.g., `Active: #reviewer #concise`), not the expanded set. The user sees their composite name, not the internals.

### S6: `#EXPLAIN` integration

Current flow: resolve each tag → load content → wrap in `<behavior>` XML. New flow:

1. Collect explain tags (existing).
2. **Expand** composites via S3 (but don't activate — explain is read-only).
3. **Build expansion tree** for each composite. ASCII tree showing the nesting structure:
   ```
   <expansion-tree>
   #security-reviewer
   ├── #reviewer
   │   ├── #=review
   │   ├── #deep
   │   └── #challenge
   ├── #simulate
   └── #contract
   </expansion-tree>
   ```
   Non-composite tags (leaves used directly) don't get a tree — just their behavior block as today.
4. **Composite blocks**: show `<behavior name="#reviewer" role="composite">` with custom text from `prompt.md` (if any).
5. **Expanded leaf blocks**: show each as `<behavior name="#tag" role="mode|modifier">` (existing format).
6. The explain instruction adds: "If an expansion tree is provided, present it to show the user how composites compose into leaf behaviors."

The tree gives the user a structural overview before the detailed behavior content. For nested composites, the tree recurses — showing the full expansion hierarchy at a glance.

### S7: State persistence

- **Write**: original hashtags from prompt, filtered to those that resolve (composite or leaf). Space-separated. Composite names stored as-is (e.g., `#reviewer`), not expanded.
- **Read**: on continuation, expand composites via S3 before extracting constraints.
- **`#CLEAR`**: unchanged — empties the state file.

### S8: Error handling

| Condition | Message (stderr) | Exit code |
|---|---|---|
| Unknown hashtag | `Unknown behaviors: #foo #bar` | 0 (continue with known) |
| Multiple modes after expansion | `Conflict: multiple operating modes: #=review #=code. Use one at a time.` | 2 |
| Cycle detected | `Cycle detected: #a → #b → #a` | 2 |
| Depth exceeded | `Nesting too deep at #name (max depth 8)` | 2 |
| Empty compose file | `Empty compose file: behaviors/name/compose` | 2 |

Cycle and depth are fatal (exit 2) — there's no partial result to return. (#first-principles)
Unknown hashtags are non-fatal (existing behavior, unchanged).

### S9: ECA hook (`eca-inject-behaviors.sh`)

Same changes as S2–S8, applied to the ECA hook. The differences between hooks are only in plumbing:

| | Claude Code | ECA |
|---|---|---|
| Session ID field | `.session_id` | `.chat_id` |
| CWD field | `.cwd` | `.workspaces[0]` |
| State dir | `~/.claude/behaviors-state/` | `~/.config/eca/.behaviors/` |
| JSON output | `{ hookSpecificOutput: { hookEventName, additionalContext } }` | `{ additionalContext }` |

All composite logic (expansion, resolution, tree building, state) is identical. The expansion function (S3) and resolution function (S2) are shared — they don't touch hook-specific plumbing.

## Deferred

- **D1**: README updates — document composites in the catalog and custom behaviors section.
- **D2**: Example composites — ship 1–2 examples in the repo (e.g., `behaviors/security-reviewer/`).

## Constraints

- C1: No changes to existing leaf behaviors. All 38 current behaviors work identically.
- C2: No changes to `#CLEAR` logic.
- C3: Expansion function is pure (no side effects) — called from three paths, must not write state or emit output.
- C4: `compose` file parsing uses the same hashtag regex as prompt extraction. (#ground)

## Resolved Questions

- **Q1**: `#EXPLAIN` shows an ASCII expansion tree before the behavior blocks. Nested composites recurse in the tree.
- **Q2**: HARD CONSTRAINTs from custom text are attributed to the composite name (e.g., `#reviewer: <constraint>`).

## Test cases

### Expansion
- T1: Pure macro composite (compose only, no prompt.md) → expands to leaf tags.
- T2: Composite with custom text (compose + prompt.md) → leaf tags + custom text in modifiers.
- T3: Nested composite (composite → composite → leaves) → fully expanded leaf list.
- T4: Cycle detection (A → B → A) → error.
- T5: Depth limit exceeded → error.
- T6: Unknown tag in compose file → reported as missing, other tags expand.
- T7: Empty compose file → error.

### Stacking
- T8: `#composite #extra-modifier` → composite expanded + extra modifier added.
- T9: Duplicate after expansion (composite includes `#deep`, user also types `#deep`) → deduplicated.

### Mode constraint
- T10: Composite includes `#=review`, user stacks `#=code` → error.
- T11: Two composites each include a mode → error.
- T12: Composite includes a mode, user stacks modifiers only → ok.

### State persistence
- T13: State file stores `#composite #extra` (original), not expanded tags.
- T14: Continuation prompt re-expands composite, extracts constraints from all leaves + custom text.

### `#EXPLAIN`
- T15: `#EXPLAIN #composite` → shows composition + individual behaviors + custom text.
- T16: `#EXPLAIN` with active composite (from state) → same as T15.

### Backward compatibility
- T17: All existing leaf behavior tests pass unchanged.
- T18: Directory with only prompt.md → leaf behavior (no regression).

### Local override
- T19: Local `.ai-behaviors/name/compose` overrides repo `behaviors/name/compose`.
- T20: Local composite composes repo-level leaf behaviors → works across boundaries.

### ECA hook
- T21: ECA composite expansion produces same leaf content as Claude Code hook (shared logic, different JSON wrapping).
- T22: ECA state persistence stores composite name, continuation re-expands.
- T23: ECA `#EXPLAIN` with composite shows expansion tree.
