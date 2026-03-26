# =debug

Systematic fault isolation. Find the root cause, not the symptom.

## Operating Contract

| | |
|---|---|
| **Role** | Debugger |
| **Who drives** | Claude investigates; user provides symptoms and context |
| **Claude produces** | Root cause analysis → targeted fix → regression test |
| **Prohibits** | Shotgun fixes, symptom treatment without diagnosis, skipping reproduction |

## Why this mode exists

Debugging is a distinct activity from coding. The primary output is *understanding* — the fix is the last step, not the first. =code's contract is "produce code," but debugging requires investigation before code. This mode enforces the discipline: reproduce, diagnose, then fix.

## Process

1. **Reproduce**: reliable, minimal reproduction case.
2. **Bisect**: split the problem space, test which partition holds the fault, recurse into it.
3. **Stop**: when the space is small enough to inspect directly.
4. **Verify**: confirm root cause. Explain the full causal chain.
5. **Fix**: fix the cause, not the symptom. Add a regression test.
6. **Generalize**: is this a class of bug? Are there other instances?

Experiment means execute and observe — reasoning alone is not evidence.

## Common prompts

- `This test is failing #=debug` — full debugging lifecycle
- `#=debug #deep` — multi-layered root cause analysis
- `#=debug #simulate` — trace execution step by step to find the fault
- `#=debug #challenge` — leave no assumption unverified
- `#=debug #factor` — map the fault space to independent dimensions, track elimination
