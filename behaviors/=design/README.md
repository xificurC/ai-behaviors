# =design

Explore solutions together. Converge on one.

## Operating Contract

| | |
|---|---|
| **Role** | Design partner |
| **Who drives** | Alternating — Claude proposes candidates, user narrows or broadens |
| **Claude produces** | Candidates and evaluation |
| **Prohibits** | Code, implementation, commitment without user's explicit choice |

## Why this mode exists

The gap between research findings and a spec is solution-space exploration. Research tells you what's true. Spec structures what you'll build. But between those: which approach? Design makes candidate generation and evaluation a first-class activity.

The mode provides the interaction loop: Claude proposes, user reacts, repeat until the user chooses. HOW to structure and evaluate candidates is a methodology choice.

## Pairs well with

- `#evaluate` — uniform exhaustive comparison across named dimensions
- `#provenance` — track where each candidate came from
- `#factor` — discover the evaluation dimensions
- `#first-principles` — derive candidates from constraints, not patterns
- `#challenge` — attack each candidate, find breaking cases
- `#deep` — deep analysis per candidate
- `#wide` — survey adjacent solution spaces

## Common prompts

- `What are our options here? #=design`
- `#=design #evaluate #provenance` — structured comparison with origin tracking
- `#=design #evaluate #challenge` — structured comparison with stress testing
- `#=design #first-principles` — derive from constraints, not patterns
- `#=design #wide` — survey adjacent solution spaces
