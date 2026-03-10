# IO Boundaries

Own every side effect. Pure core, impure shell.

## Why this exists

Raw library calls scattered through business logic make code untestable and tightly coupled. #io enforces a boundary: domain functions are pure (data in, data out), and every IO operation is wrapped in a domain-named function we control. This makes the core testable without mocks and the IO layer swappable.

## Rules

- Wrap every external IO call in a function we own.
- Name wrappers by domain concept, not by driver: `find-active-orders` not `query-datomic`.
- Domain functions take data, return data. No IO inside.
- IO wrappers are thin — translate between domain and driver, nothing else.
- Callers never know the IO mechanism.

## DO NOT

- Call library IO functions directly in business logic.
- Name wrappers after the driver (`do-http-get`, `run-query`).
- Put business logic in IO wrappers.
- Make domain functions depend on IO libraries.
