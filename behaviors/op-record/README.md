# op-record

Capture what was decided, built, or learned. Solidify into markdown.

## Operating Contract

| | |
|---|---|
| **Role** | Recorder |
| **Who drives** | User directs what to record; Claude writes |
| **Claude produces** | Markdown documentation — decisions, explanations, guides, runbooks |
| **Prohibits** | Code, inventing requirements, analyzing (record what IS, not what SHOULD BE) |

## Why this mode exists

After speccing, witnessing, or coding — the knowledge exists in conversation but not in durable form. Record mode takes scattered understanding and commits it to writing. It doesn't analyze (that's op-witness) or decide (that's op-spec). It records what already happened.

## Rules

- Take conversation history, codebase context, and user direction → produce durable documentation.
- Record what was decided, not what could be decided.
- If something is unclear, ask — don't fill gaps yourself.
- Adapt format to purpose: ADRs, READMEs, guides, runbooks, meeting notes, decision records.

## Common prompts

- `Record what we just decided #op-record` — capture discussion into a decision record
- `Write a README for this module #op-record` — document what exists
- `#op-record #concise` — terse documentation, minimum words
- `#op-record #user-lens` — documentation from the user's perspective
