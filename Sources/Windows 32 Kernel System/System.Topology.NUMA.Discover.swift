// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import System_Primitives

#if os(Windows)
internal import WinSDK

extension System.Topology.NUMA {
    /// Discovers NUMA topology via the Win32 NUMA API.
    ///
    /// Uses `GetNumaHighestNodeNumber` and `GetNumaNodeProcessorMask` /
    /// `GetNumaNodeProcessorMaskEx` to discover NUMA nodes and their CPU
    /// assignments. Group-affinity-aware via `GetNumaNodeProcessorMaskEx`
    /// when available; falls back to the legacy `GetNumaNodeProcessorMask`
    /// (single-group systems only) when the extended form fails.
    ///
    /// ## Spec authority
    ///
    /// Win32 API (Microsoft). NUMA support is part of the Windows kernel
    /// system topology surface.
    ///
    /// ## Return Values
    ///
    /// - `.uniformAccess`: Single NUMA node (UMA system)
    /// - `.nonUniform(nodes:)`: Multiple NUMA nodes
    /// - `.unavailable`: Discovery failed
    ///
    /// ## Architecture
    ///
    /// Per [PLAT-ARCH-008j], the WinSDK import lives at L2 internal scope.
    /// The public surface mirrors the Linux-side L2 pattern at
    /// `swift-linux-foundation/swift-linux-standard/Sources/Linux Kernel
    /// System Standard/System.Topology.NUMA.Discover.swift` —
    /// `extension System.Topology.NUMA { public static func discover() -> State }`.
    /// Typed Windows-native NUMA shapes (`Mask`, `GroupAffinity`, etc.)
    /// remain file-private; promotion to a public
    /// `Windows.\`32\`.Kernel.System.Topology.NUMA` namespace is deferred
    /// until consumer demand surfaces (Wave 4a-NUMA Option C, 2026-05-01).
    public static func discover() -> System.Topology.NUMA.State {
        var highestNode: ULONG = 0
        guard GetNumaHighestNodeNumber(&highestNode) else {
            return .unavailable
        }

        var nodes: [System.Topology.NUMA.Node] = []

        for nodeID in 0...Int(highestNode) {
            guard let cpus = getCPUsForNode(UCHAR(nodeID)) else {
                continue
            }

            nodes.append(System.Topology.NUMA.Node(
                id: nodeID,
                cpus: cpus,
                isSynthetic: false
            ))
        }

        switch nodes.count {
        case 0:
            return .unavailable
        case 1:
            return .uniformAccess
        default:
            return .nonUniform(nodes: nodes)
        }
    }

    private static func getCPUsForNode(_ nodeNumber: UCHAR) -> Set<Int>? {
        var groupAffinity = GROUP_AFFINITY()

        guard GetNumaNodeProcessorMaskEx(nodeNumber, &groupAffinity) else {
            var mask: ULONGLONG = 0
            guard GetNumaNodeProcessorMask(nodeNumber, &mask) else {
                return nil
            }
            return maskToCPUSet(mask, groupOffset: 0)
        }

        let groupOffset = Int(groupAffinity.Group) * 64
        return maskToCPUSet(groupAffinity.Mask, groupOffset: groupOffset)
    }

    private static func maskToCPUSet(_ mask: KAFFINITY, groupOffset: Int) -> Set<Int> {
        var cpus = Set<Int>()
        var remaining = mask

        for bit in 0..<64 {
            if remaining & 1 != 0 {
                cpus.insert(groupOffset + bit)
            }
            remaining >>= 1
            if remaining == 0 { break }
        }

        return cpus
    }
}
#else
extension System.Topology.NUMA {
    /// Non-Windows fallback. Win32 NUMA API not available.
    ///
    /// On non-Windows platforms this overload is unused — Linux NUMA
    /// discovery lives at `swift-linux-foundation/swift-linux-standard`,
    /// Darwin returns `.unavailable` at `swift-foundations/swift-darwin`.
    /// This stub exists so the L2 module compiles cleanly on non-Windows
    /// hosts.
    public static func discover() -> System.Topology.NUMA.State {
        .unavailable
    }
}
#endif
