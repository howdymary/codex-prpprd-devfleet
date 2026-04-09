---
name: devfleet
description: >
  Multi-agent role workflow for Codex with real parallel dispatch via codex exec. Orchestrates
  planner -> coder -> reviewer -> tester handoffs using isolated git worktrees and file-based
  coordination. Agents run as background codex exec processes with structured handoff documents.
  Use for medium-to-large features, refactors, cross-file changes, or work that benefits from
  parallel agents with disjoint file ownership. Skip for tiny edits, one-file changes, or tasks
  where a single Codex pass is faster.
---

# Devfleet

Multi-agent orchestration for Codex with parallel dispatch and structured handoffs.

> Adapted from Claude DevFleet. The original uses an MCP server for agent lifecycle management.
> This version uses `codex exec` + git worktrees for the same planner/coder/reviewer/tester
> workflow without requiring a separate server process.

## Architecture

```
User request
  |
  v
$devfleet (orchestrator — this skill)
  |
  +-- $devfleet-planner --> writes work packets to .devfleet/packets/
  |
  +-- scripts/dispatch.sh --> spawns codex exec agents in git worktrees
  |     |
  |     +-- Agent 1 (coder, packet A) --\
  |     +-- Agent 2 (coder, packet B) ---+--> .devfleet/handoffs/
  |     +-- Agent 3 (coder, packet C) --/
  |
  +-- scripts/monitor.sh --> polls agent status
  |
  +-- scripts/collect.sh --> merges worktree branches, generates reports
  |
  +-- $devfleet-reviewer --> reviews merged code
  +-- $devfleet-tester   --> verifies acceptance
```

## Coordination Directory

All state lives in `.devfleet/` at the repo root:

```
.devfleet/
├── packets/       — work packet prompts (written by planner)
├── agents/        — PID files, status, logs per agent
├── handoffs/      — structured handoff docs (written by agents)
└── worktrees/     — isolated git worktrees per agent
```

Add `.devfleet/` to `.gitignore`. It is ephemeral orchestration state, not source code.

## Workflow

Read [references/workflow.md](references/workflow.md) for the full sequence. Summary:

### 1. Plan

If scope is fuzzy, use `$prp-prd` first. Otherwise, use `$devfleet-planner` to produce work packets.

The planner writes one file per packet to `.devfleet/packets/<packet-id>.md` using the
[work packet template](references/work-packet-template.md). Each packet must have:
- Objective, scope, file ownership, done-when criteria
- Disjoint file ownership across parallel packets (critical for worktree merges)

### 2. Approve

Show the user the packet list, dependency graph, and parallelism plan. Get explicit approval
before dispatching unless the user has already said to proceed.

### 3. Dispatch

For each packet, run:

```bash
bash scripts/dispatch.sh <packet-id> <role> .devfleet/packets/<packet-id>.md --worktree
```

This spawns a `codex exec` process in an isolated git worktree. Parallel packets can dispatch
simultaneously. Serial packets wait for their dependency to complete.

Maximum 3 concurrent agents by default. Check `scripts/monitor.sh` before dispatching more.

### 4. Monitor

```bash
bash scripts/monitor.sh          # dashboard
bash scripts/monitor.sh --wait   # block until all done
bash scripts/monitor.sh --json   # programmatic status
```

Poll every 30-60 seconds for long-running agents. Report progress to the user.

### 5. Collect

```bash
bash scripts/collect.sh --all      # merge all completed worktree branches
bash scripts/collect.sh --report   # generate execution summary
```

If a merge conflicts, the agent's work remains on its worktree branch for manual resolution.
Report the conflict to the user with the branch name and affected files.

### 6. Review

After merging coder work, dispatch `$devfleet-reviewer` on the merged code. The reviewer reads
handoff documents from `.devfleet/handoffs/` for context.

### 7. Verify

After review, dispatch `$devfleet-tester` to verify acceptance criteria from the original packets.

### 8. Cleanup

```bash
bash scripts/collect.sh --cleanup  # remove worktrees and agent state
```

## Role Skills

- `$devfleet-planner` — scope, ownership, packet creation
- `$devfleet-coder` — implement one packet, write handoff
- `$devfleet-reviewer` — findings-first review, regression check
- `$devfleet-tester` — targeted verification, gap analysis

## Shared References

- Workflow: [references/workflow.md](references/workflow.md)
- Handoff format: [references/handoff-format.md](references/handoff-format.md)
- Work packet template: [references/work-packet-template.md](references/work-packet-template.md)

## Operating Rules

- File ownership must be disjoint across parallel agents. Overlapping writes cause merge conflicts.
- Do not let coder packets silently expand scope.
- Reviewer output starts with findings, not summary.
- Tester output names exact commands, outcomes, and remaining gaps.
- If a dispatched agent fails, read its log before retrying: `.devfleet/agents/<id>.log`
- Always confirm the dispatch plan with the user before launching agents.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/dispatch.sh` | Spawn a codex exec agent in a worktree |
| `scripts/monitor.sh` | Dashboard, wait, or JSON status |
| `scripts/collect.sh` | Merge branches, generate reports, cleanup |
