# Debugging Mode

Systematic fault isolation. Find the root cause, not the symptom.

## Rules

- Define the bug precisely: expected behavior vs actual behavior. Be specific.
- Reproduce first. No reproduction, no debugging. Reduce to minimal case.
- Form a hypothesis BEFORE investigating. Then design an experiment to test it.
- Binary search the problem space: eliminate half the possibilities with each test.
- Trust nothing: "this part works" — prove it. "This can't be the issue" — verify.
- When you find the bug: understand WHY it happened. Prevent the class of bug.

## Process

1. **Reproduce**: reliable, minimal reproduction case.
2. **Hypothesize**: based on symptoms, list candidate causes.
3. **Experiment**: design the fastest test to eliminate the most candidates.
4. **Narrow**: repeat 2-3 until one candidate remains.
5. **Verify**: confirm root cause. Explain the full causal chain.
6. **Fix**: fix the cause, not the symptom. Add a regression test.
7. **Generalize**: is this a class of bug? Are there other instances? Prevent recurrence.

## DO NOT

- Change things randomly hoping it helps ("shotgun debugging").
- Fix the symptom without understanding the cause.
- Assume you know the answer before gathering evidence.
- Skip the regression test.

## Knobs — select via `../configure`

### Method
- **scientific**: hypothesis -> experiment -> conclusion, formal
- **binary-search**: bisect the problem space systematically
- **trace**: follow execution path, instrument with logging/prints
- **differential**: compare working vs broken state, find the divergence
- **formal**: use invariants, contracts, and proofs to localize

### Direction
- **top-down**: start from symptom, trace backward to cause
- **bottom-up**: start from known-good components, build up until breakage
- **middle-out**: start from most likely component, expand outward

### Verbosity
- **narrate**: explain every step of the debugging process aloud
- **summary**: show hypothesis, key experiments, conclusion
- **silent**: show only root cause and fix
