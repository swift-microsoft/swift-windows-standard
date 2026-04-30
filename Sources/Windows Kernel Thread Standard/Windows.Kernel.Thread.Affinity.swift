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

#if os(Windows)

internal import WinSDK

// MARK: - Set Mask

// Adds L2 syscall wrappers to the existing cross-platform
// `Windows.Kernel.Thread.Affinity` struct defined in swift-kernel-primitives.
// Consumers at L3 (`swift-windows`'s `Windows.Thread.Affinity`) delegate
// here per [PLAT-ARCH-008c].

extension Windows.Kernel.Thread.Affinity {
    /// Sets the CPU affinity mask for the calling thread via `SetThreadAffinityMask`.
    ///
    /// ## Processor Groups
    ///
    /// This operates on the calling thread's current processor group; CPUs
    /// must fit in 0–63. For multi-group systems, `SetThreadGroupAffinity`
    /// would be needed (not wrapped here).
    ///
    /// - Parameter cores: Set of logical CPU IDs (0–63).
    /// - Throws:
    ///   - `.tooManyCPUs` if any core is 64 or greater (or the set is empty).
    ///   - `.platform(.win32(code))` if `SetThreadAffinityMask` returns 0.
    public static func setMask(
        cores: Set<Int>
    ) throws(Windows.Kernel.Thread.Affinity.Error) {
        guard let maxCPU = cores.max(), maxCPU < 64 else {
            throw .tooManyCPUs
        }

        var mask: DWORD_PTR = 0
        for cpu in cores {
            mask |= DWORD_PTR(1) << cpu
        }

        let result = unsafe SetThreadAffinityMask(GetCurrentThread(), mask)
        guard result != 0 else {
            throw .platform(.win32(GetLastError()))
        }
    }
}

#endif
