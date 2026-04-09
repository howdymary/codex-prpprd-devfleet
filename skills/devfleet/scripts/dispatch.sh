#!/usr/bin/env bash
# Dispatch a codex exec agent for a single work packet.
#
# Usage: dispatch.sh <packet-id> <role> <prompt-file> [--worktree]
#
# Creates:
#   .devfleet/agents/<packet-id>.pid    — PID of background codex process
#   .devfleet/agents/<packet-id>.status — running | completed | failed
#   .devfleet/agents/<packet-id>.log    — stdout/stderr from codex exec
#   .devfleet/handoffs/<packet-id>.md   — written by the agent on completion
#
# If --worktree is passed, creates an isolated git worktree for the agent.

set -euo pipefail

PACKET_ID="${1:?Usage: dispatch.sh <packet-id> <role> <prompt-file> [--worktree]}"
ROLE="${2:?Missing role (planner|coder|reviewer|tester)}"
PROMPT_FILE="${3:?Missing prompt file path}"
USE_WORKTREE="${4:-}"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FLEET_DIR="${REPO_ROOT}/.devfleet"
AGENTS_DIR="${FLEET_DIR}/agents"
HANDOFFS_DIR="${FLEET_DIR}/handoffs"
WORKTREES_DIR="${FLEET_DIR}/worktrees"

mkdir -p "${AGENTS_DIR}" "${HANDOFFS_DIR}" "${WORKTREES_DIR}"

# Validate prompt file exists
if [[ ! -f "${PROMPT_FILE}" ]]; then
  echo "ERROR: Prompt file not found: ${PROMPT_FILE}" >&2
  exit 1
fi

PROMPT="$(cat "${PROMPT_FILE}")"

# Determine working directory
WORK_DIR="${REPO_ROOT}"
BRANCH_NAME=""

if [[ "${USE_WORKTREE}" == "--worktree" ]]; then
  BRANCH_NAME="devfleet/${PACKET_ID}"
  WORKTREE_PATH="${WORKTREES_DIR}/${PACKET_ID}"

  if [[ -d "${WORKTREE_PATH}" ]]; then
    echo "WARNING: Worktree already exists at ${WORKTREE_PATH}, reusing" >&2
  else
    git worktree add -b "${BRANCH_NAME}" "${WORKTREE_PATH}" HEAD 2>/dev/null || \
    git worktree add "${WORKTREE_PATH}" "${BRANCH_NAME}" 2>/dev/null || {
      echo "ERROR: Failed to create worktree for ${PACKET_ID}" >&2
      exit 1
    }
  fi

  WORK_DIR="${WORKTREE_PATH}"
  echo "${WORKTREE_PATH}" > "${AGENTS_DIR}/${PACKET_ID}.worktree"
  echo "${BRANCH_NAME}" > "${AGENTS_DIR}/${PACKET_ID}.branch"
fi

# Build the full prompt with handoff instruction
FULL_PROMPT="You are acting as the ${ROLE} role in a devfleet workflow.

${PROMPT}

IMPORTANT: When you are done, write your handoff document to:
  ${HANDOFFS_DIR}/${PACKET_ID}.md

Use the standard devfleet handoff format (Objective, Scope, Ownership, Changes/Findings, Risks, Verification, Next Role)."

# Launch codex exec in background
echo "running" > "${AGENTS_DIR}/${PACKET_ID}.status"
echo "${ROLE}" > "${AGENTS_DIR}/${PACKET_ID}.role"
date -u +"%Y-%m-%dT%H:%M:%SZ" > "${AGENTS_DIR}/${PACKET_ID}.started"

(
  cd "${WORK_DIR}"
  codex exec \
    --approval-mode full-auto \
    "${FULL_PROMPT}" \
    > "${AGENTS_DIR}/${PACKET_ID}.log" 2>&1

  EXIT_CODE=$?

  if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "completed" > "${AGENTS_DIR}/${PACKET_ID}.status"
  else
    echo "failed" > "${AGENTS_DIR}/${PACKET_ID}.status"
  fi

  date -u +"%Y-%m-%dT%H:%M:%SZ" > "${AGENTS_DIR}/${PACKET_ID}.finished"
) &

AGENT_PID=$!
echo "${AGENT_PID}" > "${AGENTS_DIR}/${PACKET_ID}.pid"

echo "Dispatched ${ROLE} agent for packet '${PACKET_ID}' (PID: ${AGENT_PID})"
if [[ -n "${BRANCH_NAME}" ]]; then
  echo "  Worktree: ${WORKTREE_PATH}"
  echo "  Branch: ${BRANCH_NAME}"
fi
echo "  Status: ${AGENTS_DIR}/${PACKET_ID}.status"
echo "  Log: ${AGENTS_DIR}/${PACKET_ID}.log"
echo "  Handoff: ${HANDOFFS_DIR}/${PACKET_ID}.md"
