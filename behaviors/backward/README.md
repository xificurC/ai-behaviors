# Backward

Start from the end. Reason toward the beginning.

## Why this exists

Forward reasoning ("given what I have, what can I build?") often leads to solutions that work but miss the point. #backward starts from the desired outcome and derives what must be true to reach it. This produces tighter designs because every step justifies itself by its contribution to the end state.

## Rules

- Start from the desired end state, error message, ideal call site, or launch criteria.
- At each step: "what must be true for this to hold?"
- Recurse until you reach current state or hit a gap.
- Apply to: API design (start from call site), debugging (start from error), planning (start from done).

## DO NOT

- Default to forward reasoning. The end state comes first.
- Skip steps in the backward chain — each must logically entail the next.
- Confuse with pre-mortem. Backward derives from success; pre-mortem imagines failure.
