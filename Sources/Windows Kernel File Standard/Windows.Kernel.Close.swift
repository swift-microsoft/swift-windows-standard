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

@_spi(Syscall) public import Kernel_Descriptor_Primitives

#if os(Windows)
internal import WinSDK
#endif

// MARK: - Windows CloseHandle — spec-literal raw

extension Kernel.Close {
    /// Raw Windows `CloseHandle` syscall.
    ///
    /// Spec-literal: takes a HANDLE, returns the BOOL result. Zero policy:
    /// NO `GetLastError` read, NO error mapping, NO throwing. The caller
    /// inspects the return value and reads the last error on failure if
    /// needed.
    ///
    /// L3-policy throwing wrappers (`Windows.Kernel.Close.close(_:)` in
    /// swift-windows) compose this raw call with last-error-to-
    /// `Kernel.Close.Error` mapping per [PLAT-ARCH-008e]. L1 syscall
    /// callers MUST NOT call this function directly; the L1 → L3-policy →
    /// L2 chain is mandatory.
    ///
    /// - Parameter handle: HANDLE to close.
    /// - Returns: `true` on success, `false` on failure (use
    ///   `GetLastError` to inspect the error code).
    @_spi(Syscall)
    public static func close(_ handle: UInt) -> Bool {
        #if os(Windows)
        guard let pointer = UnsafeMutableRawPointer(bitPattern: handle) else {
            return false
        }
        return CloseHandle(pointer)
        #else
        return false
        #endif
    }
}
