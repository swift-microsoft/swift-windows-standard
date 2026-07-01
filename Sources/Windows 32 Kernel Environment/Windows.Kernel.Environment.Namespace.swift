// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Windows.`32`.Kernel {
    /// Environment variable access.
    ///
    /// Mirrors `ISO_9945.Kernel.Environment`. Wraps
    /// `GetEnvironmentVariableW` / `SetEnvironmentVariableW` /
    /// `GetEnvironmentStringsW`.
    ///
    /// ## Thread Safety
    ///
    /// Environment variable access is NOT thread-safe at this level.
    /// Higher-level packages (swift-environment) provide synchronized access.
    public enum Environment {}
}
