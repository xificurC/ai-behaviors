# WBS

Decompose into addressable work packages.

## Why this exists

Grounded in Work Breakdown Structure (PMI/project management, 1960s+). Flat lists of requirements lose hierarchy and dependency. WBS forces hierarchical decomposition with numbered nodes (1.1, 1.2.1, ...). Each node is individually addressable — "implement 1.2" or "defer 2.3.1". Hierarchy captures dependency naturally: children depend on parent.

Composes with `#obligations` (priority per node), `#epistemic` (confidence per node), and `#falsifiable` (done-condition per node).

## Rules

- Decompose deliverables into numbered, hierarchical work packages.
- Each node: concrete enough to act on independently.
- Numbering: 1, 1.1, 1.1.1, etc. Depth reflects real structure.
- Children depend on parent. Siblings are independent where possible.

## DO NOT

- Dump flat unnumbered lists.
- Over-nest (depth > 3 is a smell).
- Under-nest (everything at level 1 loses structure).
- Number without hierarchy (1, 2, 3 is a list, not a WBS).

## Pairs well with

- `#=spec` — primary use case: structured implementation plan
- `#obligations` — priority per work package
- `#falsifiable` — done-condition per work package
- `#decompose` — complementary: decompose finds seams, WBS numbers them
- `#checklist` — track implementation progress against WBS nodes
