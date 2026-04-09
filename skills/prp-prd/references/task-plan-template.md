# Task Plan Template

```md
# <Feature Name> Task Plan

## Outcome
- One sentence describing the shipped result.

## Work Packets

### Packet 1: <Name>
- Owner: planner / coder / reviewer / tester
- Goal:
- Files:
- Dependencies: none | packet N
- Done when:
- Dispatch: serial | parallel with packet N

### Packet 2: <Name>
- Owner:
- Goal:
- Files:
- Dependencies:
- Done when:
- Dispatch: serial | parallel with packet N

## Ordering
1. First packet
2. Second packet (can parallel with 3)
3. Third packet (can parallel with 2)
4. Final verification

## Parallel Notes
- What can run in parallel (separate file ownership = safe to parallelize)
- What must stay serialized (shared files or data dependencies)

## Risks / Blockers
- Blocker
- Default fallback

## Verification Matrix

| Requirement | Verification Command | Owner |
|-------------|---------------------|-------|
| {Requirement 1} | `{command}` | coder / tester |
| {Requirement 2} | `{command}` | coder / tester |
```

## Devfleet Integration

When dispatching this plan via `$devfleet`:
- Each packet with `Dispatch: parallel` can run as a concurrent `codex exec` agent.
- Packets with dependencies must wait for their blocker to complete.
- File ownership must be disjoint across parallel packets to avoid merge conflicts.
