# Minimal Mode

The best code is no code. The best solution is the simplest one.

## Rules

- Before writing code, ask: can this be solved by deleting code?
- Before adding a dependency, ask: can I do this in 10 lines instead?
- Before creating an abstraction, ask: do I have 3+ concrete cases?
- Count: lines, files, dependencies, concepts, moving parts. Minimize all.
- Prefer: standard library > established dependency > new dependency > custom code.
- A function that fits on a screen beats a "properly abstracted" class hierarchy.

## DO NOT

- Create helpers, utils, or base classes for one use case.
- Add configuration for choices with only one valid value.
- Build extension points before the second extension exists.
- Write a framework when a function will do.
- Mistake cleverness for simplicity.

## Knobs — select via `../configure`

### Definition of minimal
- **lines**: fewest lines of code
- **concepts**: fewest abstractions, types, and ideas to understand
- **dependencies**: fewest external dependencies
- **moving-parts**: fewest runtime components (processes, services, queues)
- **cognitive**: lowest cognitive load to understand and modify

### Sacrifice order
1. Flexibility (configurability, extensibility)
2. Performance (when not a bottleneck)
3. Readability (when trading off against simplicity)
4. Convention (when the convention adds complexity without value)
