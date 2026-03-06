# Plan: Operating Modes vs Cognitive Stances

## Goal

Split the behavior system into two explicit categories:

- **Operating modes** (`op-<name>`) — prescribe the interaction loop between Claude and the user. Who drives, what Claude produces, what Claude does NOT do. One active at a time (by convention, not enforced).
- **Cognitive stances** (current names, unchanged) — modify HOW Claude thinks within any mode. Stack freely.

Users write `#op-developer #deep #pedantic` — one mode, two stances. The `op-` prefix makes the category visible in the hashtag itself.

## Constraints

- No hook changes required. `op-developer` is just a behavior named `op-developer` that resolves to `~/.claude/behaviors/op-developer.md`. The hook's regex already handles hyphens.
- No exit conditions in mode templates. Mode switching happens via hashtag replacement (already built into the hook's persistence model).
- No guardrails for mixing two modes. If someone writes `#op-developer #op-witness`, both inject. User's responsibility.
- No breaking changes. Existing behaviors keep their current names and content. Modes are new behaviors that coexist.
- The `configure` system (knobs/template) works unchanged for modes.

## Options Considered

### A. Prefix convention (`op-developer`)

New mode behaviors live in `behaviors/op-developer/` with their own template and knobs. Old behaviors untouched. Users choose which to use.

- Pro: Zero breaking changes. Zero hook changes. Naming makes the category self-documenting.
- Pro: `./behaviors/configure --list` naturally groups modes together (alphabetical: `op-*`).
- Con: `op-developer` is 3 chars longer than `developer`. Users type it a lot.
- Con: Parallel existence — `#developer` (stance) and `#op-developer` (mode) both exist. Could confuse.

### B. Short names for modes (`dev`, `wit`, `duck`)

Modes get short names. Stances keep long names. The brevity signals "this is a mode."

- Pro: Less typing. `#dev #deep` is terse.
- Con: Abbreviations are ambiguous. `#dev` could mean anything. Not self-documenting.
- Con: Collides with potential future behaviors.

### C. Category prefix in template, not in name

Keep current names. Add a `CATEGORY: mode` or `CATEGORY: stance` line in the template. Modes and stances look the same to the hook but self-declare their category.

- Pro: No naming changes. No parallel existence problem.
- Con: Not visible in the hashtag. User can't tell from `#developer` whether it's a mode or stance.
- Con: Composition guidance is invisible at the point of use.

### Chosen: Option A (`op-` prefix)

The visibility of the category in the hashtag name is the primary value. The 3-char cost is acceptable — modes are used once per prompt, not stacked.

## Mode Template Format

Modes use a structured template that declares the interaction contract:

```
# <Mode Name>
<One-line purpose.>
ROLE: <Claude's role in one phrase>
DRIVES: <User | Claude | Alternating>
PRODUCES: <what Claude outputs each turn>
PROHIBITS: <what Claude will NOT do — the hard constraint>
<2-4 lines of behavioral detail>
DO NOT: <additional constraints>
<Knobs if any>
```

Compare to stance template (unchanged):
```
# <Stance Name>
<Multi-line description of cognitive approach>
DO NOT: <constraints>
<Knobs>
```

The structural fields (ROLE, DRIVES, PRODUCES, PROHIBITS) are the mode contract. They're terse enough for the model to parse and rigid enough to enforce predictable behavior.

## Modes to Create

### From existing behaviors (retrofitted with mode structure)

These exist as stances today. The `op-` versions add the interaction contract.

| Mode | Source | DRIVES | PRODUCES | PROHIBITS |
|---|---|---|---|---|
| `op-developer` | developer | User | Code | Unrequested features, over-engineering |
| `op-witness` | witness | Claude | Observations | Fixing, judging, prescribing |
| `op-rubber-duck` | rubber-duck | User | Questions only | Answers, code, suggestions |
| `op-socratic` | socratic | Claude | Guided questions | Direct answers |
| `op-plan` | plan | Claude | Plan document | Code, implementation |
| `op-think` | think | Claude | Thought document | Code, implementation |
| `op-reviewer` | reviewer | User submits, Claude reviews | Numbered findings | Writing fixes |
| `op-qa` | qa | Claude | Exploit reports | Fixing bugs found |
| `op-mentor` | mentor | Alternating | Explanation → code → comprehension check | Skipping explanation, skipping check |
| `op-pair` | pair | Alternating | Code in small increments + check-ins | Large changes without checking in |

### New (no existing behavior to retrofit)

| Mode | DRIVES | PRODUCES | PROHIBITS |
|---|---|---|---|
| `op-advisor` | Claude proposes, user picks | Numbered options with tradeoffs | Choosing for the user, implementing |
| `op-spec` | Alternating | Growing specification document | Code, implementation |
| `op-interrogator` | Claude | Questions to build context, growing context doc | Assuming, inferring, guessing |
| `op-triage` | Claude | Priority-ranked item list | Acting on items, going deep on any single item |
| `op-devil` | User proposes, Claude attacks | Counterarguments, failure modes | Agreeing, supporting, implementing |

## Steps

### 1. Create mode directory structure

For each mode, create `behaviors/op-<name>/` with:
- `README.md` — human-facing docs explaining the mode, its interaction contract, and when to use it
- `template` — terse Claude-facing template using the mode format
- `knobs` — if the mode has configurable dimensions

Start with the 6 strongest modes (clearest interaction contracts):
1. `op-developer` — the default mode, most used
2. `op-witness` — already well-defined
3. `op-reviewer` — clean retrofit, high demand
4. `op-spec` — addresses the #1 finding from the snake comparison
5. `op-advisor` — fills the biggest gap (no "present options" mode exists)
6. `op-rubber-duck` — already well-defined

### 2. Write templates

Each template follows the mode format. Example for `op-reviewer`:

```
# Reviewer
Review code. Find issues. Do not fix them.
ROLE: Code reviewer
DRIVES: User submits code or points to files. Claude reviews.
PRODUCES: Numbered findings. Each: location, observation, severity, question for the author.
PROHIBITS: Writing fixes. Refactoring. Writing code. Suggesting implementations.
Review what is submitted. Do not expand scope. Address the code as-is.
Severity: ${severity}. Focus: ${focus}.
```

### 3. Write knobs

Each mode gets knobs for its configurable dimensions. Examples:

`op-developer`:
- pace (deliberate / flow / spike)
- seniority (junior / mid / senior / principal)
- error philosophy (defensive / offensive / contract)

`op-reviewer`:
- severity (nitpick everything / significant only / blocking only)
- focus (correctness / style / architecture / security)

`op-spec`:
- formality (informal notes / structured clauses / formal spec)
- scope (single feature / system / API contract)

### 4. Configure and generate

Run `./behaviors/configure op-<name>` for each new mode to generate `~/.claude/behaviors/op-<name>.md`.

### 5. Update README

Add a new section to the top-level README:

```markdown
## Operating Modes (`op-*`)

Modes define the interaction loop. Use one at a time. Combine with stances.

| Mode | Who drives | Claude produces | Example |
|---|---|---|---|
| `#op-developer` | User | Code | `#op-developer #deep #pedantic` |
| `#op-witness` | Claude | Observations | `#op-witness #deep` |
| `#op-reviewer` | User submits | Findings | `#op-reviewer #pedantic #security` |
| `#op-spec` | Alternating | Specification | `#op-spec #deep #negative-space` |
| `#op-advisor` | Claude proposes | Options | `#op-advisor #creative` |
| `#op-rubber-duck` | User | Questions | `#op-rubber-duck` |
| ...  | | | |

Stances modify HOW Claude works within a mode:
`#op-developer #deep #pedantic` = developer mode + deep analysis + obsessive correctness
```

### 6. Update AI_comparison.md

Add a section discussing how mode/stance separation would have changed the snake game comparison outcomes.

## Edge Cases

- **User uses `#developer` (old stance) and `#op-developer` (new mode) together**: Both inject. The mode template is more structured and will likely dominate. Not harmful, just redundant. Could document "prefer `op-` versions."
- **User uses two modes**: Both inject. Templates may conflict (one says "produce code," other says "produce questions"). User's problem per constraints, but documenting "one mode at a time" in the README is sufficient.
- **Mode + incompatible stance**: e.g., `#op-rubber-duck #creative`. Creative says "generate 3+ approaches" (output), rubber-duck says "questions only" (no output). The mode's PROHIBITS should win because it's an absolute constraint. Template wording matters — modes use "PROHIBITS" (absolute), stances use "DO NOT" (guidance).
- **Stances that are secretly modes**: Some current stances have mode-like behavior (#forensic, #debug). These could get op- versions later. Not blocking for initial release.
- **Knob overlap**: `op-developer` and `developer` both have pace/seniority knobs. User configures them separately via `./behaviors/configure op-developer` vs `./behaviors/configure developer`. Selections are independent — each behavior has its own `.selections/` entry.

## Open Questions

1. **Should old mode-like behaviors (developer, witness, rubber-duck, socratic) eventually be deprecated in favor of op- versions?** Or do they serve a purpose as lighter-weight stances? The stance version of `developer` ("write production code") is still useful as a modifier on other modes. `#op-reviewer #developer` could mean "review this code, and when you do, think like a production developer."

2. **How many modes in the first batch?** The plan lists 15 total. Shipping 6 strong ones first and iterating is safer than shipping 15 untested ones. Which 6?

3. **Should op-pair have sub-modes (navigator/driver) or a knob?** A knob is simpler: `role: Your role? navigator: direct the user, they write code / driver: you write code, user steers`. But knobs are set at configure time, not at prompt time. A user might want to switch mid-session. This argues for two separate modes: `op-navigate` and `op-drive`.

4. **Should `op-plan` and `op-think` exist, or are the current `plan` and `think` already modes?** They already have clear operating protocols (write to a file, don't implement). Adding `op-` versions would be redundant unless the templates are meaningfully different.

## Fitness Functions

- A mode template is well-defined if someone reading only the ROLE/DRIVES/PRODUCES/PROHIBITS lines can predict Claude's behavior without reading the rest.
- A mode is distinct from existing stances if removing the stance and keeping only the mode changes the interaction structure.
- The `op-` prefix is justified if users consistently use it to signal "I want the mode, not the stance."
- The system is working if `#op-spec #deep #negative-space` produces a spec-building dialog that surfaces ambiguities, and switching to `#op-developer` after produces an implementation that references the spec.

## User Feedback

- implement all operating modes listed, not just a subset. We want consistency
- don't keep shadow stances. Only #op-developer stays. Developer is not a stance, tdd or pedantic is.
- don't update AI_comparison etc. I will archive it as v1 and create a new comparison at some point.
- I changed my mind - reject 2 modes conflicts. It's easy now - if there's 2 hashtags prefixed with "op-" it's a conflict.
- op-pair should split into 2
- turn plan and think into operating modes as well
