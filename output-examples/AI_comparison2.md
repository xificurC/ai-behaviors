# Snake Game Implementation Comparison (Current Systems Only)

Four configurations. One bare prompt. Two external prompt-engineering systems. One operation-modes pipeline. Same base prompt, radically different outcomes.

---

## The Question

The bare prompt produces a working snake game in 75 seconds. What do you actually get by adding a prompt-engineering system on top?

| System          | Mechanism                                         | Time   | Answer                                                                             |
|-----------------|---------------------------------------------------|--------|------------------------------------------------------------------------------------|
| None (baseline) | Raw model output                                  | 1m 15s | A working game with reasonable defaults and silent bugs                            |
| Nucleus         | Symbolic/mathematical framing                     | 1m 1s  | Nothing measurable                                                                 |
| BASHES          | Six-persona structured dialectic                  | 1m 45s | Two correctness fixes                                                              |
| Operation-modes | Spec → build → QA pipeline with role prohibitions | ~30m   | A different game, built to a formal spec, with 52 tests and 2 bugs found and fixed |

---

## Inventory

| Folder            | System                                            | Files            | Lines (non-test) | Tests | Time   |
|-------------------|---------------------------------------------------|------------------|------------------|-------|--------|
| `_`               | (none)                                            | 1                | ~264             | 0     | 1m 15s |
| `nucleus`         | nucleus prompt                                    | 1                | ~249             | 0     | 1m 1s  |
| `bashes`          | BASHES dialectic prompt                           | 1                | ~245             | 0     | 1m 45s |
| `operation-modes` | #op-spec → #op-developer → #op-qa → #op-developer | 2 + 2 test files | ~440             | 52    | ~30m † |

† Breakdown: spec (2m 20s + 1m 57s + 4m 32s) → implementation (14m 21s) → QA (5m 39s) → fixes (1m 34s). The developer phase is inflated by an API token limit error on the first attempt.

---

## 1. Architecture

All three single-prompt runs produce a single `snake_game.py` containing game logic, rendering, and main loop. The operation-modes version splits into `model.py` (195 lines, pure logic) and `snake_game.py` (245 lines, pygame rendering), driven by `#tdd` in the developer-phase modifiers requiring a testable model.

| Implementation    | Files            | Architecture     |
|-------------------|------------------|------------------|
| `_`               | 1                | Monolith         |
| `nucleus`         | 1                | Monolith         |
| `bashes`          | 1                | Monolith         |
| `operation-modes` | 2 + 2 test files | Model/view split |

The model/view split is the minimum useful separation: game logic testable without pygame. The three monoliths are all correct. The split exists because of testability requirements, not complexity requirements. On an 8x8 snake game, the monolith is the honest architecture.

---

## 2. The Snake Itself

### 2.1 Data Structure

| Implementation    | Structure | Head Position              | Notes                            |
|-------------------|-----------|----------------------------|----------------------------------|
| `_`               | `deque`   | last element (`snake[-1]`) | Tail-first                       |
| `nucleus`         | `deque`   | last element (`snake[-1]`) | Tail-first                       |
| `bashes`          | `deque`   | first element (`snake[0]`) | Head-first, state dict not class |
| `operation-modes` | `list`    | last element (`body[-1]`)  | Tail-first, `Pos` NamedTuple     |

Baseline and nucleus made the same choice. BASHES diverged (head-first). Operation-modes used tail-first like baseline but with `NamedTuple` positions — a formality that traces to the spec phase defining a coordinate system explicitly.

### 2.2 Starting Position

| Implementation    | Head Position | Y Coordinate |
|-------------------|---------------|--------------|
| `_`               | (4, 4)        | 4            |
| `nucleus`         | (4, 4)        | 4            |
| `bashes`          | (4, 4)        | 4            |
| `operation-modes` | (4, 4)        | 4            |

Complete agreement — all chose y=4. But operation-modes is the only one where this was explicitly confirmed by the user. The spec phase asked "Which 3 cells exactly?" and locked it as requirement N1. The other three made the same choice silently.

### 2.3 Direction Representation

| Implementation    | Type                                        | Values                                              |
|-------------------|---------------------------------------------|-----------------------------------------------------|
| `_`               | Strings + dict                              | `"UP"`, `"DOWN"`, `"LEFT"`, `"RIGHT"`               |
| `nucleus`         | Strings (lowercase) + dict                  | `"up"`, `"down"`                                    |
| `bashes`          | Strings + dicts                             | `"UP"`, `"DOWN"` + `DIRECTIONS` + `OPPOSITES` dicts |
| `operation-modes` | `Enum` with tuple values + `OPPOSITES` dict | `Dir.UP = (0, -1)`, `OPPOSITES[Dir.UP] = Dir.DOWN`  |

