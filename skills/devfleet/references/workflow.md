# Devfleet Lite Workflow

## Roles

- Planner: shapes the work into packets with scope, ownership, and done-when criteria.
- Coder: implements exactly one scoped packet and reports changed files plus test evidence.
- Reviewer: inspects for bugs, regressions, scope creep, and test gaps.
- Tester: verifies the acceptance path with the smallest useful command set.

## Default flow

1. Intake the task.
2. If needed, generate PRD/PRP artifacts first.
3. Produce a work packet.
4. Implement.
5. Review.
6. Verify.
7. Merge learnings back into the next packet or final summary.

## Packet discipline

- Every packet needs an objective.
- Every packet needs explicit files or modules.
- Every packet needs a done-when line.
- Every packet needs a verification note.

## Good packet shape

- Small enough for one person or one subagent to finish cleanly.
- Large enough to produce a meaningful checkpoint.
- Independent enough that it does not force constant re-coordination.

## Escalate when

- ownership is overlapping
- the API contract is unclear
- migration order is risky
- verification depends on unavailable infrastructure
