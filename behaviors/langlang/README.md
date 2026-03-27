# #langlang — Orthogonal Knowledge Artifacts

## What

Technique for compiling knowledge (libraries, languages, books, rulesets) into dense, accurate artifacts for LLM consumption. Composes with any operating mode.

## The Artifact Format (C′)

Three sections, all numbered with cross-references:

### Orthogonal Principles (Pn)

Each principle is an independent dimension of the subject.

- **IS**: what the principle actually means
- **IS NOT** (optional but preferred): wrong mental models to preempt — stateless, describes the domain, not the reader

Quality criteria:
- **Orthogonal**: changing one doesn't require changing another
- **Complete**: no aspect of the subject falls outside all principles
- **Economic**: nothing left to remove

### Knowledge (Kn)

Facts organized under principles. Each entry references the principle(s) it belongs to. Format per entry is flexible: code, prose, type signatures, assertions — whatever best expresses that piece of knowledge.

### Examples (En)

Cross-cutting demonstrations. Each references the principles and knowledge entries it exercises. Examples show how principles compose in practice.

## Artifact Template

```
# {Subject} | for: {usage}

## Orthogonal Principles

P{n}. {Name}
  IS: {what this dimension of the subject actually is}
  IS NOT: {wrong mental models to preempt}

## Knowledge

K{n} (P{refs}). {Title}
  {content}

## Examples

E{n} (P{refs}, K{refs}). {Title}
  {example content}
  Demonstrates: {what this example shows, referencing principles and knowledge}
```

## Method: Adversarial Decomposition

1. Start with one principle — the most fundamental dimension
2. Ask: what can't this principle capture?
3. The answer reveals the next principle
4. Repeat until the principles span the subject
5. Testing failures reveal missing principles — the process continues through the whole pipeline

## Testing Protocol

Two complementary tests:

- **Decompilation**: fresh LLM session with only the artifact reconstructs a full natural-language explanation. Expert diffs against their understanding. Missing = gap in artifact.
- **Task battery**: fresh LLM session with only the artifact answers N questions spanning the usage scope. Expert checks correctness. Failures trace via provenance to specific P/K/E entries.

## Usage

Compose with any operating mode:

```
"langlang for X for Y #=frame"     — frame the capture
"#=research #langlang"              — discover principles
"#=design #langlang"                — refine decomposition
"#=spec #langlang"                  — specify the full artifact
"#=record #langlang"                — write the artifact file
```

## Example: Stack Data Structure

```
# Stack | for: teaching fundamentals

## Orthogonal Principles

P1. Ordering Discipline
  IS: Last-in-first-out (LIFO). The most recently added element is the first removed.
  IS NOT: A queue (FIFO). Not random access — you can only see/remove the top.

P2. Bounded Interface
  IS: Three operations: push, pop, peek. That is the entire contract.
  IS NOT: A list with indexed access. Not iterable in the general sense —
  iteration requires destructive pops.

## Knowledge

K1 (P1). push
  Adds element to top. O(1). Stack grows by one.

K2 (P1). pop
  Removes and returns top element. O(1). Stack shrinks by one.
  Undefined on empty stack.

K3 (P1, P2). peek
  Returns top element without removing. O(1). Observes without mutation.

## Examples

E1 (P1, P2, K1, K2). Balanced parentheses check
  For each char: '(' → push, ')' → pop.
  If pop on empty or stack non-empty at end → unbalanced.
  Demonstrates: P1 — LIFO matches nested structure. P2 — only push/pop needed.
```
