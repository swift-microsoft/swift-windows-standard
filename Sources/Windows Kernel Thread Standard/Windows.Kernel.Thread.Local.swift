// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import WinSDK

// MARK: - Windows Thread Local Storage

extension Windows.Kernel.Thread {
    /// Per-thread storage slot — a policy-free wrapper around the Windows
    /// `TlsAlloc` / `TlsSetValue` / `TlsGetValue` / `TlsFree` family.
    ///
    /// Each `Local` instance owns one platform-allocated TLS index. The
    /// index is freed on `deinit`. The slot stores an
    /// `UnsafeMutableRawPointer?` per thread; consumers cast to/from
    /// their typed payload at the boundary.
    ///
    /// ## Threading
    /// - **value (get)**: Returns the calling thread's slot value, or
    ///   `nil` if the thread has not set one (or has not allocated).
    /// - **value (set)**: Sets the calling thread's slot value.
    ///
    /// ## Safety
    /// `@unchecked Sendable` because TlsSetValue/TlsGetValue are
    /// per-thread by construction — the kernel provides the per-thread
    /// isolation.
    ///
    /// ## Public API surface
    /// Per [PLAT-ARCH-005a], no platform C types appear in the public
    /// API: `DWORD` (TLS index) is internal storage; the slot type is
    /// `UnsafeMutableRawPointer?` (stdlib).
    ///
    /// ## Usage
    /// ```swift
    /// let local = Windows.Kernel.Thread.Local()
    /// local.value = UnsafeMutableRawPointer(...)
    /// // ... synchronous code on the same thread reads `local.value` ...
    /// ```
    public final class Local: @unchecked Sendable {
        private var index: DWORD

        /// Allocates a new TLS index.
        public init() {
            self.index = TlsAlloc()
        }

        deinit {
            _ = TlsFree(index)
        }

        /// The calling thread's slot value. `nil` if the thread has not
        /// set a value, or if the slot was just allocated.
        public var value: UnsafeMutableRawPointer? {
            get {
                TlsGetValue(index)
            }
            set {
                _ = TlsSetValue(index, newValue)
            }
        }
    }
}

#endif
