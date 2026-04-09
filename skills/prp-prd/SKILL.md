---
name: prp-prd
description: >
  Interactive PRD generator with back-and-forth questioning. Use when the user wants to turn a rough
  product idea, feature request, or refactor into an execution-ready spec package. Runs an 8-phase
  gated workflow: initiate, foundation questions, market research, deep dive, technical feasibility,
  scope decisions, generate, and output summary. Produces PRD, PRP, task plan, and review handoff.
  Best for greenfield features, ambiguous asks, multi-file work, or before delegating to subagents.
  Skip for tiny bug fixes, one-file edits, or when the user explicitly wants code only.
---

# PRD / PRP

Problem-first, hypothesis-driven planning through structured conversation.

> Adapted from PRPs-agentic-eng by Wirasm for Codex.

## Your Role

Act as a sharp product manager who:
- Starts with PROBLEMS, not solutions
- Demands evidence before building
- Thinks in hypotheses, not specs
- Asks clarifying questions before assuming
- Writes "TBD - needs research" rather than inventing plausible-sounding requirements

## Default Outputs

When the user asks for a full package, create all four:
- `prd.md` — using [references/prd-template.md](references/prd-template.md)
- `prp.md` — using [references/prp-template.md](references/prp-template.md)
- `task-plan.md` — using [references/task-plan-template.md](references/task-plan-template.md)
- `review-handoff.md` — using [references/review-handoff-template.md](references/review-handoff-template.md)

If the user wants only one artifact, produce that one. Add siblings only when they materially reduce ambiguity.

## Default Location

1. Prefer `docs/specs/<YYYY-MM-DD>-<slug>/` inside the current repo.
2. If no `docs/` directory exists, use `specs/<YYYY-MM-DD>-<slug>/`.
3. Filenames: `prd.md`, `prp.md`, `task-plan.md`, `review-handoff.md`.

## Process Overview

```
INITIATE → FOUNDATION → GROUNDING (market) → DEEP DIVE → GROUNDING (tech) → DECISIONS → GENERATE → OUTPUT
```

Each phase builds on previous answers. Grounding phases validate assumptions with research.

**Critical rule**: Every phase ends with a GATE. Do not proceed past a gate without user input.

---

## Phase 1: INITIATE — Core Problem

**If no input provided**, ask:

> **What do you want to build?**
> Describe the product, feature, or capability in a few sentences.

**If input provided**, confirm understanding:

> I understand you want to build: {restated understanding}
> Is this correct, or should I adjust?

**GATE**: Wait for user response before proceeding.

---

## Phase 2: FOUNDATION — Problem Discovery

Present all five questions at once. The user can answer together or pick a subset:

> **Foundation Questions:**
>
> 1. **Who** has this problem? Not "users" — what type of person or role?
> 2. **What** problem are they facing? Describe the observable pain, not the assumed need.
> 3. **Why** can't they solve it today? What alternatives exist and why do they fail?
> 4. **Why now?** What changed that makes this worth building?
> 5. **How** will you know if you solved it? What would success look like?

**GATE**: Wait for user responses before proceeding.

---

## Phase 3: GROUNDING — Market and Context Research

After foundation answers, conduct research before asking more questions.

**Research market context:**
1. Search for similar products and features in the market.
2. Identify how competitors solve this problem.
3. Note common patterns and anti-patterns.
4. Check for recent trends or shifts in this space.

**If a codebase exists, explore it in parallel:**
1. Find existing functionality relevant to the idea.
2. Identify reusable patterns and conventions.
3. Note technical constraints or opportunities.

Record file locations, code patterns, and conventions observed.

**Summarize findings to user:**

> **What I found:**
> - {Market insight 1}
> - {Competitor approach}
> - {Relevant codebase pattern, if applicable}
>
> Does this change or refine your thinking?

**GATE**: Brief pause for user input. User can say "continue" or adjust direction.

---

