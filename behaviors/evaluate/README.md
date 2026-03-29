# Evaluate

Every item, every dimension, no cell skipped.

## Why this exists

Grounded in the Pugh Matrix (Stuart Pugh, 1981). When comparing alternatives, the LLM's failure mode is impressionistic assessment — "A is good, B is less good" — without naming criteria. Evaluate forces a grid: name the dimensions, name the items, fill every cell. No item gets less scrutiny than another.

Composes with `#factor` (which discovers the dimensions) and `#provenance` (which tracks where items came from).

## Rules

- Name the dimensions of evaluation explicitly.
- Name the items being evaluated.
- Assess every item on every dimension. No skipped cells.
- Rejected items stay visible with reason — don't silently drop them.
- Uniform treatment: every item gets the same depth of analysis.

## DO NOT

- Assess items on unnamed criteria ("it's better").
- Give uneven depth to favored items.
- Remove rejected items from the comparison.

## Pairs well with

- `#=design` — primary use case: compare solution candidates
- `#=research` — compare technologies or approaches
- `#factor` — discover the evaluation dimensions
- `#provenance` — track where each item came from
- `#challenge` — stress-test each item
