# Frame

## Problem
During pre-code phases (frame, research, design, spec), the human-AI collaboration has clear structure: alternating turns, explicit questions, user approval before proceeding. During the code phase, this structure disappears. When implementation hits a failure or a gap not covered by the spec, Claude attempts to reason about and fix the problem autonomously — breaking the cooperative dynamic.

## Motivation
The user has built a pipeline of phases (frame → research → design → spec → code) specifically to maintain control. The pre-code phases work. But the code phase collapses into unstructured autonomy the moment something goes wrong, undermining the entire pipeline's purpose.

## Non-goals
- Making Claude less capable at writing code
- Adding ceremony to the happy path (spec is clear, code works)
- Designing the debug/review/research behaviors themselves — those already exist

## Constraints
- C1: On failure or gap discovery, Claude must full-stop and report — not reason about fixes, not continue with other pieces
- C2: "Gap" means any deviation from the spec or any surprise that needs resolving — including environmental issues, missing dependencies, unexpected behavior. Start strict.
- C3: The existing phase transitions (#=debug, #=review, #=research) are the right tools for handling failures and gaps — the code phase should hand off, not absorb their responsibilities
- C4: Must not add overhead when things are working — the spec-to-working-code path should stay fast

## Resolved questions
- Q1: Gap = any deviation from spec, any surprise. Start strict, relax later if painful.
- Q2: Full stop. Cross-dependencies may exist between pieces.

## Open questions
(none)

---

# Research

## Thread 1: Is this just `#=drive`?

**Finding: No.** `#=drive` solves a different problem. Confidence: confirmed.

| Concern              | `#=drive`                      | Framed problem                    |
|----------------------|--------------------------------|-----------------------------------|
| Assumes spec exists? | No — user directs live         | Yes — spec is the input           |
| Failure policy       | "Flag concerns" (soft)         | Full stop (hard)                  |
| Phase transitions    | None — drive is a loop         | Hand off to debug/research/design |
| Happy-path overhead  | Check-in after every increment | None required (C4)                |

Drive is for interactive pairing on unclear work. The framed problem assumes clarity (a spec) and wants control only when clarity breaks down.

## Thread 2: Modify `#=code`?

**Observation:** `#=code`'s type signature only covers the happy path:
```
code :: Task → {WorkingCode, Tests}
when task is complete ⊣ {#=test, #=review}
```

There are no failure transitions. Every other pipeline mode has structured outputs for both success and non-success. Code's failure mode is unstructured — Claude falls back to default LLM behavior (reason and fix autonomously). This is the root cause. Confidence: confirmed (by examining all mode type signatures).

**Observation:** Adding failure handling directly to `#=code` would make the strict policy apply universally. Sometimes `#=code` is used outside the full pipeline (quick fix, standalone task). Full-stop-on-any-surprise might be painful there. Confidence: probable — depends on actual usage patterns.

## Thread 3: New modifier vs. mode change?

A modifier (e.g., `#strict` composing with `#=code`) would make the policy opt-in. But the user said "I want control after spec" — suggesting this should be default for post-spec work, not opt-in.

**Observation:** The composites system would allow a composite like `#=implement` that expands to `#=code` + a halt modifier. This makes the pipeline seamless without modifying `#=code` itself.

## Thread 4: The minimal fix — failure transitions on `#=code`

Adding failure transitions to `#=code`:
```
code :: Spec → {WorkingCode, Tests} | Halt{what, why, where}
on success ⊣ {#=test, #=review}
on halt ⊣ {#=debug, #=research, #=design}
```

This is the smallest change. It doesn't add a new behavior. It doesn't add overhead on the happy path. It fills a gap that exists in the current design.

**But:** this changes `#=code` for everyone, including standalone use. Is that acceptable?

## Thread 5: What's actually missing (root cause)

The pre-code modes work because they have:
1. **Structured output on every path** — frame produces sections, research produces threads, spec produces a document.
2. **Explicit boundaries** — "when X is done, suggest Y."

Code has (1) for success but not for failure. It has (2) for success but not for failure. The asymmetry is the bug.

The fix is not "add a stop command" — it's "give code a failure protocol like every other phase has." The stop-and-report behavior is the *consequence* of having a structured failure output, not the mechanism.

## Thread 6: What to steal from `#=drive`

Steel-manning drive: its "narrate what I'm about to do" pattern is exactly right for the failure moment. When something goes wrong, the useful act is: describe what happened, describe what you see, stop. This is drive's check-in pattern, applied only at failure boundaries rather than at every increment.

## Summary of findings

| Approach                        | Adds overhead on happy path? | Requires new behavior? | Changes existing `#=code`?       | Handles standalone `#=code` use? |
|---------------------------------|------------------------------|------------------------|----------------------------------|----------------------------------|
| Use `#=drive` instead           | Yes (every increment)        | No                     | No                               | N/A — different mode             |
| Modify `#=code` directly        | No                           | No                     | Yes — all users affected         | No — strict everywhere           |
| New modifier (`#strict`)        | No                           | Yes                    | No                               | Yes — opt-in                     |
| Failure transitions on `#=code` | No                           | No                     | Yes — but only adds failure path | Debatable                        |

**Key unknown:** Does the user use `#=code` outside the pipeline (without a preceding spec)? This determines whether modifying `#=code` directly is safe or whether a modifier/composite is needed.

## Resolved threads

- **Thread A:** `#=code` has other users — cannot be modified. Constraint: new mode or modifier only.
- **Thread B:** Moot — direct modification ruled out.

---

# Design

## Constraint: `#=code` is unchanged

The user has library users depending on `#=code`'s current behavior. All candidates must leave `#=code` untouched.

## Candidate A — New operating mode `#=implement`

A standalone mode for post-spec implementation. Contains the halt-on-failure protocol directly.

```
# #=implement — Implement
Execute a spec. Stop on any surprise.

implement :: Spec → {WorkingCode, Tests} | Halt{what, observed, expected, specRef}
implement ∩ {AutonomousFixing, ReasoningAboutFailures, ContinuingPastSurprises} = ∅    -- HARD CONSTRAINT
on success ⊣ {#=test, #=review}
on halt ⊣ {#=debug, #=research, #=design}

Read existing code first — match conventions. Every function: clear contract.
On any deviation from spec, any failure, any surprise: full stop.
Report: what happened, what was expected, where in the spec it diverges.
Suggest which phase to enter. Do not attempt to fix.
```

| Aspect | Assessment                                                                                                                                                                                                                                                                  |
|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Pros   | Self-contained. Clean pipeline name: spec → implement. Own type signature (`Spec →` not `Task →`). Failure transitions are first-class.                                                                                                                                     |
| Cons   | Duplicates `#=code`'s coding directives (match conventions, clear contracts). Two modes that both mean "write code" — users must know which to pick. (#ground — what *concretely* does `#=implement` say about writing code that `#=code` doesn't, beyond the halt policy?) |
| Gaps   | If `#=code` evolves (new coding directives), `#=implement` won't inherit them. Maintenance burden of parallel modes. (#deep — this is a second-order effect: the modes diverge over time.)                                                                                  |

