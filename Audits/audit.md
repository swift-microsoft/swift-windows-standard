# Audit: swift-windows-standard

## Modularization — 2026-04-17

### Scope

- **Target**: `swift-windows-standard` (L2 platform Standards package, Microsoft)
- **Skill**: `modularization` — [MOD-DOMAIN], [MOD-001] – [MOD-016], [MOD-EXCEPT-001], [MOD-EXCEPT-002]
- **Files**: 20 source target directories, 1 Package.swift, 2 test targets
- **Commits audited**: `9f6bb5a` decomposition, `aea3fcd` vestigial-import fix, `5e5dc95` Clock split
- **Reference packages**: `swift-iso-9945` (L2 POSIX Standards), `swift-darwin-standard` (L2 Darwin Standards)

### Findings

| # | Severity | Rule | Location | Finding | Status |
|---|----------|------|----------|---------|--------|
| 1 | CRITICAL | [MOD-016] | `Sources/Windows Kernel Standard Core/Windows.Kernel.swift:12-13` | Missing `@_spi(Syscall) public import Kernel_Descriptor_Primitives`. The file accesses `Kernel.Descriptor._rawValue` (line 55) and `_rawValue:` initializer (line 54) — both marked `@_spi(Syscall)` in `swift-kernel-primitives/Sources/Kernel Descriptor Primitives/Kernel.Descriptor.swift:118-131`. The accesses live inside a `#if os(Windows)` guard so macOS dry-run succeeds; on a real Windows build the target fails with `'_rawValue' is inaccessible due to '@_spi(Syscall)' protection level`. Regression introduced by commit `9f6bb5a` when pruning the boilerplate import block. [MOD-016] is explicit that Exports.swift's `@_spi` re-export does NOT grant SPI access to sibling files. | OPEN |
| 2 | CRITICAL | [MOD-005] | `Sources/Windows Kernel Standard/exports.swift` | Umbrella target re-exports only 5 of 13 Kernel sub-targets. Current file re-exports Core, File, Socket, IO, Memory Map. Missing re-exports: Clock, Console, Directory, Environment, Process, System, Thread, Time. Consumers importing the umbrella `Windows_Kernel_Standard` do not see the narrow targets created by commit `9f6bb5a`, defeating the aggregation guarantee [MOD-005] requires. | OPEN |
| 3 | HIGH | [MOD-005] | `Sources/Windows Kernel Standard/exports.swift:1-5` | Umbrella uses `@_exported import X` without `public` modifier. Under `InternalImportsByDefault` (enabled in `Package.swift` swiftSettings line 194), bare `import` is internal. Internal imports cannot be `@_exported` to downstream consumers — the re-export silently does nothing. Every line must be `@_exported public import X`. iso-9945's umbrella (`Sources/ISO 9945/exports.swift`) demonstrates the correct form. | OPEN |
| 4 | HIGH | [MOD-005] | `Sources/Windows Kernel File Standard/`, `Sources/Windows Kernel IO Standard/`, `Sources/Windows Kernel Memory Map Standard/`, `Sources/Windows Kernel Socket Standard/` | Four narrow Kernel targets lack `Exports.swift` entirely. Consumers who `import Windows_Kernel_File_Standard` don't automatically see the `Windows` namespace or `Windows.Kernel` typealias unless they separately import `Windows_Standard_Core` and `Windows_Kernel_Standard_Core`. Inconsistent with the Clock / Console / Directory / Environment / Process / System / Thread / Time targets that DO have `Exports.swift` re-exporting `Windows_Kernel_Standard_Core`. | OPEN |
| 5 | MEDIUM | [MOD-005] | `Sources/Windows Loader Standard/`, `Sources/Windows Memory Standard/` | Two non-Kernel standalone targets lack `Exports.swift`. Should re-export `Windows_Standard_Core` at minimum so consumers get the `Windows` namespace without a separate import, mirroring Identity / Interop. | OPEN |
| 6 | MEDIUM | [MOD-011] | `Package.swift` (no Test Support product) | No `Windows Standard Test Support` library product. [MOD-011] requires every multi-product package to publish one; iso-9945 provides the precedent (`ISO 9945 Kernel Test Support` library at line 98 of that Package.swift). Two test targets exist (`Windows Kernel Standard Tests`, `Windows Loader Standard Tests`) but there is no shared test infrastructure published for downstream packages. | OPEN |
| 7 | MEDIUM | [MOD-005] | `Sources/Windows Kernel Standard Core/Exports.swift` | Core's `Exports.swift` re-exports kernel primitives but does NOT re-export itself via `@_exported public import Windows_Kernel_Standard_Core`; this is fine because a target cannot re-export itself. However, the narrow Kernel targets depend on Core AND their Exports.swift re-exports Core — this means the Kernel Clock / Thread / etc. consumers get the full `@_spi(Syscall)` re-exports from Core (Kernel_Primitives_Core, Kernel_Descriptor_Primitives, Kernel_Error_Primitives). That SPI surface is exposed to ANY consumer of a narrow target, not just those who opt in with `@_spi(Syscall)`. Verify whether the Core's SPI re-exports should be narrowed (per-file opt-in rather than Core-wide re-export) to avoid leaking the SPI surface beyond syscall implementation layers. | OPEN |
| 8 | MEDIUM | [AUDIT-009] | `Audits/_index.md` (missing) | Per [AUDIT-009], `audit.md` MUST be listed in `Audits/_index.md`. The index file does not exist. | OPEN |
| 9 | LOW | [MOD-013] | `Package.swift:174-185` | Semantic group markers are present for all source targets (Core, Kernel Core, Kernel Clock, Kernel Console, ..., Identity, Interop, Loader, Memory). However the two `.testTarget(...)` declarations at lines 249-261 are not preceded by a `// MARK: - Tests` marker. Minor consistency gap. | OPEN |
| 10 | LOW | [MOD-012] | `Package.swift` (naming) | Target names use `Windows X Standard` pattern (e.g., `Windows Kernel Clock Standard`). [MOD-012]'s L2 row prescribes `{Domain} {Variant}` with no layer suffix. However, "Standard" here is the package's platform-source-identifying word, analogous to "ISO 9945" in iso-9945 (which uses `ISO 9945 Kernel Clock`) and "Darwin Standard" in swift-darwin-standard (which uses `Darwin Kernel Standard`). This is an ecosystem-wide L2 platform-standards convention, not a literal [MOD-012] violation. | FALSE_POSITIVE — documented L2 platform convention |

