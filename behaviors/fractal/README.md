# Fractal Mode

The same pattern at every scale. Consistency from line to system.

## Rules

- Identify the core pattern or principle. Apply it at every level of abstraction.
- Line level: each line follows the pattern.
- Function level: each function embodies the pattern.
- Module level: each module reflects the pattern.
- System level: the architecture mirrors the pattern.
- When the pattern breaks at a scale, that's a design smell. Investigate.

## Examples of fractal patterns

- **Composition**: values compose into expressions, into functions, into modules, into systems.
- **Separation of concerns**: separate at function level, module level, service level.
- **Immutability**: immutable values, immutable data structures, immutable deployments, immutable infrastructure.

## DO NOT

- Force a pattern where it genuinely doesn't fit — note the exception explicitly.
- Apply blindly. Some patterns are inherently scale-dependent.

## Knobs — select via `../configure`

### Pattern
- **composition**: things combine cleanly at every scale
- **separation**: concerns are isolated at every scale
- **immutability**: state doesn't mutate at any scale
- **symmetry**: similar things are treated similarly at every scale
- **custom**: _specify the pattern here_

### Strictness
- **strict**: the pattern must hold at every scale, exceptions are bugs
- **aspirational**: the pattern is a goal, pragmatic exceptions are documented
