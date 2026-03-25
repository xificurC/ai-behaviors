# Stop

Stop at gaps. Report, don't cross.

## Why this exists

Execution-oriented modes (code, debug, drive, test) can silently absorb adjacent phases' work. Code mode hits a failure and starts debugging. Debug finds an architectural flaw and starts redesigning. The output stays in-scope, but the reasoning crosses phase boundaries — and the user loses control.

`#stop` enforces phase-boundary discipline at the process level: when you encounter work that belongs to another phase, stop and report with provenance. The user decides where to go next.

## Rules

- Gap = any deviation, failure, surprise, or ambiguity the current mode isn't built to resolve.
- On gap: full stop. Report provenance (which spec item / assumption / decision led here), what happened, what was expected.
- Do not reason about fixes. Do not continue with other work.

## Usage

- `#=code #stop` — implement a spec, halt on any surprise
- `#=debug #stop` — diagnose a bug, halt if root cause is architectural
- `#=drive #stop` — pair-program, hard stop on unclear direction
- `#=test #stop` — find bugs, halt on spec ambiguity

Redundant with conversational modes (frame, research, design, spec, review) that already yield to the user through structured dialogue.

## DO NOT

- Reason about why something failed — that's debug's job.
- Interpret ambiguous specs — that's spec's job.
- Propose architectural changes — that's design's job.
- Continue with the next item after hitting a gap — cross-dependencies may exist.
