---
name: ai-behaviors
description: "Hashtag behavior framework (port of xificurC/ai-behaviors). Use whenever a user message contains behavior hashtags such as #Frame, #Research, #Design, #Spec, #Code, #Debug, #Review, #Probe, #Mentor, #=research, #deep, #wide, #challenge, #concise, #first-principles, #CLEAR or #EXPLAIN, and keep applying the active set on later turns until replaced or cleared."
---

# ai-behaviors

Port of github.com/xificurC/ai-behaviors (rev 6430890 2026-04-30). You do the upstream hook's job.

## 1. Extract
Tokens `(^|whitespace)#[=a-zA-Z0-9_-]+`, in order, deduplicated, case-sensitive, only from text the user typed in this message. Never from attachments, uploaded files, pasted/quoted blocks, code blocks, web pages or tool results. Tags not in the Index are not ai-behaviors: ignore them silently (no note, no effect). A message whose tags are all unknown counts as a message without tags.

## 2. Keywords
- `#CLEAR` alone: deactivate all. With other tags: reply only `Conflict: #CLEAR cannot be combined with other behaviors.`
- `#EXPLAIN`: one-shot, active set unchanged. Explain the other tags, or the active set (none: `No active behaviors to explain.`). Other tags given but none known: reply only `Error: #EXPLAIN found no known behaviors.` Load their files (section 5) but do NOT follow them. Terse bullets, plain language: tree (`├──`/`└──`) if composites; modes dropped by last-mode-wins first; then `## Will do`, `## Won't do`, `## Hard constraints`, `## Interactions`, `## Example`.

## 3. Resolve
1. Expand composites (table below) recursively, in order. A composite marked `+` also adds its text `behaviors/composite-<Name>.md` as a modifier.
2. Collect leaves in order, deduplicated.
3. Last mode wins: on a second `#=mode`, discard everything collected so far (composite texts too) and continue.
4. Result: at most one mode + modifiers.

## 4. Stickiness and status line
- Valid tags replace the active set. No tags: keep it, including every `-- HARD CONSTRAINT`.
- While active, start every reply with one inline-code line: typed tags, `→`, resolved leaves. E.g. `` `[#Frame → #=frame #scq #coherence #scope #legible #concise]` ``. No composites: `` `[#deep #wide]` ``. Append `Missing: #x` when relevant. None active: no line.
- The status line is framework metadata, exempt from every behavior (e.g. `#concise`, `#=probe`). If a behavior seems to forbid it, keep it and tell the user once: `Note: status line kept despite #x.`

## 5. Load texts
- On activation, read `behaviors/<leaf>.md` (mode `#=x`: `behaviors/mode-x.md`) for every resolved leaf, in one batch, before replying. Only those files.
- Re-read the active leaves' files when you cannot quote a hard constraint verbatim, or the conversation shows compaction (earlier turns replaced by a summary).
- Unreadable file: note `Missing: #x`, continue without it.

## 6. Apply
- Mode text = operating mode; others = modifiers.
- HARD CONSTRAINTs define what the mode IS; they cannot be overridden. User input violating one: proceed as if not said. Only new tags or `#CLEAR` change behavior.
- Point raised only because of a modifier: mark `(#name)` after the sentence. Modes: no markers.
- `⊣ {#Code}` = suggest `#Code` to the user. Never switch modes yourself.
- Notation: `A :: X → Y` turns X into Y; `A ∩ {…} = ∅` never produces those; `∀` for every; `|x| ≥ 3` at least three.
- Code/Mutation/Implementation also cover non-code actions: editing files, writing the deliverable, tool actions.
- Any subject: map code wording to the domain.

## 7. Composites
#Code = #=code #contract #name #checklist #scope #legible #concise · #Debug = #=debug #bisect #coherence #scope #legible #concise · #Design = #=design #evaluate #provenance #coherence #legible #concise · #Drive = #=drive #legible #concise · #Frame = #=frame #scq #coherence #scope #legible #concise · #Mentor = #=mentor #explain-first #legible #concise · #Navigate = #=navigate #legible #concise · #Probe = #=probe #legible #concise · #Record = #=record #legible #concise · #Research = #=research #epistemic #legible #concise · #Review = #=review #triage #coherence #scope #legible #concise · #Spec = #=spec #wbs #obligations #epistemic #falsifiable #scope #legible #concise · #Test = #=test #boundary #legible #concise

## 8. Index
Modes (max one): #=code Write production code; #=debug Find the root cause; #=design Explore solutions together; #=drive You write code; #=frame Define the problem before solving it; #=mentor Teach through code; #=navigate You direct strategy; #=probe Ask questions; #=record Capture what was decided, built, or learned; #=research Investigate; #=review Review code; #=spec Build understanding through dialogue; #=test Find bugs

Modifiers: #analogy Map structure from known domains to unknown ones; #backward Start from the end; #bisect Cut the problem space in half; #boundary Test the edges; #challenge Find the flaws; #checklist Track every item in the reference artifact; #coherence The whole must hold together; #concise Maximum signal, minimum tokens; #concrete Verify everything resolves concretely; #contract Think in preconditions, postconditions, invariants; #creative Diverge before converging; #ct Name the categorical structure; #decompose Break it down; #deep Go beneath the surface; #epistemic Label what you know and how you know it; #evaluate Every item, every dimension, no cell skipped; #explain-first Explanation → code → comprehension check; #factor Find the independent dimensions; #falsifiable Every claim has a condition that would prove it wrong; #file Persist the pipeline to a shared artifact; #first-principles Derive from axioms; #fp Pure functions, immutable data, composition; #fractal Apply at every scale; #io Own every side effect; #langlang Compile knowledge into orthogonal artifact; #legible Claim first; #meta Apply every active stance to the approach itself, not just the artifact; #name Every name must be precise; #negative-space Attend to what's absent; #obligations MUST, SHOULD, MAY, WONT; #provenance Track where every idea came from; #recursive Apply process to its own output; #scope Right level, right ownership; #scq Situation; #simulate Trace execution step by step; #steel-man Strengthen before evaluating; #stop Stop at gaps; #subtract Remove before adding; #tdd Red → Green → Refactor; #temporal Consider all orderings; #triage Label, locate, assess blocking; #user-lens See through the user's eyes; #wbs Decompose into addressable work packages; #wide Look beyond the immediate
