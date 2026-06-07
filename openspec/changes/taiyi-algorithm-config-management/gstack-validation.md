# gStack Validation: taiyi-algorithm-config-management

## Source Skill Notes

- `/Users/jingtaiwei/.codex/skills/gstack/SKILL.md`: gStack is the validation evidence layer for release readiness, QA readiness, and implementation applicability.
- `/Users/jingtaiwei/.gemini/skills/gstack-plan-eng-review/SKILL.md`: engineering plan review covers architecture, data flow, edge cases, testing, unresolved decisions, and implementation readiness.
- `/Users/jingtaiwei/.gemini/skills/gstack-qa-only/SKILL.md`: QA report mode requires structured evidence and a health/readiness summary.

## Architecture Readiness Checklist

- [ ] Layer 1 and Layer 2 boundaries are explicit.
- [ ] Layer 1 uses typed configuration models and a typed Dart engine.
- [ ] JSON profiles cannot execute code or arbitrary expressions.
- [ ] `FoundationResult` is the only required bridge from Layer 1 to Layer 2.
- [ ] Official profile ids are stable and versioned.
- [ ] Layer 2 is split into palace, count, general, and pan-placement sublayers.
- [ ] Layer 1 implementation can proceed without repository boundary refactoring.
- [ ] Repository boundary refactoring can proceed without algorithm configuration work.

## QA Readiness Checklist

- [ ] OpenSpec validates:

```bash
openspec validate taiyi-algorithm-config-management --strict --no-interactive
```

- [ ] Placeholder scan returns no matches:

```bash
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-algorithm-config-management
```

- [ ] Layer 1 implementation starts with failing vector tests.
- [ ] Jing Mirror 1949, 2026, and 2027 year vectors are included.
- [ ] TongZong year/month/day/hour vectors are included from authoritative regression fixtures.
- [ ] JiCheng year/month/day/hour vectors are included with source provenance.
- [ ] Full metadata regressions are run after calculator integration.
- [ ] `flutter analyze` result is recorded.
- [ ] GitNexus detect-changes result is recorded before commit.

## Go / No-Go Recommendation Rule

- Go to Layer 1 implementation after this OpenSpec validates and the current dirty regression work is isolated in the worker workspace.
- No-go if the worker attempts Layer 2 production code in the same change.
- No-go if configuration supports arbitrary executable expressions.
- No-go if official profile behavior changes without vector evidence.
- No-go if the root governance process requires parent-level OpenSpec and this package-local change has not been copied or registered there.

## Application Boundary

This OpenSpec is package-local under `xuan-taiyishenshu/openspec/changes`. It is sufficient for package-local planning and validation. If the parent `xuan-migration` OpenSpec registry is the required source of truth for the implementation worker, copy or register this change under the parent registry and run validation from the parent root before code changes begin.