### Compliance summary per rule

| Rule | Status | Note |
|------|--------|------|
| [MOD-DOMAIN] Factor the Law | ✓ Compliant | Each new target represents a coherent kernel subsystem (Clock, File, Directory, …) — matches iso-9945 decomposition axis. |
| [MOD-001] Core Layer | ✓ Compliant | `Windows Kernel Standard Core` exists, is internal-only (not in products list), holds the Windows.Kernel namespace typealias + Descriptor veneer + Error. Every Kernel target depends on Core. Note: a second, slimmer Core (`Windows Standard Core` — just the `Windows` namespace enum) exists for the non-Kernel targets (Identity, Interop, Loader, Memory). Two-tier Core is pragmatic given that Kernel-adjacent and non-Kernel targets have different transitive dependency needs. |
| [MOD-002] External Dep Centralization | ✓ Compliant (with exception) | Core holds the cross-cutting primitives (Kernel Primitives Core, Descriptor, Error). Per-domain primitives (Clock, File, Thread, …) are declared on the specific variant — matches iso-9945 exactly. This is the [MOD-002] exception case: "Variant targets MAY directly depend on external packages when they need … conformances that cannot be provided transitively." |
| [MOD-003] Variant Decomposition | ✓ Compliant | All 13 Kernel variants + Identity + Interop are independent. No inter-variant dependencies. Single axis: kernel subsystem. |
| [MOD-004] Constraint Isolation | N/A | No `~Copyable` generic parameters at the target level. |
| [MOD-005] Umbrella Re-export | ✗ See findings #2, #3, #4, #5, #7 | Multiple issues: stale umbrella, missing `public`, 4 Kernel targets + 2 standalone targets lack Exports.swift, Core's SPI re-exports may be over-broad. |
| [MOD-006] Dependency Minimization | ✓ Compliant | Each target declares specific deps. No target depends on the umbrella. |
| [MOD-007] Dependency Graph Shape | ✓ Compliant | Max depth 2 (Core → Variant). 13 wide variants = excellent build parallelism (Brent: max ~6.5× theoretical speedup). |
| [MOD-008] Split Decision Criteria | ✓ Compliant | Each variant satisfies "independent consumer value" criterion — a downstream package could import Windows_Kernel_Time_Standard alone. |
| [MOD-009] Inline Variant Satellite | N/A | No heap/inline variant pairs in this package. |
| [MOD-010] Stdlib Integration Module | N/A | No stdlib-extension target; none of the Kernel files extend Swift stdlib types. |
| [MOD-011] Test Support Product | ✗ See finding #6 | Missing. |
| [MOD-012] Target Naming | Partial — see finding #10 | Ecosystem L2 platform-standards convention deviates from literal [MOD-012]. |
| [MOD-013] Semantic Group Markers | ✓ Mostly — see finding #9 | Present for all source targets; missing the tests marker. |
| [MOD-014] Cross-Package Integration via Traits | N/A | No cross-package trait-gated integration; not applicable to this L2 platform-standards package. |
| [MOD-015] Consumer Import Precision | N/A (provider-side) | Rule applies to consumers. Provider's responsibility: correctly classify decomposition type. This package is **primary decomposition** — variants are independently useful modules along the kernel-subsystem axis. Consumers MUST import specific variants (`Windows_Kernel_Clock_Standard`) not the umbrella. Finding #2 would undermine even the aggregated-import fallback consumers expect from [MOD-015a] shadow-disambiguation. |
| [MOD-015a] Narrow-Imports Shadow Exception | N/A (provider-side) | The umbrella's broken re-export list (finding #2) would also defeat shadow-disambiguation imports when a consumer needs the umbrella as a declared-module anchor. |
| [MOD-016] @_spi Per-File Opt-In | ✗ See finding #1 | One CRITICAL violation in Core's `Windows.Kernel.swift`. 23 other moved-file SPI-import strips are safe — those files don't access SPI members. |
| [MOD-EXCEPT-001] Platform Packages | N/A | Exemption lists L1 (`swift-windows-primitives`) and L3 (`swift-windows`). swift-windows-standard is L2 (Standards) and not exempted. The decomposition (commit `9f6bb5a`) demonstrates that [MOD-EXCEPT-001]'s "1-8 files per target, no shared types" rationale does NOT apply here — each domain has 1-13 files and shares Kernel.Descriptor / Kernel.Error from Core. |

