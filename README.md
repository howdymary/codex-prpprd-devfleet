# codex-prpprd-devfleet

Pre-release Codex skills for structured planning and role-based execution.

This repo currently packages:

- `prp-prd`: turn a rough idea into a PRD, PRP, task plan, and review handoff
- `devfleet`: orchestrate planner -> coder -> reviewer -> tester handoffs
- `devfleet-planner`
- `devfleet-coder`
- `devfleet-reviewer`
- `devfleet-tester`

## Install

Use Codex's GitHub skill installer.

Install only `prp-prd`:

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo howdymary/codex-prpprd-devfleet \
  --ref main \
  --path skills/prp-prd
```

Install the full bundle:

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

Restart Codex after install so the new skills are indexed.

## Use

- `$prp-prd`: "Turn this feature idea into a PRD, PRP, task plan, and review handoff."
- `$devfleet`: "Break this work into planner, coder, reviewer, and tester handoffs."
- `$devfleet-planner`: create scoped work packets
- `$devfleet-coder`: implement one packet
- `$devfleet-reviewer`: review for bugs, regressions, and missing tests
- `$devfleet-tester`: verify acceptance paths and remaining gaps

## Smoke Test

1. Open a fresh Codex session after installation.
2. Confirm the skill picker shows `prp-prd` and the `devfleet` skills.
3. Run `$prp-prd` on a small feature idea and check that it produces planning artifacts.
4. Run `$devfleet` or one of the role skills on the same idea and confirm the handoff structure appears.

## Notes

- These skills include `agents/openai.yaml` metadata so they surface more reliably in the Codex skill UI.
- This repo is still being tested before wider release.
