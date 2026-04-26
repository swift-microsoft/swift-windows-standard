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

extension Kernel.Descriptor.Validity.Error {
    /// Creates an error from a Windows error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to a handle error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: A handle error, or `nil` if not applicable.
    @inlinable
    public init?(code: Kernel.Error.Code) {
        switch code {
        case .Windows.ERROR_INVALID_HANDLE:
            self = .invalid
        case .Windows.ERROR_TOO_MANY_OPEN_FILES:
            self = .limit(.process)
        default:
            return nil
        }
    }
}
#endif
