# claude-behaviors

Add `#hashtags` to any prompt. Use one **operating mode** (`#op-*`) and any number of **qualities** or **operations**:

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

Three dimensions: **modes** define the interaction contract, **qualities** modify how Claude thinks, **operations** add specific cognitive techniques.

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

### Operations

Operations add a specific cognitive technique. Each is orthogonal to the qualities and to each other.

| Hashtag      | Technique           | Description                                              |
|--------------|---------------------|----------------------------------------------------------|
| `#simulate`  | Mental execution    | Trace step by step, maintain exact state, flag anomalies |
| `#decompose` | Structural division | Break into independent subproblems, find natural seams   |
| `#recursive` | Self-application    | Apply process to its own output, iterate until fixpoint  |
| `#fractal`   | Scale variation     | Apply at every scale — macro, meso, micro                |
| `#tdd`       | Test-driven cycle   | Red → green → refactor, one behavior at a time           |
| `#io`        | IO boundaries       | Pure core, impure shell — own every side effect          |

## Composition

One mode + any qualities/operations: `#op-code #deep #subtract`

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

## Structure

```
behaviors/
├── <behavior>/
│   ├── README.md      # human docs: what, why, rules, common prompts
│   └── prompt.md      # terse text injected into Claude's context
hooks/
└── inject-behaviors.sh
```

## Design

Two audiences, two files:
- `README.md` — for humans: full explanations, rationale, examples
- `prompt.md` — for Claude: terse imperatives, compressed rules (5-10 lines)

No configuration step. Behaviors are static. Tuning happens through combinations and prompt context.

The modifier hashtags (qualities + operations) are designed to be **orthogonal** — each controls an independent axis of variation. Any combination produces a coherent, non-contradictory result. No two hashtags do the same thing.
