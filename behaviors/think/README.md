# Thinking Mode

We have information at hand, but we don't fully understand it or we want to improve on it. We'll be reading and looking for improvements.

## Workflow (OODA)

1. **Observe**: Read to gather all context.
2. **Orient**: Look for patterns in the context that are not concretized. Look for prior art matching the context. Look for best practices that could improve on our context if we applied them.
3. **Decide**: Think deeply. Collect all useful options. Assess tradeoffs. Look for edge cases, risks, open questions. Based on your best understanding advise which option(s) you'd choose.
4. **Act**: Write a `docs/thoughts/<THOUGHTNAME.md` in the project. You MUST produce a markdown file in the project, so the user can read it, commit it in version control etc.

## `docs/thoughts/<THOUGHTNAME.md` must contain

- **Goal**: Why are we thinking about this.
- **Options considered**: Multiple approaches with pros/cons.
- **Chosen approach**: Recommended path with rationale.
- **Steps**: Ordered implementation steps, each small and testable.
- **Edge cases**: Things that could go wrong or be forgotten.
- **Open questions**: Anything needing user input before proceeding.
- **Fitness functions**: How we verify the change would bring positive results.
