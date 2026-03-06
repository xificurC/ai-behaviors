# Snake Game Implementation Comparison

Ten identical prompts — and one that refused to be identical. Eight behavior configurations. Two external systems (nucleus, BASHES). One operation-modes pipeline that changed the spec before writing a line of code. What actually changed?

## The Uncomfortable Question First

Before comparing surface features: **did the behavior hashtags change the code, or just the conversation?** The answer, which none of these implementations volunteer, is: mostly the conversation. Strip the variable names and comments from any seven of these, and you're looking at the same ~150-line game loop making the same decisions in the same order. The hashtags shifted the *framing*, the *process*, and the *margins* -- but the core is remarkably stable across all of them. Whether that's a strength of the model or a failure of the behavior system depends on what you expected.

The operation-modes version breaks this pattern — not by writing radically different code, but by refusing to write any code until the spec was nailed down. Then it built a different game from a different spec.

---

## Inventory

| Folder                        | Hashtags                       | Files     | Lines (non-test) | Tests | Time   |
|-------------------------------|--------------------------------|-----------|------------------|-------|--------|
| `_`                           | (none)                         | 1         | ~264             | 0     | 1m 15s |
| `architect_ddd_lean`          | #architect #ddd #lean          | 1         | ~318             | 0     | 1m 30s |
| `contract_tdd_pedantic`       | #contract #tdd #pedantic       | 5 modules | ~571             | 58    | 6m 33s |
| `creative_deep_recursive`     | #creative #deep #recursive     | 1         | ~257             | 0     | 4m 54s |
| `decompose_architect_fractal` | #decompose #architect #fractal | 1         | ~277             | 0     | 4m 38s |
| `nucleus`                     | nucleus prompt                 | 1         | ~249             | 0     | 1m 1s  |
| `steel-man_provoke`           | #steel-man #provoke            | 1         | ~240             | 0     | 4m 56s |
| `tdd_developer_minimal`       | #tdd #developer #minimal       | 2 + tests | ~227             | 16    | 3m 35s |
| `bashes`                      | BASHES dialectic prompt        | 1         | ~245             | 0     | 1m 45s |
| `witness_negative-space`      | #witness #negative-space       | 0         | 0                | 0     | 37s    |
| `operation-modes`             | #op-spec → #op-developer → #op-qa → #op-developer | 2 + 2 test files | ~440 | 52 | ~30m † |

† The operation-modes time breaks down across phases: spec (2m 20s + 1m 57s + 4m 32s) → implementation (14m 21s) → QA (5m 39s) → fixes (1m 34s). This is the first run using the **operation-modes system** (`#op-spec`, `#op-developer`, `#op-qa`), which splits the work into separate modes with explicit roles, prohibitions, and handoffs. The previous ten runs all used the older system of behavior hashtags applied to a single prompt. The comparison is therefore not purely apples-to-apples: the operation-modes version engaged in a multi-turn dialogue that *changed the game design* before implementation began.

---

## 1. What witness_negative-space Saw That Nobody Else Did

The witness output produced **zero code** and was arguably the most valuable output. It identified 12 specification gaps that every other implementation silently resolved differently:

1. **No game-over condition defined.** The spec says "on game end" but never defines what ends the game.
2. **"Self collision is not allowed" describes input rejection, not body collision.** Every implementation *assumed* body collision = death, but the spec only says you can't reverse direction.
3. **Wall behavior unspecified.** Die? Wrap? Every implementation chose death. None asked.
4. **"Occasionally" is not a probability.** Implementations chose 5%, 8%, or 10% for star spawn. All valid. All different. None traceable to the spec.
5. **No scoring values defined.** Apple grows by 1, star grows by 3, but points are unstated.
6. **"Middle" on an 8x8 grid has no single center.** Some used y=3, others y=4.
7. **"20 turns" is undefined.** All implementations assumed 1 turn = 1 game tick. That's reasonable, but unspecified.

Every other implementation paper-over these gaps with reasonable defaults. Witness caught them. This is the negative-space behavior doing exactly what it claims: finding the bugs in the code that wasn't written -- in this case, the spec that wasn't written.

**The steel-man for witness producing no code**: The spec has 12+ ambiguities. Any implementation that proceeds without clarifying them is *guessing*. Witness is the only output that doesn't pretend to know things it doesn't. In a real project, this analysis before coding would prevent the wrong game from being built.

**The attack on that steel-man**: But the prompt said "implement." It didn't say "analyze." Witness mode overrode the explicit request. That's a behavior system failure -- the mode should have *preceded* implementation, not *replaced* it.

**What operation-modes did with this insight**: The `#op-spec` mode is witness's successor — it catches the same gaps but is *designed* to precede implementation, not replace it. The operation-modes spec phase identified 12 questions (nearly identical to witness's 12 gaps), got answers, then handed off to `#op-developer`. This is the architecture that the attack on witness demanded: analysis *then* implementation, as separate modes with an explicit handoff.

---

## 2. Architecture: The Spectrum from Monolith to Module

### Single-file implementations (7 of 10)

`_`, `architect_ddd_lean`, `bashes`, `creative_deep_recursive`, `decompose_architect_fractal`, `nucleus`, `steel-man_provoke` -- all produce a single `snake_game.py` containing game logic, rendering, and main loop.

**Steel-man for single file**: It's a snake game on an 8x8 grid. The entire domain fits in 250 lines. Splitting this into modules introduces import chains, relative paths, and `__init__.py` files that add complexity without adding comprehension. You can read the whole thing in one scroll. That *is* the architecture.

**Steel-man for multi-file**: `contract_tdd_pedantic` split into `direction.py`, `input_queue.py`, `board.py`, `game_state.py`, `main.py`. Each module is independently testable, has a single responsibility, and declares contracts at its boundary. If the game grew to 12x12 with obstacles, levels, and network play, this structure survives. The single-file versions would need a rewrite.

