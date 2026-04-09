# codex-prpprd-devfleet

Codex skills for structured planning and multi-agent execution, adapted from Claude Code's
`/prp-prd` command and Claude DevFleet MCP workflow.

## What This Is

These skills bring two Claude Code workflows to Codex:

- **prp-prd**: An interactive PRD generator that uses gated questioning phases, market/technical
  research, and hypothesis-driven framing to produce execution-ready spec packages. Adapted from
  the Claude Code `/prp-prd` slash command (originally by Wirasm's PRPs-agentic-eng).

- **devfleet**: A multi-agent orchestrator that dispatches parallel `codex exec` agents in isolated
  git worktrees with structured handoffs. Adapted from Claude DevFleet, which uses an MCP server
  for agent lifecycle management.

### How This Differs from the Claude Originals

| Aspect | Claude Code | This Codex Version |
|--------|------------|-------------------|
| **prp-prd** interaction | Built-in slash command with native conversation gates | Skill with phase instructions and GATE markers |
| **DevFleet dispatch** | MCP server (`plan_project`, `dispatch_mission`, etc.) | `codex exec` + git worktrees + shell scripts |
| **Agent isolation** | MCP-managed worktrees with auto-merge | Git worktrees created by `scripts/dispatch.sh` |
| **Monitoring** | `get_dashboard()`, `get_mission_status()` MCP calls | `scripts/monitor.sh` (file-based status) |
| **Concurrency** | Server-managed agent pool (configurable slots) | Background processes, max ~3 recommended |

The devfleet scripts provide real parallel execution — not just a process document — but the
coordination layer is file-based rather than server-based.

## Skills

| Skill | Purpose |
|-------|---------|
| `prp-prd` | Interactive PRD/PRP/task-plan/review-handoff generator |
| `devfleet` | Orchestrator: plan, dispatch, monitor, collect, review, verify |
| `devfleet-planner` | Write scoped work packets to `.devfleet/packets/` |
| `devfleet-coder` | Implement one packet in an isolated worktree |
| `devfleet-reviewer` | Review merged code using handoff context |
| `devfleet-tester` | Verify acceptance criteria from work packets |

## Install

### Full bundle (recommended)

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo howdymary/codex-prpprd-devfleet \
  --ref main \
  --path skills/prp-prd \
  --path skills/devfleet \
  --path skills/devfleet-planner \
  --path skills/devfleet-coder \
  --path skills/devfleet-reviewer \
  --path skills/devfleet-tester
```

### Just prp-prd

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo howdymary/codex-prpprd-devfleet \
  --ref main \
  --path skills/prp-prd
```

Restart Codex after install so the new skills are indexed.

## Prerequisites

- **Codex CLI** with `codex exec` support
- **Git** (for worktree-based agent isolation)
- A git repository as the working directory (devfleet creates worktrees from HEAD)

## Usage

### Planning: `$prp-prd`

```
$prp-prd "Add a payment processing system with Stripe"
```

Runs an 8-phase gated conversation:
1. **Initiate** — confirm understanding
2. **Foundation** — who, what, why, why now, how to measure
3. **Grounding** — market research, competitor analysis
4. **Deep Dive** — vision, primary user, JTBD, constraints
5. **Grounding** — technical feasibility, codebase exploration
6. **Decisions** — MVP scope, hypothesis, non-goals
7. **Generate** — write PRD, PRP, task plan, review handoff
8. **Output** — summary with validation status and next steps

### Execution: `$devfleet`

```
$devfleet "Implement the payment system from the PRD"
```

1. **Plan** — `$devfleet-planner` produces work packets in `.devfleet/packets/`
2. **Approve** — review packet list and parallelism plan
3. **Dispatch** — `scripts/dispatch.sh` spawns codex exec agents in git worktrees
4. **Monitor** — `scripts/monitor.sh` tracks agent status
5. **Collect** — `scripts/collect.sh` merges worktree branches
6. **Review** — `$devfleet-reviewer` checks merged code
7. **Verify** — `$devfleet-tester` runs acceptance checks
8. **Cleanup** — `scripts/collect.sh --cleanup` removes worktrees

### Individual roles

```
$devfleet-planner "Break this feature into work packets"
$devfleet-coder   "Implement the auth-middleware packet"
$devfleet-reviewer "Review the merged coder output"
$devfleet-tester  "Verify acceptance criteria for the payment flow"
```

## Smoke Test

1. Open a fresh Codex session after installation.
2. Confirm `prp-prd` and the `devfleet` skills appear in the skill picker.
3. Run `$prp-prd` on a small feature idea — it should ask foundation questions before generating.
4. Run `$devfleet` on the same idea — it should produce work packets and offer to dispatch agents.
5. Test dispatch with a trivial packet:
   ```bash
   mkdir -p .devfleet/packets
   echo "## Objective\nCreate a hello.txt file" > .devfleet/packets/test-hello.md
   bash ~/.codex/skills/devfleet/scripts/dispatch.sh test-hello coder .devfleet/packets/test-hello.md --worktree
   bash ~/.codex/skills/devfleet/scripts/monitor.sh
   ```

## Architecture

```
.devfleet/                    # ephemeral orchestration state (gitignored)
├── packets/                  # work packet prompts from planner
│   ├── auth-middleware.md
│   └── db-schema.md
├── agents/                   # PID, status, logs per agent
│   ├── auth-middleware.pid
│   ├── auth-middleware.status
│   ├── auth-middleware.log
│   └── ...
├── handoffs/                 # structured handoff docs from agents
│   ├── auth-middleware.md
│   ├── db-schema.md
│   ├── review.md
│   └── testing.md
└── worktrees/                # isolated git worktrees per agent
    ├── auth-middleware/
    └── db-schema/
```
