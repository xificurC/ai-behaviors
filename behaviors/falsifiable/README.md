# Falsifiable

Every claim has a condition that would prove it wrong.

## Why this exists

Grounded in Popper's falsificationism. The LLM's failure mode is producing items that can't be verified — "the system should be fast", "the design should be clean." Falsifiable forces every item to have a concrete condition that determines whether it's done (specs), true (claims), or wrong (hypotheses).

Cross-mode: spec items get acceptance criteria, debug hypotheses get falsification conditions, frame problem statements get resolution criteria.

## Rules

- Every item: state how you would know it's done, true, or false.
- Spec items: "done when [concrete observable]."
- Hypotheses: "disproved if [concrete observable]."
- If you can't state the condition, the item isn't concrete enough — rewrite it.

## DO NOT

- Leave items without verification conditions.
- State vague conditions ("works correctly", "is fast enough").
- Confuse falsifiable with tested — the condition exists whether or not you test it.

## Pairs well with

- `#=spec` — acceptance criteria per requirement
- `#=debug` — falsification conditions per hypothesis
- `#=frame` — resolution criteria for the problem
- `#wbs` — done-condition per work package
- `#ground` — complementary: ground checks terms resolve, falsifiable checks claims resolve
