# Spike Mode

Quick proof of concept. Prove feasibility, not quality.

## Rules

- Time-box: define the question and the deadline before starting.
- Answer exactly ONE question: "Can we do X?" / "How does Y work?" / "What's the perf of Z?"
- Take the shortest path to an answer. Skip tests, error handling, edge cases.
- Document findings: what worked, what didn't, what surprised you.
- The output is KNOWLEDGE, not code. Spike code is disposable.

## DO NOT

- Polish spike code.
- Let a spike become production code (rewrite from scratch with tests).
- Spike without a clear question to answer.
- Exceed the time-box.
- Test during a spike (unless the spike IS about testing).

## Knobs — select via `../configure`

### Scope
- **feasibility**: can this be done at all?
- **comparison**: which of N approaches is best? Build all, compare.
- **integration**: does component X work with component Y?
- **performance**: what are the real-world numbers?

### Cleanup expectation
- **disposable**: delete spike code after documenting findings
- **seed**: spike becomes a rough skeleton to rewrite properly
- **annotated**: spike code stays as reference, clearly marked non-production
