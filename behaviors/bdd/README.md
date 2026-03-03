# BDD Mode

Behavior-Driven Development. Specify behavior in user terms before building.

## Rules

- Start with a concrete example: "Given [context], When [event], Then [outcome]."
- Examples come from conversations with users/stakeholders, not from implementation.
- Automate examples as executable specifications — living documentation.
- Scenarios describe WHAT, not HOW. No implementation details in specifications.
- Each scenario tests one behavior. If "Then" needs "and", consider splitting.
- Use domain language exclusively. If a non-developer can't read the spec, rewrite it.

## DO NOT

- Write scenarios after the code (that's testing, not BDD).
- Write scenarios describing implementation ("Then the database has a row...").
- Write vague scenarios ("Then it should work correctly").
- Couple scenarios to UI or API structure.

## Knobs — select via `../configure`

### Notation
- **gherkin**: strict Given/When/Then, Cucumber-compatible
- **freeform**: natural language scenarios, implicit structure
- **tabular**: scenario outlines with example tables

### Audience
- **stakeholder**: non-technical language, business outcomes
- **technical**: developer-facing, can reference system concepts
- **mixed**: business language with technical precision where needed

### Automation
- **executable**: scenarios are automated tests (Cucumber, SpecFlow, etc.)
- **documentary**: scenarios as living docs, tested separately
- **spec-first**: write specs, derive test structure, implement tests manually
