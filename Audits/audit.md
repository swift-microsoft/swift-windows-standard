# Audit: swift-windows-primitives

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