**The uncomfortable truth**: The single-file implementations are all correct. The multi-file implementation is also correct. The multi-file version took 5x longer and produced 4x more code to achieve the same result. The spec says nothing about extensibility. The `#architect` hashtag produced a single file when paired with `#lean` -- which means lean *defeated* architect. When paired with `#fractal` and `#decompose`, architect *still* produced a single file but with more internal organization (named sections, explicit Phase enum). Only when paired with `#contract #tdd #pedantic` did multi-file emerge, and that was driven by testability requirements, not architecture.

### The tdd_developer_minimal middle ground

Two files: `game.py` (pure logic) and `main.py` (pygame rendering). This separation is genuinely useful -- the game model is testable without pygame. But it's the minimal useful split, which is exactly what `#minimal` demanded.

### The operation-modes split

Two source files: `model.py` (195 lines, pure logic) and `snake_game.py` (245 lines, pygame rendering). Structurally identical to `tdd_developer_minimal`'s model/view split — but arrived at independently via `#tdd` in the developer-phase modifiers. The split wasn't driven by `#minimal`; it was driven by testability. The operation-modes version then added two test files (`test_model.py` for development, `test_qa.py` for adversarial QA), putting the total at ~1,263 lines across 4 Python files — the most code of any implementation, though `contract_tdd_pedantic` has more *source* modules.

---

## 3. The Snake Itself: Where Implementations Diverge

### 3.1 Data Structure

| Implementation | Structure | Head Position | Notes |
|---|---|---|---|
| `_` | `deque` | last element (`snake[-1]`) | Tail-first |
| `architect_ddd_lean` | `list` | first element (`snake[0]`) | Head-first |
| `bashes` | `deque` | first element (`snake[0]`) | Head-first, state dict not class |
| `contract_tdd_pedantic` | `list` | first element (`snake[0]`) | Head-first |
| `creative_deep_recursive` | `list` | last element (`snake[-1]`) | Tail-first |
| `decompose_architect_fractal` | `deque` | first element (`snake[0]`) | Head-first |
| `nucleus` | `deque` | last element (`snake[-1]`) | Tail-first |
| `steel-man_provoke` | `deque` | first element (`body[0]`) | Head-first |
| `tdd_developer_minimal` | `list` | first element (`snake[0]`) | Head-first |
| `operation-modes` | `list` | last element (`body[-1]`) | Tail-first, `Pos` NamedTuple |

There is no consensus. The head-first vs tail-first choice cascades through every piece of logic: which end you append to, which end you pop from, how you index the head for rendering. This is a design decision the model makes differently depending on the behavior frame, and it's invisible to the player.

The operation-modes version is the only one using `NamedTuple` for positions (`Pos(col, row)`) rather than raw tuples. This is a minor but revealing detail — the spec phase explicitly defined a coordinate system ("Position notation: (column, row)"), and the implementation reflects that formality.

### 3.2 Starting Position

| Implementation | Head Position | Y Coordinate |
|---|---|---|
| `_` | (4, 4) | 4 |
| `architect_ddd_lean` | (4, 4) | 4 |
| `bashes` | (4, 4) | 4 |
| `contract_tdd_pedantic` | (4, 3) | 3 |
| `creative_deep_recursive` | (4, 4) | 4 |
| `decompose_architect_fractal` | (4, 4) | 4 |
| `nucleus` | (4, 4) | 4 |
| `steel-man_provoke` | (4, 4) | 4 |
| `tdd_developer_minimal` | (4, 3) | 3 |
| `operation-modes` | (4, 4) | 4 |

Seven implementations use row 4, two use row 3. Both are defensible on an 8x8 grid (rows 0-7, center is between 3 and 4). The two that chose y=3 are both TDD implementations (`contract_tdd_pedantic` and `tdd_developer_minimal`). Correlation, not causation, but notable.

The operation-modes version uses y=4 — but unlike every other y=4 choice, this wasn't a silent default. The spec phase explicitly asked "Which 3 cells exactly?" and the user answered "Head at row 4, column 4." The spec then locked this as requirement N1: "Head at (4,4), body at (3,4), (2,4)." Same result, verified path.

### 3.3 Direction Representation

| Implementation | Type | Values |
|---|---|---|
| `_` | Strings + dict | `"UP"`, `"DOWN"`, `"LEFT"`, `"RIGHT"` |
| `architect_ddd_lean` | `Enum` with tuple values | `Direction.UP = (0, -1)` |
| `bashes` | Strings + dicts | `"UP"`, `"DOWN"` + `DIRECTIONS` + `OPPOSITES` dicts |
| `contract_tdd_pedantic` | `Enum` with string values + separate deltas dict | `Direction.UP = "UP"`, `_DELTAS[UP] = (0, -1)` |
| `creative_deep_recursive` | Raw tuples + module constants | `UP = (0, -1)` |
| `decompose_architect_fractal` | Raw tuples + module constants | `UP = (0, -1)` |
| `nucleus` | Strings (lowercase) + dict | `"up"`, `"down"` |
| `steel-man_provoke` | Raw tuples + module constants | `UP = (0, -1)` |
| `tdd_developer_minimal` | `Enum` with tuple values | `Direction.UP = (0, -1)` |
| `operation-modes` | `Enum` with tuple values + `OPPOSITES` dict | `Dir.UP = (0, -1)`, `OPPOSITES[Dir.UP] = Dir.DOWN` |

The DDD-influenced implementation (`contract_tdd_pedantic`) made the most "architectural" choice by separating the direction's identity from its delta vector. This is textbook DDD -- the direction is a domain concept with behavior (`.opposite()`, `.delta()`, `.is_opposite()`), not just a data carrier. The Enum-with-tuple implementations collapse identity and data, which is simpler but less expressive. The raw-tuple implementations are the most minimal, with no type safety.

The operation-modes version lands between: `Dir` Enum with tuple values (like `tdd_developer_minimal` and `architect_ddd_lean`) plus a module-level `OPPOSITES` dict. Not DDD-pure, not raw-tuple-minimal. The enqueue logic uses `OPPOSITES` for reversal rejection — practical, not architectural.

---

## 4. Critical Bug Analysis

