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

public import Path_Primitives

// MARK: - Windows Error Code Mapping

extension Path.Resolution.Error {
    /// Creates an error from a Windows error code, if it maps to a path resolution error.
    ///
    /// - Parameter code: The platform error code.
    /// - Returns: The semantic error, or nil if the code doesn't map to a path resolution error.
    @inlinable
    public init?(code: Kernel.Error.Code) {
        switch code {
        case .Windows.ERROR_FILE_NOT_FOUND, .Windows.ERROR_PATH_NOT_FOUND:
            self = .notFound
        case .Windows.ERROR_FILE_EXISTS, .Windows.ERROR_ALREADY_EXISTS:
            self = .exists
        case .Windows.ERROR_DIRECTORY:
            self = .isDirectory
        case .Windows.ERROR_DIR_NOT_EMPTY:
            self = .notEmpty
        case .Windows.ERROR_NOT_SAME_DEVICE:
            self = .crossDevice
        default:
            return nil
        }
    }
}
#endif
