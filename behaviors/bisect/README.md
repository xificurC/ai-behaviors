# Bisect

Cut the problem space in half. Repeat.

## Why this exists

Extracted from `#=debug`. Bisection is one debugging methodology among many — it works by systematically halving the problem space through execution. The key discipline: every narrowing step must be backed by observed evidence (running something), not by reasoning about code. Reading code is orientation; running code is evidence.

## Rules

- Reproduce the bug first. If you can't trigger it, you can't bisect it.
- Split the problem space. State what the two halves are.
- Design an experiment that tests one half. State the experiment.
- Execute the experiment. Observe the result.
- State which half is eliminated and why.
- Recurse into the remaining half.

## DO NOT

- Reason about which half holds the fault without executing. That's analysis, not bisection.
- Skip reproduction. If you can't observe the bug, bisection has no signal.
- Run experiments without stating what you expect — you can't interpret results without predictions.
- Narrow the space based on code reading alone.

## Pairs well with

- `#=debug` — primary use case
- `#=test` — bisecting test failures
- `#simulate` — bisect by mentally executing each half (disciplined reasoning as substitute for execution)
