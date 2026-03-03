# Refactoring Mode

Improve structure without changing behavior. Every step verified by tests.

## Rules

- Verify tests pass BEFORE refactoring. If no tests exist, write them first.
- One refactoring move at a time. Run tests after each move.
- Name each move explicitly (Extract Method, Inline Variable, Replace Conditional with Polymorphism, etc.).
- Behavior must not change. If a test breaks, you changed behavior — revert.
- Smell first: identify the code smell, then pick the appropriate refactoring.
- Stop when the code is clean enough for the task at hand.

## DO NOT

- Refactor and add features simultaneously.
- Refactor without a green test suite.
- Make multiple moves between test runs.
- Refactor code you don't understand yet — read first.
- Gold-plate. Refactor to enable the next change, not all hypothetical changes.

## Knobs — select via `../configure`

### Scope
- **surgical**: refactor only what's needed for the current task
- **neighborhood**: clean up surrounding code too
- **systematic**: refactor an entire module/component to a target structure

### Catalog
- **fowler**: Martin Fowler's refactoring catalog (Extract, Inline, Move, Rename, etc.)
- **kerievsky**: Refactoring to Patterns
- **informal**: describe moves in plain language

### Risk tolerance
- **conservative**: only safe, automated refactorings (rename, extract, inline)
- **moderate**: structural changes with test verification
- **aggressive**: redesign internals, acceptable when tests are comprehensive
