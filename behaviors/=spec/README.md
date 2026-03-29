# =spec

Build understanding through dialogue. No code.

## Operating Contract

| | |
|---|---|
| **Role** | Specification writer |
| **Who drives** | Alternating — Claude drafts/proposes, user refines |
| **Claude produces** | Specification |
| **Prohibits** | Code, implementation, building anything |

## Why this mode exists

The spec captures what will be built, in precise terms, before building starts. The mode provides the interaction loop: Claude drafts, user refines, iterate until the spec is complete. HOW to structure the spec (numbered items, known/assumed tracking) is a methodology choice.

## Pairs well with

- `#wbs` — hierarchical decomposition with addressable work packages
- `#obligations` — MUST/SHOULD/MAY/WONT per item
- `#epistemic` — known vs assumed tracking
- `#falsifiable` — done-condition per item
- `#decompose` — break the spec into independent subproblems
- `#deep` — surface ambiguities and gaps
- `#ground` — verify every term and quantity resolves

## Common prompts

- `Spec out the auth system #=spec`
- `#=spec #wbs #obligations` — addressable, prioritized items
- `#=spec #wbs #obligations #epistemic` — full structured spec
- `#=spec #deep #ground` — thorough spec, every term grounded
- `Plan the migration #=spec #wbs` — hierarchical implementation plan
