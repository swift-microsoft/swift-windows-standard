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

// MARK: - Windows Error Code Mapping

extension Windows.Kernel.Lock.Error {
    /// Creates a lock error from a Windows error code, if applicable.
    ///
    /// - Parameter code: The kernel error code.
    /// - Returns: A lock error, or `nil` if not applicable.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .Windows.ERROR_LOCK_VIOLATION:
            self = .contention
        default:
            return nil
        }
    }
}
#endif
