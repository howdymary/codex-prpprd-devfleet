# Devfleet Workflow

## Execution Model

Devfleet uses `codex exec` to run agents as background processes, each in an isolated git worktree.
Coordination happens through files in `.devfleet/` — no server, no daemon, no external dependencies.

```
Plan → Approve → Dispatch → Monitor → Collect → Review → Verify → Cleanup
```

## Roles

- **Planner**: shapes work into packets with scope, ownership, and done-when criteria.
- **Coder**: implements exactly one scoped packet and writes a structured handoff.
- **Reviewer**: inspects for bugs, regressions, scope creep, and test gaps.
- **Tester**: verifies the acceptance path with the smallest useful command set.

## Detailed Flow

### 1. Intake

Receive the task description. If scope is fuzzy, route to `$prp-prd` first.

### 2. Plan

Use `$devfleet-planner` to produce work packets. Each packet is written to
`.devfleet/packets/<packet-id>.md` and must include:

- Objective
- Explicit file ownership (must be disjoint across parallel packets)
- Done-when criteria
- Dependencies on other packets (if any)
- Verification notes

### 3. Approve

Present to the user:
- Packet list with objectives
- Dependency graph (what depends on what)
- Parallelism plan (which packets run simultaneously)
- Estimated agent count

Get explicit approval before dispatching.

### 4. Dispatch

```bash
# Serial packet (no dependencies)
bash scripts/dispatch.sh packet-1 coder .devfleet/packets/packet-1.md --worktree

# Parallel packets (independent file ownership)
bash scripts/dispatch.sh packet-2a coder .devfleet/packets/packet-2a.md --worktree
bash scripts/dispatch.sh packet-2b coder .devfleet/packets/packet-2b.md --worktree
```

Each dispatch:
1. Creates a git worktree branch `devfleet/<packet-id>` from HEAD
2. Launches `codex exec` in that worktree with full-auto approval
3. Records PID, status, and log paths in `.devfleet/agents/`

### 5. Monitor

```bash
bash scripts/monitor.sh          # show all agents
bash scripts/monitor.sh --wait   # block until all done
bash scripts/monitor.sh --json   # for programmatic checks
```

Report progress to the user as agents complete.

### 6. Collect

```bash
bash scripts/collect.sh --all     # merge completed branches into current branch
bash scripts/collect.sh --report  # generate markdown summary from handoffs
```

Merge uses `--no-ff` for clean history. If a conflict occurs:
- The agent's branch is preserved
- Report the conflict and affected files to the user
- User resolves manually, then re-runs collect

### 7. Review

Dispatch `$devfleet-reviewer` on the merged codebase. The reviewer reads handoff
documents from `.devfleet/handoffs/` for context on what each agent changed and why.

### 8. Verify

Dispatch `$devfleet-tester` to run acceptance checks against the original packet
done-when criteria.

### 9. Cleanup

```bash
bash scripts/collect.sh --cleanup
```

Removes worktrees, agent state files, and PID files for completed agents.

## Packet Discipline

- Every packet needs an objective.
- Every packet needs explicit files or modules.
- Every packet needs a done-when line.
- Every packet needs a verification note.
- Parallel packets MUST have disjoint file ownership.

## Good Packet Shape

- Small enough for one codex exec agent to finish cleanly.
- Large enough to produce a meaningful checkpoint.
- Independent enough to avoid merge conflicts with parallel agents.

## Escalate When

- Ownership is overlapping across packets
- The API contract between packets is unclear
- Migration order is risky
- Verification depends on unavailable infrastructure
- An agent fails and the log shows a design ambiguity, not a transient error
