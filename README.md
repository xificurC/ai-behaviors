# claude-behaviors

Add `#hashtags` to any prompt. Use one **operating mode** (`#op-*`) and any number of **qualities** or **techniques**:

```
- Fix the auth bug #op-debug #deep
- Review this PR #op-review #challenge #deep
- Help me understand this #op-mentor #first-principles
- Plan the migration #op-spec #decompose #wide
```

Behaviors stick until replaced — a `#op-code #decompose #first-principles` prompt applies those behaviors to every response until your next prompt containing hashtags. A prompt without hashtags keeps the current behaviors. A prompt with new hashtags replaces the previous set entirely.

Only one operating mode at a time — multiple `#op-*` hashtags will be rejected.

## Setup

Clone, then run `./install`. This symlinks a hook into `~/.claude/hooks/`. The hook reads behaviors directly from the repo — `git pull` updates everything.

## Catalog

Three dimensions: **modes** define the interaction contract, **qualities** modify how Claude thinks, **techniques** add specific cognitive methods.

### Operating Modes (`op-*`)

Modes define the interaction contract — what Claude produces and what it will NOT do. Use one at a time.

| Mode           | Use when                                   | Boundary                   |
|----------------|--------------------------------------------|----------------------------|
| `#op-research` | You need facts, not opinions               | facts only                 |
| `#op-assess`   | You need interpretation                    | insight, not action        |
| `#op-spec`     | You need a plan or decision                | plans, not code            |
| `#op-code`     | You know what to build                     | requested scope            |
| `#op-debug`    | Something's broken                         | root cause, not symptoms   |
| `#op-review`   | You have code to evaluate                  | findings, not fixes        |
| `#op-test`     | You want something broken                  | attacks, not fixes         |
| `#op-drive`    | Pair programming — you steer, Claude types | small steps                |
| `#op-navigate` | Pair programming — Claude steers, you type | direction, not code        |
| `#op-record`   | Knowledge needs documenting                | capture, not invent        |
| `#op-mentor`   | You want to learn while building           | explain, never just answer |
| `#op-probe`    | You want to think it through yourself      | questions only             |

**Pipeline.** The first four modes trace a natural arc: research → assess → spec → code. Each produces the input the next one consumes. Research gathers evidence without interpreting. Assess interprets without proposing action. Spec proposes without implementing. Code implements.

**Evaluation.** review reads and judges; test actively tries to break. Review is a critique; test is an assault.

**Pair programming.** drive and navigate are the same interaction with roles swapped — who steers vs who types.

**Learning.** mentor provides knowledge; probe draws out yours.

### Qualities

Qualities modify HOW Claude thinks. Each controls an independent axis. Stack freely.

| Hashtag             | Axis              | Description                                                |
|---------------------|-------------------|------------------------------------------------------------|
| `#deep`             | Vertical reach    | Go beneath the surface, ask "why?" three times             |
| `#wide`             | Horizontal reach  | Look beyond the immediate, survey adjacent concerns        |
| `#challenge`        | Critical stance   | Find flaws, attack assumptions, construct counterarguments |
| `#steel-man`        | Charitable stance | Strengthen ideas before evaluating them                    |
| `#concise`          | Output density    | Maximum signal, minimum tokens                             |
| `#first-principles` | Reasoning method  | Derive from axioms, not patterns or conventions            |
| `#creative`         | Solution space    | Seek unconventional approaches, cross-pollinate            |
| `#subtract`         | Direction bias    | Remove before adding, question necessity                   |

Q: If there's `#creative`, why not also `#concrete` or `#grounded`? `#verbose` to counter `#concise`?

A: The purpose of the qualities is to steer Claude to a new direction. Claude is already concrete and verbose, if you need those qualities you don't need to add hashtags. Use these when you want to override the defaults.

Q: Can I stack all qualities at once?

A: You can, but you'll get worse results than picking 2-3. Each quality is a steering force. `#deep` pulls toward depth, `#concise` pulls toward brevity — together they fight. `#creative` explores freely, `#first-principles` derives rigorously — together they blur. Each hashtag also consumes context window. Pick the 2-3 that matter most for *this* prompt. The power is in selection, not accumulation.

### Techniques

Techniques add a specific cognitive method. Each is orthogonal to the qualities and to each other.

| Hashtag      | Technique           | Description                                              |
|--------------|---------------------|----------------------------------------------------------|
| `#simulate`  | Mental execution    | Trace step by step, maintain exact state, flag anomalies |
| `#decompose` | Structural division | Break into independent subproblems, find natural seams   |
| `#recursive` | Self-application    | Apply process to its own output, iterate until fixpoint  |
| `#fractal`   | Scale variation     | Apply at every scale — macro, meso, micro                |
| `#tdd`       | Test-driven cycle   | Red → green → refactor, one behavior at a time           |
| `#io`        | IO boundaries       | Pure core, impure shell — own every side effect          |
| `#invariant` | Correctness criteria| State what must hold, verify after every change          |
| `#backward`  | Reverse reasoning   | Start from end state, derive preconditions               |
| `#analogy`   | Structural transfer | Map structure from solved domains to unsolved ones       |
| `#temporal`  | Ordering analysis   | Consider all orderings, find the ones that break         |
| `#name`      | Naming precision    | If you can't name it precisely, the abstraction is wrong |

