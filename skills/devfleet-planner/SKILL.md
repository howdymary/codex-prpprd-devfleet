---
name: devfleet-planner
description: >
  Planner role for devfleet. Use when a task needs explicit scope, file ownership, task breakdown,
  sequencing, and work packets before coding starts. Writes structured packets to .devfleet/packets/
  for dispatch via codex exec. Best for medium-to-large work, fuzzy requirements, or multi-agent
  delegation. Skip when a strong PRD/PRP plus task plan already exists or the task is tiny.
---

# Devfleet Planner

## Purpose

Turn the ask into clean packets that `codex exec` agents can execute without guessing.

## Responsibilities

1. Define objective and non-goals.
2. Map likely file and module touch points.
3. Split work into the smallest independently verifiable packets.
4. Ensure parallel packets have disjoint file ownership.
5. Identify sequencing, blockers, and parallelizable slices.
6. Write each packet to `.devfleet/packets/<packet-id>.md` using
   [../devfleet/references/work-packet-template.md](../devfleet/references/work-packet-template.md).
7. Write a summary handoff to `.devfleet/handoffs/planning.md` using
   [../devfleet/references/handoff-format.md](../devfleet/references/handoff-format.md).

## Setup

Before writing packets:

```bash
mkdir -p .devfleet/packets .devfleet/handoffs
```

## Default Output

- `.devfleet/packets/<packet-id>.md` for each work packet
- `.devfleet/handoffs/planning.md` with:
  - Short scope summary
  - Ordered packet list with dependencies
  - Parallelism plan (which packets can dispatch simultaneously)
  - Ownership map (packet -> files)
  - Done-when criteria per packet
  - Verification notes for downstream roles

## Quality Bar

- Packet boundaries are clear.
- Write scopes do NOT overlap across parallel packets.
- Acceptance criteria are measurable.
- Risks are surfaced before coding begins.
- Each packet is small enough for one codex exec agent to finish cleanly.

## Parallelism Check

Before finalizing packets, verify:
- [ ] No two parallel packets own the same file
- [ ] Dependencies are explicit and acyclic
- [ ] Each packet's done-when is independently verifiable