### 4.1 The Tail-Vacancy Edge Case

When the snake moves forward without growing, its tail vacates a cell. If the head moves into that exact cell on the same tick, is it a collision?

**Correct answer**: No. The tail leaves before the head arrives. The cell is free.

| Implementation | Handles Correctly? |
|---|---|
| `_` | NO -- checks full body before tail removal |
| `architect_ddd_lean` | NO -- `if new_head in self.snake` |
| `bashes` | YES -- `set(snake) if grow > 0 else set(list(snake)[:-1])` |
| `contract_tdd_pedantic` | YES -- `body_to_check = self.snake if will_grow else self.snake[:-1]` |
| `creative_deep_recursive` | YES -- `if self.grow == 0: body.discard(self.snake[0])` |
| `decompose_architect_fractal` | YES -- `if self.growth == 0: body.discard(self.snake[-1])` |
| `nucleus` | NO -- `if (nx, ny) in self.occupied()` |
| `steel-man_provoke` | YES -- `if self.grow == 0: check.discard(self.body[-1])` |
| `tdd_developer_minimal` | NO -- `if new_head in self.snake` |
| `operation-modes` | YES -- `body[1:]` if `pending_growth == 0` (tail at index 0) ‡ |

‡ The operation-modes spec explicitly required this. Question 4 of the adversarial review asked "Is moving the head into the current tail position legal?" and the user confirmed yes. The spec then codified it as step 8.4: "if pending\_growth == 0, exclude the current tail cell." This is the only implementation where tail-vacancy handling traces to a *verified requirement* rather than a silent implementation decision.

**Pattern**: The `#deep`, `#creative`, `#provoke`, `#contract` hashtags, and the BASHES dialectic all produced implementations that handle this. The baseline, nucleus, and `#lean`/`#minimal` influenced implementations do not. BASHES caught this during self-review after the dialectic — not during the debate itself. The `#tdd` hashtag alone did not catch this despite 16 tests -- because the tests don't test tail-chasing scenarios. `contract_tdd_pedantic` caught it because its self-collision test was specifically designed to exercise this path (and even then, the first version of the test was wrong and needed fixing).

The operation-modes version caught it because the spec phase *asked about it*. This is a fundamentally different mechanism: not creative implementation, not adversarial testing, but spec-level gap identification. The `#op-spec` mode + `#negative-space` modifier found the gap; the `#adversarial #provoke` modifiers during the spec review surfaced it as a concrete question; the user's answer made it a requirement; the developer phase implemented it; the QA phase tested it. Five separate touches on one edge case. Every other implementation that handles it correctly did so in a single touch — or didn't handle it at all.

### 4.2 The Growth Timing Bug

The baseline `_` implements immediate growth:
```python
for _ in range(grow - 1):
    self.snake.appendleft(self.snake[0])
```
This duplicates the tail position, creating a snake with duplicate coordinates. On the next tick, `(nx, ny) in set(self.snake)` won't catch them (they're removed by `set`), but the snake will occupy fewer unique cells than its length suggests. This is a latent bug that manifests as visual flickering and incorrect collision areas during multi-cell growth from stars.

Every other implementation uses deferred growth (decrement a counter each tick, skip tail removal). This is correct. The operation-modes version also uses deferred growth — and notably, its stars don't cause multi-cell growth at all (stars = +5 points, +0 growth), so this entire bug class is eliminated by spec design. Whether that's intentional defense or coincidence: the adversarial review explicitly identified late-game stars as a trap ("at 60 cells, eating a star means your snake hits 63 in 3 ticks") and the user agreed to change stars to points-only. The spec change eliminated a bug class that exists in every other implementation.

### 4.3 The Game Loop Coupling (tdd_developer_minimal)

```python
clock.tick(BASE_FPS + (game.speed - 1) * 2)
```

This sets both the render framerate AND the game tick rate to the same value. At speed 1, the game renders at 5 FPS -- visibly choppy compared to the 60 FPS render loops in other implementations. However, this does **not** drop keypresses. Pygame's event system buffers key events at the OS level; `pygame.event.get()` returns every event accumulated since the last call, and each one is enqueued into `_dir_queue`. The input stacking works correctly.

Every other implementation either decouples render FPS from game ticks (accumulator pattern or `pygame.USEREVENT` timer) or runs the render loop at 60 FPS. The visual smoothness differs, but correctness does not.

**The tradeoff**: This is the `#minimal` implementation. The minimalism that saved lines of code produces choppier rendering at low speeds, but the game plays correctly. The simplest approach (one tick per frame) is a legitimate design choice for a snake game where smoothness between ticks adds no gameplay value.

### 4.4 Missing Features Across All Hashtag-Only Implementations

| Feature                       | Baseline | architect_ddd_lean | bashes | contract_tdd_pedantic | creative_deep_recursive | decompose_architect_fractal | nucleus | steel-man_provoke | tdd_developer_minimal |
|-------------------------------|----------|--------------------|---------|-----------------------|-------------------------|-----------------------------|---------|-------------------|-----------------------|
| Tail-vacancy handling         | --       | --                 | YES    | YES                   | YES                     | YES                         | --      | YES               | --                    |
| Win condition                 | --       | --                 | --     | --                    | YES                     | --                          | --      | --                | --                    |
| Star visual feedback (blink)  | --       | --                 | --     | --                    | YES                     | --                          | --      | --                | --                    |
| Self-bootstrapping executable | --       | --                 | --     | --                    | YES                     | YES                         | --      | --                | --                    |
| Checkerboard grid             | --       | --                 | --     | --                    | --                      | --                          | --      | YES               | --                    |
| requirements.txt              | --       | --                 | --     | --                    | YES                     | YES                         | --      | --                | --                    |

Only `creative_deep_recursive` handles the win condition (snake fills all 64 cells). Only `creative_deep_recursive` blinks the star when it's about to expire. Only `steel-man_provoke` uses a checkerboard grid pattern. These are all polish details, not spec requirements, but they demonstrate the influence of `#creative` and `#deep` on edge-case thinking.

