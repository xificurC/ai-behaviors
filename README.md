# ai-behaviors

Does your LLM 

- edit code when you tell it not to? 
- fill in the blanks without asking?
- need to be constantly reminded what to do and not do?
- fail at finding what's missing from your request?
- think for 10 minutes then splash a conditional at the root of your project?
- always agree with you when you want it to argue and spar with you?

Then this framework is for you.

How? Add a couple of `#hashtag` behaviors to any prompt:

```
- Fix the auth bug #Debug #deep
- Review this PR #Review #challenge #deep
- Help me understand this #Mentor #first-principles
- Plan the migration #Spec #decompose #wide
- Find alternative solutions to X #Research #deep #wide #meta
```

Shift what and how your LLM operates. (Claude Code and [ECA](https://eca.dev/) support.)

Behaviors stick until replaced — a `#Code #decompose #first-principles` prompt applies those behaviors to every response until your next prompt containing hashtags. A prompt without hashtags keeps the current behaviors. A prompt with new hashtags replaces the previous set entirely.

## Setup

Clone, then run `./install` for Claude Code, `./eca-install` for ECA. This symlinks a hook into your configuration. The hook reads behaviors directly from the repo — `git pull` updates everything.

## Easy Start

If you want to get a quick feel of how this works, then:

- in your first prompt, state your problem/task. Add `#Frame` at the end of your prompt. "I want to add feature X. #Frame"
- after a few iterations the LLM will suggest moving to `#Research`. Type it.
- follow the suggestions

This is already enough to use this framework. **If you want to start quickly you don't need to read further**. 

## Catalog

The framework consists of 3 main concepts:

- operating modes - define the interaction loop. Use at most one at a time.
- behaviors - adjust behavior. Use as many as you like.
- composites - compose any of these 3.

### Operating Modes

Modes define the interaction loop — who drives, what the LLM produces, and what it will NOT do. Modes are pure interaction patterns; they don't prescribe methodology. Only one operating mode at a time — in case of multiple modes the last one wins (this supports copy-pasting).

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

### Behaviors

Behaviors prescribe how the LLM works within a mode. Stack freely with any mode.

#### Qualities — thinking axes

Each controls an independent axis. Stack freely.

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

A: Because your needs don't reflect that. For some problem you want to `#=research #wide #creative` to find alternatives, for another you want to `#=research #deep #first-principles` to find the best implementation.

#### Methods — cognitive and structural approaches

Each is orthogonal to qualities and to each other. Some pair naturally with specific modes (noted in mode READMEs).

| Hashtag             | Method                | Description                                                |
|---------------------|-----------------------|------------------------------------------------------------|
| `#simulate`         | Mental execution      | Trace step by step, maintain exact state, flag anomalies   |
| `#decompose`        | Structural division   | Break into independent subproblems, find natural seams     |
| `#factor`           | Dimensional analysis  | Find independent dimensions, state value of each           |
| `#recursive`        | Self-application      | Apply process to its own output, iterate until fixpoint    |
| `#fractal`          | Scale variation       | Apply at every scale — macro, meso, micro                  |
| `#tdd`              | Test-driven cycle     | Red → green → refactor, one behavior at a time             |
| `#io`               | IO boundaries         | Pure core, impure shell — own every side effect            |
| `#fp`               | Functional style      | Immutable data, pure functions, composition, values over objects |
| `#contract`         | Correctness criteria  | Pre/post/invariant — who owes what to whom                 |
| `#backward`         | Reverse reasoning     | Start from end state, derive preconditions                 |
| `#analogy`          | Structural transfer   | Map structure from solved domains to unsolved ones         |
| `#ct`               | CT mapping            | Map concepts to categorical structure, name gaps           |
| `#temporal`         | Ordering analysis     | Consider all orderings, find the ones that break           |
| `#name`             | Naming precision      | If you can't name it precisely, the abstraction is wrong   |
| `#checklist`        | Scope tracking        | Track every spec item, force disposition, skip nothing     |
| `#stop`             | Boundary discipline   | Stop at gaps, report provenance, don't cross phases        |
| `#langlang`         | Knowledge compilation | Compile knowledge into orthogonal artifact (IS/IS NOT)     |
| `#bisect`           | Fault isolation       | Cut problem space in half by executing, observe, repeat    |
| `#epistemic`        | Epistemic rigor       | Label claims with source and confidence, distinguish fact/inference/gap |
| `#scq`              | Problem framing       | Situation / Complication / Question / Constraints / Non-goals |
| `#evaluate`         | Uniform evaluation    | Every item × every dimension, no cell skipped              |
| `#obligations`      | Priority levels       | MUST / SHOULD / MAY / WONT per item                        |
| `#triage`           | Finding triage        | Label (issue/suggestion/question/nitpick) + blocking + location |
| `#provenance`       | Origin tracking       | Track where every idea/claim/candidate came from           |
| `#wbs`              | Work breakdown        | Hierarchical decomposition, numbered, addressable          |
| `#falsifiable`      | Verification          | Every item has a done-condition or falsification-condition |
| `#boundary`         | Edge case testing     | Boundaries, sequences, environment, concurrency            |
| `#explain-first`    | Teach by explaining   | Explanation → code → comprehension check cycle             |

### Composites

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

#### Shipped composites

Each mode has a capitalized composite that bundles a curated default methodology. Three tiers of usage:

1. `#Debug` — curated default (composite, expands to `#=debug #bisect`)
2. `#=debug #backward` — explicit methodology choice (override the default)
3. `#=debug` — bare mode, LLM picks approach

| Composite   | Expands to                                         |
|-------------|----------------------------------------------------|
| `#Frame`    | `#=frame #scq`                                     |
| `#Research` | `#=research #epistemic`                            |
| `#Design`   | `#=design #evaluate #provenance`                   |
| `#Spec`     | `#=spec #wbs #obligations #epistemic #falsifiable` |
| `#Code`     | `#=code #contract #name #checklist`                |
| `#Debug`    | `#=debug #bisect`                                  |
| `#Review`   | `#=review #triage`                                 |
| `#Test`     | `#=test #boundary`                                 |
| `#Mentor`   | `#=mentor #explain-first`                          |
| `#Probe`    | `#=probe`                                          |
| `#Drive`    | `#=drive`                                          |
| `#Navigate` | `#=navigate`                                       |
| `#Record`   | `#=record`                                         |

Stack behaviors on top: `#Debug #deep`, `#Code #subtract`, `#Frame #factor`.

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

### Methodology composition

Modes define the interaction loop. Behaviors fill in the methodology. The same mode with different behaviors produces different approaches:

| Combo                                 | What happens                                     |
|---------------------------------------|--------------------------------------------------|
| `#=debug #bisect`                     | Debug by bisecting through execution             |
| `#=debug #simulate`                   | Debug by tracing execution mentally              |
| `#=debug #backward`                   | Debug by reasoning backward from the error       |
| `#=debug`                             | Debug loop, LLM picks approach                   |
| `#=frame #scq`                        | Frame with SCQ structure                         |
| `#=frame #scq #factor`                | Frame with SCQ and dimensional analysis          |
| `#=research #epistemic`               | Research with confidence-tagged findings         |
| `#=design #evaluate #provenance`      | Design with uniform evaluation + origin tracking |
| `#=spec #wbs #obligations`            | Spec with addressable, prioritized items         |
| `#=review #triage`                    | Review with labeled, located findings            |
| `#=test #boundary`                    | Test with systematic edge case categories        |
| `#=mentor #explain-first`             | Teach: explain → demonstrate → check             |
| `#=code #tdd`                         | Test-driven implementation                       |
| `#=code #deep #challenge`             | Thorough, critically verified code               |
| `#=code #subtract #concise`           | Least code, least words                          |
| `#=review #triage #deep`              | Deep review with triaged findings                |
| `#=review #steel-man`                 | Appreciate what works, then find the flaws       |
| `#=spec #wbs #obligations #decompose` | Prioritized spec, broken into subproblems        |
| `#=frame #factor`                     | Scope the problem by identifying its dimensions  |
| `#=design #evaluate #challenge`       | Uniform evaluation, stress-tested                |
| `#=design #first-principles`          | Derive candidates from constraints, not patterns |
| `#=test #boundary #deep`              | Exhaustive boundary testing                      |
| `#=debug #bisect #deep`               | Systematic bisection with deep investigation     |
| `#=code #contract`                    | Pre/post/invariant on every function boundary    |
| `#=research #epistemic #deep #wide`   | Deep, broad investigation with epistemic rigor   |
| `#=mentor #explain-first #deep`       | Deep teaching, explain → demonstrate → check     |
| `#=probe #challenge`                  | Hard questioning, expose contradictions          |
| `#=spec #ground`                      | Verify spec terms are concrete before building   |
| `#=record #concise`                   | Terse documentation, minimum words               |
| `#=design #ct`                        | Evaluate candidates through categorical structure |
| `#ct #analogy`                        | CT mapping + free-domain analogy in parallel      |
| `#=navigate #wide #challenge`         | Direct strategy while surfacing risks            |
| `#deep #challenge #steel-man`         | Dialectic: strengthen then attack, in depth      |
| `#=code #checklist #stop`             | Implement spec items, halt on gaps, track all    |
| `#=debug #stop`                       | Diagnose bug, halt if cause is architectural     |
| `#=research #langlang #deep`          | Discover orthogonal principles for a subject     |

## Uninstall

```
cd ~/git/ai-behaviors
./uninstall
```

Removes the hook symlink and settings.json entry.

## Examples

See the output-examples folder for generated python snake games with various frameworks/approaches.

## How it works

1. `UserPromptSubmit` hook extracts `#hashtags` from your prompt
2. Resolves its symlink to find the repo
3. For each hashtag: if a `compose` file exists, recursively expands the composite to leaf behaviors
4. Reads `behaviors/<name>/prompt.md` for each leaf behavior (and composite custom text if present)
5. Injects the content as ephemeral additional context
6. The LLM follows the directives until the next prompt with hashtags replaces them

## Relation to Claude Code's plan mode

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

I wanted to use these but none match the requirements:

- invoke explicitly when needed
- stick until next override
- auto-reinforce on next prompt
- consume context lazily
- obey rules unconditionally

## Design

**Modes = interaction loops.** Operating modes define ONLY the interaction pattern: who drives, what's exchanged, when the loop re-triggers. They don't prescribe methodology.

**Behaviors = everything else.** Behaviors prescribe how the LLM works within the loop: methodology, way of thinking, output format, constraints. They stack additively with any mode.

Two audiences, two files:
- `README.md` — for humans: full explanations, rationale, examples
- `prompt.md` — for the LLM: terse imperatives, compressed rules (5-10 lines)

No configuration step. Behaviors are static. Tuning happens through combinations and prompt context.

Behaviors are designed to be **orthogonal** — each controls an independent axis of variation. Any combination produces a coherent, non-contradictory result. No two behaviors do the same thing.

## Failure modes

LLMs operate on prose and as such can fail to follow our orders. The hashtags went through a lot of iterations. The operating modes don't fail me anymore. Some behaviors like `#bisect` are still flaky. If you encounter issues or have suggestions [please open an issue](https://github.com/xificurC/ai-behaviors/issues).

## FAQ

**Does installing this change anything if I don't use hashtags?**

No. The hook only activates when it sees `#hashtags` in your prompt. If you never use them, the LLM behaves exactly as it would without the hook installed.

**How can I quickly see what hashtags are active?**

Here's an example how to show the active hashtags in Claude Code's statusline, you can ask Claude to incorporate the snippet.

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

The hook persists the active hashtags in a session-scoped file. Other tools can read it too.

**Will the active hashtags survive a compaction?**

Yes, the injected instructions include the logic to carry over the active hashtags. Also, every new user message includes a reminder of the active hashtags.
