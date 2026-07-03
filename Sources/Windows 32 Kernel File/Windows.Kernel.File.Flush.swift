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

extension Windows.`32`.Kernel.File.Flush {
    /// Flushes file buffers to disk for a HANDLE bit pattern.
    ///
    /// Spec-literal raw `FlushFileBuffers`. The typed L2 convenience
    /// (`flush(_:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to this raw SPI
    /// internally via `descriptor._rawValue` after a fast-fail validity
    /// check.
    ///
    /// Ensures that all buffered data for the specified file has been
    /// written to the underlying storage device.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Throws: `Windows.`32`.Kernel.File.Flush.Error` on failure.
        package static func flush(_ handle: UInt) throws(Windows.`32`.Kernel.File.Flush.Error) {
        guard FlushFileBuffers(UnsafeMutableRawPointer(bitPattern: handle)!) else {
            throw .current()
        }
    }
}

// MARK: - Typed Convenience

extension Windows.`32`.Kernel.File.Flush {
    /// Flushes file buffers to disk.
    ///
    /// Typed L2 form. Delegates to the raw `flush(_:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// No favored-overload-disabling attribute is required on this typed
    /// form. Empirical re-check (Escalation 3 resolution, 2026-04-29):
    /// `Windows.`32`.Kernel.File.Flush+CrossPlatform.Windows.swift` defines `data(_:)`
    /// and `directory(path:)` only — no method-name overlap with this
    /// file's `flush(_:)`/`flushData(_:)`. Per [PLAT-ARCH-008e] empty-tier
    /// exception, the unifier `Windows.`32`.Kernel.File.Flush.flush(_:)` is inherited
    /// from this L2 form via `Windows.`32`.Kernel == Kernel` namespace identity.
    ///
    /// - Parameter descriptor: The file descriptor to flush.
    /// - Throws: `Windows.`32`.Kernel.File.Flush.Error` on failure.
    public static func flush(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) throws(Windows.`32`.Kernel.File.Flush.Error) {
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
    /// - Throws: `Windows.`32`.Kernel.File.Flush.Error` on failure.
    public static func flushData(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) throws(Windows.`32`.Kernel.File.Flush.Error) {
        try flush(descriptor)
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.File.Flush.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(e)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}

#endif
