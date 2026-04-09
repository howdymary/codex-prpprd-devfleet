#!/usr/bin/env bash
# Monitor devfleet agent status.
#
# Usage:
#   monitor.sh              — show all agents
#   monitor.sh <packet-id>  — show one agent's detail
#   monitor.sh --wait       — block until all agents reach a terminal state
#   monitor.sh --json       — output as JSON for programmatic use

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
FLEET_DIR="${REPO_ROOT}/.devfleet"
AGENTS_DIR="${FLEET_DIR}/agents"
HANDOFFS_DIR="${FLEET_DIR}/handoffs"

MODE="${1:-all}"

if [[ ! -d "${AGENTS_DIR}" ]]; then
  echo "No devfleet agents found. Run dispatch.sh first."
  exit 0
fi

show_agent() {
  local id="$1"
  local status_file="${AGENTS_DIR}/${id}.status"
  local role_file="${AGENTS_DIR}/${id}.role"
  local pid_file="${AGENTS_DIR}/${id}.pid"
  local started_file="${AGENTS_DIR}/${id}.started"
  local finished_file="${AGENTS_DIR}/${id}.finished"
  local handoff_file="${HANDOFFS_DIR}/${id}.md"

  local status="unknown"
  local role="unknown"
  local pid=""
  local started=""
  local finished=""
  local has_handoff="no"

  [[ -f "${status_file}" ]] && status="$(cat "${status_file}")"
  [[ -f "${role_file}" ]] && role="$(cat "${role_file}")"
  [[ -f "${pid_file}" ]] && pid="$(cat "${pid_file}")"
  [[ -f "${started_file}" ]] && started="$(cat "${started_file}")"
  [[ -f "${finished_file}" ]] && finished="$(cat "${finished_file}")"
  [[ -f "${handoff_file}" ]] && has_handoff="yes"

  # Check if PID is still alive when status says running
  if [[ "${status}" == "running" && -n "${pid}" ]]; then
    if ! kill -0 "${pid}" 2>/dev/null; then
      # Process died without updating status
      echo "failed" > "${status_file}"
      status="failed"
      date -u +"%Y-%m-%dT%H:%M:%SZ" > "${finished_file}"
      finished="$(cat "${finished_file}")"
    fi
  fi

  printf "  %-20s  %-10s  %-10s  started: %s" "${id}" "${role}" "${status}" "${started:-n/a}"
  if [[ -n "${finished}" ]]; then
    printf "  finished: %s" "${finished}"
  fi
  if [[ "${has_handoff}" == "yes" ]]; then
    printf "  [handoff ready]"
  fi
  printf "\n"
}

show_all() {
  echo "=== Devfleet Agent Dashboard ==="
  echo ""

  local running=0 completed=0 failed=0 total=0

  for status_file in "${AGENTS_DIR}"/*.status; do
    [[ -f "${status_file}" ]] || continue
    local id
    id="$(basename "${status_file}" .status)"
    local status
    status="$(cat "${status_file}")"
    total=$((total + 1))
    case "${status}" in
      running) running=$((running + 1)) ;;
      completed) completed=$((completed + 1)) ;;
      failed) failed=$((failed + 1)) ;;
    esac
  done

  echo "  Total: ${total}  Running: ${running}  Completed: ${completed}  Failed: ${failed}"
  echo ""

  for status_file in "${AGENTS_DIR}"/*.status; do
    [[ -f "${status_file}" ]] || continue
    local id
    id="$(basename "${status_file}" .status)"
    show_agent "${id}"
  done

  echo ""
}

wait_all() {
  echo "Waiting for all agents to complete..."
  while true; do
    local all_done=true
    for status_file in "${AGENTS_DIR}"/*.status; do
      [[ -f "${status_file}" ]] || continue
      local status
      status="$(cat "${status_file}")"
      if [[ "${status}" == "running" ]]; then
        local id
        id="$(basename "${status_file}" .status)"
        local pid_file="${AGENTS_DIR}/${id}.pid"
        if [[ -f "${pid_file}" ]]; then
          local pid
          pid="$(cat "${pid_file}")"
          if kill -0 "${pid}" 2>/dev/null; then
            all_done=false
          else
            echo "failed" > "${status_file}"
            date -u +"%Y-%m-%dT%H:%M:%SZ" > "${AGENTS_DIR}/${id}.finished"
          fi
        fi
      fi
    done

    if $all_done; then
      echo "All agents have reached a terminal state."
      show_all
      break
    fi

    sleep 5
  done
}

case "${MODE}" in
  --wait) wait_all ;;
  --json)
    echo "["
    first=true
    for status_file in "${AGENTS_DIR}"/*.status; do
      [[ -f "${status_file}" ]] || continue
      local_id="$(basename "${status_file}" .status)"
      local_status="$(cat "${status_file}")"
      local_role="unknown"
      [[ -f "${AGENTS_DIR}/${local_id}.role" ]] && local_role="$(cat "${AGENTS_DIR}/${local_id}.role")"
      local_handoff="false"
      [[ -f "${HANDOFFS_DIR}/${local_id}.md" ]] && local_handoff="true"
      $first || echo ","
      first=false
      printf '  {"id":"%s","role":"%s","status":"%s","handoff":%s}' \
        "${local_id}" "${local_role}" "${local_status}" "${local_handoff}"
    done
    echo ""
    echo "]"
    ;;
  all) show_all ;;
  *) show_agent "${MODE}" ;;
esac
