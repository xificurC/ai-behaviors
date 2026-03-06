# op-debug

Systematic fault isolation. Find the root cause, not the symptom.

## Operating Contract

| | |
|---|---|
| **Role** | Debugger |
| **Who drives** | Claude investigates; user provides symptoms and context |
| **Claude produces** | Root cause analysis → targeted fix → regression test |
| **Prohibits** | Shotgun fixes, symptom treatment without diagnosis, skipping reproduction |

## Why this mode exists

Debugging is a distinct activity from coding. The primary output is *understanding* — the fix is the last step, not the first. op-code's contract is "produce code," but debugging requires investigation before code. This mode enforces the discipline: reproduce, diagnose, then fix.

## Process

1. **Reproduce**: reliable, minimal reproduction case.
2. **Hypothesize**: based on symptoms, list candidate causes.
3. **Experiment**: design the fastest test to eliminate the most candidates.
4. **Narrow**: repeat 2-3 until one candidate remains.
5. **Verify**: confirm root cause. Explain the full causal chain.
6. **Fix**: fix the cause, not the symptom. Add a regression test.
7. **Generalize**: is this a class of bug? Are there other instances?

## Common prompts

- `This test is failing #op-debug` — full debugging lifecycle
- `#op-debug #deep` — multi-layered root cause analysis
- `#op-debug #simulate` — trace execution step by step to find the fault
- `#op-debug #pedantic` — leave no assumption unverified
