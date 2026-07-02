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

// MARK: - Windows Error Conversion

extension Windows.`32`.Kernel.File.Clone.Error {
    /// Maps a Windows error code to a semantic error.
    ///
    /// - Note: This is SPI for platform-specific packages.
    /// Maps a raw syscall failure to the semantic error. Mirrors
    /// `ISO_9945.Kernel.File.Clone.Error.init(from:)` per [PLAT-ARCH-008c].
    public init(from syscall: Syscall) {
        switch syscall {
        case .notSupported:
            self = .notSupported
        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    @_spi(Syscall)
    public init(code: Error_Primitives.Error.Code, operation: Operation) {
        switch code {
        case _ where code == .Windows.ERROR_FILE_NOT_FOUND:
            self = .sourceNotFound
        case _ where code == .Windows.ERROR_FILE_EXISTS,
             _ where code == .Windows.ERROR_ALREADY_EXISTS:
            self = .destinationExists
        case _ where code == .Windows.ERROR_ACCESS_DENIED:
            self = .permissionDenied
        case _ where code == .Windows.ERROR_NOT_SAME_DEVICE:
            self = .crossDevice
        default:
            self = .platform(code: code, operation: operation)
        }
    }
}
#endif
