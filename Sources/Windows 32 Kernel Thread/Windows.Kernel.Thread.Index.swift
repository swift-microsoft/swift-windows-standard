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

    // MARK: - Windows Thread Local Storage Index

    extension Windows.`32`.Kernel.Thread {
        /// Per-thread storage index — a policy-free wrapper around the
        /// Windows `TlsAlloc` / `TlsSetValue` / `TlsGetValue` / `TlsFree`
        /// family.
        ///
        /// Spec-mirrors the Windows "TLS index" terminology (`DWORD`
        /// returned by `TlsAlloc`) per [API-NAME-003]. The L3 unifier
        /// ``Kernel/Thread/Local`` wraps this raw index with typed payload
        /// accessors and the `Unmanaged` retain/release dance — per
        /// [PLAT-ARCH-008f] solution (a), the L2 raw type uses the
        /// spec-literal name to free `Local` for the L3 typed wrapper.
        ///
        /// Each `Index` instance owns one platform-allocated TLS index. The
        /// index is freed on `deinit`. The slot stores an
        /// `UnsafeMutableRawPointer?` per thread; consumers cast to/from
        /// their typed payload at the boundary (or use the L3 generic
        /// `Windows.`32`.Kernel.Thread.Local<Payload>` which encapsulates the cast).
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
        /// let index = Windows.`32`.Kernel.Thread.Index()
        /// index.value = UnsafeMutableRawPointer(...)
        /// // ... synchronous code on the same thread reads `index.value` ...
        /// ```
        public final class Index: @unchecked Sendable {
            private var index: DWORD

            /// Allocates a new TLS index.
            public init() {
                self.index = TlsAlloc()
            }

            deinit {
                _ = TlsFree(index)
            }
        }
    }

    extension Windows.`32`.Kernel.Thread.Index {
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

#endif