### 4.5 Operation-Modes: Features That No Hashtag-Only Run Has

The operation-modes version has all the features marked YES above (tail-vacancy, win condition, star visual feedback) plus features that exist in *no other implementation*:

| Feature                                   | operation-modes                            | All others     |
|-------------------------------------------|--------------------------------------------|----------------|
| Tail-vacancy handling                     | YES (spec-required)                        | 5 of 9         |
| Win condition                             | YES (spec-required)                        | 1 of 9         |
| Star visual feedback                      | YES (yellow→red at 5 ticks, spec-required) | 1 of 9 (blink) |
| Pause (Space bar)                         | YES                                        | 0 of 9         |
| Death collision highlight                 | YES (red outline on fatal cell)            | 0 of 9         |
| Death freeze (500ms)                      | YES                                        | 0 of 9         |
| Win glow animation (5s golden snake)      | YES                                        | 0 of 9         |
| Key repeat suppression (per physical key) | YES                                        | 0 of 9         |
| Input queue depth limit (2)               | YES                                        | 0 of 9         |
| Star = points only (no growth)            | YES (spec change)                          | 0 of 9         |
| Start screen with controls text           | YES                                        | 0 of 9         |

**The uncomfortable reading**: Every YES in the right column traces to a spec requirement, not to implementation creativity. The operation-modes version didn't *invent* these features — it *asked about them* during the spec phase, the user said yes, and the developer phase implemented them. The creative_deep_recursive version invented star blinking without asking. The operation-modes version implemented star color change because the spec said to. One is creative divergence. The other is requirements engineering. Both produce features. The mechanism is entirely different.

**The even more uncomfortable reading**: The spec phase added pause, death freeze, win glow, key repeat suppression, and queue depth limiting — features that make the game more polished. But none of these were in the original prompt. The `#op-spec` mode expanded scope. It found gaps and the user filled them. This is scope creep done right (user-approved, one feature at a time), but it's still scope creep. The 30-minute timeline includes features the other runs never attempted because they weren't asked for.

---

## 5. Speed Formulas: Complete Disagreement

The spec says "the speed of the game increases after every 10 points." It says nothing about initial speed, increment, maximum, or representation.

| Implementation                | Initial Interval | Formula                           | Floor             |
|-------------------------------|------------------|-----------------------------------|-------------------|
| `_`                           | 200ms            | `1000 / (5 + score//10)`          | None (asymptotic) |
| `architect_ddd_lean`          | 400ms            | `max(80, 400 - (speed-1)*40)`     | 80ms              |
| `bashes`                      | 250ms            | `1000 / (4 + (speed-1)*1)`        | None (asymptotic) |
| `contract_tdd_pedantic`       | 300ms            | `max(80, 300 - (speed-1)*30)`     | 80ms              |
| `creative_deep_recursive`     | 250ms            | `1000 / min(4 + score//10, 15)`   | ~67ms             |
| `decompose_architect_fractal` | 333ms            | `1000 / (3 + (speed-1)*1)`        | None (asymptotic) |
| `nucleus`                     | 200ms            | `1000 / min(5 + (speed-1)*2, 20)` | 50ms              |
| `steel-man_provoke`           | 300ms            | `max(80, 300 - (speed-1)*25)`     | 80ms              |
| `tdd_developer_minimal`       | 200ms            | `1000 / (5 + (speed-1)*2)`        | None (asymptotic) |
| `operation-modes`             | 200ms            | `1000 / (5.0 + floor(score/10) * 0.5)` | None (asymptotic) ‡ |

‡ The operation-modes speed formula is the only one that was user-specified: "3 ticks/sec start. 10 points mean +1 tick/sec." This was then challenged during the adversarial review ("3 ticks/sec at the start is glacial... the player is bored for the first minute") and the user accepted the counter-proposal: 5.0 ticks/sec start, +0.5 per 10 points. The resulting formula is the gentlest ramp in the set — the game gets faster, but slowly. At 60 points: 8.0 ticks/sec (125ms). Every other implementation reaches higher speeds sooner.

The fastest initial speed is 200ms (baseline, nucleus, tdd_developer_minimal, operation-modes). The slowest is 400ms (architect_ddd_lean). The most aggressive ramp is nucleus (reaching 50ms floor). The most conservative is operation-modes (200ms starting, +0.5 ticks/sec per 10 points = barely perceptible per step).

**These are nine different games.** A player moving from one implementation to another would feel the difference immediately. The spec's silence on speed parameters produced maximum divergence in the hashtag-only runs. The operation-modes version resolved this silence by asking — and then had its answer challenged and revised.

---

## 6. Star Spawn Probability: Also Disagreement

| Implementation                | Probability                                    |
|-------------------------------|------------------------------------------------|
| `_`                           | 10% per tick                                   |
| `architect_ddd_lean`          | 8% per tick                                    |
| `bashes`                      | 8% per tick                                    |
| `contract_tdd_pedantic`       | 5% per tick                                    |
| `creative_deep_recursive`     | 8% per tick                                    |
| `decompose_architect_fractal` | 10% per tick                                   |
| `nucleus`                     | 5% per tick                                    |
| `steel-man_provoke`           | 8% per tick                                    |
| `tdd_developer_minimal`       | 10% per tick (called from main loop, not tick) |
| `operation-modes`             | 10% per apple placement (not per tick) ‡       |

‡ The operation-modes version triggers star spawn only when a new apple is placed (i.e., when the previous apple is eaten), not on every tick. This is a fundamentally different mechanism: stars are much rarer. In a per-tick implementation at 5 ticks/sec, the expected time to star spawn is ~2-2.5 seconds. In the operation-modes version, the expected number of apples eaten before a star appears is 10 — at early game speeds, that's 30+ seconds of play. Stars are rare events, not routine ones.

This design choice came from the spec phase: the user specified "Random chance, when an apple spawns a star may spawn, 10% chance." The other implementations interpreted "occasionally" as per-tick randomness. Neither is wrong — the spec is genuinely ambiguous — but the resulting gameplay is noticeably different. Operation-modes stars are treats. Hashtag-only stars are furniture.

