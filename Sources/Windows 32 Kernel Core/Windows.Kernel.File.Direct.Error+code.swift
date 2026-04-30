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

// MARK: - Windows Translation from Syscall

extension Windows.`32`.Kernel.File.Direct.Error {
    /// Creates a semantic error from a raw syscall error.
    public init(from syscall: Syscall) {
        switch syscall {
        case .invalidDescriptor:
            self = .invalidHandle

        case .alignmentViolation(let operation):
            self = .platform(code: .win32(0xFFFFFFFF), operation: operation)

        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    /// Maps a Windows error code to a semantic error.
    @usableFromInline
    internal init(code: Error_Primitives.Error.Code, operation: Operation) {
        // Windows: most direct-IO errors surface as ERROR_INVALID_PARAMETER (87)
        // or ERROR_NOT_SUPPORTED (50). Without a clean POSIX-style mapping,
        // route Windows codes to .platform.
        self = .platform(code: code, operation: operation)
    }
}
#endif