## Composition

One mode + any qualities/techniques: `#op-code #deep #subtract`

### Examples

| Combo                                  | Effect                                           |
|----------------------------------------|--------------------------------------------------|
| `#op-code #tdd`                        | Test-driven implementation                       |
| `#op-code #deep #challenge`            | Thorough, critically verified code               |
| `#op-code #subtract #concise`          | Least code, least words                          |
| `#op-review #challenge #deep`          | Deep code review, find real flaws                |
| `#op-review #steel-man`                | Appreciate what works, then find the flaws       |
| `#op-review #fractal`                  | Review at system, module, function, line level   |
| `#op-spec #deep #wide`                 | Spec-building that goes deep and surveys broadly |
| `#op-spec #decompose #first-principles`| Break the spec into derived subproblems          |
| `#op-assess #wide`                     | Observe broadly without prescribing              |
| `#op-test #challenge #simulate`        | Adversarial testing with mental execution traces |
| `#op-debug #deep #simulate`            | Deep debugging, trace exact execution state      |
| `#op-debug #backward`                  | Start from error, reason backward to cause       |
| `#op-code #invariant`                  | State invariants, verify every change preserves  |
| `#op-code #name`                       | Precise naming, challenge every vague label      |
| `#op-spec #analogy`                    | Find structural analogs before designing         |
| `#op-review #temporal`                 | Review for race conditions and ordering bugs     |
| `#op-mentor #deep #first-principles`   | Teach from fundamentals, trace to axioms         |
| `#op-probe #challenge`                 | Hard questioning, expose contradictions          |
| `#op-research #deep #wide`             | Investigate deeply and broadly                   |
| `#op-record #concise`                  | Terse documentation, minimum words               |
| `#op-navigate #wide #challenge`        | Direct strategy while surfacing risks            |
| `#deep #challenge #steel-man`          | Dialectic: strengthen then attack, in depth      |
| `#decompose #fractal`                  | Break apart at every scale                       |
| `#recursive #challenge`                | Multi-pass self-critique until stable            |

## Uninstall

```
cd ~/git/claude-behaviors
./uninstall
```

Removes the hook symlink and settings.json entry.

## Examples

See the output-examples folder on generated python snake games with various hashtags.

## How it works

1. `UserPromptSubmit` hook extracts `#hashtags` from your prompt
2. Resolves its symlink to find the repo
3. Reads `behaviors/<name>/prompt.md` for each hashtag
4. Injects the content as ephemeral additional context
5. Claude follows the directives until the next prompt with hashtags replaces them

## Relation to plan mode

These behaviors work with or without Claude Code's built-in plan mode.

**With plan mode:** Use hashtags to shape how Claude plans and implements. `#op-spec #decompose` during planning; `#op-code #deep` during implementation. Hashtags persist across the plan/implement boundary until you replace them.

**Instead of plan mode:** The operating mode pipeline — research → assess → spec → code — offers more granular phase control than plan mode's binary plan/implement split. Each mode has an explicit boundary (research can't opine, assess can't propose, spec can't implement), so you control exactly when Claude shifts from thinking to building. Switch modes as you go:

```
What are the options for caching here? #op-research
Ok, which approach fits best? #op-assess
Write up the approach #op-spec
Implement it #op-code
```

## Structure

```
behaviors/
├── <behavior>/
│   ├── README.md      # human docs: what, why, rules, common prompts
│   └── prompt.md      # terse text injected into Claude's context
hooks/
└── inject-behaviors.sh
```

## Custom behaviors

Add your own hashtag by creating a directory under `behaviors/`:

```
mkdir behaviors/my-review-style
cat > behaviors/my-review-style/prompt.md << 'EOF'
# My Review Style
Focus on error handling and edge cases first.
Flag any function longer than 30 lines.
EOF
```

Now `#my-review-style` works like any built-in behavior.

To keep custom behaviors separate from upstream updates, either:
- prefix with `my-` and add `behaviors/my-*` to `.git/info/exclude`
- or simply gitignore specific directories

Custom behaviors follow the same rules: one `prompt.md` with terse directives. Add a `README.md` for your own reference if you like.

## Design

Two audiences, two files:
- `README.md` — for humans: full explanations, rationale, examples
- `prompt.md` — for Claude: terse imperatives, compressed rules (5-10 lines)

No configuration step. Behaviors are static. Tuning happens through combinations and prompt context.

The modifier hashtags (qualities + techniques) are designed to be **orthogonal** — each controls an independent axis of variation. Any combination produces a coherent, non-contradictory result. No two hashtags do the same thing.

## FAQ

**Does installing this change anything if I don't use hashtags?**

No. The hook only activates when it sees `#hashtags` in your prompt. If you never use them, Claude behaves exactly as it would without the hook installed.
