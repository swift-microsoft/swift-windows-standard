// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import WinSDK

// MARK: - Windows FlushFileBuffers syscall (raw @_spi(Syscall))

extension Windows.Kernel.File.Flush {
    /// Flushes file buffers to disk for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `FlushFileBuffers`. The typed L2 convenience
    /// (`flush(_:)` taking `Kernel.Descriptor`) delegates to this raw SPI
    /// internally via `descriptor._rawValue` after a fast-fail validity
    /// check.
    ///
    /// Ensures that all buffered data for the specified file has been
    /// written to the underlying storage device.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    @_spi(Syscall)
    public static func flush(_ handle: UInt) throws(Kernel.File.Flush.Error) {
        guard FlushFileBuffers(UnsafeMutableRawPointer(bitPattern: handle)!) else {
            throw .current()
        }
    }
}

// MARK: - Typed Convenience

extension Windows.Kernel.File.Flush {
    /// Flushes file buffers to disk.
    ///
    /// Typed L2 form. Delegates to the raw `flush(_:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// Per Escalation 3 resolution (2026-04-29): NO `@_disfavoredOverload`
    /// is required. Empirical re-check confirmed
    /// `Kernel.File.Flush+CrossPlatform.Windows.swift` defines `data(_:)` and
    /// `directory(path:)` only — no method-name overlap with this file's
    /// `flush(_:)`/`flushData(_:)`. Per [PLAT-ARCH-008e] empty-tier
    /// exception, the unifier `Kernel.File.Flush.flush(_:)` is inherited
    /// from this L2 form via `Windows.Kernel == Kernel` namespace identity.
    ///
    /// - Parameter descriptor: The file descriptor to flush.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func flush(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Flush.Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        try flush(descriptor._rawValue)
    }

    /// Flushes file data to disk (same as flush on Windows).
    ///
    /// Typed L2 form. Delegates to the raw `flush(_:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// On Windows, there is no distinction between flushing data and
    /// metadata. Both operations flush all data and metadata.
    ///
    /// - Parameter descriptor: The file descriptor to flush.
    /// - Throws: `Kernel.File.Flush.Error` on failure.
    public static func flushData(_ descriptor: Kernel.Descriptor) throws(Kernel.File.Flush.Error) {
        try flush(descriptor)
    }
}

// MARK: - Error Construction

extension Kernel.File.Flush.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(e)
        }
        if let e = Kernel.IO.Error(code: code) {
            return .io(e)
        }
        return .platform(Kernel.Error(code: code))
    }
}

#endif
