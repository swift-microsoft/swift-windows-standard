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

public import Cardinal_Primitives
public import Tagged_Primitives

extension Windows.`32`.Kernel {
    /// Hard link operations.
    ///
    /// Mirrors `ISO_9945.Kernel.Link`. Wraps `CreateHardLinkW()`.
    public enum Link {}
}

// MARK: - Count

extension Windows.`32`.Kernel.Link {
    /// Hard link count for a file.
    public typealias Count = Tagged<Windows.`32`.Kernel.Link, Cardinal>
}
