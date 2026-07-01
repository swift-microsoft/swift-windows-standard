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

extension Windows.`32`.Kernel.Socket.Shutdown {
    /// Specifies which half of the connection to shut down.
    public enum How: Int32, Sendable {
        /// Shut down the read side of the connection.
        case read = 0  // SHUT_RD

        /// Shut down the write side of the connection.
        case write = 1  // SHUT_WR

        /// Shut down both read and write sides.
        case both = 2  // SHUT_RDWR
    }
}
