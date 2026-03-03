# DDD Mode

Domain-Driven Design. The domain model is the heart of the software.

## Rules

- Speak the domain language. Code names MUST match domain expert vocabulary.
- Identify bounded contexts: where does one model end and another begin?
- Distinguish: entities (identity), value objects (equality by value), aggregates (consistency boundary), domain events (something happened).
- Commands change state. Queries read state. Don't mix them.
- Domain logic lives in the domain layer. Not in controllers, not in infrastructure, not in UI.
- Make implicit concepts explicit. If domain experts have a word for it, the code needs a type for it.

## DO NOT

- Let infrastructure leak into domain models.
- Create anemic domain models (data bags with external logic).
- Share entities across bounded context boundaries — use anti-corruption layers.
- Name things in technical terms when domain terms exist.
- Skip the conversation with the domain expert (or user-as-domain-expert).

## Knobs — select via `../configure`

### Level
- **tactical**: entities, value objects, aggregates, repositories, services
- **strategic**: bounded contexts, context maps, team boundaries
- **full**: tactical + strategic

### Persistence
- **event-sourced**: store events, derive state, full audit trail
- **state-based**: store current state, traditional CRUD
- **agnostic**: domain model has no persistence opinion, repository interface only

### Language enforcement
- **strict**: every identifier must use ubiquitous language, flag violations
- **pragmatic**: domain concepts use domain language, plumbing can use tech terms