### Systemic patterns

1. **Boilerplate-block vestiges**: the pre-split Core had a 13-line `@_spi(Syscall) public import Kernel_*_Primitives` boilerplate block copy-pasted into every file, most of which didn't use SPI members. The decomposition stripped the dead lines. In one case (`Windows.Kernel.swift`) the strip was too aggressive — the file genuinely needed `@_spi(Syscall) public import Kernel_Descriptor_Primitives` for the Descriptor veneer. Finding #1.

2. **Inconsistent Exports.swift coverage**: 9 of 15 source targets have an `Exports.swift` (the ones created or updated in commits `5e5dc95` and `9f6bb5a`). The 4 pre-existing Kernel sub-targets (File, IO, Memory Map, Socket) plus Loader and Memory Standard lack the re-export file. The ecosystem pattern (iso-9945, and the new targets in this package) consistently includes one. Findings #4, #5.

3. **Stale umbrella**: the Kernel umbrella's exports list was not updated when 8 new narrow Kernel targets were added in commit `9f6bb5a`. The umbrella target's dependency list in Package.swift DID get updated, but the corresponding `@_exported import` statements in `exports.swift` did not. Findings #2, #3.

4. **Ecosystem L2 standards-package naming**: the `X Standard` suffix pattern used by swift-windows-standard parallels swift-darwin-standard (`Darwin Standard Core`, `Darwin Kernel Event Standard`, etc.) and deviates from the literal [MOD-012] L2 row. This is an ecosystem-wide L2 platform-standards convention, probably warrants codification as an addition to [MOD-012] or a new [MOD-EXCEPT-*] rule.

