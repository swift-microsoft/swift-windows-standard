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

public import Error_Primitives

extension Windows.`32`.Kernel.File {
    /// File position seeking operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Seek`. Wraps `SetFilePointerEx()`.
    /// The reference point is expressed via ``Origin`` (the POSIX-specific
    /// raw `Whence` carrier is not mirrored — Windows expresses the move
    /// method directly from `Origin`).
    public enum Seek: Sendable {}
}

// MARK: - Error

extension Windows.`32`.Kernel.File.Seek {
    /// Errors that can occur during seek operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor is invalid.
        case invalidDescriptor

        /// The resulting offset would be negative.
        case negativeOffset

        /// The file descriptor refers to a pipe, socket, or FIFO.
        case notSeekable

        /// The resulting offset is too large for the file.
        case overflow

        /// Platform-specific error.
        case platform(code: Error_Primitives.Error.Code)
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.File.Seek.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalidDescriptor:
            return "Invalid file descriptor"
        case .negativeOffset:
            return "Resulting offset would be negative"
        case .notSeekable:
            return "File descriptor is not seekable (pipe, socket, or FIFO)"
        case .overflow:
            return "Resulting offset would overflow"
        case .platform(let code):
            return "Seek failed: \(code)"
        }
    }
}
