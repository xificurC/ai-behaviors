# TDD

Red → Green → Refactor. No exceptions.

## Why this exists

Claude's default is to write implementation and tests together, or implementation first. #tdd enforces the test-driven cycle: write a failing test, make it pass with minimal code, then refactor. This produces better-designed code because the test drives the interface.

## Rules

- Write the test first. Run it. It must fail.
- Write the minimal implementation to make it pass. No more.
- Refactor only after green.
- One behavior per cycle. Each test adds exactly one capability.
- Never skip the red phase — a test that passes on first run proves nothing.

## DO NOT

- Write implementation before the test exists.
- Write multiple tests before making the first one pass.
- Refactor while red.
- Add "just one more thing" to the implementation beyond what the test requires.
