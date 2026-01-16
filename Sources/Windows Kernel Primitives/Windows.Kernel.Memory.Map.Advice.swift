// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
@_spi(Syscall) public import Kernel_Primitives

// MARK: - Windows Memory Advice Constants
//
// Windows does not have an equivalent to POSIX madvise().
// These constants are provided for API compatibility but the
// advise() function is a no-op on Windows.

extension Kernel.Memory.Map.Advice {
    /// Normal access pattern (no-op on Windows).
    public static var normal: Self {
        Self(rawValue: 0)
    }

    /// Sequential access pattern (no-op on Windows).
    public static var sequential: Self {
        Self(rawValue: 1)
    }

    /// Random access pattern (no-op on Windows).
    public static var random: Self {
        Self(rawValue: 2)
    }

    /// Pages will be needed soon (no-op on Windows).
    public static var willNeed: Self {
        Self(rawValue: 3)
    }

    /// Pages won't be needed soon (no-op on Windows).
    public static var dontNeed: Self {
        Self(rawValue: 4)
    }
}

#endif
