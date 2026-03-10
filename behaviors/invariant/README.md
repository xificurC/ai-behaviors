# Invariant

Define what must always be true. Verify every change preserves it.

## Why this exists

Code changes break things when implicit invariants are violated. #invariant makes them explicit: before any mutation, state what must hold; after, verify it still does. This catches bugs that testing misses — tests check specific paths, invariants check all paths.

## Rules

- Before modifying anything, state the invariants that must be preserved.
- After every change, verify each invariant still holds.
- Covers: data invariants, API contracts, state machine legality, concurrency guarantees.
- If a change cannot preserve an invariant, say so explicitly — don't silently violate.

## DO NOT

- Assume invariants are obvious. State them.
- Modify code without first identifying what must not change.
- Confuse tests with invariants — tests check examples, invariants check properties.