## Candidate B — Modifier `#halt`

A modifier that adds halt-on-failure behavior. Composes with `#=code` (or any mode).

```
# #halt — Halt on Surprise
Stop on any deviation. Report, don't fix.

∀ failures, gaps, surprises: full stop. Report {what, observed, expected}.
halt ∩ {AutonomousFixing, ReasoningAboutFailures, ContinuingPastSurprises} = ∅    -- HARD CONSTRAINT

On halt, suggest: #=debug (if failure), #=research (if gap), #=design (if architectural).
Do not attempt to fix. Do not continue with other work.
```

Usage: `#=code #halt`

| Aspect | Assessment |
|---|---|
| Pros | No duplication — reuses all of `#=code`. Composable with any mode, not just code. Single responsibility: the halt policy is one thing, coding directives are another. A composite `#=implement` can sugar `#=code #halt` into one hashtag. |
| Cons | The halt policy is arguably a mode-level concern (it changes control flow), not a quality modifier. Existing modifiers affect *how* work is done (#deep, #file); this affects *when work stops*. (#ground — is a control-flow constraint the same kind of thing as #deep or #subtract?) |
| Gaps | The modifier doesn't change the type signature. `#=code`'s signature still says `Task → {WorkingCode, Tests}` — the `| Halt{...}` path is invisible in the formal notation. (#deep — is that a real problem or just aesthetic? The HARD CONSTRAINT does the actual work; the type signature is documentation.) |

## Candidate C — Composite `#=implement` = `#=code` + `#halt`

Not a separate candidate — it's Candidate B with a composite on top. Mentioned because it resolves the UX concern: the user types `#=implement` and gets `#=code #halt` without knowing or caring about the decomposition.

The composite directory:
```
behaviors/=implement/
├── compose    # #=code #halt
└── README.md
```

No `prompt.md` needed — no custom text beyond what `#halt` provides.

## Comparison

|  | A (new mode) | B (modifier) | C (B + composite) |
|---|---|---|---|
| `#=code` unchanged? | Yes | Yes | Yes |
| Duplicates code directives? | Yes | No | No |
| Maintenance when `#=code` evolves? | Manual sync | Automatic | Automatic |
| Single hashtag UX? | Yes (`#=implement`) | No (`#=code #halt`) | Yes (`#=implement`) |
| Halt policy reusable with other modes? | No — baked into implement | Yes | Yes |
| Type signature accuracy | Clean (`Spec → ... | Halt`) | Inherited from code (`Task → ...`) | Same as B |

## Tensions

**T1: Is halt a mode concern or a modifier concern?**
Existing modifiers change output quality/style. `#halt` changes control flow. But so does `#file` (changes where output goes) and arguably `#subtract` (changes what gets proposed). The line between "modifier" and "mode-level change" isn't crisp. (#deep)

Counter-argument: the halt policy *constrains* what `#=code` does — it doesn't replace it. That's exactly what modifiers are for. `#=code` says "write code"; `#halt` says "but stop if anything's off." The mode defines the activity; the modifier defines the guardrails. (#deep — third layer: this maps to how safety constraints work in general. You don't build a new car — you add brakes to the existing one.)

**T2: Type signature aesthetics vs. runtime behavior.**
Candidate A has a cleaner type signature. But the type signature is documentation for the LLM, not executable code. The HARD CONSTRAINT line does the enforcement. A modifier's HARD CONSTRAINT is just as binding as a mode's. (#ground — the type signature doesn't *do* anything; the constraint text does.)

## Recommendation

**Candidate C** (modifier `#halt` + composite `#=implement`).

- No duplication. `#=code` evolves, `#=implement` inherits.
- `#halt` is reusable — could compose with `#=drive` or future modes.
- Single hashtag via composite for pipeline use.
- The type-signature gap is real but cosmetic — the HARD CONSTRAINT carries the load.
- (#deep) The deepest argument: candidate A creates a parallel world that must be maintained. Candidate C is compositional — it follows the same principle that makes the rest of the behavior system work.

## User choice: Candidate B (modifier)

Rationale: avoids proliferating same-looking-but-slightly-different modes.

## Cross-mode analysis: where does `#halt` fit?

| Mode | Halt useful? | Why / why not |
|---|---|---|
| `#=code` | **Yes — primary case** | The motivating problem. Code has no failure protocol. |
| `#=drive` | **Marginal.** | Drive already has "check in after each logical unit." Halt would tighten "flag concerns" (soft) to "full stop" (hard). Adds something, but drive's rhythm already provides most of the control. |
| `#=test` | **Marginal.** | Test failures are the *output*, not a halt condition. But infrastructure failures (can't run tests, environment broken) could trigger halt. Narrow use case. |
| `#=debug` | **No.** | Debug's purpose is to investigate surprises. Halt would contradict it — when debugging hits something unexpected, you want Claude to dig deeper, not stop. |
| `#=frame` | **No.** | Structured Q&A. Nothing executes, nothing fails. |
| `#=research` | **No.** | Already has "don't fill gaps with guesses" and "surface unknowns." Research's own constraints already do what halt would do. |
| `#=design` | **No.** | Already requires user choice before committing. |
| `#=spec` | **No.** | Iterative dialogue with user approval. |
| `#=review` | **No.** | Read-only. Prohibits fixes already. |
| `#=navigate` | **No.** | Claude directs, user writes. No execution to fail. |
| `#=mentor` | **No.** | A failure during teaching is a teaching moment, not a halt condition. Stopping would hurt the learning. (#deep) |
| `#=probe` | **No.** | All questions, no actions. |
| `#=record` | **No.** | Already says "if unclear, ask." |

**Finding:** `#halt` is primarily a `#=code` companion. It has marginal utility with `#=drive` and `#=test`, and no meaningful fit with the other 10 modes.

**Tension:** This weakens the "reusable modifier" argument for B over A. If halt only really serves one mode, the compositional benefit is thin. (#deep — but the *other* argument for B still holds: no duplication, no maintenance burden, no parallel mode that diverges over time. Reusability was a bonus, not the core reason.)

## Reframing: from `#halt` to phase-boundary discipline

The original `#halt` framing: "stop on failure/surprise." This fits `#=code` well but is irrelevant to most modes because they don't execute things that fail.

**Reframing:** the trigger isn't failure — it's **crossing a phase boundary**. Failure is just the most common reason Claude crosses boundaries in code mode. The general abstraction: **don't absorb adjacent phases' work, even as an intermediate reasoning step.**

Existing modes already exclude adjacent outputs (`review ∩ {Fixes} = ∅`). What's missing in execution-oriented modes is excluding adjacent *process* — don't do debug's reasoning while in code, don't do design's reasoning while in debug.

### Cross-mode utility under reframing

| Mode                  | Boundary it could cross      | Concrete example                                                                                                 | Useful?            |
|-----------------------|------------------------------|------------------------------------------------------------------------------------------------------------------|--------------------|
| `#=code`              | Debug, research, design work | Code fails → Claude reasons about root cause (debug's job)                                                       | **Yes — primary**  |
| `#=debug`             | Design, spec work            | Root cause is architectural → Claude proposes new design (design's job)                                          | **Yes**            |
| `#=drive`             | Strategy decisions           | Direction unclear → Claude decides strategy instead of yielding (already soft-forbidden, modifier makes it hard) | **Yes — tightens** |
| `#=test`              | Spec interpretation          | Spec ambiguous on expected behavior → Claude interprets rather than surfacing (spec's job)                       | **Yes**            |
| `#=research`          | Opinions                     | Already hard-excluded                                                                                            | No — redundant     |
| `#=review`            | Fixes                        | Already hard-excluded                                                                                            | No — redundant     |
| `#=frame/design/spec` | Structured dialogue          | Already yields naturally                                                                                         | No — redundant     |

**Result:** under this reframing, the modifier is useful for 4 modes (code, debug, drive, test) — the execution-oriented modes. Same behavior for code as the original `#halt`, but now grounded in a general principle. (#ground)

### Candidate names for the reframed modifier

| Name        | Fit                                                                         |
|-------------|-----------------------------------------------------------------------------|
| `#halt`     | Too specific — "halt" implies failure, but the trigger is boundary-crossing |
| `#boundary` | Descriptive but could be confused with testing boundaries                   |
| `#defer`    | Good — "defer out-of-scope work to the right phase"                         |
| `#scope`    | Clean, but vague without context                                            |
| `#lane`     | Colloquial — "stay in your lane"                                            |
| `#yield`    | Good — "yield to the user on boundary"                                      |
| `#handoff`  | Good — "hand off to the right phase"                                        |

### Could the modifier replace existing mode exclusions?

**No.** The exclusions serve two different purposes:

| Layer                   | What it constrains                                    | Example                                              | Where it lives         |
|-------------------------|-------------------------------------------------------|------------------------------------------------------|------------------------|
| **Identity**            | Mode's output type — what it produces / won't produce | Review doesn't produce fixes                         | Mode's `∩ ∅` exclusion |
| **Boundary discipline** | Mode's process — what reasoning it won't do at edges  | Code doesn't reason about root causes (debug's work) | The modifier           |

For conversational modes (frame, research, design, spec, review), identity exclusions imply boundary discipline — if you can't produce code, you won't reason toward code. Removing the exclusions would destroy the mode's identity: review-without-no-fixes is not review.

For execution modes (code, debug, drive, test), identity exclusions do NOT imply boundary discipline — you can reason about root causes (debug's process) while still producing code (code's output). This is why the problem only manifests in execution modes.

**The modifier is a new layer, not a replacement for an existing one.**

## Design choice

**Candidate B, reframed:** a modifier enforcing phase-boundary discipline at the process level. Composes with any mode, primarily useful for the four execution-oriented modes (code, debug, drive, test). Not a replacement for existing identity exclusions.

**REJECTED candidates:**
- Modify `#=code` directly — other users depend on it.
- Use `#=drive` — solves different problem (research thread 1).
- Candidate A (new mode `#=implement`) — user chose B to avoid mode proliferation.
- `#halt` as originally framed — too narrow, misses the general abstraction.
- Factor out existing exclusions into the modifier — exclusions are identity (Layer 1), modifier is boundary discipline (Layer 2). Different layers, can't substitute.

**Name chosen:** `#stop`. Zero ambiguity, name is the instruction.

---

# Spec

Restating: `#stop` is a behavior modifier that enforces phase-boundary discipline. When the current mode encounters work that belongs to another phase, Claude must stop and report rather than absorb it. Composes with any mode; primarily useful for execution-oriented modes (code, debug, drive, test).

## Scope

### S1: `prompt.md`

```markdown
# #stop — Stop
Stop at gaps. Report, don't cross.

∀ boundary-crossings: full stop, report {provenance, what, observed, expected}.
stop ∩ {AutonomousFixing, CrossPhaseReasoning, ContinuingPastGaps} = ∅    -- HARD CONSTRAINT
Gap = any deviation, failure, surprise, or ambiguity that the current mode isn't built to resolve.
On halt: which spec item / assumption / decision led here, what happened, what was expected. Do not attempt to fix.
```

Grounding each term in the HARD CONSTRAINT: (#ground)
- `AutonomousFixing` — attempting to resolve a failure without user direction (e.g., modifying code to fix a test failure).
- `CrossPhaseReasoning` — reasoning about *why* something failed or *how* to fix it, which is debug/research/design's work. This is the key constraint: not just "don't fix" but "don't reason toward a fix."
- `ContinuingPastGaps` — moving on to the next piece of work after encountering a gap, even if the next piece appears independent. Full stop means full stop.

### S2: Report structure

On halt, Claude produces:
- **Provenance**: which spec item, assumption, or prior decision led to this point — the trail back to where the gap originates
- **What**: what was attempted and what happened
- **Observed**: the actual behavior/error/ambiguity
- **Expected**: what the spec/mode/task said should happen

No phase suggestion. The user routes themselves based on the provenance. (#deep — provenance is information, not advice. It decouples `#stop` from knowledge of other modes, making it a purer modifier. The user sees *where this came from* and decides *where to go next*.)

This is not a rigid template — it's the minimum content. The constraint is on *what to include when stopping*, not on *how to format it*.

### S3: File placement

```
behaviors/stop/
├── prompt.md    # S1 content
└── README.md    # S4 content
```

Standard behavior directory. No `compose` file — this is a leaf modifier, not a composite.

### S4: README.md

Brief description, usage examples, cross-mode notes. Content:
- What it does (one sentence)
- Example usage: `#=code #stop`, `#=debug #stop`
- What counts as a gap (the definition from the prompt)
- Note: primarily useful with execution-oriented modes; redundant with conversational modes that already have strict output exclusions

## Deferred

- D1: Composite `#=implement` (`#=code #stop`) — straightforward to add later via `compose` file. Not blocked on `#stop` itself.
- D2: Relaxation mechanisms — if strict stopping proves too painful in practice, a future iteration could add graduated responses (e.g., "flag but continue for environmental issues"). Not designed now; wait for real usage feedback.

## Constraints

- C1: `#=code` is unchanged. `#stop` is additive only.
- C2: No happy-path overhead. The modifier activates only when a gap is detected. When code is flowing, `#stop` is silent.
- C3: The prompt follows existing modifier conventions: title line, tagline, formal constraint, prose. Same structure as `#subtract`, `#contract`, `#deep`.

## Resolved questions

- Q1: ~~Phase suggestion~~ → Dropped. Report includes provenance instead. User routes themselves. This decouples `#stop` from other modes.

## Test cases

These are interaction-level, not code-level — they describe expected LLM behavior.

- T1: `#=code #stop` — code compiles, tests pass → no intervention from `#stop`. Happy path unaffected.
- T2: `#=code #stop` — test fails → Claude reports {what, observed, expected, provenance: spec item that produced this code}. Does not reason about the failure.
- T3: `#=code #stop` — spec says "use Redis for caching", but the codebase has no Redis dependency → Claude reports the gap with provenance (spec item S3 or whichever). Does not install Redis.
- T4: `#=code #stop` — spec is ambiguous on an edge case → Claude reports the ambiguity, traces provenance to the spec item. Does not interpret.
- T5: `#=debug #stop` — root cause identified as architectural flaw → Claude reports with provenance (which design decision led here). Does not propose a new architecture.
- T6: `#=test #stop` — spec unclear on expected behavior for an edge case → Claude reports with provenance. Does not assume intent.
- T7: `#=code #stop` — first item succeeds, second item hits a gap → Claude stops entirely. Does not deliver the first item's success and continue.