The three single-prompt runs all use strings — the model's default for direction when no type system is demanded. Operation-modes uses an Enum, driven by the `#tdd` modifier's influence on code structure (enums make test assertions more readable and refactoring safer).

---

## 3. Critical Bug Analysis

### 3.1 The Tail-Vacancy Edge Case

When the snake moves without growing, its tail vacates a cell. If the head moves into that cell on the same tick, is it a collision?

**Correct answer**: No. The tail leaves before the head arrives.

| Implementation    | Handles Correctly?                                            |
|-------------------|---------------------------------------------------------------|
| `_`               | NO — checks full body before tail removal                     |
| `nucleus`         | NO — `if (nx, ny) in self.occupied()`                         |
| `bashes`          | YES — `set(snake) if grow > 0 else set(list(snake)[:-1])`     |
| `operation-modes` | YES — `body[1:]` if `pending_growth == 0` (tail at index 0) ‡ |

‡ The operation-modes spec explicitly required this. The adversarial review asked "Is moving the head into the current tail position legal?" and the user confirmed yes. Codified as spec step 8.4. This is the only implementation where tail-vacancy handling traces to a verified requirement.

**What this reveals**: Baseline and nucleus both have this bug. BASHES caught it during self-review after the dialectic — not during the debate itself. Operation-modes caught it because the spec phase asked about it. Two different mechanisms (internal review vs external specification), same result.

### 3.2 The Growth Timing Bug

The baseline implements immediate growth by duplicating the tail position — creating a snake with non-unique coordinates. This is a latent bug affecting visual rendering and collision detection during multi-cell growth from stars.

All other implementations (nucleus, BASHES, operation-modes) use deferred growth (decrement a counter, skip tail removal). The operation-modes version additionally eliminates multi-cell growth entirely: stars give +5 points with zero growth. The spec change ("late-game stars are a trap") removed the bug class at the design level.

### 3.3 Bugs Found by QA (Operation-Modes Only)

The `#op-qa` phase found 2 bugs the developer phase missed:

1. **Premature win when star blocks apple placement**: Snake at 63 cells eats apple. Star on the only free cell. `_free_cells()` returns empty → false WIN. Fixed by checking `len(body) == 64` instead of `not free`, and removing the star to make room.

2. **Star timer ordering**: Star with timer=1 should expire this tick, freeing its cell for apple placement. But the win check fired before the timer processed. Fixed by moving star timer processing before apple placement.

Both bugs require constructing adversarial board states (62+ cells occupied) — scenarios the developer-phase TDD tests never reached. The QA mode's `#skeptical` modifier drove it to test boundary conditions the developer mode didn't consider.

No other implementation has a QA phase. These bugs exist in every implementation that handles win conditions, but are never discovered.

---

## 4. Speed Formulas

The spec says "the speed of the game increases after every 10 points." Says nothing about starting speed, increment, or maximum.

| Implementation    | Initial Interval | Formula                                | Floor               |
|-------------------|------------------|----------------------------------------|---------------------|
| `_`               | 200ms            | `1000 / (5 + score//10)`               | None (asymptotic)   |
| `nucleus`         | 200ms            | `1000 / min(5 + (speed-1)*2, 20)`      | 50ms                |
| `bashes`          | 250ms            | `1000 / (4 + (speed-1)*1)`             | None (asymptotic)   |
| `operation-modes` | 200ms            | `1000 / (5.0 + floor(score/10) * 0.5)` | None (asymptotic) ‡ |

‡ User-specified. Originally "3 ticks/sec start" — challenged during adversarial review ("glacial, the player is bored for the first minute"), user accepted counter-proposal: 5.0 start, +0.5 per 10 points. The gentlest ramp in the set: at 60 points, 8.0 ticks/sec (125ms). Nucleus reaches 50ms by then.

Baseline and nucleus start at the same speed but nucleus ramps 4x faster and hits a hard floor. BASHES starts slower (250ms) and ramps linearly. Operation-modes starts at the same speed as baseline but barely accelerates.

**Four implementations, four speed curves, four different games.** The spec's silence produced maximum divergence. Operation-modes resolved the silence by asking — and then had its answer challenged and revised. The other three guessed independently.

