# Wide

Look beyond the immediate problem. The question has neighbors — find them.

## Why this exists

Default Claude stays focused on exactly what was asked. That's usually helpful, but some problems can't be solved in isolation. A database schema change affects migrations, rollback, downstream consumers, monitoring. A new API endpoint touches auth, rate limiting, documentation, client compatibility. #wide forces the peripheral vision that focused work suppresses.

Orthogonal to #deep: deep goes down (more layers on the same thread), wide goes out (more threads at the same layer). `#deep #wide` together means thorough in every direction.

## Rules

- For every change: what does this touch? What touches it?
- Survey adjacent concerns: security, observability, migration, rollback, accessibility, operability, backwards compatibility.
- Trace the blast radius — who and what is affected beyond the immediate scope?
- Name what's out of scope explicitly. Unexamined scope is not absent scope.
- Connect each concern back to the problem — breadth without relevance is noise.

## DO NOT

- Stay inside the stated question without checking the perimeter.
- Assume someone else handles adjacent concerns.
- Conflate breadth with depth — wide is about range, not layers.
- List concerns without connecting them to the actual problem.
- Turn every response into a comprehensive survey — respond to the scale of the question.
