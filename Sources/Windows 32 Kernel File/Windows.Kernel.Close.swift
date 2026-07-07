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

// MARK: - Windows CloseHandle — spec-literal raw

extension Windows.`32`.Kernel.Close {
    /// Raw Windows `CloseHandle` syscall.
    ///
    /// Spec-literal: takes a HANDLE, returns the BOOL result. Zero policy:
    /// NO `GetLastError` read, NO error mapping, NO throwing.
    ///
    /// **Internal scope only.** Per [PLAT-ARCH-008l] (Wave 4c-deinit-helper,
    /// 2026-05-01), L2 deinit-context APIs use the typed throwing form via
    /// `try?`; raw `(_ handle: UInt) -> Bool` companion forms are not L2
    /// public surface. The typed form (`close(_:consuming Descriptor)` at
    /// `Windows 32 Kernel Core/Windows.Kernel.Close.swift`) inlines
    /// `CloseHandle` directly — this raw form is retained at internal scope
    /// for future delegation use.
    ///
    /// - Parameter handle: HANDLE to close.
    /// - Returns: `true` on success, `false` on failure (use
    ///   `GetLastError` to inspect the error code).
    internal static func close(_ handle: UInt) -> Bool {
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
