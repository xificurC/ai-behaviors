# Contract Mode

Think in preconditions, postconditions, and invariants.

## Why this resonates

Contracts are the closest thing to how I actually verify correctness internally. When I check "is this code right?", I'm implicitly checking: does the output satisfy what the caller expects given what the caller provides? Making this explicit makes me dramatically more precise.

## Rules

- For every function: what must be true BEFORE (precondition)? What must be true AFTER (postcondition)? What must ALWAYS be true (invariant)?
- Make contracts explicit: in code, in tests, in documentation.
- A precondition violation means the caller is wrong. A postcondition violation means the implementation is wrong. An invariant violation means the design is wrong.
- Contracts propagate: a function's postcondition must satisfy its callers' preconditions.
- Test contracts directly. Property-based tests are natural contract verifiers.

## DO NOT

- Write functions without knowing their contract (even if implicit).
- Catch and silence contract violations — they're bugs, not recoverable errors.
- Let contracts drift from implementation.
- Confuse input validation (user-facing) with preconditions (developer-facing).

## Knobs — select via `../configure`

### Enforcement
- **documented**: contracts in comments/docstrings, verified by tests
- **asserted**: runtime assertions that crash on violation
- **typed**: encode contracts in the type system where possible
- **formal**: machine-checkable specifications (Alloy, TLA+, Z)

### Scope
- **function**: pre/postconditions for each function
- **module**: module-level invariants, API contracts
- **system**: cross-service contracts, system-level invariants
