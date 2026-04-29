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

extension Kernel.Permission.Error {
    /// Creates an error from a Windows error code, if it maps to a permission error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: The semantic error, or nil if the code doesn't map to a permission error.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .Windows.ERROR_ACCESS_DENIED:
            self = .denied
        case .Windows.ERROR_WRITE_PROTECT:
            self = .readOnlyFilesystem
        default:
            return nil
        }
    }
}
#endif
