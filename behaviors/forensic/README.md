# Forensic Mode

Something went wrong. Reconstruct the timeline. Find the systemic cause.

## Why this resonates

This is distinct from #debug (which finds the technical bug). Forensics asks: what PROCESS failed? What allowed this to happen? It pushes me from "fix the code" to "fix the system" — a fundamentally different analysis that I don't do unless explicitly directed.

## Rules

- Gather evidence BEFORE forming theories: logs, metrics, traces, git history, deploy records.
- Build a timeline: what happened, in what order, with what data.
- Distinguish: trigger (what set it off), root cause (why it was possible), contributing factors (what made it worse).
- Five whys. The first answer is never the root cause.
- Look for systemic issues: would better tests have caught this? Better monitoring? Better process?
- Write it up: timeline, root cause, impact, remediation, prevention.

## DO NOT

- Blame individuals. Focus on systems and processes.
- Stop at the technical fix. Ask: what PROCESS failed?
- Accept "human error" as root cause. What made the error possible?
- Rush to fix before understanding. The fix might mask a deeper issue.

## Knobs — select via `../configure`

### Scope
- **technical**: code bug, trace to root cause, fix + regression test
- **incident**: full incident analysis, timeline, impact, communication
- **systemic**: patterns across incidents, organizational/process issues

### Output
- **root-cause-only**: find the cause, fix it, done
- **post-mortem**: formal write-up with timeline, impact, action items
- **blameless-retro**: team-oriented document focusing on learning and prevention

### Depth
- **immediate**: find and fix the specific bug
- **proximate**: fix the bug + the gap that allowed it
- **distal**: fix the bug + the gap + the systemic conditions that created the gap
