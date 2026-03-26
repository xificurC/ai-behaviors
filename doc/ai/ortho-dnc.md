# Frame

## Problem

Are "orthogonalize" and "divide-and-conquer" genuinely missing techniques, or already covered by the existing repertoire?

## Motivation

Avoid adding behaviors that duplicate what compositions of existing behaviors already achieve. Every behavior must earn its place. (#subtract)

## Existing coverage

### Divide-and-conquer

**Verdict: fully covered.**

`#decompose` already says: *"Recursively decompose until each subproblem is trivially solvable"* with independence as the explicit goal. Combined with `#recursive` (apply until fixpoint), this IS divide-and-conquer. The repertoire also has `#fractal` (same lens at every scale) and `#backward` (decompose from end state). A `#divide-and-conquer` behavior would restate `#decompose` with different words.

### Orthogonalize

**Verdict: genuine gap — different operation than any existing behavior.**

`#decompose` is **structural**: big problem → smaller problems (parts to solve).
`#orthogonalize` is **analytical**: problem → N independent concerns, each with a value/range (a coordinate system for the problem space).

Decompose breaks the thing apart. Orthogonalize defines axes you can move along independently.

|                           | Decompose                      | Orthogonalize                                  |
|---------------------------|--------------------------------|------------------------------------------------|
| Operation                 | Split into parts               | Map to coordinate system                       |
| Input                     | A problem                      | A problem space                                |
| Output                    | N subproblems                  | N axes, each with a value/range                |
| Purpose                   | Solve parts independently      | Understand what you can vary independently     |
| Example: "design a chair" | seat, legs, back, joinery      | ergonomics, cost, aesthetics, durability       |
| What you do next          | Solve each subproblem          | Locate current position, explore tradeoffs     |

No existing behavior or composition names this move. `#decompose` + `#first-principles` gets close to finding the axes, but doesn't produce the "each axis has a value/range" parameterization, and the intent is different (solve vs. understand).

## Non-goals

- Adding divide-and-conquer as a behavior (covered by `#decompose`). (#subtract)
- Changing existing behaviors to accommodate this analysis.

## Constraints

- The repertoire is explicitly designed around orthogonal axes — a new behavior must not overlap with `#decompose`.
- Any new behavior must do something no composition of existing behaviors achieves concisely.

## Open questions

1. ~~Is the distinction real enough?~~ → Yes. Structural splitting vs. analytical parameterization.
2. ~~Output shape?~~ → "Here are the N axes and where we sit on each." Analysis move, not refactoring.
3. What's the name? → Open. See Research thread 1.
4. Independence strictness? → Open. See Research thread 2.
5. Scope of the behavior? → Open. See Research thread 3.

# Research

## Thread 1: Overlap audit

**Question:** Does any existing behavior already cover "map problem to N independent axes with values"?

Checked all 10 techniques and 12 qualities. Findings:

| Behavior | What it does | Overlap with orthogonalize | Confidence |
|---|---|---|---|
| `#decompose` | Split into subproblems | Shares independence criterion. Different output: parts vs. axes. | confirmed |
| `#first-principles` | Derive from axioms | Shares "find atoms." Different operation: build up vs. parameterize. | confirmed |
| `#wide` | Survey adjacent concerns | Breadth, not dimensionality. No axis/value output. | confirmed |
| `#deep` | Find layers beneath surface | Depth on one thread, not mapping to N independent threads. | confirmed |
| `#creative` | Diverge before converging | Explores solution space, doesn't parameterize problem space. | confirmed |
| `#analogy` | Map structure from solved domains | Transfer method, not analysis method. | confirmed |
| `#simulate` | Trace execution step by step | State tracking, not dimension identification. | confirmed |
| `#fractal` | Same lens at every scale | Scale variation, not axis identification. | confirmed |
| `#backward` | Reason from end state | Direction of reasoning, not parameterization. | confirmed |
| `#contract` | Pre/post/invariant | Boundary specification, not problem-space mapping. | confirmed |

**Finding:** No single behavior or obvious 2-behavior composition produces "here are the N axes and where we sit on each." The gap is real. (#ground)

Closest composition: `#decompose` + `#first-principles` finds independent atoms, but the output is subproblems to solve, not a coordinate system to navigate. You'd have to fight the behaviors' framing to get dimensional output. (#deep)

## Thread 2: Naming

**Question:** What should it be called?

### Round 1 — rejected

| Candidate              | Why rejected                                    |
|------------------------|-------------------------------------------------|
| `#orthogonalize`       | Too long (14 chars). User wants shorter.        |
| `#axes`, `#dimensions` | Nouns. Techniques are verbs. (#ground)          |
| `#parameterize`        | Implies configuration, not analysis. Also long. |
| `#orthogonal`          | Adjective. Techniques aren't adjectives.        |

### Round 2 — short verbs

| Candidate  | Chars | Meaning match                                                                                                                                                              | Cons                                                                                                                                              |
|------------|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| `#factor`  | 6     | Strong. "Factor the problem" = find its independent factors. Math lineage: prime factorization separates into irreducible independent components. Each factor has a value. | Could be confused with "factor out" (extract/remove). Also a noun ("factors to consider") — but so is "contract" and "analogy" in the repertoire. |
| `#resolve` | 7     | Physics: "resolve a force into orthogonal components." Exact operation we want.                                                                                            | "Resolve" primarily means "fix" or "decide" in everyday English. High ambiguity.                                                                  |
| `#span`    | 4     | Linear algebra: "what dimensions span this space?" Very short.                                                                                                             | Too many other meanings (time span, HTML span). Doesn't signal the operation clearly.                                                             |
| `#chart`   | 5     | "Chart the problem space." Cartography: define a coordinate system for a territory.                                                                                        | Could be read as "make a chart/diagram."                                                                                                          |
| `#map`     | 3     | "Map the problem to its dimensions."                                                                                                                                       | Extremely overloaded. Too generic. (#ground — what does `#map` resolve to without context? Nothing specific.)                                     |
| `#isolate` | 7     | "Isolate the independent concerns."                                                                                                                                        | Implies removing/quarantining, not identifying axes. Too close to `#decompose`.                                                                   |

**Finding (confirmed):** `#factor` is the strongest short-verb candidate. (#ground — verified: "factor" as a verb means "resolve or be resolvable into factors"; as a noun means "a circumstance, fact, or influence that contributes to a result." Both meanings align with the operation.)

**Finding (confirmed):** `#factor` is distinct from `#decompose`. Decompose = break into parts to solve separately. Factor = identify the independent factors that compose the space. Same independence criterion, different output shape and purpose. (#deep — layer 1: the words mean different things; layer 2: they produce different outputs; layer 3: they lead to different next-actions — solving subproblems vs. navigating tradeoffs.)

**Finding (probable):** Risk of `#factor` — "factor" is slightly less self-explanatory than `#decompose` (where the name IS the instruction). The prompt would need to do more work to signal "dimensions with values" rather than "things to consider." Mitigated by the prompt itself. (#deep)

**Unknown:** User preference. The name is a judgment call.

### Round 3 — stress-test against `#factor`

User leans toward `#factor`. Diverging to make sure nothing beats it. (#creative)

**Nearby verbs — same semantic neighborhood as "factor":**

| Candidate  | Chars | Why consider it                                                                  | How it compares to `#factor`                                                                                   |
|------------|-------|----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `#distill` | 7     | "Distill the problem to its essential dimensions." Implies reduction to essence. | Weaker: distill implies removing noise, not identifying independent axes. Doesn't produce a coordinate system. |
| `#dissect` | 7     | "Dissect the problem space." Implies careful analytical separation.              | Too close to `#decompose` — cutting into parts, not identifying dimensions.                                    |
| `#project` | 7     | Math: "project onto orthogonal bases." Exact linear algebra operation.           | Overloaded: software project, project management. Would confuse in `#=frame` context.                          |
| `#basis`   | 5     | Linear algebra: the basis vectors define the coordinate system. Short.           | Noun, not verb. "Basis the problem" doesn't work.                                                              |

**Cross-domain pollination — what other fields call this operation:** (#creative)

| Domain       | Term                                               | Verb form                 | Assessment                                                                                                     |
|--------------|----------------------------------------------------|---------------------------|----------------------------------------------------------------------------------------------------------------|
| Statistics   | Factor analysis                                    | `#factor`                 | Literally the name for finding independent latent dimensions. Strongest provenance.                            |
| Physics      | Resolve into components                            | `#resolve`                | Already rejected — "fix" ambiguity.                                                                            |
| Cartography  | Survey / triangulate                               | `#survey`, `#triangulate` | `#survey` is too passive (observe, not structure). `#triangulate` implies locating a point, not defining axes. |
| Music        | Voicing — separate a chord into independent voices | `#voice`                  | Evocative but too obscure. Nobody would guess the meaning. (#creative — the one that feels wrong.)             |
| Engineering  | Degrees of freedom                                 | `#dof`                    | Acronym. Opaque.                                                                                               |
| Spectroscopy | Decompose signal into frequency components         | `#spectrum`               | Noun. Also too close to decompose.                                                                             |

**The "inversion" test — how to make this name fail:** (#creative)
- `#factor` fails if the LLM reads it as "what factors should I consider?" (loose list, not independent axes with values). Mitigated by the prompt's hard constraint.
- `#factor` fails if the user types it and someone unfamiliar reads the conversation — they might think "factoring out code." But all techniques need their prompt to be self-explanatory; the hashtag is a trigger, not documentation. (#wide — impact on readability for others.)

**Adjacent concern — does `#factor` collide with anything in the ecosystem?** (#wide)
- No existing behavior uses "factor" in its name or description.
- `#decompose` prompt says "break into independent subproblems" — doesn't use the word "factor."
- The README's glossary doesn't use "factor."
- No collision found.

**Finding (confirmed):** `#factor` survives stress-testing. The statistics provenance ("factor analysis" = identifying independent latent dimensions) is exact. No candidate from rounds 1–3 beats it on the intersection of {short, verb, precise, distinct from existing behaviors}.

**Rejected in round 3:** `#distill` (wrong operation), `#dissect` (too close to decompose), `#project` (overloaded), `#basis` (noun), `#survey` (passive), `#triangulate` (wrong operation), `#voice` (obscure), `#spectrum` (noun + overlap).

## Thread 3: Independence strictness

**Question:** Must axes be truly orthogonal (independent), or is "minimize coupling" sufficient?

Three layers here: (#deep)

**Layer 1 — Mathematical reality:** True orthogonality means changing one axis has zero effect on others. In real problem spaces, dimensions often correlate (cost↔durability, performance↔readability). Enforcing true orthogonality would force the LLM to either reject correlated dimensions or artificially separate them.

**Layer 2 — Practical value:** The value of orthogonalizing isn't perfect independence — it's *making the axes of variation visible*. Even correlated dimensions are useful to name: "cost and durability are coupled here — moving one moves the other" is a valuable finding. Demanding pure orthogonality could suppress this.

**Layer 3 — Precedent in the repertoire:** `#decompose` says "independence is the goal" and "where impossible, name the coupling." This is the same pragmatic stance: aim for independence, name the residual coupling. (#ground)

**Finding (probable):** Same pattern as `#decompose` — orthogonality as goal, coupling as named finding, not a failure mode.

## Thread 4: Scope — find axes or also navigate?

**Question:** Does the behavior stop at "here are the N axes and values" or include "explore the tradeoff space"?

**Observation:** Every existing technique has a tight scope: (#ground)
- `#decompose` = split + verify completeness. Doesn't solve the subproblems.
- `#simulate` = trace + track state. Doesn't fix bugs found.
- `#backward` = reason from end. Doesn't execute forward.

**Inference:** Following the pattern, orthogonalize should stop at "identify axes, locate current position, name couplings." Tradeoff exploration is what the operating mode does with the axes — `#=design` explores tradeoffs, `#=frame` uses them for scoping. (#subtract — don't bundle exploration into the technique)

**Finding (probable):** Scope = identify axes + locate position + name couplings. Stop there.

## Unknowns

- **Naming** is a user preference, not researchable further.
- **How the LLM will actually behave** with this technique — whether it produces genuine dimensional analysis or just reframes decomposition. Only testable with a draft prompt. Not researchable from here.

## Proposed threads

Threads are largely exhausted — findings are stable and the unknowns are judgment calls or require design-phase artifacts. Suggest moving to `#=design` to draft the prompt and resolve naming.

# Design

## Decisions from prior phases

- **Name:** `#factor` (user chose)
- **Category:** technique
- **Independence:** goal, not absolute; name couplings (same pattern as `#decompose`)
- **Scope:** identify axes + locate current position + name couplings. Stop there.

## Design constraints (derived from first principles)

What MUST be true for this prompt to work? (#first-principles)

1. **Output shape must be axes-with-values, not a list.** Without this, the LLM defaults to "factors to consider" — a brainstorm, not dimensional analysis. The hard constraint must enforce the shape.
2. **Must not collapse into `#decompose`.** The LLM already knows decomposition well. If the prompt is vague, it will decompose. The prompt must make the distinction load-bearing.
3. **Must compose with operating modes.** `#=frame #factor` should produce scoping dimensions. `#=design #factor` should produce evaluation axes. The technique provides the lens, the mode provides the purpose.
4. **Must be ≤7 lines.** All existing technique prompts are 6-7 lines. (#first-principles — this isn't convention, it's a real constraint: longer prompts dilute the instruction's signal in the system prompt.)

## Failure modes (#challenge)

| Failure mode                                                     | How it happens                                        | Which candidates address it                     |
|------------------------------------------------------------------|-------------------------------------------------------|-------------------------------------------------|
| Loose-list: "here are some factors" (no values, no independence) | LLM reads "factor" as noun, produces brainstorm       | Hard constraint must require values per factor  |
| Decompose-in-disguise: axes that are really subproblems          | LLM's strong prior on decomposition                   | Explicit "not parts — axes" framing             |
| Dead analysis: axes identified, nobody uses them                 | Technique produces structure but no actionable output | "State where you are on each" forces grounding  |
| Over-enumeration: 15 axes, all trivial                           | No upper pressure on count                            | Should we constrain? Or let the mode handle it? |

On over-enumeration: `#decompose` doesn't constrain count either. The operating mode naturally limits it — `#=frame` wants few dimensions for scoping, `#=design` wants the significant ones for evaluation. Adding a count constraint would be arbitrary. (#first-principles — no constraint without a derivation.) (#challenge — but the risk is real: 15 shallow axes is worse than 4 deep ones. Counter: the LLM's tendency is toward manageable lists, not exhaustive ones. And composing with `#deep` would catch this.)

## Candidates

### Candidate A — Decompose-parallel structure

Mirrors `#decompose` closely in form. Relies on the hard constraint to distinguish output shape.

```
# #factor — Factor
Find the independent dimensions. State the value of each.

∀ problems: factored into independent dimensions with values. ∀ couplings: named.    -- HARD CONSTRAINT
Identify what you can vary independently. Each factor has a current value or range.
Independence is the goal. Where factors couple: name the coupling explicitly.
Verify: do the factors together span the problem? What's missing?
```

**Pros:** Familiar structure for users of `#decompose`. Completeness check mirrors decompose's "∀ subproblems solved → original solved."
**Cons:** Similarity to decompose might cause the LLM to blend them. Doesn't explicitly say "not parts." (#challenge — the very thing that makes it familiar also makes it vulnerable to decompose-collapse.)

### Candidate B — Explicit anti-decompose

Spends one line distinguishing from decompose. Costs a line but addresses the primary failure mode directly.

```
# #factor — Factor
Find the independent dimensions. State the value of each.

∀ problems: factored into independent dimensions with values. ∀ couplings: named.    -- HARD CONSTRAINT
Not parts to solve — axes to navigate. Each factor is a dimension you can move along.
State where you are on each axis: current value, range, or constraint.
Independence is the goal. Where factors couple: name the coupling.
```

**Pros:** "Not parts to solve — axes to navigate" directly blocks decompose-collapse. "State where you are" forces grounded output (current position, not just axis names).
**Cons:** Defining by negation ("not parts") is a weaker signal than defining by positive assertion. (#first-principles — what IS it, derived from axioms, rather than what it ISN'T.)
**Counter to con:** The negation earns its place because the LLM's decompose-prior is the primary failure mode. One line of negation prevents the most likely misfire. (#challenge)

### Candidate C — Minimal

Trusts the hard constraint and two guidance lines. Shortest possible.

```
# #factor — Factor
Find the independent dimensions. State the value of each.

∀ problems: factored into independent dimensions with values. ∀ couplings: named.    -- HARD CONSTRAINT
Each factor: a dimension you can vary independently, with a current value or range.
Where factors couple: name the coupling.
```

**Pros:** 5 lines. Maximum signal density. No decompose-reference avoids priming the LLM to think about decompose at all. (#first-principles — don't reference what you're not.)
**Cons:** No completeness check ("do factors span the problem?"). No explicit anti-decompose guard. (#challenge — if the primary failure mode is decompose-collapse, silence about it is a bet that the positive framing is sufficient. Is it?)

## Comparison

| Criterion | A | B | C |
|---|---|---|---|
| Blocks decompose-collapse | Weak (implicit) | Strong (explicit) | Medium (positive-only) |
| Forces grounded output (values) | Yes (hard constraint) | Yes (hard constraint + "state where you are") | Yes (hard constraint) |
| Completeness check | Yes ("span the problem?") | No | No |
| Line count | 6 | 6 | 5 |
| Defines by positive assertion | Yes | Partially (one negation line) | Yes |

**My assessment:** B is the strongest. The anti-decompose line ("not parts to solve — axes to navigate") is the single most important design decision — it addresses the highest-probability failure mode with six words. The "state where you are on each axis" grounds the output better than A's more abstract "current value or range." C is a principled bet that positive framing suffices, but it's a bet I wouldn't take given how strong the LLM's decomposition prior is. (#challenge — C's minimalism is elegant but fragile against the primary threat.)

However: B lacks the completeness check from A ("do the factors span the problem?"). This matters — without it, the LLM might identify 3 axes and miss 2. Propose hybrid: B + completeness line from A.

### Candidate D — B + completeness (proposed hybrid)

```
# #factor — Factor
Find the independent dimensions. State the value of each.

∀ problems: factored into independent dimensions with values. ∀ couplings: named.    -- HARD CONSTRAINT
Not parts to solve — axes to navigate. Each factor is a dimension you can move along.
State where you are on each axis: current value, range, or constraint.
Independence is the goal. Where factors couple: name the coupling.
Verify: do the factors together span the problem? What's missing?
```

**Pros:** All of B's strengths + completeness check. 7 lines — same as `#decompose`.
**Cons:** 7 lines is the ceiling. Every line must earn its place. Does "verify: span?" earn its line? (#challenge)
**Argument it earns it:** `#decompose` has the equivalent ("∀ subproblems solved → original solved"). Dimensional analysis without a completeness check is incomplete dimensional analysis. A missing axis is an unexamined assumption — the most dangerous kind. (#deep — layer 1: missing axes; layer 2: decisions made without seeing the axis; layer 3: invisible tradeoffs that bite later.)

## Narrowing prompts

1. **B vs D** — Is the completeness check worth the 7th line?
2. **"Not parts to solve"** — Does the anti-decompose line earn its place, or is it defining by negation unnecessarily? (#first-principles)

**User chose: D.**

**Rejected:** A (weak decompose guard), B (no completeness check), C (no decompose guard, no completeness check).

# Spec

User chose Candidate D. This spec covers two files: `prompt.md` and `README.md`.

## S1: prompt.md — the injected behavior

The exact text injected into the system prompt when `#factor` is activated.

```
# #factor — Factor
Find the independent dimensions. State the value of each.

∀ problems: factored into independent dimensions with values. ∀ couplings: named.    -- HARD CONSTRAINT
Not parts to solve — axes to navigate. Each factor is a dimension you can move along.
State where you are on each axis: current value, range, or constraint.
Independence is the goal. Where factors couple: name the coupling.
Verify: do the factors together span the problem? What's missing?
```

### Line-by-line audit (#ground)

| Line                                                                                        | Role                                               | Resolves to concrete instruction?                                                                                                 | Earns its place? (#subtract)                                                                                                                                                                                                 |
|---------------------------------------------------------------------------------------------|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `# #factor — Factor`                                                                        | Title. Matches `# #decompose — Decompose` pattern. | Yes — parsed by hook system.                                                                                                      | Required.                                                                                                                                                                                                                    |
| `Find the independent dimensions. State the value of each.`                                 | Tagline. Two imperatives: find + state.            | "independent dimensions" — yes, concrete. "value of each" — yes, concrete.                                                        | Yes — the tagline IS the behavior in miniature.                                                                                                                                                                              |
| (blank line)                                                                                | Separator.                                         | N/A                                                                                                                               | Required by format.                                                                                                                                                                                                          |
| `∀ problems: factored into independent dimensions with values. ∀ couplings: named.`         | Hard constraint. Two universals.                   | "factored into dimensions" — clear. "with values" — clear. "couplings named" — clear.                                             | Yes — the enforcement line.                                                                                                                                                                                                  |
| `Not parts to solve — axes to navigate.` + `Each factor is a dimension you can move along.` | Anti-decompose + positive definition.              | "parts to solve" grounds against decompose. "axes to navigate" grounds the alternative. "move along" — concrete spatial metaphor. | Yes — blocks primary failure mode (decompose-collapse). (#deep — without this line, the hard constraint alone doesn't distinguish factor from decompose; both say "independent." This line carries the semantic difference.) |
| `State where you are on each axis: current value, range, or constraint.`                    | Output shape instruction.                          | "current value" — concrete. "range" — concrete. "constraint" — concrete. Three options, exhaustive. (#ground)                     | Yes — forces grounded output, prevents dead analysis.                                                                                                                                                                        |
| `Independence is the goal. Where factors couple: name the coupling.`                        | Independence pragmatics.                           | Mirrors decompose pattern exactly.                                                                                                | Yes — without this, user might think coupled factors are failures.                                                                                                                                                           |
| `Verify: do the factors together span the problem? What's missing?`                         | Completeness check.                                | "span the problem" — do they cover the full space? "What's missing" — concrete prompt to look for gaps.                           | Yes — catches missing axes. (#deep — layer 1: missing axis; layer 2: invisible decisions; layer 3: tradeoffs that surface too late.)                                                                                         |

**Verdict:** All 7 lines earn their place. Nothing to cut. (#subtract)

### Term consistency check (#ground)

- "dimensions" (line 2, 4, 5) — used consistently to mean "axis of independent variation"
- "factors" (line 5, 7) — used consistently to mean "the identified dimensions" (the output)
- "value" (line 2, 4, 6) — used consistently to mean "position on an axis"
- "coupling" (line 4, 7) — same meaning as in `#decompose`
- "axes" (line 5, 6) — synonym for "dimensions" — used in the spatial-metaphor context. Acceptable: "dimension" is the abstract term, "axis" is the spatial concretization. Not contradictory. (#ground)
- "span" (line 8) — linear algebra: do the factors form a basis for the problem space? Consistent with the dimensional metaphor. (#ground)

No contradictions found.

## S2: README.md — the human documentation

Follows the pattern from `behaviors/decompose/README.md`: title, "why this resonates," rules, DO NOT.

### Draft

```markdown
# Factor

Find the independent dimensions. State the value of each.

## Why this resonates

Factor analysis — mapping a problem to its independent axes of variation — is distinct
from decomposition. Decomposition breaks a problem into parts to solve. Factoring
identifies the dimensions you can move along independently, and where you currently sit
on each. This produces a coordinate system for the problem space rather than a task list.

## Rules

- Identify the dimensions of the problem that can vary independently.
- Each factor has a current value, range, or constraint — state it.
- Independence is the goal. Where factors couple, name the coupling explicitly.
- Verify completeness: do the factors together span the problem? What's missing?
- The factors parameterize the space. They are not subproblems to solve.

## DO NOT

- Produce a loose list of "things to consider" without values or independence.
- Decompose into subproblems and call them factors.
- Identify axes without stating where you currently are on each.
- Treat coupled factors as failures — name the coupling, that's a finding.
```

### Audit of README (#ground, #subtract)

- **"Why this resonates"** — explains the distinction from decompose in concrete terms. Earns its place: a user reading the README needs to understand when to use `#factor` vs `#decompose`.
- **Rules** — 5 items, each maps to a line in the prompt. No rule is redundant with another. (#subtract)
- **DO NOT** — 4 items, each addresses a specific failure mode from the design phase. (#ground — every "do not" traces to a documented failure mode.)

## S3: Project README.md — technique table + composition examples

Three independent edits to `README.md`: (#decompose)

### S3a: Techniques table — add row after `#decompose`

```
| `#factor`    | Dimensional analysis| Find independent dimensions, state value of each         |
```

**Placement:** After `#decompose` (line 98). These are the two "structural analysis" techniques — grouping them makes the distinction visible. (#ground — placement isn't arbitrary; adjacency signals relatedness and invites comparison.)

### S3b: Composition examples — add `#factor` combos

```
| `#=frame #factor`                     | Scope the problem by identifying its independent dimensions |
| `#=design #factor`                    | Evaluate candidates along independent axes                  |
| `#=research #factor #deep`            | Investigate each dimension of the problem space in depth    |
```

**Why these three:** (#subtract — only add combos that show something non-obvious about `#factor`)
- `#=frame #factor` — the most natural pairing. Factoring IS a framing move. Shows the technique composing with the mode it's most useful in.
- `#=design #factor` — shows factors as evaluation axes, distinct from `#=design #decompose` (which would break the design into parts). The contrast matters. (#deep — layer 1: different output; layer 2: different decision-making process; layer 3: factors let you compare candidates along axes, decompose doesn't.)
- `#=research #factor #deep` — shows a 3-way composition. Factor identifies the dimensions, deep goes beneath each one.

**Not adding:** `#=code #factor` — factoring is an analysis technique, not a coding technique. Omitting it prevents misuse. (#subtract)

### S3c: No other README changes needed

- "Three dimensions" prose (line 34) — still accurate, `#factor` is a technique (#ground)
- Technique count — not stated numerically in README, no update needed (#ground)
- Design section's orthogonality claim (line 311) — `#factor` is orthogonal to all existing behaviors per research thread 1, claim holds (#ground)

## Deferred

- D1: Example output showing factored vs. decomposed output in the behavior README. Can add after testing.

## Constraints

- C1: File location must be `behaviors/factor/prompt.md` and `behaviors/factor/README.md`.
- C2: prompt.md must be exactly the 7-line format — the hook system parses line 1 for `# #name — Name`.
- C3: README.md is documentation only — not injected into prompts.
- C4: Project README edits must not reorder existing rows or change existing content.

## Open questions

- Q1: ~~Does the completeness check earn line 7?~~ → Yes, per audit. Closed.
- Q2: ~~Does the anti-decompose line earn its place?~~ → Yes, per audit. Closed.
- Q3: ~~Should the README include example output?~~ → Deferred to D1. Closed.
- Q4: ~~Does the project README need updating?~~ → Yes, S3 added. Closed.

---

# Debug bisection redesign

Surfaced during review of `#factor` composition with `#=debug`. The debug mode's prompt compressed away its bisection strategy, causing LLMs to random-walk over hypotheses instead of systematically narrowing.

## Decision: rewrite `#=debug` prompt (Candidate E)

**Root cause:** README had the right process (enumerate → eliminate most → repeat) but prompt.md compressed it to `Hypothesize → Experiment → Narrow` — three labels that lost operational content.

**Fix:** Replace hypothesis-experiment-narrow with recursive bisection: split → test → recurse.

**Rejected approaches:**
- Candidates A, B, C (list-all-candidates-first): wrong model — assumes space is enumerable upfront. User corrected: the space reveals itself as you descend, like git bisect.
- Standalone `#bisect` technique: doesn't earn its place — only serves debug. The fix belongs in the mode.

## Deliverables

### `#=debug` prompt.md (Candidate E)

```
# #=debug — Debug
Systematic fault isolation. Find root cause, not symptom.

debug :: Symptom → Reproduction → Bisect* → RootCause → Fix → RegressionTest; debug ∩ {ShotgunFixes, SymptomTreatment, SkippedReproduction} = ∅; when root cause is confirmed ⊣ {#=code}    -- HARD CONSTRAINT

Claude investigates; user provides symptoms and context.
Reproduce. Then bisect: split the problem space, test which half holds the fault, recurse.
Stop when the space is small enough to inspect. Experiment = execute, not reason.
Understand WHY before fixing. The fix might mask a deeper issue.
```

### `#=debug` README.md — updated process

Steps 2-4 (Hypothesize, Experiment, Narrow) → Step 2 (Bisect) + Step 3 (Stop). Added `#=debug #factor` to common prompts. Added "Experiment means execute and observe" standalone line.

### Project README — no changes needed

Debug mode table row ("Something's broken | root cause, not symptoms") still accurate. Existing debug composition examples still hold.

## Implementation status

| Item | Status |
|---|---|
| `behaviors/factor/prompt.md` | done |
| `behaviors/factor/README.md` | done |
| Project README: `#factor` technique row | done |
| Project README: `#factor` composition examples | done |
| `behaviors/=debug/prompt.md` rewrite | pending |
| `behaviors/=debug/README.md` update | pending |
| Project README: debug changes | not needed |
