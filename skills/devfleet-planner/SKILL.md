---
name: devfleet-planner
description: >
  Planner role for Devfleet-style Codex execution. Use when a task needs explicit scope, file ownership, task breakdown, sequencing, and handoff packets before coding starts. Best for medium-to-large work, fuzzy requirements, or subagent delegation. Skip when a strong PRD/PRP plus task plan already exists or the task is tiny.
---

# Devfleet Planner

## Purpose

Turn the ask into a clean packet another role can execute without guessing.

## Responsibilities

- define objective and non-goals
- map likely file and module touch points
- split work into the smallest independently verifiable packets
- identify sequencing, blockers, and parallelizable slices
- produce a handoff using [../devfleet/references/handoff-format.md](../devfleet/references/handoff-format.md)

## Default output

- short scope summary
- ordered work packets
- ownership per packet
- done-when criteria
- verification notes for downstream roles

## Quality bar

- packet boundaries are clear
- write scopes do not overlap unless absolutely necessary
- acceptance is measurable
- risks are surfaced before coding begins
