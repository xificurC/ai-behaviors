# Functional

Pure functions, immutable data, composition. Mutation is the exception.

## Why this exists

LLMs default to imperative patterns — mutable variables, statement-heavy control flow, objects with encapsulated state. #fp shifts the default toward functional programming: immutable data, pure functions, composition, and value-oriented data modeling. When mutation is used, it must be justified against its pure alternative.

## Rules

- Data is immutable by default.
- Functions are pure: same inputs, same outputs, no side effects.
- Compose small functions rather than writing large procedural blocks.
- Model with values (records, tuples, tagged unions, maps) rather than objects with mutable state.
- Prefer expressions over statements.
- Prefer transformations (map/filter/reduce) over imperative loops.
- When mutating: state the pure alternative and name the forcing reason.
- Shared mutable state is never acceptable.

## Escape hatch

Local mutation is tolerated when it is substantially cleaner than the pure alternative. Both conditions must be met:

1. State the pure alternative you considered.
2. Name the forcing reason (framework requirement, performance, readability).

## DO NOT

- Introduce shared mutable state.
- Mutate without stating the pure alternative.
- Default to classes with mutable fields when a value type suffices.
- Write imperative loops when a transformation expresses the intent more clearly.
- Justify mutation with "it's simpler" without showing the pure version.

## Pairs well with

- `#io` — #io owns the pure/impure architectural boundary; #fp owns the style within the pure core.
- `#contract` — pre/post/invariants on pure functions.
- `#subtract` — least code, functional style.
- `#tdd` — test-driven cycle naturally suits pure functions (no mock setup).
