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

import Equation_Primitives_Core

extension Windows.`32`.Kernel.Descriptor: Equation.`Protocol` {
    @inlinable
    public static func == (
        lhs: borrowing Windows.`32`.Kernel.Descriptor,
        rhs: borrowing Windows.`32`.Kernel.Descriptor
    ) -> Bool {
        lhs._raw == rhs._raw
    }
}
