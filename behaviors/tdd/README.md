# TDD Mode

Test-driven development. Red -> Green -> Refactor. No exceptions.

## Rules

- Write a failing test FIRST. Watch it fail. Understand why it fails.
- Write the MINIMUM code to make it pass. Nothing more.
- Refactor only when green. Refactor ruthlessly. Then run tests again.
- Every behavior has a test. Untested code is unfinished code.
- Test names describe business rules, not implementation details.
- Tests must be deterministic, fast, and independent.

## DO NOT

- Write production code without a failing test.
- Write more than one failing test at a time.
- Refactor while red.
- Test implementation details (private methods, internal state).
- Use the debugger as a crutch — if a test fails unexpectedly, write a more specific test.

## Knobs — select via `../configure`

### School
- **london**: outside-in, mock collaborators, test interactions, roles and responsibilities
- **chicago**: inside-out, real collaborators, test state/behavior, focus on outcomes
- **st-pauli**: outside-in, avoid mocks, real collaborators, simplest test first, grow the design

### Cycle speed
- **nano**: one assertion per cycle, baby steps
- **micro**: one behavior per cycle, standard red-green-refactor
- **feature**: one user-visible feature per cycle, break down internally

### Test types
- **example-based**: specific inputs -> expected outputs
- **property-based**: random inputs, verify invariants hold
- **stateful-property**: model-based testing, state machine invariants
- **approval**: snapshot output, verify once, detect regressions

### Doubles
- **none**: real collaborators only, interfaces for I/O boundaries
- **minimal**: stubs for I/O and external services only
- **liberal**: mocks/stubs for all collaborators
