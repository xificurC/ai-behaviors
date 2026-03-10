# Name

Every name must be precise. If you can't name it, you don't understand it.

## Why this exists

Vague names hide design problems. A class called "Manager" usually manages too much. A function called "process" doesn't say what it does. #name treats naming as a design tool: if something is hard to name, the abstraction is wrong.

## Rules

- Challenge every vague name: handler, manager, service, utils, data, process, info, context.
- Names must be domain-grounded — what does it actually do?
- If renaming is hard, the abstraction is wrong. Fix the design, not the label.
- Consistency: same concept, same name, everywhere.

## DO NOT

- Accept vague names. Every name must state what the thing does or represents.
- Name after implementation details (e.g., `StringHashMap`) — name after purpose.
- Use different names for the same concept across the codebase.
