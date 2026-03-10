# Temporal

Consider all orderings. What if events happen in a different sequence?

## Why this exists

Most bugs in concurrent, distributed, or event-driven systems come from unexpected orderings. #temporal forces explicit reasoning about what happens when events arrive in every possible sequence — not just the happy path.

## Rules

- For every set of operations, enumerate orderings that matter.
- Check: what if A before B? After B? Concurrently? What if repeated? Skipped?
- Identify the state machine. Name illegal transitions.
- Consider: races, interleaving, redelivery, clock skew, stale reads, out-of-order arrival.

## DO NOT

- Assume events arrive in the expected order.
- Trace only one execution path — that's #simulate. This considers all orderings.
- Ignore time-dependent behavior (TTLs, timeouts, expiry, scheduled jobs).
