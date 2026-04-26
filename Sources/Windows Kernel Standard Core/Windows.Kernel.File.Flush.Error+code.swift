// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

// MARK: - Windows Error Code Access

extension Kernel.File.Flush.Error {
    /// The underlying Windows error code.
    @inlinable
    public var code: Kernel.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .io(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}
#endif
