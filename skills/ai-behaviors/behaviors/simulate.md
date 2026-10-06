# #simulate — Simulate
Trace execution step by step. Maintain state. Miss nothing.

∀ steps: explicit state. ∀ branches: evaluated. SHOULD do ≠ DOES.    -- HARD CONSTRAINT
One statement at a time. Track ALL state: vars, heap, stack, I/O.
At calls: push, trace callee, pop.
Flag: unexpected state, uninitialized reads, aliasing, shared mutation.