### Summary

10 findings: 2 CRITICAL, 2 HIGH, 4 MEDIUM, 2 LOW.

**Critical fixes block Windows CI** (finding #1) and **break narrow-import consumption** of the aggregated umbrella (finding #2). Findings #3, #4 weaken [MOD-005]'s re-export guarantee and should be addressed in the same remediation pass. Findings #5-#8 are quality-of-life MEDIUM items. Findings #9-#10 are LOW.

The decomposition commit `9f6bb5a` delivered the structural work correctly — 13 narrow Kernel targets, Core slimmed from 14 to 4 deps, consistent re-export pattern for all new targets. The critical misses are (a) the umbrella was not updated in lockstep with the new targets, (b) four pre-existing Kernel targets were not retrofitted to match the new Exports.swift pattern, and (c) one Core file lost a genuinely-needed `@_spi(Syscall)` import during boilerplate cleanup.

### Recommended remediation order

1. Restore `@_spi(Syscall) public import Kernel_Descriptor_Primitives` in `Windows.Kernel.swift` (unblocks Windows CI).
2. Rewrite `Sources/Windows Kernel Standard/exports.swift` to re-export all 13 Kernel sub-targets with `@_exported public import` (each line).
3. Add `Exports.swift` to File, IO, Memory Map, Socket, Loader, Memory Standard targets.
4. Audit Core's SPI re-export surface — decide whether `Kernel_Descriptor_Primitives` and friends should be re-exported `@_spi(Syscall)` (current) or non-SPI, given the Core is itself a package-wide foundation.
5. Publish `Windows Standard Test Support` library product.
6. Create `Audits/_index.md`.
7. Add `// MARK: - Tests` marker before testTargets.

---

## Legacy — Consolidated 2026-04-08

### From: swift-institute/Research/audit-primitives.md (2026-04-03)

**Pre-publication dependency-tree audit — P0/P1/P2 checks**

#### P2: Methods in Type Body [API-IMPL-008]

All in `Sources/Windows Kernel Primitives/`:

| File | Items in body |
|------|---------------|
| `Kernel.IO.Completion.Port.swift` | 10 |
| `Kernel.IO.Completion.Port.Dequeue.swift` | 7 |
| `Kernel.IO.Completion.Port.Cancel.swift` | 7 |

**Assessment**: Platform packages consistently define methods inside struct/enum bodies rather than using extensions. This appears to be a systematic pattern in the platform layer, possibly because these are thin syscall wrappers where the extension pattern adds overhead without benefit.

**Recommendation**: Consider as a batch cleanup across all platform packages, but lower priority since these are platform-specific code.

---

### From: swift-institute/Research/audits/implementation-naming-2026-03-20/swift-windows-primitives.md (2026-03-20)

**Implementation + naming audit**

HIGH=0, MEDIUM=30, LOW=9, INFO=5
Finding IDs: IMPL-002, PATTERN-017, WIN-001, WIN-002, WIN-003, WIN-004, WIN-005, WIN-006, WIN-007, WIN-008, WIN-009, WIN-010, WIN-011, WIN-012, WIN-013 (+31 more)
