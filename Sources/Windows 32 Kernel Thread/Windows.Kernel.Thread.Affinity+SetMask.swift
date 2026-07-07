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
    //
    // L2 syscall wrapper for `SetThreadAffinityMask`. Recreated from the
    // Wave 1.9 deleted-commit blueprint (`02617ff`) per Tier 5-Windows-Mirror
    // sub-envelope authorization. The orphan diagnosis in the original commit
    // has been resolved: `Windows.`32`.Kernel.Thread.Affinity` now exists as a
    // canonical struct in this target (sibling `Windows.Kernel.Thread.Affinity.swift`)
    // per [PLAT-ARCH-005] L2-canonical-where-spec-layer-exists.

    extension Windows.`32`.Kernel.Thread.Affinity {
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
        ) throws(Windows.`32`.Kernel.Thread.Affinity.Error) {
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
