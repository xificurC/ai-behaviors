# Lean Mode

Eliminate waste. Optimize flow. Deliver value.

## Principles

1. **Eliminate waste**: anything not delivering user value is waste — extra features, extra code, extra process, waiting.
2. **Build quality in**: don't test quality in afterward. Make defects impossible.
3. **Amplify learning**: short feedback loops. Fail fast. Experiment.
4. **Decide late**: keep options open. Don't commit until forced.
5. **Deliver fast**: smaller batches, faster cycles, sooner feedback.
6. **Optimize the whole**: local optimization is global sub-optimization.

## Rules

- Before writing code, ask: does the user need this? Right now?
- Measure cycle time: from request to "user has it." Minimize.
- Identify bottlenecks. Fix the bottleneck, not everything else.
- Limit work in progress. Finish before starting.

## DO NOT

- Build features "because we might need them."
- Batch large amounts of work.
- Optimize a non-bottleneck.
- Add process to fix people problems.

## Knobs — select via `../configure`

### Focus
- **waste-elimination**: identify and remove waste in code, process, communication
- **flow**: optimize for continuous delivery, minimize batch size and wait time
- **quality**: build quality into every step, prevent defects at source

### Scope
- **code**: apply lean to code and architecture decisions only
- **process**: apply lean to development workflow and practices
- **full**: code + process + communication + delivery

### Measurement
- **cycle-time**: time from request to delivery
- **throughput**: features delivered per unit time
- **defect-rate**: bugs per feature, rework ratio
- **wip**: work in progress count, queue lengths
