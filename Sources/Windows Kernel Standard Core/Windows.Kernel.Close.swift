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

#if os(Windows)
internal import WinSDK
#endif

extension Windows.Kernel {
    /// Windows handle close operations.
    public enum Close: Sendable {}
}

extension Windows.Kernel.Close {
    /// Close a Windows handle, reporting errors.
    ///
    /// Consumes the descriptor: after this call, the descriptor is destroyed.
    /// The deinit does NOT double-close — the descriptor is disarmed before
    /// the syscall.
    ///
    /// - Parameter descriptor: The handle to close (consumed).
    /// - Throws: ``Error`` on failure.
    public static func close(_ descriptor: consuming Windows.Kernel.Descriptor) throws(Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        let raw = descriptor._raw
        // Disarm: deinit will see !isValid and skip.
        descriptor._raw = ~0

        #if os(Windows)
        guard unsafe CloseHandle(UnsafeMutableRawPointer(bitPattern: raw)!) else {
            throw .platform(Error_Primitives.Error(code: .win32(GetLastError())))
        }
        #endif
    }
}
