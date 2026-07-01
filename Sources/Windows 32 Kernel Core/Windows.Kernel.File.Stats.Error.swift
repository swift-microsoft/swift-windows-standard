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

extension Windows.`32`.Kernel.File.Stats {
    /// Errors that can occur during stat operations.
    ///
    /// Mirrors `ISO_9945.Kernel.File.Stats.Error`, plus an `io` case for
    /// Win32 I/O failures surfaced by `GetFileInformationByHandle`.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor or handle is invalid.
        case handle(Windows.`32`.Kernel.Descriptor.Validity.Error)

        /// An I/O error occurred while reading file information.
        case io(Windows.`32`.Kernel.IO.Error)

        /// A platform-specific error that doesn't map to a semantic case.
        case platform(Error_Primitives.Error)
    }
}

// MARK: - Stats.Error CustomStringConvertible

extension Windows.`32`.Kernel.File.Stats.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .io(let e): return "io: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}
