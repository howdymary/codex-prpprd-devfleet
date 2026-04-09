---
name: prp-prd
description: Use when the user wants to turn a rough product idea, feature request, workflow change, or refactor into an execution-ready spec package. Produces some or all of: PRP, PRD, task plan, acceptance criteria, implementation notes, and review handoff. Best for greenfield features, ambiguous asks, multi-file work, or before delegating to subagents. Skip for tiny bug fixes, one-file edits, or when the user explicitly wants code only.
---

# PRD / PRP

Create build-ready planning artifacts for Codex and subagents.

## Default outputs

When the user asks for a full package, create:

- `prd.md`
- `prp.md`
- `task-plan.md`
- `review-handoff.md`

If the user wants only one artifact, produce that artifact and only add siblings when they materially reduce ambiguity.

## Default location

If the user asks you to write the docs and gives no path:

1. Prefer `docs/specs/<YYYY-MM-DD>-<slug>/` inside the current repo.
2. If there is no `docs/` directory, use `specs/<YYYY-MM-DD>-<slug>/`.
3. Keep filenames deterministic: `prd.md`, `prp.md`, `task-plan.md`, `review-handoff.md`.

## Workflow

1. Clarify the real objective, user, and outcome from the request and local repo context.
2. Write the PRD using [references/prd-template.md](references/prd-template.md).
3. Write the PRP using [references/prp-template.md](references/prp-template.md).
4. Split the work into implementation packets using [references/task-plan-template.md](references/task-plan-template.md).
5. Write the reviewer/tester packet using [references/review-handoff-template.md](references/review-handoff-template.md).
6. If implementation starts in the same turn, keep the docs aligned with any scope changes.

## Quality bar

- Goals and non-goals are both explicit.
- Acceptance criteria are testable and binary.
- File and module touch points are named, not hand-waved.
- Risks, migrations, and rollback paths are concrete.
- Verification covers happy path, failure path, and observability.
- Open questions are isolated so they do not pollute the whole plan.

## PRD guidance

- Focus on user problem, scope, outcomes, constraints, and success criteria.
- Avoid solution-detail overload unless the repo context makes the shape obvious.
- Keep the language product-facing and easy to scan.

## PRP guidance

- Turn product intent into implementation shape: file map, data flow, API boundaries, tests, rollout.
- Name likely files and modules when they can be inferred from the repo.
- Prefer explicit sequencing over broad “implement feature” steps.

## Task plan guidance

- Break the work into the smallest independently verifiable packets.
- Assign ownership by file area or responsibility when subagents are involved.
- Call out blockers, dependencies, and parallelizable work.

## Review handoff guidance

- Give reviewer/tester the exact behavior to verify, key changed files, main risks, and commands already run.
- Include residual uncertainty so the next role does not need to rediscover it.

## References

- PRD template: [references/prd-template.md](references/prd-template.md)
- PRP template: [references/prp-template.md](references/prp-template.md)
- Task plan template: [references/task-plan-template.md](references/task-plan-template.md)
- Review handoff template: [references/review-handoff-template.md](references/review-handoff-template.md)

## Pairing note

When a repo uses a role-based execution layer, pair this skill with `$devfleet` after the PRD/PRP package is written.
