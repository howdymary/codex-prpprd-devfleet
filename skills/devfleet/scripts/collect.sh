#!/usr/bin/env bash
# Collect and merge completed devfleet agent work.
#
# Usage:
#   collect.sh <packet-id>    — merge one agent's worktree branch
#   collect.sh --all          — merge all completed agents
#   collect.sh --report       — generate summary report from all handoffs
#   collect.sh --cleanup      — remove worktrees and state for completed agents

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FLEET_DIR="${REPO_ROOT}/.devfleet"
AGENTS_DIR="${FLEET_DIR}/agents"
HANDOFFS_DIR="${FLEET_DIR}/handoffs"
WORKTREES_DIR="${FLEET_DIR}/worktrees"

MODE="${1:?Usage: collect.sh <packet-id> | --all | --report | --cleanup}"

merge_agent() {
  local id="$1"
  local status_file="${AGENTS_DIR}/${id}.status"
  local branch_file="${AGENTS_DIR}/${id}.branch"
  local worktree_file="${AGENTS_DIR}/${id}.worktree"

  if [[ ! -f "${status_file}" ]]; then
    echo "ERROR: No agent found with id '${id}'" >&2
    return 1
  fi

  local status
  status="$(cat "${status_file}")"
  if [[ "${status}" != "completed" ]]; then
    echo "SKIP: Agent '${id}' status is '${status}', not 'completed'" >&2
    return 1
  fi

  if [[ -f "${branch_file}" ]]; then
    local branch
    branch="$(cat "${branch_file}")"
    echo "Merging branch '${branch}' for packet '${id}'..."
    cd "${REPO_ROOT}"
    git merge --no-ff -m "devfleet: merge packet ${id} ($(cat "${AGENTS_DIR}/${id}.role"))" "${branch}" || {
      echo "ERROR: Merge conflict for '${id}'. Resolve manually from branch '${branch}'." >&2
      echo "  Worktree: ${WORKTREES_DIR}/${id}"
      echo "  Branch: ${branch}"
      return 1
    }
    echo "  Merged successfully."
  else
    echo "Agent '${id}' ran in-place (no worktree). Nothing to merge."
  fi
}

merge_all() {
  local merged=0 skipped=0 failed=0

  for status_file in "${AGENTS_DIR}"/*.status; do
    [[ -f "${status_file}" ]] || continue
    local id
    id="$(basename "${status_file}" .status)"
    local status
    status="$(cat "${status_file}")"

    if [[ "${status}" == "completed" ]]; then
      if merge_agent "${id}"; then
        merged=$((merged + 1))
      else
        failed=$((failed + 1))
      fi
    else
      skipped=$((skipped + 1))
    fi
  done

  echo ""
  echo "Merged: ${merged}  Skipped: ${skipped}  Failed: ${failed}"
}

generate_report() {
  echo "# Devfleet Execution Report"
  echo ""
  echo "Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo ""

  for status_file in "${AGENTS_DIR}"/*.status; do
    [[ -f "${status_file}" ]] || continue
    local id
    id="$(basename "${status_file}" .status)"
    local status role started finished
    status="$(cat "${status_file}")"
    role="unknown"
    [[ -f "${AGENTS_DIR}/${id}.role" ]] && role="$(cat "${AGENTS_DIR}/${id}.role")"
    started="n/a"
    [[ -f "${AGENTS_DIR}/${id}.started" ]] && started="$(cat "${AGENTS_DIR}/${id}.started")"
    finished="n/a"
    [[ -f "${AGENTS_DIR}/${id}.finished" ]] && finished="$(cat "${AGENTS_DIR}/${id}.finished")"

    echo "## ${id} (${role})"
    echo ""
    echo "- Status: ${status}"
    echo "- Started: ${started}"
    echo "- Finished: ${finished}"
    echo ""

    local handoff="${HANDOFFS_DIR}/${id}.md"
    if [[ -f "${handoff}" ]]; then
      echo "### Handoff"
      echo ""
      cat "${handoff}"
      echo ""
    else
      echo "_No handoff document produced._"
      echo ""
    fi

    echo "---"
    echo ""
  done
}

cleanup() {
  local cleaned=0

  for status_file in "${AGENTS_DIR}"/*.status; do
    [[ -f "${status_file}" ]] || continue
    local id
    id="$(basename "${status_file}" .status)"
    local status
    status="$(cat "${status_file}")"

    if [[ "${status}" == "completed" || "${status}" == "failed" ]]; then
      # Remove worktree if it exists
      local worktree_path="${WORKTREES_DIR}/${id}"
      if [[ -d "${worktree_path}" ]]; then
        git worktree remove "${worktree_path}" --force 2>/dev/null || true
      fi

      # Remove agent state files
      rm -f "${AGENTS_DIR}/${id}".{status,role,pid,started,finished,log,worktree,branch}
      cleaned=$((cleaned + 1))
    fi
  done

  echo "Cleaned up ${cleaned} agent(s)."
}

case "${MODE}" in
  --all) merge_all ;;
  --report) generate_report ;;
  --cleanup) cleanup ;;
  *) merge_agent "${MODE}" ;;
esac
