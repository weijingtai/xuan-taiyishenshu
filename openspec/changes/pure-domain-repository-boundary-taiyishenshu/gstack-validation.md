# gStack Validation: pure-domain-repository-boundary-taiyishenshu

## Source Skill Notes

- `/Users/jingtaiwei/.codex/skills/gstack/SKILL.md`: gStack is used as the product validation evidence layer. For architecture or QA validation, inspect the relevant source skill rather than treating gStack as a dependency.
- `/Users/jingtaiwei/.gemini/skills/gstack-plan-eng-review/SKILL.md`: engineering plan review should cover architecture, data flow, diagrams, edge cases, test coverage, performance, unresolved decisions, and implementation readiness.
- `/Users/jingtaiwei/.gemini/skills/gstack-qa-only/SKILL.md`: report-only QA should produce structured evidence and a health/readiness summary without fixing code; backend/config changes still require affected behavior verification.

## Architecture Verification Checklist

- [ ] Boundary diagram matches implementation: product `lib/taiyi/**` contains domain models, product ports, usecases, viewmodels, and product assembly only.
- [ ] Host/adapter side contains contract DTO mappers and contract repository wrappers.
- [ ] `TaiYiDataAssembly` receives product ports, not `repository_interface_taiyishenshu` ports.
- [ ] No product file imports or exports `repository_interface_taiyishenshu`.
- [ ] No product file imports persistence or platform storage packages.
- [ ] Backend creation remains in `example/lib/taiyi_host.dart` or an explicitly host-side helper.
- [ ] Runtime dependency cleanup aligns with the final import graph.
- [ ] Tests assert behavior and boundary contracts rather than brittle runtime type strings where possible.
- [ ] Algorithm management/configuration is absent from the implementation scope.
- [ ] Any unresolved adapter-location decision is documented before implementation proceeds.

## QA Verification Checklist

- [ ] Static scan: `rg -n "^import .*repository_interface_taiyishenshu|^export .*repository_interface_taiyishenshu|^import .*persistence_|^import .*shared_preferences|^import .*drift" lib/taiyi` returns no matches.
- [ ] Dependency scan: `rg -n "repository_interface_taiyishenshu" pubspec.yaml` confirms no runtime product dependency remains, or any remaining dev/test need is documented.
- [ ] Analyzer: `flutter analyze` passes or all failures are proven unrelated to this change.
- [ ] Usecase tests cover school/deity load, copy, save, delete, preference toggle, and pan calculation.
- [ ] ViewModel tests cover school/deity workflows with product-port fakes.
- [ ] Assembly tests prove product-port injection works.
- [ ] Integration tests prove official assets remain read-only, user Drift data persists, preference SharedPreferences data persists, and pan recalculation still uses expected data.
- [ ] GitNexus `detect_changes` confirms affected symbols/flows are within repository boundary migration scope.
- [ ] If a host app route is available, perform a quick smoke run and record console/runtime errors; otherwise state that no browser-visible route was available and rely on static/analyzer/test evidence.

## Go / No-Go Recommendation Rule

- Go to implementation only after OpenSpec validates and the main thread accepts Strategy A or explicitly selects Strategy B.
- No-go if product `lib/taiyi/**` still imports contract/persistence packages, if `TaiYiDataAssembly` still accepts contract ports, or if tests rely on product-owned contract mappers.

## Application Boundary

This OpenSpec is package-local under `xuan-taiyishenshu/openspec/changes`. It is sufficient for package-local planning and validation. If the parent `xuan-migration` OpenSpec registry is the required source of truth for the implementation worker, copy or register this change under the parent registry and run validation from the parent root before code changes begin.

Implementation SHALL remain documentation-gated until current regression changes in the working tree are isolated or accepted by the main thread. The repository boundary worker SHALL NOT include algorithm configuration changes in the same implementation pass.
