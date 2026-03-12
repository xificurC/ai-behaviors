# claude-behaviors

Add `#hashtags` to any prompt. Use one **operating mode** (`#=<mode-name>`) and any number of **qualities** or **techniques**:

```
- Fix the auth bug #=debug #deep
- Review this PR #=review #challenge #deep
- Help me understand this #=mentor #first-principles
- Plan the migration #=spec #decompose #wide
```

Behaviors stick until replaced — a `#=code #decompose #first-principles` prompt applies those behaviors to every response until your next prompt containing hashtags. A prompt without hashtags keeps the current behaviors. A prompt with new hashtags replaces the previous set entirely.

Only one operating mode at a time — multiple `#=` hashtags will be rejected.

## Setup

Clone, then run `./install`. This symlinks a hook into `~/.claude/hooks/`. The hook reads behaviors directly from the repo — `git pull` updates everything.

## Catalog

Three dimensions: **modes** define the interaction contract, **qualities** modify how Claude thinks, **techniques** add specific cognitive methods.

### Operating Modes (`=*`)

Modes define the interaction contract — what Claude produces and what it will NOT do. Use one at a time.

| Mode         | Use when                                   | Boundary                   |
|--------------|--------------------------------------------|----------------------------|
| `#=research` | You need facts, not opinions               | facts only                 |
| `#=assess`   | You need interpretation                    | insight, not action        |
| `#=spec`     | You need a plan or decision                | plans, not code            |
| `#=code`     | You know what to build                     | requested scope            |
| `#=debug`    | Something's broken                         | root cause, not symptoms   |
| `#=review`   | You have code to evaluate                  | findings, not fixes        |
| `#=test`     | You want something broken                  | attacks, not fixes         |
| `#=drive`    | Pair programming — you steer, Claude types | small steps                |
| `#=navigate` | Pair programming — Claude steers, you type | direction, not code        |
| `#=record`   | Knowledge needs documenting                | capture, not invent        |
| `#=mentor`   | You want to learn while building           | explain, never just answer |
| `#=probe`    | You want to think it through yourself      | questions only             |

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

One mode + any qualities/techniques: `#=code #deep #subtract`

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
| `#=assess #wide`                      | Observe broadly without prescribing              |
| `#=test #challenge #simulate`         | Adversarial testing with mental execution traces |
| `#=debug #deep #simulate`             | Deep debugging, trace exact execution state      |
| `#=debug #backward`                   | Start from error, reason backward to cause       |
| `#=code #invariant`                   | State invariants, verify every change preserves  |
| `#=code #name`                        | Precise naming, challenge every vague label      |
| `#=spec #analogy`                     | Find structural analogs before designing         |
| `#=review #temporal`                  | Review for race conditions and ordering bugs     |
| `#=mentor #deep #first-principles`    | Teach from fundamentals, trace to axioms         |
| `#=probe #challenge`                  | Hard questioning, expose contradictions          |
| `#=research #deep #wide`              | Investigate deeply and broadly                   |
| `#=record #concise`                   | Terse documentation, minimum words               |
| `#=navigate #wide #challenge`         | Direct strategy while surfacing risks            |
| `#deep #challenge #steel-man`         | Dialectic: strengthen then attack, in depth      |
| `#decompose #fractal`                 | Break apart at every scale                       |
| `#recursive #challenge`               | Multi-pass self-critique until stable            |

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

I don't use plan mode (I have a hook that disables it). The operating mode pipeline — research → assess → spec > code — offers more granular phase control than plan mode's binary plan/implement split. Each mode has an explicit boundary (research can't opine, assess can't propose, spec can't implement), so you control exactly when Claude shifts from thinking to building. You can also move up and down the modes, `#=record` it once fully specced etc.

```
What are the options for caching here? #=research #=wide
Ok, which approach fits best? #=assess #challenge
I see, how does library X do it? #=research #deep
Let's use approach A. Write up the approach #=spec #concise
Record it in doc/spec #=record
Implement it #=code #decompose #recursive
```

That said, you can use plan mode, but I'd suggest not using an operating mode then. You lose the granularity of research → assess → spec but can still use qualities and techniques, e.g. `#deep #wide #fractal #decompose`.

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

**Persisted hashtags mean I can lose state of which mode I'm in, how can I counter that?**

The hook persists the active hashtags in a session-scoped file. You can e.g. render it in the status line. Here's an example.

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
