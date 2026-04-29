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

extension Kernel.IO.Error {
    /// Creates an error from a Windows error code, if applicable.
    ///
    /// Returns `nil` if the error code doesn't map to an I/O error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: An I/O error, or `nil` if not applicable.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        switch code {
        case .Windows.ERROR_BROKEN_PIPE:
            self = .broken
        case .win32(1167):  // ERROR_DEVICE_NOT_CONNECTED — closest stable Win32 analogue for hardware I/O failure
            self = .hardware
        default:
            return nil
        }
    }
}
#endif
