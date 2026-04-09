# Work Packet Template

The planner writes one file per packet to `.devfleet/packets/<packet-id>.md`.

```md
# <Packet Name>

## Objective
- What this packet delivers

## Scope
- Included
- Excluded

## Ownership
- `path/to/file.ext`
- `path/to/module/`

## Dependencies
- none | packet-id that must complete first

## Dispatch
- serial | parallel with <packet-id>

## Done When
- [ ] Result 1
- [ ] Result 2

## Verification
- `command to run`
- Manual check description

## Handoff Notes
- Risks to flag for reviewer
- Context the next role needs
```

## Packet ID Convention

Use short, descriptive kebab-case IDs: `auth-middleware`, `db-schema`, `api-routes`, `test-suite`.

## Parallelism Rules

Packets marked `parallel` MUST have disjoint file ownership. If two packets need to edit the same
file, they must be serialized or the shared file must be extracted into its own packet that runs first.
