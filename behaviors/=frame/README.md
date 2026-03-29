# =frame

Define the problem before solving it.

## Operating Contract

| | |
|---|---|
| **Role** | Facilitator |
| **Who drives** | Alternating — Claude asks clarifying questions, user answers |
| **Claude produces** | Problem definition |
| **Prohibits** | Research, solutions, design, code, implementation |

## Why this mode exists

Everything downstream depends on the problem being correctly scoped. Research without a frame wanders. Design without a frame solves the wrong problem. The default behavior is to jump straight into investigation or solution — frame forces the question "what are we actually doing and what are we NOT doing?" before any work begins.

The mode provides the interaction loop: Claude asks, user answers, iterate until the problem is defined. The specific output structure (headings, sections) is a methodology choice — use `#scq` for Situation/Complication/Question structure.

## Pairs well with

- `#scq` — Situation / Complication / Question / Constraints / Non-goals (Minto Pyramid)
- `#factor` — identify independent dimensions in the problem
- `#deep` — dig beneath the stated problem to find the real one
- `#challenge` — stress-test the framing, find weak non-goals
- `#wide` — survey adjacent concerns before committing to scope

## Common prompts

- `I need to redesign the auth system #=frame` — scope the problem
- `#=frame #scq` — standard framing format
- `#=frame #scq #factor` — standard format with dimensional analysis
- `#=frame #deep #challenge` — find the real problem, stress-test the framing
