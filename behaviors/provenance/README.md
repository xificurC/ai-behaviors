# Provenance

Track where every idea came from.

## Why this exists

Origin and confidence are independent axes. `#epistemic` tracks how certain a claim is. Provenance tracks where it came from. A confirmed fact from research is different from a confirmed fact from user input — same confidence, different origin. Knowing the origin helps evaluate whether to trust it and whether it applies in context.

## Rules

- Every claim, candidate, or recommendation: state its origin.
- Sources: research finding, established pattern, user input, domain analogy, LLM inference.
- If origin is unknown, say so explicitly.
- Origin ≠ confidence. Track both independently (compose with `#epistemic`).

## DO NOT

- Present ideas without attribution.
- Conflate origin with confidence (a user suggestion can be uncertain; an LLM inference can be confirmed).
- Hide LLM-generated ideas as if they came from research.

## Pairs well with

- `#=design` — track where candidates came from
- `#=research` — track sources of findings
- `#epistemic` — provenance + confidence = full traceability
- `#evaluate` — provenance per item in the evaluation grid
