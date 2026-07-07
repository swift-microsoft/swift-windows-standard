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

    // MARK: - Windows.`32`.Kernel.Thread.Handle structural anchor (post-Tier-5-Windows-Mirror, 2026-05-02)
    //
    // L2 spec form per [PLAT-ARCH-005] L2-canonical-where-spec-layer-exists +
    // [PLAT-ARCH-008k] Spec/Policy Namespace Split. Hosts the Win32 thread
    // handle wrapper used by `Windows.\`32\`.Kernel.Thread.{create,join,close,current}`
    // (declared at `Windows.Kernel.Thread.swift`).
    //
    // **Pre-existing condition**: the four syscall wrappers reference
    // `Windows.\`32\`.Kernel.Thread.Handle` (return type of `create` / `current`,
    // parameter of `join` / `close`) but the type was never declared. Same
    // structural-anchor-completion shape as Tier 5-Windows-FOS+Affinity-Combined
    // Phase 3 L2-side work (commit `d36c9fe` — Windows.\`32\`.Kernel.Thread
    // namespace anchor). Tier 5-Windows-Event close-report flagged this as a
    // "deferred follow-up cycle outside the Tier 5-Windows-Mirror sub-envelope".
    //
    // **Shape rationale (mechanically derived from existing references)**:
    // - `RawRepresentable` with `RawValue == UInt` — matches the `Self(rawValue:
    //   UInt(bitPattern: _handle))` reassignment at `Windows.Kernel.Thread.swift:145`.
    //   Windows HANDLE is a pointer-sized opaque value, hence UInt (not UInt32).
    // - **Copyable** (NOT `~Copyable`) — the `self = Self(...)` reassignment in
    //   the package init requires Copyable.
    // - **No RAII close** — `current()` returns a pseudo-handle from
    //   `GetCurrentThread()` which the Windows API specifies must NOT be closed
    //   (per `Windows.Kernel.Thread.swift:120` doc-comment); RAII would
    //   incorrectly call CloseHandle on it. Ownership API is the explicit
    //   `close(_:)` static method.
    // - Mirrors `Windows.\`32\`.Kernel.Thread.ID` shape (RawRepresentable struct,
    //   no RAII) which is the closest precedent in the same namespace.

    extension Windows.`32`.Kernel.Thread {
        /// Opaque OS thread handle on Windows.
        ///
        /// Wraps a Win32 `HANDLE` (pointer-sized opaque value) as `UInt` to
        /// avoid leaking the platform typedef into the public API. Returned by
        /// `Windows.\`32\`.Kernel.Thread.create()` (real handle) and
        /// `Windows.\`32\`.Kernel.Thread.current()` (pseudo-handle).
        ///
        /// ## Ownership
        ///
        /// **Not** RAII — Handle does not call `CloseHandle` on drop. Real
        /// handles (from `create()`) must be explicitly released via
        /// `Windows.\`32\`.Kernel.Thread.close(_:)`. Pseudo-handles (from
        /// `current()`) must NOT be closed; the Windows API documents
        /// `GetCurrentThread()` as returning a non-closeable pseudo-handle.
        ///
        /// The explicit-close convention matches Windows API ergonomics; the
        /// distinction between real and pseudo handles cannot be encoded in
        /// the type without sacrificing the existing call-site ergonomics.
        public struct Handle: Sendable, RawRepresentable, Hashable {
            /// The Win32 HANDLE bit-pattern as `UInt`. Pointer-sized; on
            /// 64-bit Windows this is `UInt64`, on 32-bit Windows `UInt32`.
            public let rawValue: UInt

            @inlinable
            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
        }
    }

#endif