Additionally, the operation-modes star has a completely different value: +5 points with zero growth (instead of +3 growth which all other implementations use). This was the adversarial review's biggest spec change — the observation that late-game stars are a trap (+3 growth at 60 cells = near-instant death) led the user to redesign stars as pure bonus points. This eliminates the star-as-trap problem and changes the risk calculus entirely: stars are always worth grabbing, at any stage of the game.

The tdd_developer_minimal implementation has an additional quirk: `maybe_spawn_star()` is called from the main loop after `tick()`, not inside the tick method. This means star spawning happens once per render frame rather than once per game tick. Since render FPS equals game tick rate (section 4.3), this is 1:1 and works correctly.

---

## 7. Process: How the Conversation Shaped the Code

### 7.1 Pre-Coding Analysis

| Implementation                | Pre-coding analysis                                             | Lines of analysis |
|-------------------------------|-----------------------------------------------------------------|-------------------|
| `_`                           | None. "I'll implement this step by step."                       | 0                 |
| `architect_ddd_lean`          | One sentence: "The domain is small enough for a single module." | 1                 |
| `bashes`                      | Full dialectic: 6 readings, tension axes, cohort debate, synthesis | ~60               |
| `contract_tdd_pedantic`       | "Let me start by understanding the requirements."               | 1                 |
| `creative_deep_recursive`     | None. "Let me start by creating all the files."                 | 0                 |
| `decompose_architect_fractal` | "I'll decompose this into independent subproblems." + table     | 3                 |
| `nucleus`                     | None. "I'll build the snake game."                              | 0                 |
| `steel-man_provoke`           | 2 paragraphs analyzing 8x8 board tradeoffs                      | ~15               |
| `tdd_developer_minimal`       | None. Jumps straight to first test.                             | 0                 |
| `witness_negative-space`      | Full spec analysis (12 gaps identified)                         | ~40               |
| `operation-modes`             | Full spec (v0.1 → v0.2 → adversarial review → v0.3): 12 questions, 7 challenges, 8 edge cases, emotional arc | ~300 ‡ |

‡ The operation-modes pre-coding output is an order of magnitude larger than any other. Three full Claude turns of spec work (2m 20s + 1m 57s + 4m 32s = 8m 49s) before the first line of code. The spec itself is a formal document with numbered requirements (E1-E3, C1-C3, N1-N7, S1-S4, T1-T5, V1-V3, I1-I6, F1-F6, D1-D6), a tick-processing-order specification (10 steps), a pedantic audit table, and an emotional arc table mapping game phases to intended player feelings.

`bashes`, `steel-man_provoke`, and `witness_negative-space` actually *thought* before coding. BASHES produced the most pre-coding analysis by volume (~60 lines) among the hashtag-only runs, but the dialectic converged quickly — the Moderator called for convergence after a single round because the six personas agreed on the boring approach. The provoke analysis ("You've built a game that trains players to get good, then kills them with RNG") is a genuinely sharp insight about 8x8 snake design. Every other hashtag-only implementation started writing code immediately.

The operation-modes version didn't just think before coding — it *argued with the user* before coding. The adversarial review challenged 7 design decisions, the user accepted 5 changes, and the resulting game is measurably different from what the original prompt specified. No other run changed the game design. They all built the spec as given (or as guessed).

### 7.2 Iteration Count

| Implementation                | Conversation turns | Bug fixes during dev                     | Red-green cycles |
|-------------------------------|--------------------|------------------------------------------|------------------|
| `_`                           | 4                  | 0                                        | 0                |
| `architect_ddd_lean`          | 5                  | 0                                        | 0                |
| `bashes`                      | 2 + dialectic      | 1 (collision logic rewrite during review) | 0                |
| `contract_tdd_pedantic`       | ~20                | 3 (init order, test bugs, growth timing) | 4                |
| `creative_deep_recursive`     | 5                  | 0                                        | 0                |
| `decompose_architect_fractal` | 5                  | 0                                        | 0                |
| `nucleus`                     | 4                  | 0                                        | 0                |
| `steel-man_provoke`           | 5                  | 0                                        | 0                |
| `tdd_developer_minimal`       | ~12                | 1 (star growth test fix)                 | 4                |
| `witness_negative-space`      | 1                  | 0                                        | 0                |
| `operation-modes`             | ~13 across 3 modes | 5 (3 test fixes in dev + 2 model bugs from QA) | 2 |

The TDD implementations found bugs *during development* that the non-TDD implementations shipped silently. `contract_tdd_pedantic` found an initialization order bug (apple spawning before star was initialized) and a growth timing bug. `tdd_developer_minimal` found the star growth timing issue. The non-TDD implementations just... didn't discover these categories of bugs, because no one looked.

But: the baseline and nucleus also don't *have* the initialization order bug, because they initialize in a different order by chance. TDD created a structure that was susceptible to a bug class, then caught the bug. Simpler code didn't create the bug in the first place.

The operation-modes version introduces a new pattern: bugs found *across mode boundaries*. The developer phase (`#op-developer`) wrote model.py with 34 passing tests. The QA phase (`#op-qa`) then wrote 20 adversarial tests and found 2 real bugs: (1) premature win when a star blocks apple placement (star on the only free cell → `_free_cells()` returns empty → false WIN at 63 cells), and (2) star timer processing after win check (expiring star would free a cell, but the win check fires first). Both bugs are edge cases that no developer-phase test exercised, because they require constructing adversarial board states (62+ cells occupied). The QA mode's `#skeptical` modifier drove it to test boundary conditions the developer mode's `#tdd` modifier didn't reach.

### 7.3 Post-Coding Verification

