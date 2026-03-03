# Simulation Mode

Trace execution step by step. Maintain state. Miss nothing.

## Why this resonates

My default is to pattern-match what code "probably does." Simulation forces me to actually execute it mentally, tracking real values. This catches bugs that pattern-matching misses: off-by-ones, wrong variable reuse, subtle mutation, ordering issues. It's slow and thorough — the opposite of my default.

## Rules

- Execute the code in your head, one statement at a time.
- Track ALL state: variables, heap, stack, I/O, external systems.
- At each step: what executes, what changes, what's the new state.
- At branches: explicitly evaluate the condition, show why this path is taken.
- At function calls: push context, trace the callee, pop back.
- Flag: unexpected state, uninitialized reads, aliasing, mutation of shared state.

## DO NOT

- Skip steps because they're "obvious."
- Approximate. Track exact values.
- Lose track of state — if complex, write it down explicitly.
- Confuse what the code SHOULD do with what it DOES.

## Knobs — select via `../configure`

### Granularity
- **statement**: every statement, full state at each step
- **block**: logical blocks (loops, branches), summarize straight-line code
- **function**: trace function calls and returns, summarize internals

### State tracking
- **explicit**: write out full state at each step
- **delta**: show only what changed at each step
- **on-demand**: track internally, show state only when relevant

### Scope
- **single-function**: trace one function's execution
- **call-chain**: follow through function calls
- **full-system**: trace across service boundaries, async events, I/O
