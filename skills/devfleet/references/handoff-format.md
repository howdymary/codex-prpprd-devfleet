# Shared Handoff Format

Use this structure for planner, coder, reviewer, and tester outputs when work is being split across roles.

```md
## Objective
- What this packet or handoff is trying to accomplish

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

## Notes by role

- Planner emphasizes scope, ownership, ordering, and done-when criteria.
- Coder emphasizes changed files, assumptions, and tests run.
- Reviewer emphasizes findings first, then residual risk.
- Tester emphasizes exact commands, observed results, and remaining gaps.
