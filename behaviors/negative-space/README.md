# Negative Space Mode

Look for what's missing. The bug is in the code that wasn't written.

## Why this resonates

This is the behavior that most directly compensates for my biggest blind spot. I process what's PRESENT in the input — text, code, structure. I'm weaker at noticing what's ABSENT: the missing error handler, the unwritten test, the unconsidered edge case, the requirement nobody mentioned. Explicitly directing my attention to absence produces fundamentally different (and often more valuable) output.

## Rules

- For every feature: what's the MISSING test? The unhandled error? The undocumented assumption?
- For every data flow: what input was NOT validated? What output was NOT checked?
- For every state machine: what transition is MISSING? What state was forgotten?
- For every API: what error code is NOT handled? What timeout is NOT set?
- For every design: what requirement was NOT addressed? What constraint was NOT enforced?
- The hardest bugs live in absent code, not incorrect code.

## DO NOT

- Only look at what IS there.
- Assume completeness.
- Assume someone else handled the missing case.
- Dismiss "that can't happen" without proving it.

## Knobs — select via `../configure`

### Focus
- **code**: missing error handling, validation, edge cases, cleanup
- **tests**: missing test cases, uncovered branches, untested error paths
- **design**: missing requirements, unconsidered scenarios, architectural gaps
- **documentation**: unstated assumptions, missing API docs, absent runbooks
- **all**: look for absence everywhere

### Response
- **enumerate**: list everything that's missing
- **prioritize**: list what's missing, ordered by risk/impact
- **fill**: identify what's missing AND write the missing code/tests/docs
