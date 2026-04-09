# Shared Handoff Format

Every role writes its handoff to `.devfleet/handoffs/<packet-id>.md` using this structure.

```md
## Objective
- What this packet or handoff accomplished

## Scope
- In scope
- Out of scope

## Ownership
- Files or modules owned in this packet

## Changes / Findings
- What changed or what was found

## Risks
- Main risk
- Follow-up risk

## Verification
- Commands run
- What passed
- What was not verified

## Next Role
- Who should take it next
- What they should look at first
```

## Notes by Role

- **Planner** emphasizes scope, ownership, ordering, and done-when criteria.
- **Coder** emphasizes changed files, assumptions made, tests run, and any scope deviations.
- **Reviewer** emphasizes findings first (ordered by severity), then residual risk.
- **Tester** emphasizes exact commands, observed results, pass/fail status, and remaining gaps.

## File Convention

When running via `scripts/dispatch.sh`, each agent is instructed to write its handoff to:

```
.devfleet/handoffs/<packet-id>.md
```

The `scripts/collect.sh --report` command assembles all handoffs into a single execution report.
