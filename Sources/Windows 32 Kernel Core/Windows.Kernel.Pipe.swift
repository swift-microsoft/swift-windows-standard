// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Windows.`32`.Kernel {
    /// Anonymous pipe operations for inter-process communication.
    ///
    /// Creates unidirectional byte streams for communication. Data written
    /// to the write end can be read from the read end. Pipes are commonly
    /// used for parent-child process I/O redirection (`CreateProcess`-time
    /// stdio inheritance) and producer-consumer patterns.
    ///
    /// ## Descriptor Lifecycle
    ///
    /// Both descriptors must be closed explicitly via
    /// ``Windows/32/Kernel/Close/close(_:)``. Close the write end to signal
    /// EOF to readers. Close the read end to cause writes to fail with
    /// `ERROR_BROKEN_PIPE`.
    ///
    /// ## v2 scope
    ///
    /// The v2 surface ships anonymous pipes via `CreatePipe`. Named pipes
    /// (server / client API, message-mode, overlapped I/O) are reserved
    /// for v3 advanced redirection. See ``Windows/32/Kernel/Pipe/Named``
    /// for the named-pipe API which remains under construction.
    public enum Pipe: Sendable {}
}

// MARK: - Pipe.Error

extension Windows.`32`.Kernel.Pipe {
    /// Errors from anonymous pipe operations.
    ///
    /// Cases mirror the POSIX iso-9945 ``ISO_9945/Kernel/Pipe/Error``
    /// shape for cross-platform consumer compatibility.
    public enum Error: Swift.Error, Sendable {
        /// Handle validity error (descriptor exhaustion, invalid handle).
        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)

        /// Other platform error not classified as handle.
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Pipe.Error: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.handle(let l), .handle(let r)): return l == r
        case (.platform(let l), .platform(let r)): return l == r
        default: return false
        }
    }
}

extension Windows.`32`.Kernel.Pipe.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
