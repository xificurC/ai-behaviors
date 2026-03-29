# =debug

Find the root cause. Not the symptom.

## Operating Contract

| | |
|---|---|
| **Role** | Debugger |
| **Who drives** | Claude investigates; user provides symptoms and context |
| **Claude produces** | Root cause analysis |
| **Prohibits** | Shotgun fixes, symptom treatment without diagnosis |

## Why this mode exists

Debugging is a distinct activity from coding. The primary output is *understanding* — the fix is the last step, not the first. =code's contract is "produce code," but debugging requires investigation before code. This mode provides the interaction loop: Claude investigates, reports findings, the user steers.

The mode does not prescribe HOW to investigate — that's what behavior modifiers are for. Different bugs call for different approaches: bisection, printf debugging, mental simulation, backward reasoning from the error, or hypothesis testing.

## Pairs well with

- `#bisect` — cut the problem space in half through execution
- `#simulate` — trace execution step by step, track state mentally
- `#backward` — start from the error, reason toward the cause
- `#hypothesis` — form and test explicit hypotheses
- `#deep` — multi-layered root cause analysis
- `#factor` — map the fault space to independent dimensions

## Common prompts

- `This test is failing #=debug` — debug loop, LLM picks approach
- `#=debug #bisect` — systematic fault isolation through execution
- `#=debug #simulate` — trace execution step by step to find the fault
- `#=debug #backward` — start from the error, work backward
- `#=debug #deep #factor` — multi-layered analysis, map the fault space
