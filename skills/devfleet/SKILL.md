---
name: devfleet
description: >
  Devfleet-style role workflow for Codex. Use when work should move through explicit planner -> coder -> reviewer -> tester handoffs with shared packets and deterministic ownership. Best for medium-to-large features, refactors, cross-file changes, or bugfixes where you want cleaner delegation and verification. Skip for tiny edits, one-file docs changes, or cases where a single direct Codex pass is faster.
---

# Devfleet

Structured role workflow for Codex with explicit planner, coder, reviewer, and tester handoffs.

## Purpose

Give multi-step work a shared operating model:

1. planner defines the packet
2. coder implements the packet
3. reviewer checks risk and regressions
4. tester verifies behavior

Use this when the project needs explicit handoffs, not just raw momentum.

## Trigger

- 3+ files likely to change
- new feature or refactor with clear role separation
- cross-cutting reliability or workflow redesign
- work that will benefit from Codex subagents with disjoint ownership
- tasks where “done” needs a stronger audit trail

## Skip

- one-file edits
- quick text changes
- tiny bug fixes where planning overhead is wasteful

## Standard sequence

1. If scope is fuzzy, use the global `$prp-prd` skill first.
2. Planner produces a scoped packet and task order.
3. Coder implements one packet at a time and records changed files plus tests run.
4. Reviewer focuses on bugs, regressions, and missing tests.
5. Tester runs the smallest useful proof set for acceptance.

## Role skills

- `$devfleet-planner`
- `$devfleet-coder`
- `$devfleet-reviewer`
- `$devfleet-tester`

## Shared references

- Workflow: [references/workflow.md](references/workflow.md)
- Handoff format: [references/handoff-format.md](references/handoff-format.md)
- Work packet template: [references/work-packet-template.md](references/work-packet-template.md)

## Operating rules

- Ownership should be explicit by file path or subsystem.
- Do not let coder packets silently expand scope.
- Reviewer output starts with findings, not summary.
- Tester output names exact commands, outcomes, and remaining gaps.
- If multiple subagents are used, each one gets a disjoint write surface.
