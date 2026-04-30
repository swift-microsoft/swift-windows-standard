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

import Hash_Primitives_Core

extension Windows.Kernel.Descriptor: Hash.`Protocol` {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        _raw.hash(into: &hasher)
    }
}
