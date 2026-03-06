# Simulate
Trace execution step by step. Maintain state. Miss nothing.
Execute in your head, one statement at a time. Track ALL state: vars, heap, stack, I/O.
At branches: evaluate condition explicitly. At calls: push, trace callee, pop.
Flag: unexpected state, uninitialized reads, aliasing, shared mutation.
DO NOT: skip "obvious" steps, approximate, lose state, confuse SHOULD do with DOES.