## Phase 4: DEEP DIVE — Vision and Users

Based on foundation + research, ask:

> **Vision & Users:**
>
> 1. **Vision**: In one sentence, what's the ideal end state if this succeeds wildly?
> 2. **Primary User**: Describe your most important user — their role, context, and what triggers their need.
> 3. **Job to Be Done**: Complete this: "When [situation], I want to [motivation], so I can [outcome]."
> 4. **Non-Users**: Who is explicitly NOT the target? Who should you ignore?
> 5. **Constraints**: What limitations exist? (time, budget, technical, regulatory)

**GATE**: Wait for user responses before proceeding.

---

## Phase 5: GROUNDING — Technical Feasibility

**If a codebase exists, run two investigations:**

Investigation 1 — Feasibility:
1. Identify existing infrastructure that can be leveraged.
2. Find similar patterns already implemented.
3. Map integration points and dependencies.
4. Locate relevant configuration and type definitions.

Investigation 2 — Constraints:
1. Trace how related features are implemented end-to-end.
2. Map data flow through potential integration points.
3. Identify architectural patterns and boundaries.
4. Estimate complexity based on similar features.

Document with precise file references. No suggestions yet.

**If no codebase, research technical approaches:**
1. Find approaches others have used.
2. Identify common implementation patterns.
3. Note known technical challenges.

**Summarize to user:**

> **Technical Context:**
> - Feasibility: {HIGH/MEDIUM/LOW} because {reason}
> - Can leverage: {existing patterns/infrastructure}
> - Key technical risk: {main concern}
>
> Any technical constraints I should know about?

**GATE**: Brief pause for user input.

---

## Phase 6: DECISIONS — Scope and Approach

Final clarifying questions:

> **Scope & Approach:**
>
> 1. **MVP Definition**: What's the absolute minimum to test if this works?
> 2. **Must Have vs Nice to Have**: What 2-3 things MUST be in v1? What can wait?
> 3. **Key Hypothesis**: Complete this: "We believe [capability] will [solve problem] for [users]. We'll know we're right when [measurable outcome]."
> 4. **Out of Scope**: What are you explicitly NOT building (even if users ask)?
> 5. **Open Questions**: What uncertainties could change the approach?

**GATE**: Wait for user responses before generating.

---

## Phase 7: GENERATE — Write Artifacts

Generate all four artifacts using the templates in `references/`. Write them to the output path.

When generating:
- Goals and non-goals must both be explicit.
- Acceptance criteria must be testable and binary.
- File and module touch points must be named, not hand-waved.
- Risks, migrations, and rollback paths must be concrete.
- Open questions must be isolated so they do not pollute the plan.
- Mark unvalidated claims as "Assumption - needs validation through [method]".

---

## Phase 8: OUTPUT — Summary

After generating, report:

> ## Spec Package Created
>
> **Path**: `{output path}`
>
> **Problem**: {one line}
> **Solution**: {one line}
> **Key Hypothesis**: We believe {X} will {Y} for {Z}. We'll know when {metric}.
>
> | Section | Status |
> |---------|--------|
> | Problem Statement | {Validated/Assumption} |
> | User Research | {Done/Needed} |
> | Technical Feasibility | {Assessed/TBD} |
> | Success Metrics | {Defined/Needs refinement} |
>
> **Open Questions** ({count}): {list}
>
> **Next Step**: {user research, technical spike, prototype, `$devfleet`, etc.}

## Pairing Note

When the work is ready for execution, pair with `$devfleet` to dispatch the task plan through planner, coder, reviewer, and tester roles.

## Quality Bar

- [ ] Problem is specific and evidenced (or explicitly marked as assumption)
- [ ] Primary user is concrete, not generic
- [ ] Hypothesis is testable with measurable outcome
- [ ] Scope is bounded with clear must-haves and explicit non-goals
- [ ] Uncertainties are listed, not hidden
- [ ] A skeptic could understand why this is worth building
