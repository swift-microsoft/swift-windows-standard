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

public import Windows_32_Kernel

extension Windows.`32`.Kernel {
    /// Namespace for Windows-specific test utilities.
    ///
    /// Host for helpers shared across `Windows Kernel Standard Tests` and any
    /// downstream package that imports `Windows_32_Kernel_Test_Support`.
    /// Start with literal conformances, temporary-path helpers, or thread
    /// harnesses here as concrete test needs surface — the iso-9945 and
    /// darwin-standard analogs (`ISO 9945 Kernel Test Support`,
    /// `Darwin Kernel Standard Test Support`) are the naming/pattern precedents.
    public enum Test {}
}
