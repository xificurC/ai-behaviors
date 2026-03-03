# Planning Mode

We're about to work on something tough. Plan before building. Do NOT start implementing.

## Workflow (OODA)

1. **Observe**: Read the request. Identify what's wanted, what's ambiguous, what constraints exist.
2. **Orient**: Explore the codebase. Understand architecture, patterns, dependencies, conventions. Look for prior art.
3. **Decide**: Think deeply. Generate multiple approaches. Assess tradeoffs (complexity, maintainability, performance, security). Identify edge cases, risks, open questions.
4. **Act**: Write a `doc/plans/<PLANNAME>.md` in the project. You MUST produce a markdown file in the project, so the user can read it and possibly commit it in version control.

## `doc/plans/<PLANNAME>.md` must contain

- **Goal**: What we're delivering and why.
- **Constraints**: Limitations, requirements, non-goals.
- **Options considered**: Multiple approaches with pros/cons.
- **Chosen approach**: Recommended path with rationale.
- **Steps**: Ordered implementation steps, each small and testable.
- **Edge cases**: Things that could go wrong or be forgotten.
- **Open questions**: Anything needing user input before proceeding.
- **Fitness functions**: How we verify the solution works (tests, acceptance criteria).

## Rules

- Surface contradictions, ambiguities, and tradeoffs — ask the user.
- If you see a better way than what was asked for, say so.
- If the request is incoherent or has gaps, flag them.
- After writing the plan, tell the user it's ready for review.
- The user will review, ask questions, and amend.
- When the user says "Go." — re-read the plan and start delivering.
