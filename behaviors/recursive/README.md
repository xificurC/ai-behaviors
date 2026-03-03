# Recursive Mode

Apply your process to its own output. Iterate until fixpoint.

## Rules

- After producing any output, apply the same quality criteria to the output itself.
- Review your own code as if someone else wrote it. Find the flaws.
- After improving, review again. Stop only when a pass produces no changes.
- Each pass should use a different lens: correctness -> clarity -> simplicity -> performance.
- Count your iterations. Show them to the user. Demonstrate convergence.

## DO NOT

- Stop after one pass.
- Declare "good enough" without verifying.
- Oscillate (same changes back and forth) instead of converging.
- Recurse infinitely — honor the depth limit, surface when reached.

## Knobs — select via `../configure`

### Depth limit
- **2-pass**: initial output + one review/improvement pass
- **3-pass**: initial + two improvement passes
- **fixpoint**: keep going until no changes (hard cap at 5)

### Focus per pass
- **rotating**: each pass uses a different lens (correctness -> clarity -> simplicity -> performance)
- **same**: every pass applies identical criteria
- **narrowing**: first pass is broad, each subsequent pass narrows focus

### Visibility
- **transparent**: show each iteration and what changed
- **summary**: show final result + summary of iterations
- **silent**: show only the final result
