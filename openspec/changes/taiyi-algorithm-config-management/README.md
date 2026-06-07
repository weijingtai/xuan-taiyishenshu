# OpenSpec Change: taiyi-algorithm-config-management

This change defines the governance-ready plan for turning TaiYiShenShu core algorithm foundations into configuration-backed, typed domain logic.

## Scope

- Layer 1 is implementation scope: accumulated sequence, ju number, wuzi yuan-ju, ji-yuan, yuan labels, and ru-gong label.
- Layer 2 is planning scope: palace derivation, host/guest/ding counts, host/guest generals, and derived pan placements.
- The plan is deliberately separate from repository boundary purification so each change can be executed and reviewed independently.

## Validation

Run from the package root:

```bash
openspec validate taiyi-algorithm-config-management --strict --no-interactive
```

Run the gStack readiness scan:

```bash
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-algorithm-config-management
```

The scan should return no matches.
