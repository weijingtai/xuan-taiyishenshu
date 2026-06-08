# OpenSpec Change: taiyi-algorithm-config-management

This change defines an implementable, extensible algorithm platform for TaiYiShenShu traditions.

## Scope

- Implement option C: strategy registry + typed profiles + finite pluggable Dart engines.
- Model four first-class traditions: Jing Mirror, Fu Ying Jing, Tong Zong, and Tao Jin Ge.
- Implement Jing Mirror and Tong Zong against `docs/classes/金镜_统宗_四计_三算_alg.md`.
- Include Fu Ying Jing and Tao Jin Ge profiles and rule-level tests now; require user-confirmed numeric vectors before claiming full algorithm parity.
- Preserve synchronous calculator behavior during the first implementation pass.

## Validation

Run from the package root:

```bash
openspec validate taiyi-algorithm-config-management --strict --no-interactive
```

Run the readiness scan:

```bash
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-algorithm-config-management
```

The scan should return no matches.

## Discussion Gates

Stop and ask the user before converting Fu Ying Jing or Tao Jin Ge from rule-only tests to numeric assertions unless the vector source is already present in repository docs or tests.
