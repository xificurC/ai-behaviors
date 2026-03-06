# claude-behaviors

Composable behavior hashtags for Claude Code. Type `#op-code #decompose #first-principles` in a prompt and Claude's behavior shifts accordingly.

## Setup

```
git clone <repo-url> ~/git/claude-behaviors
cd ~/git/claude-behaviors
./install
```

This symlinks the hook into `~/.claude/hooks/`. The hook reads behaviors directly from the repo — `git pull` updates everything.

## Usage

Add `#hashtags` to any prompt. Use one **operating mode** (`#op-*`) and any number of **qualities** or **operations**:

```
Fix the auth bug #op-debug #deep
Review this PR #op-review #challenge #deep
Help me understand this #op-mentor #first-principles
Plan the migration #op-spec #decompose #wide
```

Behaviors stick until replaced — a `#op-code #decompose #first-principles` prompt applies those behaviors to every response until your next prompt containing hashtags. A prompt without hashtags keeps the current behaviors. A prompt with new hashtags replaces the previous set entirely.

Only one operating mode at a time — the hook rejects prompts with multiple `#op-*` hashtags.

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

## Catalog

Three dimensions: **modes** define the interaction contract, **qualities** modify how Claude thinks, **operations** add specific cognitive techniques.

### Operating Modes (`op-*`)

Modes prescribe WHO drives, WHAT Claude produces, and what it will NOT do. Use one at a time.

**Build things:**

| Mode        | Use when                                            | Claude produces                                       |
|-------------|-----------------------------------------------------|-------------------------------------------------------|
| `#op-code`  | You know what to build                              | Working code that solves the stated problem           |
| `#op-drive` | You want pair programming — you steer, Claude types | Code in small increments with narration and check-ins |
| `#op-debug` | Something's broken                                  | Root cause analysis → targeted fix → regression test  |

op-code is autonomous: describe the problem, get a solution. op-drive is collaborative: you direct each step, Claude implements in small pieces. op-debug is investigative: Claude follows the reproduce→hypothesize→narrow→fix pipeline.

**Understand things:**

| Mode           | Use when                     | Claude produces                                       |
|----------------|------------------------------|-------------------------------------------------------|
| `#op-research` | You need facts, not opinions | Findings labeled confirmed/probable/uncertain/unknown |
| `#op-witness`  | You need interpretation      | Patterns, tensions, priorities — what it means        |
| `#op-spec`     | You need a plan or decision  | Options with tradeoffs, specifications, plans         |

These three form a pipeline. Research gathers evidence (no interpretation). Witness interprets what the evidence means (no action). Spec proposes what to do about it (no implementation). Use the one that matches how far along your thinking is.

**Evaluate things:**

| Mode         | Use when                  | Claude produces                                                |
|--------------|---------------------------|----------------------------------------------------------------|
| `#op-review` | You have code to review   | Numbered findings: location, severity, question for the author |
| `#op-test`   | You want something broken | Bug reports with reproduction steps, exploit scenarios         |

Review reads and judges. Test actively tries to break. Review is a critique; test is an assault.

**Learn and teach:**

| Mode         | Use when                              | Claude produces                                       |
|--------------|---------------------------------------|-------------------------------------------------------|
| `#op-mentor` | You want to learn while building      | Explanation (why) → code (what) → comprehension check |
| `#op-probe`  | You want to think it through yourself | Questions only — never answers, never hints           |

Mentor provides knowledge. Probe draws out yours.

**Other:**

| Mode           | Use when                                   | Claude produces                                         |
|----------------|--------------------------------------------|---------------------------------------------------------|
| `#op-navigate` | Pair programming — Claude steers, you type | Strategy, direction, code review of your implementation |
| `#op-record`   | Knowledge needs to become a document       | Markdown — decisions, guides, runbooks                  |

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

### Operations

Operations add a specific cognitive technique. Each is orthogonal to the qualities and to each other.

| Hashtag      | Technique           | Description                                              |
|--------------|---------------------|----------------------------------------------------------|
| `#simulate`  | Mental execution    | Trace step by step, maintain exact state, flag anomalies |
| `#decompose` | Structural division | Break into independent subproblems, find natural seams   |
| `#recursive` | Self-application    | Apply process to its own output, iterate until fixpoint  |
| `#fractal`   | Scale variation     | Apply at every scale — macro, meso, micro                |

## Composition

One mode + any qualities/operations: `#op-code #deep #subtract`

### Examples

| Combo                                  | Effect                                           |
|----------------------------------------|--------------------------------------------------|
| `#op-code #deep #challenge`            | Thorough, critically verified code               |
| `#op-code #subtract #concise`          | Least code, least words                          |
| `#op-review #challenge #deep`          | Deep code review, find real flaws                |
| `#op-review #steel-man`                | Appreciate what works, then find the flaws       |
| `#op-review #fractal`                  | Review at system, module, function, line level   |
| `#op-spec #deep #wide`                 | Spec-building that goes deep and surveys broadly |
| `#op-spec #decompose #first-principles`| Break the spec into derived subproblems          |
| `#op-witness #wide`                    | Observe broadly without prescribing              |
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