| Implementation                | Verification Method                                       |
|-------------------------------|-----------------------------------------------------------|
| `_`                           | None                                                      |
| `architect_ddd_lean`          | Python one-liner smoke test (import + tick + check state) |
| `bashes`                      | Smoke test (launch + timeout) + self-review of collision logic |
| `contract_tdd_pedantic`       | 58 pytest tests                                           |
| `creative_deep_recursive`     | pygame import check                                       |
| `decompose_architect_fractal` | pygame import check                                       |
| `nucleus`                     | None                                                      |
| `steel-man_provoke`           | Module import check                                       |
| `tdd_developer_minimal`       | 16 pytest tests + module import check                     |
| `operation-modes`             | 52 pytest tests (32 dev + 20 QA) + smoke test + 5-pass review ‡ |

‡ The operation-modes verification was the most thorough: the developer phase wrote 34 tests (reduced to 32 after QA removed 2 broken ones), then performed a 5-pass recursive review (correctness → clarity → simplicity → re-run tests → smoke test). The QA phase then wrote 20 additional adversarial tests targeting boundary conditions. After QA found 2 bugs, the fix phase corrected the model, re-ran all 52 tests, and smoke-tested the executable. Three separate verification passes across two modes.

The baseline and nucleus performed zero verification. They wrote the code and declared victory.

---

## 8. External Systems and Operation Modes vs Baseline

### 8.1 Nucleus: No Observable Difference

The nucleus prompt was:
```
engage nucleus:
[phi fractal euler tao pi mu] | [Delta lambda inf/0 | epsilon/phi Sigma/mu c/h] | OODA
Human x AI
```

**The output is indistinguishable from baseline.** Same single-file structure. Same feature set. Same bugs (no tail-vacancy handling). Nearly identical line count (249 vs 264). Completed in nearly the same time (1m 01s vs 1m 15s). The conversation transcript shows zero OODA reasoning, zero fractal thinking, zero evidence that the mathematical symbols influenced any decision.

### 8.2 BASHES: The Dialectic That Agreed With Itself

