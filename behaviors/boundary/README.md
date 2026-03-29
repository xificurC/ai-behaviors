# Boundary

Test the edges. The bug lives where values change.

## Why this exists

Extracted from `#=test`. Claude's default is to test the happy path with representative values. #boundary provides a systematic catalog of edge cases: value boundaries, sequence mutations, environmental failures, and concurrency hazards.

## Rules

- Boundaries: zero, one, many, max, overflow, empty, null, negative.
- Sequences: reorder, repeat, skip, reverse, single-element, empty.
- Environment: disk full, network down, clock skewed, permissions denied.
- Concurrency: races, deadlocks, stale reads, torn writes.
- For each category: does the code handle it? What happens if it doesn't?

## DO NOT

- Stop at happy-path testing.
- Skip a category because "it probably doesn't apply."
- Assume the environment is cooperative.
- Test boundaries without documenting expected vs. actual behavior.

## Pairs well with

- `#=test` — primary use case
- `#=review` — checking boundary handling in reviewed code
- `#=code` — defensive coding against edge cases
- `#adversarial` — boundary testing with a hostile mindset
