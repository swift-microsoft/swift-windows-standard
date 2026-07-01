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

extension Windows.`32`.Kernel.IO {
    /// I/O operation errors.
    ///
    /// Cases mirror the POSIX iso-9945 surface for cross-platform consumer compatibility.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Broken pipe — peer closed the connection.
        /// - Windows: `ERROR_BROKEN_PIPE`
        case broken

        /// Connection reset by peer.
        /// - Windows: `WSAECONNRESET`
        case reset

        /// Physical I/O error.
        /// - Windows: `ERROR_IO_DEVICE`
        case hardware

        /// Illegal seek on non-seekable descriptor.
        /// - Windows: `ERROR_INVALID_FUNCTION` (approximate)
        case illegalSeek

        /// Device does not support the operation.
        /// - Windows: `ERROR_NOT_SUPPORTED`
        case deviceUnsupported

        /// Device not configured or unavailable.
        /// - Windows: `ERROR_DEV_NOT_EXIST`
        case deviceUnavailable

        /// Operation not supported on this type.
        /// - Windows: `ERROR_NOT_SUPPORTED`
        case unsupported
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.IO.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .broken:
            return "broken pipe"
        case .reset:
            return "connection reset"
        case .hardware:
            return "I/O error"
        case .illegalSeek:
            return "illegal seek"
        case .deviceUnsupported:
            return "operation not supported by device"
        case .deviceUnavailable:
            return "device unavailable"
        case .unsupported:
            return "operation not supported"
        }
    }
}
