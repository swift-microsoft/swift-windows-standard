// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - Windows.`32`.Kernel.Thread.Affinity (Tier 5-Windows-FOS+Affinity-Combined Phase 1)
//
// Tier 5-Windows-Mirror sub-envelope (2026-05-02): recreates the canonical
// Windows-side Affinity struct + nested Kind/Error/Failure/Support sub-types
// at swift-windows-32 L2 per [PLAT-ARCH-005] L2-canonical-where-spec-layer-exists
// + [PLAT-ARCH-008k] Spec/Policy Namespace Split. Mirrors the
// `ISO_9945.Kernel.Thread.Affinity` shape (see swift-iso-9945 / ISO 9945
// Kernel Thread / Kernel.Thread.Affinity{,.Kind,.Error,.Failure,.Support}.swift)
// as a nominally distinct type because per [PLAT-ARCH-007] swift-windows-32
// cannot import swift-iso-9945 (Windows is not POSIX).
//
// Deleted in Wave 1.9 option-c REMOVE (commit `02617ff`); recreated here per
// principal Tier 5-Windows-FOS+Affinity-Combined dispatch authorization.
//
// L2 syscall wrapper (`setMask(cores:)`) is in the sibling
// `Windows.Kernel.Thread.Affinity+SetMask.swift` file (separated for the
// `#if os(Windows)` WinSDK-bearing extension).
//
// Wrapped in `#if os(Windows)` to match the target convention at swift-windows-32
// (all sibling files in this target — Mutex, Condition, Index, ID, Thread —
// are platform-gated; the parent `Windows.\`32\`.Kernel.Thread` namespace is
// only in scope inside `os(Windows)`).

#if os(Windows)

extension Windows.`32`.Kernel.Thread {
    /// Thread affinity specification.
    ///
    /// Describes which CPUs a thread should be allowed to execute on.
    /// This is a logical model independent of platform-specific APIs
    /// (cpu_set_t on Linux, GROUP_AFFINITY on Windows).
    ///
    /// ## Usage
    /// ```swift
    /// // Allow OS to schedule freely
    /// let any = Windows.`32`.Kernel.Thread.Affinity.any
    ///
    /// // Pin to specific cores
    /// let pinned = Windows.`32`.Kernel.Thread.Affinity.cores([0, 1, 2, 3])
    ///
    /// // Pin to a NUMA node (resolved via System.topology())
    /// let numa = Windows.`32`.Kernel.Thread.Affinity.numaNode(0)
    /// ```
    public struct Affinity: Sendable, Equatable {
        /// The affinity specification.
        public let kind: Kind

        /// Creates an affinity with the specified kind.
        public init(kind: Kind) {
            self.kind = kind
        }
    }
}

extension Windows.`32`.Kernel.Thread.Affinity {
    /// No affinity constraint - OS scheduler decides placement.
    public static let any = Self(kind: .any)

    /// Pin to specific logical CPU cores.
    ///
    /// - Parameter cores: Set of logical CPU IDs (0-based).
    public static func cores(_ cores: some Swift.Sequence<Int>) -> Self {
        Self(kind: .cores(Set(cores)))
    }

    /// Pin to a NUMA node's CPUs.
    ///
    /// The node ID is resolved to specific CPUs via `System.topology()`
    /// at the point of application.
    ///
    /// - Parameter id: NUMA node identifier.
    public static func numaNode(_ id: Int) -> Self {
        Self(kind: .numaNode(id))
    }
}

#endif
