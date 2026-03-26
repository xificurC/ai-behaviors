# ai-behaviors

Does your LLM 

- edit code when you tell it not to? 
- fill in the blanks without asking?
- need to be constantly reminded what to do and not do?
- fail at finding what's missing from your request?
- think for 10 minutes than splash a conditional at the root of your project?
- always agree with you when you want it to argue and spar with you?

Then this framework is for you.

Shift what and how your LLM operates. (Claude Code and [ECA](https://eca.dev/) support.)

How? Add a couple of `#hashtag` behaviors to any prompt:

```
- Fix the auth bug #=debug #deep
- Review this PR #=review #challenge #deep
- Help me understand this #=mentor #first-principles
- Plan the migration #=spec #decompose #wide
- Find alternatives solutions to X #=research #deep #wide #meta
```

Behaviors stick until replaced — a `#=code #decompose #first-principles` prompt applies those behaviors to every response until your next prompt containing hashtags. A prompt without hashtags keeps the current behaviors. A prompt with new hashtags replaces the previous set entirely.

## Setup

Clone, then run `./install` for Claude Code, `./eca-install` for ECA. This symlinks a hook into your configuration. The hook reads behaviors directly from the repo — `git pull` updates everything.

## Catalog

Three dimensions: **modes** define the interaction contract, **qualities** modify how the LLM thinks, **techniques** add specific cognitive methods.

### Operating Modes

Modes define the interaction contract — what the LLM produces and what it will NOT do. Only one operating mode at a time — multiple modes will be rejected.

| Mode         | Use when                                   | Boundary                   |
|--------------|--------------------------------------------|----------------------------|
| `#=frame`    | You need to scope the problem first        | problem, not solutions     |
| `#=research` | You need facts, not opinions               | facts only                 |
| `#=design`   | You need to explore solution options        | candidates, not code       |
| `#=spec`     | You need a plan or decision                | plans, not code            |
| `#=code`     | You know what to build                     | requested scope            |
| `#=debug`    | Something's broken                         | root cause, not symptoms   |
| `#=review`   | You have code to evaluate                  | findings, not fixes        |
| `#=test`     | You want something broken                  | attacks, not fixes         |
| `#=drive`    | Pair programming — you steer, LLM types    | small steps                |
| `#=navigate` | Pair programming — LLM steers, you type    | direction, not code        |
| `#=record`   | Knowledge needs documenting                | capture, not invent        |
| `#=mentor`   | You want to learn while building           | explain, never just answer |
| `#=probe`    | You want to think it through yourself      | questions only             |

**Pipeline.** The first five modes trace a natural arc: frame → research → design → spec → code. Each produces the input the next one consumes. Frame scopes the problem without investigating. Research gathers evidence without recommending. Design explores solution candidates without committing. Spec structures the chosen approach without implementing. Code implements.

**Evaluation.** review reads and judges; test actively tries to break. Review is a critique; test is an assault.

**Pair programming.** drive and navigate are the same interaction with roles swapped — who steers vs who types.

**Learning.** mentor provides knowledge; probe draws out yours.

### Qualities

Qualities modify HOW your LLM thinks. Each controls an independent axis. Stack freely.

| Hashtag             | Axis              | Description                                                |
|---------------------|-------------------|------------------------------------------------------------|
| `#deep`             | Vertical reach    | Go beneath the surface, ask "why?" three times             |
| `#wide`             | Horizontal reach  | Look beyond the immediate, survey adjacent concerns        |
| `#ground`           | Referential rigor | Verify every term resolves, compositions don't contradict  |
| `#negative-space`   | Absence detection | Attend to what's missing FROM this, not around it          |
| `#challenge`        | Critical stance   | Find flaws, attack assumptions, construct counterarguments |
| `#steel-man`        | Charitable stance | Strengthen ideas before evaluating them                    |
| `#user-lens`        | Perspective       | Inhabit the user's position, stay there                    |
| `#concise`          | Output density    | Maximum signal, minimum tokens                             |
| `#first-principles` | Reasoning method  | Derive from axioms, not patterns or conventions            |
| `#creative`         | Solution space    | Seek unconventional approaches, cross-pollinate            |
| `#subtract`         | Direction bias    | Remove before adding, question necessity                   |
| `#meta`             | Scope elevation   | Apply active stances to the approach, not just the artifact|

Q: If there's `#creative`, why not also `#concrete`? `#verbose` to counter `#concise`?

A: The purpose of the qualities is to steer the LLM towards a new direction. LLMs are already concrete and verbose, if you need those qualities you don't need to add hashtags. Use these when you want to override the defaults.

Q: Why not just pick all qualities every time?

A: Because your needs don't reflect that. For some problem you want to `#=research #wide #creative` to find alternatives, for another you want to `#=research #deep #first-principles` to find the best implementation. For one document you want to `#=record #concise #subtract`, for another `#=record #steel-man #challenge`.

### Techniques

Techniques add a specific cognitive method. Each is orthogonal to the qualities and to each other.

| Hashtag      | Technique           | Description                                              |
|--------------|---------------------|----------------------------------------------------------|
| `#simulate`  | Mental execution    | Trace step by step, maintain exact state, flag anomalies |
| `#decompose` | Structural division | Break into independent subproblems, find natural seams   |
| `#factor`    | Dimensional analysis| Find independent dimensions, state value of each         |
| `#recursive` | Self-application    | Apply process to its own output, iterate until fixpoint  |
| `#fractal`   | Scale variation     | Apply at every scale — macro, meso, micro                |
| `#tdd`       | Test-driven cycle   | Red → green → refactor, one behavior at a time           |
| `#io`        | IO boundaries       | Pure core, impure shell — own every side effect          |
| `#contract`  | Correctness criteria| Pre/post/invariant — who owes what to whom               |
| `#backward`  | Reverse reasoning   | Start from end state, derive preconditions               |
| `#analogy`   | Structural transfer | Map structure from solved domains to unsolved ones       |
| `#temporal`  | Ordering analysis   | Consider all orderings, find the ones that break         |
| `#name`      | Naming precision    | If you can't name it precisely, the abstraction is wrong |
| `#checklist` | Scope tracking      | Track every spec item, force disposition, skip nothing   |
| `#stop`      | Boundary discipline | Stop at gaps, report provenance, don't cross phases      |

### Output-Channel Modifiers

Output-channel modifiers change where the output goes, not how the LLM thinks. They compose with any mode.

| Hashtag  | Description                                              |
|----------|----------------------------------------------------------|
| `#file`  | Persist structured output to a named file across modes   |

### Meta-Keywords

Meta-keywords are not behaviors — they control the hook itself.

| Keyword    | Description                                                   |
|------------|---------------------------------------------------------------|
| `#CLEAR`   | Deactivate all behaviors for the session                      |
| `#EXPLAIN` | Explain what a behavior combo would do, without activating it |

`#EXPLAIN` can be combined with behaviors (`#EXPLAIN #=code #deep`) or used alone to explain the currently active set. Cannot be combined with `#CLEAR`.

## Composition

One mode + any qualities/techniques/modifiers: `#=code #deep #subtract`, `#=design #file #challenge`

### Examples

| Combo                                 | Effect                                           |
|---------------------------------------|--------------------------------------------------|
| `#=code #tdd`                         | Test-driven implementation                       |
| `#=code #deep #challenge`             | Thorough, critically verified code               |
| `#=code #subtract #concise`           | Least code, least words                          |
| `#=review #challenge #deep`           | Deep code review, find real flaws                |
| `#=review #steel-man`                 | Appreciate what works, then find the flaws       |
| `#=review #fractal`                   | Review at system, module, function, line level   |
| `#=spec #deep #wide`                  | Spec-building that goes deep and surveys broadly |
| `#=spec #decompose #first-principles` | Break the spec into derived subproblems          |
| `#=frame #factor`                     | Scope the problem by identifying its independent dimensions |
| `#=design #factor`                    | Evaluate candidates along independent axes                  |
| `#=research #factor #deep`            | Investigate each dimension of the problem space in depth    |
| `#=frame #challenge`                  | Stress-test the problem framing                  |
| `#=design #deep #challenge`           | Deep candidate analysis, attack each option      |
| `#=design #first-principles`          | Derive candidates from constraints, not patterns |
| `#=design #file`                      | Persist candidate exploration to a file          |
| `#=test #challenge #simulate`         | Adversarial testing with mental execution traces |
| `#=debug #deep #simulate`             | Deep debugging, trace exact execution state      |
| `#=debug #backward`                   | Start from error, reason backward to cause       |
| `#=code #contract`                    | Pre/post/invariant on every function boundary    |
| `#=code #name`                        | Precise naming, challenge every vague label      |
| `#=spec #analogy`                     | Find structural analogs before designing         |
| `#=review #temporal`                  | Review for race conditions and ordering bugs     |
| `#=mentor #deep #first-principles`    | Teach from fundamentals, trace to axioms         |
| `#=probe #challenge`                  | Hard questioning, expose contradictions          |
| `#=spec #ground`                      | Verify spec terms are concrete before building   |
| `#=review #ground #challenge`         | Ground terms, then attack the logic              |
| `#=research #deep #wide`              | Investigate deeply and broadly                   |
| `#=record #concise`                   | Terse documentation, minimum words               |
| `#=navigate #wide #challenge`         | Direct strategy while surfacing risks            |
| `#deep #challenge #steel-man`         | Dialectic: strengthen then attack, in depth      |
| `#decompose #fractal`                 | Break apart at every scale                       |
| `#recursive #challenge`               | Multi-pass self-critique until stable            |
| `#=review #negative-space #deep`      | Find what's absent, then dig into why            |
| `#=spec #negative-space #wide`        | Surface missing requirements and adjacent gaps   |
| `#=code #user-lens #name`             | Build from user's perspective, name in their language |
| `#=review #deep #challenge #meta`     | Deep critical review that also audits its own framing |
| `#=code #contract #tdd`               | Test-driven with explicit contracts per function |
| `#=code #checklist`                   | Implement against a spec, track every item       |
| `#=code #checklist #decompose`        | Break spec into parts, track each independently  |
| `#=code #stop`                        | Implement, halt on any gap or surprise           |
| `#=code #stop #checklist`             | Implement spec items, halt on gaps, track all    |
| `#=debug #stop`                       | Diagnose bug, halt if cause is architectural     |

## Uninstall

```
cd ~/git/ai-behaviors
./uninstall
```

Removes the hook symlink and settings.json entry.

## Examples

See the output-examples folder on generated python snake games with various frameworks/approaches.

## How it works

1. `UserPromptSubmit` hook extracts `#hashtags` from your prompt
2. Resolves its symlink to find the repo
3. For each hashtag: if a `compose` file exists, recursively expands the composite to leaf behaviors
4. Reads `behaviors/<name>/prompt.md` for each leaf behavior (and composite custom text if present)
5. Injects the content as ephemeral additional context
6. The LLM follows the directives until the next prompt with hashtags replaces them

## Relation to plan mode

I don't use plan mode (I have a hook that disables it). The operating mode pipeline — frame → research → design → spec → code — offers more granular phase control than plan mode's binary plan/implement split. Each mode has an explicit boundary (frame can't research, research can't recommend, design can't commit without your choice, spec can't implement), so you control exactly when the LLM shifts from thinking to building. You can also move up and down the modes, `#=record` it once fully specced etc.

```
What problem are we solving? #=frame
What are the options for caching here? #=research #wide
What are the candidate approaches? #=design #challenge
I see, how does library X do it? #=research #deep
Back to candidates #=design
Let's go with approach B. Write it up #=spec #concise
Record it in doc/spec #=record
Implement it #=code #stop #decompose
```

Use `#file` to persist the pipeline to a shared artifact: `#=frame #file` starts a file that accumulates across modes, capturing decisions, rejections, and rationale. A new session can read the file and pick up where you left off.

That said, you can use plan mode, but I'd suggest not using an operating mode then. You lose the granularity of frame → research → design → spec but can still use qualities and techniques, e.g. `#deep #wide #fractal #decompose`.

## Structure

```
behaviors/
├── <behavior>/
│   ├── README.md      # human docs: what, why, rules, common prompts
│   ├── prompt.md      # terse text injected into the LLM's context
│   └── compose        # (composites only) hashtags this composite expands to
hooks/
└── inject-behaviors.sh
```

## Composites

A composite is a named composition of behaviors. Instead of typing `#=review #deep #challenge #simulate` every time, define it once:

```
mkdir behaviors/security-reviewer
echo "#=review #deep #challenge #simulate" > behaviors/security-reviewer/compose
```

Now `#security-reviewer` expands to all four behaviors. Stacking works — `#security-reviewer #concise` adds `#concise` on top.

**Custom text.** Add a `prompt.md` alongside `compose` for directives that only apply within this composite:

```
mkdir behaviors/security-reviewer
echo "#=review #deep #challenge #simulate" > behaviors/security-reviewer/compose
cat > behaviors/security-reviewer/prompt.md << 'EOF'
# #security-reviewer — Security Reviewer
Prioritize OWASP Top 10. Flag any use of unsafe or raw pointer manipulation.
EOF
```

**Nesting.** Composites can compose other composites. `#EXPLAIN` shows the expansion tree.

**Rules:**
- Same namespace as behaviors — no special syntax
- One operating mode after full expansion (same constraint as always)
- `compose` file: single line of space-separated hashtags
- State persists the composite name, not the expanded set
- Cycle detection and depth limit (max 8) are enforced

## Custom behaviors

Create your own behaviors or composites at three levels:

| Level             | Location                            | Scope             | Use for                                                |
|-------------------|-------------------------------------|-------------------|--------------------------------------------------------|
| **User-local**    | `~/.config/ai-behaviors/behaviors/` | All your projects | Personal review styles, composites, workflow shortcuts |
| **Project-local** | `.ai-behaviors/` at project root    | One project       | Project-specific conventions, team agreements          |
| **Repo**          | `behaviors/` in this repo           | Everyone          | Shared with upstream, updated via `git pull`           |

Resolution order: project-local → user-local → repo. First match wins.

### User-local (recommended for personal behaviors)

```
mkdir -p ~/.config/ai-behaviors/behaviors/my-review-style
cat > ~/.config/ai-behaviors/behaviors/my-review-style/prompt.md << 'EOF'
# #my-review-style — My Review Style
Focus on error handling and edge cases first.
Flag any function longer than 30 lines.
EOF
```

Now `#my-review-style` works in any project. Composites work the same way — add a `compose` file referencing any behaviors.

Respects `$XDG_CONFIG_HOME` if set (defaults to `~/.config`).

### Project-local

Create `.ai-behaviors/<name>/prompt.md` at your project root. Useful for project-specific behaviors that shouldn't follow you to other projects. Add `.ai-behaviors/` to `.gitignore` if these are personal, or commit them for team use.

### Repo-level

Add directly to `behaviors/` in this repo. These are shared — consider contributing upstream.

Custom behaviors follow the same rules: one `prompt.md` with terse directives. Add a `README.md` for your own reference if you like.

Q: There's plenty of CLAUDE.md / AGENTS.md files I can use for this, or I can write a skill, why would I use this?

You'd write "When doing X follow these rules: ...". You are a) implicitly and b) unconditionally instructing the LLM. Implicit can fail silently - it's a soft request. Unconditional cannot be turned off. Hashtags solve both problems - invoke when needed and the built-ins never fail - I iterated on their language and the framework until it stopped failing. The work's done for you - write up in prose the behavior you want, then tell the LLM to translate it into the language of the builtins.

## Design

Two audiences, two files:
- `README.md` — for humans: full explanations, rationale, examples
- `prompt.md` — for the LLM: terse imperatives, compressed rules (5-10 lines)

No configuration step. Behaviors are static. Tuning happens through combinations and prompt context.

The modifier hashtags (qualities + techniques) are designed to be **orthogonal** — each controls an independent axis of variation. Any combination produces a coherent, non-contradictory result. No two hashtags do the same thing.

## FAQ

**Does installing this change anything if I don't use hashtags?**

No. The hook only activates when it sees `#hashtags` in your prompt. If you never use them, the LLM behaves exactly as it would without the hook installed.

**Persisted hashtags mean I can lose state of which mode I'm in, how can I counter that?**

The hook persists the active hashtags in a session-scoped file. You can e.g. render it in the status line. Here's an example how to do it for Claude Code.

``` shell
INPUT=$(cat)
SESSION_ID=$(jq -r '.session_id // empty' <<< "$INPUT")

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

STATE_FILE="$HOME/.claude/behaviors-state/$SESSION_ID"
if [ -f "$STATE_FILE" ]; then
  TAGS=$(cat "$STATE_FILE")
  if [ -n "$TAGS" ]; then
    echo "[$TAGS]"
  fi
fi
```

**Will the active hashtags survive a compaction?**

Yes, the injected instructions include the logic to carry over the active hashtags. Also, every new user message includes a reminder of the active hashtags.
