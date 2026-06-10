# gStack Validation: taiyi-algorithm-config-management

## Architecture Readiness Checklist

- [ ] Four traditions are first-class profile ids: `jingMirror`, `fuYing`, `tongZong`, `taoJinGe`.
- [ ] `jiCheng` is treated as compatibility/custom, not a source tradition.
- [ ] Algorithm law is split into foundation, chart entry, eye, and three-count engines.
- [ ] JSON profiles select finite Dart strategy ids and cannot execute code.
- [ ] Built-in profiles can be registered synchronously so `TaiYiPanCalculator.calculate` does not need an immediate `Future<PanDataModel>` API break.
- [ ] Jing Mirror and Tong Zong use `docs/classes/金镜_统宗_四计_三算_alg.md` as the immediate implementation reference.
- [ ] Fu Ying Jing and Tao Jin Ge are marked `needsAuthoritativeVectors` until the user confirms numeric examples.
- [ ] `dingCount` versus classical `定算` is explicitly audited in strategy names, tests, and result metadata.
- [ ] Precise solar-term boundaries are modeled behind `SolarTermProvider`; fixed June/December boundaries are not accepted for final parity.

## QA Readiness Checklist

- [ ] OpenSpec validates:

```bash
openspec validate taiyi-algorithm-config-management --strict --no-interactive
```

- [ ] Readiness scan returns no matches:

```bash
rg -n "[T]BD|[T]ODO|[F]IXME|[p]laceholder|[i]mplement later|[f]ill in|[s]kip:|@[S]kip|[F]akeRepository|[F]akeViewModel|[f]akeAsync" openspec/changes/taiyi-algorithm-config-management
```

- [ ] Jing Mirror four-count rule tests include year/month/day/hour where source vectors exist.
- [ ] Tong Zong four-count rule tests include year/month/day/hour where source vectors exist.
- [ ] Fu Ying Jing tests verify profile selection, yin/yang starts, and direction/endpoint policy without invented numeric vectors.
- [ ] Tao Jin Ge tests verify near-era Jia Zi and mnemonic wheel behavior without invented numeric vectors.
- [ ] Existing focused regression tests still pass or pre-existing failures are recorded.
- [ ] `flutter analyze` result is recorded.
- [ ] GitNexus detect-changes result is recorded before commit.

## Go / No-Go Recommendation Rule

- Go if the worker starts with profile/model tests and then migrates calculator behavior incrementally.
- No-go if the worker converts all calculator APIs to async in this change without a separate compatibility plan.
- No-go if Fu Ying Jing or Tao Jin Ge numeric outputs are invented.
- No-go if JSON profiles become a scripting language.
- No-go if three-count behavior is hidden in generic `hostGuest` code without tradition and chart-type provenance.

## Application Boundary

This OpenSpec is package-local under `xuan-taiyishenshu/openspec/changes`. If parent governance is required, copy or register this change under the parent registry and validate from the parent root before code changes begin.
