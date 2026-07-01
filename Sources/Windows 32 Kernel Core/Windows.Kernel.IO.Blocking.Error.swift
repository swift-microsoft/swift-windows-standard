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

extension Windows.`32`.Kernel.IO.Blocking {
    /// Blocking-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Operation would block on a non-blocking descriptor.
        /// - POSIX: `EAGAIN`, `EWOULDBLOCK`
        ///
        /// The caller should wait for the descriptor to become ready
        /// (e.g., via poll/select/kqueue/epoll) and retry.
        case wouldBlock
    }
}

// MARK: - CustomStringConvertible

extension Windows.`32`.Kernel.IO.Blocking.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .wouldBlock:
            return "operation would block"
        }
    }
}
