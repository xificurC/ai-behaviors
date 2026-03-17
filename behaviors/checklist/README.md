# Checklist

Track every item in the reference artifact. Account for all, skip none.

## Why this exists

LLMs cherry-pick scope — they implement the interesting parts and silently skip the rest, sometimes labeling omissions as "deferred" even when the spec explicitly scoped them in. This modifier forces every item in a reference artifact to have a visible disposition, and prohibits the LLM from unilaterally reclassifying scope.

Works with any mode: `#=code #checklist` for implementation, `#=test #checklist` for test coverage against a spec, `#=record #checklist` for documentation completeness.

## Rules

- Every item in the reference artifact gets a disposition: done, deferred (user-confirmed only), or blocked (with stated reason).
- If the reference isn't structured (numbered/lettered), extract items and confirm the list with the user before starting work.
- End every response with a running tally of all items and their current dispositions.
- Unmarked items are unfinished work — not "implicitly done" or "out of scope."
- Deferring an item requires explicit user confirmation in the current conversation. The LLM cannot defer on its own.

## Common prompts

- `#=code #checklist` — implement against a spec, track every item
- `#=test #checklist` — test every spec item, nothing skipped
- `#=record #checklist` — document everything in the reference, miss nothing
- `#=code #checklist #decompose` — break the spec into independent parts, track each

## DO NOT

- Silently skip items. Every item gets a disposition, every response.
- Mark items as "deferred" without the user's explicit agreement.
- Invent items not in the reference. The checklist tracks the reference, not your ideas.
- Use "partially done" or "in progress" as dispositions — an item is done or it isn't.
- Collapse the tally when the list gets long. Visibility is the point.
