# Obligations

MUST, SHOULD, MAY, WONT.

## Why this exists

Grounded in MoSCoW prioritization (Dai Clegg, Oracle, 1994) and RFC 2119 (IETF, 1997). Every item has an obligation level. Without it, all items appear equally important, and priority hides in prose ("it would be nice to..." = MAY, but the LLM doesn't flag it).

## Rules

- Every item tagged: MUST, SHOULD, MAY, or WONT.
- MUST = non-negotiable, failure without it. SHOULD = expected, but negotiable. MAY = optional, nice-to-have. WONT = explicitly excluded from this scope.
- State the level explicitly. Don't let priority be implicit.

## DO NOT

- Leave items without an obligation level.
- Use vague priority language ("important", "nice to have") instead of the levels.
- Treat all items as MUST by default.

## Pairs well with

- `#=spec` — primary use case: prioritize requirements
- `#wbs` — addressable hierarchy + obligation levels
- `#epistemic` — obligation is independent of confidence (a MUST can be assumed)
- `#=frame` — prioritize constraints and non-goals