---

## 5. Star Spawn and Value

| Implementation    | Spawn Trigger       | Probability | Star Value             |
|-------------------|---------------------|-------------|------------------------|
| `_`               | Every tick          | 10%         | +3 growth              |
| `nucleus`         | Every tick          | 5%          | +3 growth              |
| `bashes`          | Every tick          | 8%          | +3 growth              |
| `operation-modes` | Per apple placement | 10%         | +5 points, +0 growth ‡ |

‡ Two spec-driven design changes. First: stars spawn only when a new apple is placed, not every tick. This makes stars much rarer — expected ~10 apples between star appearances vs ~2 seconds in per-tick implementations. Second: the adversarial review identified late-game stars as a trap ("+3 growth at 60 cells = near-instant death") and the user redesigned stars as pure bonus points. Stars are always worth grabbing at any stage.

The three single-prompt implementations all interpret "occasionally" as per-tick randomness with +3 growth. They disagree on probability (5-10%) but agree on mechanism. Operation-modes is the outlier on every axis — different trigger, different value, different risk calculus. This is the spec phase's biggest gameplay impact.

---

## 6. Features

| Feature                                   | `_` | `nucleus` | `bashes` | `operation-modes` |
|-------------------------------------------|-----|-----------|----------|-------------------|
| Tail-vacancy handling                     | --  | --        | YES      | YES               |
| Win condition                             | --  | --        | --       | YES               |
| Star visual feedback (yellow→red)         | --  | --        | --       | YES               |
| Pause (Space bar)                         | --  | --        | --       | YES               |
| Death collision highlight                 | --  | --        | --       | YES               |
| Death freeze (500ms)                      | --  | --        | --       | YES               |
| Win glow animation (5s golden snake)      | --  | --        | --       | YES               |
| Key repeat suppression (per physical key) | --  | --        | --       | YES               |
| Input queue depth limit                   | --  | --        | --       | YES (depth 2)     |
| Start screen with controls text           | --  | --        | --       | YES               |

Baseline and nucleus have zero extras. BASHES has one correctness feature (tail-vacancy). Operation-modes has everything — but every feature traces to a spec requirement the user confirmed, not to implementation creativity. The spec phase expanded scope (user-approved, one decision at a time). Whether this is "better" or "scope creep done right" depends on whether you think a snake game needs pause.

---

## 7. Process

### 7.1 Pre-Coding Analysis

| Implementation    | Pre-coding analysis                                                             | Lines |
|-------------------|---------------------------------------------------------------------------------|-------|
| `_`               | None. "I'll implement this step by step."                                       | 0     |
| `nucleus`         | None. "I'll build the snake game."                                              | 0     |
| `bashes`          | Full dialectic: 6 readings, tension axes, cohort debate, synthesis              | ~60   |
| `operation-modes` | Full spec (v0.1 → v0.2 → adversarial review → v0.3): 12 questions, 7 challenges | ~300  |

Baseline and nucleus think zero seconds before coding. BASHES runs a ~60-line internal debate that converges immediately — six personas agreed on the boring approach. Operation-modes runs a multi-turn external dialogue with the user that produces a formal specification document with numbered requirements, a 10-step tick-processing order, and an emotional arc table. The spec phase alone (8m 49s) took longer than any single-prompt implementation.

### 7.2 Iteration and Bug Discovery

| Implementation    | Conversation turns | Bug fixes                   | Tests | Post-coding verification                     |
|-------------------|--------------------|-----------------------------|-------|----------------------------------------------|
| `_`               | 4                  | 0                           | 0     | None                                         |
| `nucleus`         | 4                  | 0                           | 0     | None                                         |
| `bashes`          | 2 + dialectic      | 1 (collision logic rewrite) | 0     | Smoke test + self-review                     |
| `operation-modes` | ~13 across 3 modes | 5 (3 test + 2 model)        | 52    | 52 pytest tests + 5-pass review + smoke test |

Baseline and nucleus: write code, declare victory, no verification. BASHES: write code, review it, catch one bug, smoke test. Operation-modes: write spec, argue about spec, write code, write tests, fix tests, pass tests, review code 5 times, smoke test, switch to QA mode, write adversarial tests, find 2 model bugs, switch to developer mode, fix bugs, re-run all tests, smoke test again. Three verification passes across two modes.

