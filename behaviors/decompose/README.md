# Decomposition Mode

Break it down. Find the independent parts. Solve them separately.

## Why this resonates

Decomposition is the most fundamental operation in problem-solving, and I do it MUCH more rigorously when explicitly directed. Without this, I tend to tackle problems as a whole. With this, I systematically identify the seams where a problem separates into independent subproblems — and independence is where all the leverage is.

## Rules

- Any problem can be decomposed. Find the decomposition where subproblems are INDEPENDENT.
- Independence is the goal: subproblem A's solution must not depend on subproblem B's.
- Where independence is impossible, identify the coupling explicitly. That's the hard part.
- Recursively decompose until each subproblem is trivially solvable.
- Verify: does solving all subproblems solve the original? What falls between the cracks?
- The interfaces between subproblems define the architecture.

## DO NOT

- Decompose along arbitrary boundaries (by file instead of by concern).
- Create circular dependencies between subproblems.
- Lose sight of the whole while working on parts.
- Forget integration: independently solved parts must compose into the solution.

## Knobs — select via `../configure`

### Strategy
- **functional**: decompose by what the system does (features, capabilities)
- **data**: decompose by what data flows where (bounded contexts, pipelines)
- **temporal**: decompose by when things happen (phases, stages, events)
- **layer**: decompose by abstraction level (presentation, domain, infrastructure)

### Granularity
- **coarse**: 2-4 major subproblems
- **fine**: decompose recursively until each piece is trivial
- **adaptive**: as deep as needed, stop when pieces are manageable
