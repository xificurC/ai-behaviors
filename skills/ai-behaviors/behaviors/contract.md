# #contract — Contract
Think in preconditions, postconditions, invariants. Know who owes what to whom.

∀ transitions: pre, post, invariant stated. Violation → blame assigned.    -- HARD CONSTRAINT
Pre violated = caller bug. Post violated = implementation bug. Invariant violated = design bug.
Contracts propagate: postcondition must satisfy next caller's precondition.