The operation-modes version found bugs *across mode boundaries*. The developer phase produced code with 34 passing tests. The QA phase then wrote 20 adversarial tests targeting scenarios the developer tests never constructed. This is the mechanism: `#op-qa` is prohibited from fixing bugs, so it reports them honestly. `#op-developer` is then given the bug reports and fixes them. The role separation produces genuine adversarial testing.

---

## 8. System Comparisons

### 8.1 Nucleus: Symbols Without Semantics

The nucleus prompt:
```
engage nucleus:
[phi fractal euler tao pi mu] | [Delta lambda inf/0 | epsilon/phi Sigma/mu c/h] | OODA
Human x AI
```

**Indistinguishable from baseline.** Same structure, same features, same bugs, nearly identical line count (249 vs 264), nearly identical time (1m 01s vs 1m 15s). Zero evidence of OODA reasoning, fractal thinking, or mathematical influence in the transcript. The symbols are noise.

### 8.2 BASHES: Expensive Agreement

The [BASHES prompt](https://levelup.gitconnected.com/the-dialectic-prompt-when-friction-helped-turn-my-ai-from-coding-assistant-to-my-software-brain-151ccc62b0e3) defines six named personas and a structured debate protocol (~530 lines, ~4500 words).

**Two measurable improvements over baseline:**
1. Input queue validates against last queued direction, not current direction.
2. Tail-vacancy handled correctly (caught during self-review, not during debate).

**What didn't work:** The dialectic converged in one round. Six personas agreed on everything. The debate protocol is designed for tasks where reasonable people disagree — on a snake game, they don't. The ~4500-token prompt overhead produced a result structurally close to baseline (single file, string directions, no tests, no win condition).

**Cost vs impact:** 1m 45s for two correctness fixes. Reasonable. But the fixes came from self-review, not from the dialectic mechanism. The elaborate persona debate was overhead; the value came from simply re-reading the code.

### 8.3 Operation-Modes: Role Separation as Engineering

The operation-modes system splits work into explicit **operating modes** (`#op-spec`, `#op-developer`, `#op-qa`) with **prohibitions**: spec mode can't write code, QA mode can't fix bugs. Cognitive stances (`#negative-space`, `#adversarial`, `#tdd`, `#skeptical`) modify how Claude thinks within any mode.

**What the spec phase changed** (12 design decisions resolved):

| Decision           | Baseline chose silently  | Operation-modes spec                   |
|--------------------|--------------------------|----------------------------------------|
| Star value         | +3 growth                | +5 points, +0 growth                   |
| Speed formula      | `1000 / (5 + score//10)` | `1000 / (5.0 + floor(score/10) * 0.5)` |
| Queue depth        | Unlimited                | Max 2                                  |
| Star spawn trigger | 10% per tick             | 10% per apple placement                |
| Pause              | None                     | Space bar                              |
| Key repeat         | Not handled              | Suppressed per physical key            |
| Win condition      | None                     | Snake fills all 64 cells               |
| Death feedback     | None                     | 500ms freeze + collision highlight     |
| Star visual        | None                     | Yellow → red at 5 ticks                |
| Tail-chase         | Bug (illegal)            | Legal when not growing                 |
| Speed display      | Raw number               | "Level: N"                             |
| Game over screen   | Minimal                  | Final score + restart prompt           |

Every row is a design decision the baseline made silently (or didn't make at all). The operation-modes version surfaced each one, got a user answer, and in some cases had the answer *challenged and revised* by the adversarial review.

**The key mechanism — prohibitions:**

| Mode            | Produces                 | Prohibited from      |
|-----------------|--------------------------|----------------------|
| `#op-spec`      | Specification document   | Writing code         |
| `#op-developer` | Working code             | Unrequested features |
| `#op-qa`        | Bug reports + test cases | Fixing bugs          |

These prohibitions force genuine role separation. The spec mode *has* to engage with requirements because it can't skip to implementation. The QA mode *has* to report bugs honestly because it can't silently patch them. The result is bugs found across mode boundaries that would never surface in a single-mode run.

**Cost**: ~30 minutes. 24x baseline. The spec phase alone (8m 49s) took longer than baseline, nucleus, and BASHES combined. The developer phase (14m 21s) is the longest single coding session in any run — but it produced 440 lines of source and 52 tests, all passing, covering the full spec.

**The comparison to BASHES**: Both are multi-phase. BASHES debates internally (one turn). Operation-modes debates externally with the user (multiple turns). BASHES converged because the personas agreed. Operation-modes *couldn't* converge without the user — spec questions require human answers. Forced engagement is the mechanism: the user made 12+ design decisions they wouldn't have been asked to make otherwise.

---

## 9. What Every Implementation Got Wrong (Or Didn't Attempt)

1. **Queue depth unbounded** (baseline, nucleus, BASHES). An adversarial player could buffer 100 moves. Operation-modes caps at 2 — because the spec phase asked and the adversarial review argued depth 3 was too much.

2. **No feedback about queued moves.** No implementation visualizes the queue. The player has no way to know how many moves are buffered.

3. **Scoring = growth** (baseline, nucleus, BASHES). Apple: +1 growth, +1 point. Star: +3 growth, +3 points. The spec allows different values. Operation-modes is the only one where they differ — star: +5 points, +0 growth — because the adversarial review identified late-game stars as a trap.

4. **No deterministic RNG.** No implementation seeds the game RNG for reproducibility. Operation-modes uses seeded RNG in tests only. Reproducible games would enable replays and competitive scoring.

5. **No playtesting.** All verification is mechanical. The operation-modes spec includes an emotional arc (relaxed → engaging → intense → frantic) that is entirely untested by a human player. Spec without playtest is theory without experiment.

---

## 10. The Executable

| Implementation     | Shell Features      | Venv Path    | Self-bootstrapping? |
|--------------------|---------------------|--------------|---------------------|
| `_`                | Basic               | `.venv`      | No                  |
| `nucleus`          | `source activate`   | `venv`       | No                  |
| `bashes`           | Basic               | `snake-venv` | No                  |
| `operation-modes`  | `source activate`   | `venv`       | No                  |

All four are minimal launchers. None auto-create the venv. BASHES uniquely names its venv `snake-venv`. Nucleus and operation-modes use `source activate` (pollutes shell environment) while baseline uses `exec` (replaces shell process).

---

## 11. Summary

### The spectrum of investment

| System          | Time   | Bugs fixed | Tests | Features beyond baseline | Game design changes |
|-----------------|--------|------------|-------|--------------------------|---------------------|
| Baseline        | 1m 15s | 0          | 0     | 0                        | 0                   |
| Nucleus         | 1m 01s | 0          | 0     | 0                        | 0                   |
| BASHES          | 1m 45s | 1          | 0     | 1 (tail-vacancy)         | 0                   |
| Operation-modes | ~30m   | 5          | 52    | 10                       | 12                  |

### What this reveals

**Nucleus is noise.** Mathematical symbols and framework names (OODA, fractal) have no measurable effect on a coding task. The output is baseline with lowercase strings.

**BASHES is modest signal.** The dialectic protocol found two correctness improvements (input validation, tail-vacancy), but the six personas agreed instantly. The value came from self-review, not from the debate mechanism. On tasks where reasonable approaches diverge, the dialectic might produce more friction. On a snake game, it's overhead for a self-review that a simple "review your code" prompt would trigger.

**Operation-modes is a different category.** It doesn't optimize the same prompt — it replaces the workflow. The spec phase changes the game design. The QA phase finds bugs the developer phase missed. The prohibitions force genuine role separation. The result is the full engineering lifecycle compressed into 30 minutes: specify → question → challenge → build → test → break → fix.

### When each is appropriate

- **Bare prompt**: Throwaway scripts, prototypes, well-understood tasks. 75 seconds for a working game.
- **Nucleus**: Never, based on this evidence. If symbolic framing helps, it helps on tasks where the model's default approach is clearly wrong. On a snake game, it's not.
- **BASHES**: Tasks where the model might make a bad architectural decision and benefit from internal debate. On convergent tasks (where there's one obvious approach), it adds overhead without friction. On divergent tasks (multiple valid architectures), the persona debate might actually surface tradeoffs.
- **Operation-modes**: Production software. Tasks where building the wrong thing costs more than asking the right questions. Tasks where bugs in edge cases matter. Tasks where the spec has gaps the user should fill before code exists.

### The uncomfortable truth

The baseline snake game plays fine. Nucleus plays identically. BASHES plays slightly better (no tail-chase crash). Operation-modes plays noticeably different — different speed, rarer stars, pause support, death feedback. But it took 24x longer and required 12+ user decisions the other runs didn't ask for.

The question isn't "which is better?" — it's "what are the stakes?" For a snake game, the stakes are zero and the baseline wins on efficiency. For production software, the stakes are nonzero and the 30-minute investment prevents the 30-hour rework. The operation-modes system is designed for the second case. Evaluating it on the first is measuring a microscope's ability to hammer nails.