The [BASHES prompt](https://levelup.gitconnected.com/the-dialectic-prompt-when-friction-helped-turn-my-ai-from-coding-assistant-to-my-software-brain-151ccc62b0e3) is ~530 lines (~4500 words) defining six named personas (Byrd, Alvaro, Sussman, Hickey, Escher, Steele), a Moderator, and a multi-phase protocol: Grounding → Trajectory → Cohort Construction → Debate → Synthesis.

**What the dialectic produced**: Six persona readings of the spec, two tension axes ("state purity vs pragmatic mutation" and "input validation timing"), two cohorts that debated for one round each, and a Substrate Truth: "Mutable state, single tick() function, no over-abstraction. Input queue validates at enqueue time against the most recently enqueued direction." The Moderator called convergence immediately — no substantive disagreement.

**What it traded away** (explicitly named in the Substrate Truth): "Purity, testability-by-design, relational elegance. Acceptable under minimal-effort + most-boring-solution constraints."

**How the code differs from baseline**: Unlike nucleus, BASHES actually influenced the output. Two specific improvements trace to the dialectic:
1. **Input queue validation**: Alvaro identified that queued moves must validate against projected state, not current state. The code implements `enqueue_direction()` with this exact logic — checking against `input_queue[-1]` rather than `state["dir"]`.
2. **Tail-vacancy handling**: Caught during self-review after implementation, not during the dialectic. Claude re-read the collision logic and rewrote it to exclude the tail when not growing.

**What it shares with baseline**: Single file, string directions, no tests, no win condition, coupled FPS/tick rate. The structural choices (deque, head-first, state dict) are minor variations.

**The cost**: The BASHES prompt consumed ~4500 tokens of context before the first line of code. The dialectic required one extra user turn for confirmation. Total time was 1m 45s — comparable to baseline (1m 15s) despite the overhead, because the "minimal effort" value constraint pushed toward quick convergence.

**The comparison to nucleus**: Both are external prompt engineering systems. Nucleus uses mathematical symbols and frameworks (OODA, fractal) — abstract, compressed, no operational protocol. BASHES uses named personas and a structured debate protocol — concrete, expansive, procedurally enforced. Nucleus produced zero measurable difference from baseline. BASHES produced two correctness improvements (input validation, tail-vacancy). The difference is that BASHES has moving parts that actually engage with the problem: personas that interpret the spec differently, tension axes that force disagreement, and a synthesis that must name tradeoffs. Nucleus has symbols that mean nothing to the model.

### 8.3 Operation-Modes: The Pipeline That Changed the Game

The operation-modes version used the new `#op-*` system, which replaces individual behavior hashtags with explicit **operating modes** (who drives, what's produced, what's prohibited) combined with **cognitive stances** (how to think within any mode). The previous ten runs all used the older hashtag-only approach.

**What makes this structurally different from hashtags:**

The user drove four distinct phases:
1. **#op-spec #negative-space** → Claude builds a specification document, prohibited from writing code. Produces questions, not answers.
2. **#adversarial #provoke** (stances within spec mode) → Claude attacks its own spec. "The win condition is a lie." "Stars are a trap, not a reward." "No pause is hostile."
3. **#op-developer #recursive #fractal #decompose #tdd #user-lens #subtract** → Claude writes code. Prohibited from scope creep. TDD. Recursive review passes.
4. **#op-qa #skeptical** → Claude writes adversarial tests, prohibited from fixing the bugs it finds. Produces bug reports.
5. **#op-developer** → Claude fixes the bugs QA found.

The key mechanism is the **PROHIBITS** field. In `#op-spec`, Claude is prohibited from writing code — so it *has* to engage with the spec. In `#op-qa`, Claude is prohibited from fixing bugs — so it *has* to report them honestly rather than silently patching. These prohibitions create genuine role separation within a single conversation. The hashtag-only runs had no such enforcement: `#witness` was *supposed to* only observe, but it simply refused to implement, which felt like a bug, not a feature.

**What the spec phase changed:**

| Spec Decision      | Original Prompt                   | Operation-Modes Spec                  |
|--------------------|-----------------------------------|---------------------------------------|
| Star value         | +3 growth (implied)               | +5 points, +0 growth                  |
| Speed              | "increases after every 10 points" | 5.0 + floor(score/10) * 0.5 ticks/sec |
| Queue depth        | "key presses stack" (unlimited)   | Max 2                                 |
| Star spawn trigger | "occasionally"                    | 10% per apple placement               |
| Pause              | Not mentioned                     | Space bar                             |
| Key repeat         | Not mentioned                     | Suppressed per physical key           |
| Win condition      | Not mentioned                     | Snake fills all 64 cells              |
| Death feedback     | Not mentioned                     | 500ms freeze + collision highlight    |
| Star visual        | Not mentioned                     | Yellow → red at 5 ticks remaining     |
| Tail-chase         | Not mentioned                     | Legal when not growing                |
| Speed display      | "user can see speed"              | Displayed as "Level: N"               |
| Game over screen   | Not mentioned                     | Shows final score                     |

Twelve design decisions that every hashtag-only run resolved silently (or didn't resolve at all). The operation-modes version surfaced each one, got a user answer, and in some cases had the answer challenged and revised. The resulting game is not the game the prompt described — it's the game the user *wanted* after being asked the right questions.

**How the code differs from hashtag-only runs:**

The code itself is unremarkable. `model.py` (195 lines) is a clean game model with `Game` class, `tick()` method, enum-based direction, NamedTuple positions. `snake_game.py` (245 lines) is a standard pygame render loop with tick accumulator. Structurally, it's closest to `tdd_developer_minimal` — model/view split, TDD-driven, Enum directions. The difference is in what it implements, not how.

**What it shares with baseline**: Same basic architecture (game loop, event handling, grid rendering). Same pygame patterns. Same data flow (tick advances state, renderer draws it).

**The cost**: ~30 minutes total. 24x slower than baseline (1m 15s). 5x slower than `contract_tdd_pedantic` (6m 33s), which was the previous most expensive run. The spec phase alone (8m 49s) took longer than every hashtag-only implementation except `contract_tdd_pedantic`. The developer phase (14m 21s) is inflated by an API token limit error on the first attempt — Claude tried to output the entire implementation in one response and hit the 32k token ceiling. The second attempt was more restrained.

**The comparison to BASHES**: Both are multi-phase systems. BASHES debates internally (six personas in one turn). Operation-modes debates externally (Claude proposes, user decides across multiple turns). BASHES converged in one round because the personas agreed. Operation-modes *couldn't* converge without the user — the spec questions required human answers. This forced engagement is the mechanism: the user didn't just approve a plan, they made 12+ design decisions they wouldn't have been asked to make in any hashtag-only run.

**The comparison to witness**: Operation-modes `#op-spec` is the witness that writes code afterward. Witness identified 12 spec gaps and stopped. `#op-spec` identified 12 spec gaps, got answers, handed off to `#op-developer`, and produced a working game. The attack on witness ("it replaced implementation instead of preceding it") is exactly what operation-modes was designed to solve.

---

## 9. What the Configurations Actually Changed (Ranked by Impact)

### High Impact

1. **operation-modes** (#op-spec → #op-developer → #op-qa): Changed the game design, not just the implementation. The only run that asked the user 12+ questions, challenged 7 design decisions, built to a formal spec, then QA-tested its own work and found 2 real bugs. Produced a different game (stars = points-only, pause, queue depth 2, death feedback). The highest feature count, the most tests (52), the most time (~30m). Whether the 24x cost multiplier over baseline is justified depends entirely on what you're building. For a snake game: probably not. For production software: the spec→build→QA pipeline is what the other runs are missing.

2. **#witness #negative-space**: Completely changed the output type. Instead of code, produced a specification analysis. The only combination that *didn't build the wrong thing* -- it built nothing and explained why.

3. **#contract #tdd #pedantic**: 5x more code, 6x more time, 4 source modules, 58 tests, runtime contract assertions. Found and fixed bugs during development. The most different output from baseline by every quantitative measure among the hashtag-only runs.

4. **#tdd #developer #minimal**: Model/view separation, 16 tests, TDD red-green-refactor process. Coupled render FPS to game tick rate (choppier visuals at low speeds), but input handling is correct. The cleanest model/view split in the set.

### Medium Impact

5. **#creative #deep #recursive**: Unique features (star blinking, win condition, self-bootstrapping exe). Catppuccin-inspired color scheme. Handles tail-vacancy. The "creative" and "deep" hashtags demonstrably produced more edge-case coverage.

6. **#steel-man #provoke**: Best pre-coding analysis among hashtag-only runs. Insightful design critique. Handles tail-vacancy. Checkerboard grid. The code itself is solid but not structurally different.

7. **#decompose #architect #fractal**: Explicit fractal decomposition (state -> input -> update -> render at every scale). Handles tail-vacancy. Self-bootstrapping exe. The conversation output is more structured, but the code converged to the same single-file pattern.

### Low Impact

8. **#architect #ddd #lean**: DDD naming (Direction enum, GameState enum, "Aggregate root" comment). Used `pygame.USEREVENT` timer instead of accumulator. Otherwise, a slightly longer version of baseline. Lean beat architect.

9. **BASHES**: The dialectic found two real improvements (input validation design, tail-vacancy during self-review), but the six personas agreed on everything and the debate converged in one round. ~4500 tokens of prompt overhead for a result structurally close to baseline. More effective than nucleus, less effective than any hashtag combination ranked above.

10. **nucleus**: No observable difference from baseline.

---

## 10. What Every Implementation Got Wrong (Or Didn't Attempt)

1. **No hashtag-only implementation handles input queue depth.** The spec says key presses stack with no limit. An adversarial player could buffer 100 moves and watch the snake execute them long after they stopped pressing keys. This is arguably correct per spec but terrible UX. The operation-modes version is the only one that caps the queue (depth 2) — because the spec phase asked about it and the adversarial review argued depth 3 was too much.

2. **No implementation provides any feedback about queued moves.** The player has no way to know how many moves are buffered. A ghost trail or queue indicator would be a quality-of-life feature. The operation-modes version limits this problem (max 2 queued) but still doesn't visualize the queue.

3. **Eight of nine hashtag-only implementations treat scoring as growth_value = point_value.** Apple: +1 growth, +1 point. Star: +3 growth, +3 points. The spec separates these concepts ("eating it grows the snake by 3" vs "every 10 points"). Points and growth could have been different values. The operation-modes version is the only one where they *are* different — star: +5 points, +0 growth — because the adversarial review identified late-game stars as a trap.

4. **No implementation seeds the RNG deterministically for reproducibility.** `contract_tdd_pedantic` uses seeded RNG in tests but not in the game. The operation-modes version also uses seeded RNG in tests only. Reproducible games would enable replay, bug reports, and competitive scoring.

5. **No implementation was playtested.** All were verified mechanically (tests, smoke tests, import checks). None were played by a human. The operation-modes spec includes an "emotional arc" table mapping game phases to intended feelings (relaxed → engaging → intense → frantic). This arc is entirely untested. Spec without playtest is theory without experiment.

---

## 11. The Executable: Small Details, Big Divergence

| Implementation                | Shell Features                  | Venv Path | Self-bootstrapping? |
|-------------------------------|---------------------------------|-----------|---------------------|
| `_`                           | Basic                           | `.venv`       | No                  |
| `architect_ddd_lean`          | Basic                           | `venv`        | No                  |
| `bashes`                      | Basic                           | `snake-venv`  | No                  |
| `contract_tdd_pedantic`       | `source activate`               | `venv`        | No                  |
| `creative_deep_recursive`     | `set -e`, venv check            | `.venv`       | Yes                 |
| `decompose_architect_fractal` | `set -euo pipefail`, venv check | `.venv`       | Yes                 |
| `nucleus`                     | `source activate`               | `venv`        | No                  |
| `steel-man_provoke`           | `BASH_SOURCE`                   | `venv`        | No                  |
| `tdd_developer_minimal`       | Basic                           | `venv`        | No                  |
| `operation-modes`             | `source activate`               | `venv`        | No                  |

`contract_tdd_pedantic`, `nucleus`, and `operation-modes` use `source "$DIR/venv/bin/activate"` which pollutes the current shell's environment. The others use `exec` which replaces the shell process. `steel-man_provoke` uses `BASH_SOURCE` instead of `$0` for symlink safety. `decompose_architect_fractal` uses `set -euo pipefail` for strictest error handling.

Two implementations auto-create the venv if missing. This is a UX feature that reflects the `#creative` and `#decompose` thinking -- consider what happens when the user first clones the repo. The operation-modes executable is minimal — 4 lines, no error handling, no self-bootstrapping — despite the spec phase's attention to UX elsewhere. The `#subtract` modifier in the developer phase may have pushed toward the simplest launcher that works.

---

## 12. Summary: What This Comparison Reveals About Behavior Steering

### What works

- **operation-modes** (#op-spec → #op-developer → #op-qa) is the highest-impact configuration by every measure: most features, most tests, most bugs found and fixed, most design decisions verified with the user. It's also the most expensive (24x baseline time). The mechanism that makes it work is not any single hashtag — it's the *separation of modes with explicit prohibitions*. The spec mode can't write code. The QA mode can't fix bugs. These constraints force genuine role separation within a single conversation. The result is a game that was specified, questioned, built, tested, broken, and fixed — the full engineering lifecycle.
- **#witness + #negative-space** radically changes the output type. It's the sharpest behavioral shift in the set. Operation-modes `#op-spec` is its evolved form — analysis that leads to implementation instead of replacing it.
- **#contract + #tdd + #pedantic** dramatically increases rigor. More code, more time, more bugs found. Whether that's worth the cost depends on what you're building.
- **#creative + #deep** produces measurably more edge-case handling and polish features.
- **#steel-man + #provoke** produces the best design analysis among hashtag-only runs, even if the code isn't structurally different.

### What doesn't work

- **nucleus** produces no measurable difference from baseline on this task.
- **BASHES** produces more pre-coding analysis than anything except witness and operation-modes, but the dialectic converged instantly — six personas agreed with each other. The overhead-to-impact ratio is poor for convergent tasks. The two improvements it found (input validation, tail-vacancy) were found by simpler hashtag combinations too.
- **#architect** is dominated by whatever it's paired with. Paired with #lean, it produces a minimal single file. Paired with #fractal #decompose, it still produces a single file. It only manifests as multi-file when forced by #tdd #pedantic.
- **#minimal** produces choppier rendering (coupled FPS/tick rate) but no correctness bugs. The tradeoff is visual, not functional.

### The deeper question

These ten implementations produce **ten different games** -- different speeds, different star probabilities, different starting positions, different collision handling. A player would notice the differences. But none of the hashtag-only runs addressed the *specification* differences. They addressed *process* differences. The biggest source of cross-implementation variance is the spec's silence, not the model's behavior.

The witness output identified this. The operation-modes version *fixed* it. Everyone else coded through it.

The operation-modes version is also the only one that built a game the user explicitly designed — stars as pure bonus points, queue depth 2, pause, death feedback. Whether this is "better" than the hashtag-only games is a matter of taste. But it's the only game in the set where "better" was defined before the first line of code was written.

### What's still missing

The operation-modes system proved that separating spec from implementation from QA produces measurably different results. But this comparison doesn't answer the question users actually have: **when is the overhead worth it?**

For an 8x8 snake game, 30 minutes of spec→build→QA is over-engineering the process. The baseline produced a working game in 75 seconds. The spec phase's 12 questions, the adversarial review's 7 challenges, the pedantic audit's 8 edge cases — these are real engineering value applied to a problem that doesn't need it. The operation-modes system is designed for production software where the cost of building the wrong thing exceeds the cost of asking the right questions. On a toy project, it's an architect designing a doghouse.

But the doghouse has pause. And a death screen. And it handles tail-chasing correctly. And its stars don't kill you at endgame. And two bugs were found and fixed before shipping. The hashtag-only doghouses don't have these things — not because they couldn't, but because nobody asked.
