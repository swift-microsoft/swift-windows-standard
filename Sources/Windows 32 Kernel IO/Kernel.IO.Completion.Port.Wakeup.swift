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

// Tier 5-Windows-Event Direction (iii) parity-completeness add (2026-05-02):
// adds a `wakeup(_:) -> @Sendable () -> Void` signal-closure constructor on
// `Windows.`32`.Kernel.IO.Completion.Port` that mirrors the
// `Linux.Kernel.Event.Poll.wakeup(eventfd:)` and
// `ISO_9945.Kernel.Event.Queue.wakeup()` shapes used by the L3-unifier
// `Kernel.Wakeup.Channel(signal:)` constructor at swift-kernel.
//
// ## Direction (iii) — architectural-minimalist disposition
//
// Per principal Q4 disposition for the Tier 5-Windows-Mirror sub-envelope,
// `Kernel.Event` remains POSIX-only on Windows. The Windows IOCP paradigm
// is **proactor-style completion** (the OS reports "I/O finished, here are
// the bytes"), not **reactor-style readiness** (the OS reports "the fd is
// readable, do the read yourself"). These paradigms are not interchangeable
// and bridging them across the cross-platform `Kernel.Event` surface would
// either degrade Windows performance or impose a Linux/Darwin-shaped reactor
// API on consumers who should be using IOCP directly. Cross-platform
// proactor consumers use `Kernel.Completion` (the natural home for IOCP);
// cross-platform reactor consumers see `.unsupportedPlatform` on Windows
// and migrate to `Kernel.Completion`.
//
// ## Why this wrapper exists despite Direction (iii)
//
// The signal-closure parity precedent at L1 `Kernel.Wakeup.Channel` is
// paradigm-agnostic — it carries an opaque `@Sendable () -> Void` signal
// that can wake up *any* blocked OS primitive, not just reactor poll loops.
// Linux uses it for epoll wakeup (eventfd-driven), Darwin uses it for
// kqueue wakeup (EVFILT_USER-driven), and Windows uses it for IOCP wakeup
// (PostQueuedCompletionStatus with sentinel values). This wrapper supplies
// the Windows-side L2 constructor so cross-platform consumers building on
// `Kernel.Wakeup.Channel` (e.g., for clean shutdown of blocking
// `GetQueuedCompletionStatus*` calls) have parity coverage on Windows
// without depending on the absent `Kernel.Event` surface.

#if os(Windows)
public import WinSDK

extension Windows.`32`.Kernel.IO.Completion.Port {
    /// Creates a Sendable signal closure for cross-thread IOCP interruption.
    ///
    /// Captures the port's raw HANDLE bit pattern into a `@Sendable` closure
    /// that, when invoked from any thread, posts a sentinel completion packet
    /// via `PostQueuedCompletionStatus` (0 bytes transferred, 0 completion
    /// key, NULL OVERLAPPED). Threads blocked in `GetQueuedCompletionStatus`
    /// or `GetQueuedCompletionStatusEx` will wake and observe the sentinel
    /// packet, allowing graceful shutdown.
    ///
    /// L3 consumers wrap the returned closure into
    /// `Kernel.Wakeup.Channel(signal:)` at the site of use; the closure
    /// carries the raw HANDLE capture so L3 callers never see `_rawValue`
    /// (typed-everywhere discipline per [PLAT-ARCH-008j]).
    ///
    /// ## Sentinel pattern
    ///
    /// The returned closure posts `(bytes: 0, key: 0, overlapped: nil)` —
    /// the canonical Win32 IOCP shutdown idiom. Consumers must distinguish
    /// shutdown packets from real completions by checking for this sentinel
    /// shape (e.g., a NULL `lpOverlapped` field).
    ///
    /// ## Errors
    ///
    /// Construction never throws — IOCP wakeup requires no per-port
    /// registration (unlike epoll's `EPOLL_CTL_ADD`-on-eventfd or kqueue's
    /// `EV_ADD` on `EVFILT_USER`). Errors during signal invocation
    /// (e.g., `ERROR_INVALID_HANDLE` if the port was closed during
    /// shutdown) are silently suppressed inside the closure, matching
    /// the `EBADF`/`ENOENT` suppression in
    /// `ISO_9945.Kernel.Event.Queue.wakeup()`.
    ///
    /// - Parameter port: The completion port handle.
    /// - Returns: A `@Sendable` signal closure.
    @unsafe
    @inlinable
    public static func wakeup(
        _ port: borrowing Windows.`32`.Kernel.Descriptor
    ) -> @Sendable () -> Void {
        let rawPort = port._rawValue
        return {
            _ = unsafe PostQueuedCompletionStatus(
                UnsafeMutableRawPointer(bitPattern: rawPort)!,
                0,    // dwNumberOfBytesTransferred — sentinel
                0,    // dwCompletionKey — sentinel
                nil   // lpOverlapped — sentinel
            )
            // Errors during shutdown ignored — benign if port already closed.
        }
    }
}

#endif
