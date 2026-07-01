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
    /// Permission domain - access control errors.
    ///
    /// These errors indicate the calling process lacks sufficient
    /// permissions to perform the requested operation.
    public enum Permission: Sendable {}
}
