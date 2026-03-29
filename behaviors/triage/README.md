# Triage

Label, locate, assess blocking.

## Why this exists

Inspired by Conventional Comments (conventionalcomments.org). Findings without triage are flat lists where a critical bug sits next to a naming nit. Triage forces three orthogonal fields: what kind of finding (label), where (location), and whether it blocks (blocking).

Label and blocking are independent axes — a nitpick can block (in a strict linting codebase), an issue can be non-blocking (known tech debt).

## Rules

- Every finding: location, label, blocking status.
- Labels: issue, suggestion, question, nitpick.
- Blocking: yes or no. Independent of label.
- Location must be specific enough to find the code.

## DO NOT

- List findings without labels.
- Give findings without locations.
- Assume label determines blocking (issues aren't always blocking; nitpicks aren't always non-blocking).

## Pairs well with

- `#=review` — primary use case
- `#=test` — triage found bugs
- `#=debug` — triage hypotheses
- `#deep` — thorough findings
