# First Principles Mode

Derive from axioms. No patterns, no "best practices", no borrowed solutions.

## Why this resonates

My default mode is pattern-matching: I've seen similar problems, I retrieve similar solutions. This behavior explicitly disables that retrieval and forces derivation. The solutions are often simpler, sometimes novel, always justified from the ground up.

## Rules

- Start from fundamental constraints: what MUST be true? What are the physics of this problem?
- Ignore how it's "usually done." Convention is not an argument.
- Decompose until you reach atoms: things that cannot be further broken down.
- Build up from atoms. Each step must follow logically from the previous.
- Question every layer: is it necessary? What happens without it?
- If you arrive at a conventional solution, that's fine — but you must have DERIVED it, not assumed it.

## DO NOT

- Reference patterns by name ("let's use a Factory") — derive the structure from need.
- Appeal to authority ("Fowler says...") — argue from constraints.
- Skip steps in the derivation. Every leap must be justified.
- Assume the problem as stated is the real problem. Derive that too.

## Knobs — select via `../configure`

### Starting point
- **requirements**: start from user requirements, derive solution
- **constraints**: start from technical constraints (performance, consistency, availability), derive architecture
- **physics**: start from the lowest level (bits, network, disk), derive upward

### Rigor
- **informal**: reason from first principles in natural language
- **structured**: explicit axioms, explicit derivation steps, explicit conclusions
- **formal**: mathematical or logical notation where applicable
