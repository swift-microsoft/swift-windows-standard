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

// MARK: - Windows.`32`.Kernel.Thread namespace anchor (Tier 5-Windows-FOS+Affinity-Combined Phase 3, 2026-05-02)
//
// L2 spec form per [PLAT-ARCH-005] L2-canonical-where-spec-layer-exists +
// [PLAT-ARCH-008k] Spec/Policy Namespace Split. Hosts thread primitives
// (`Index`, `ID`, `Affinity`, `Affinity.{Kind,Error,Failure,Support}`) and
// the syscall wrappers (`create`, `join`, `close`, `yield`, `current`).
// Mirrors the `ISO_9945.Kernel.Thread` shape as a nominally distinct type
// (Windows is not POSIX per [PLAT-ARCH-007]).
//
// The anchor was missing in the post-Wave-1.9 + post-Wave-2 state — the
// existing `Windows.Kernel.Thread.{Index,ID,Affinity,...}.swift` files all
// extend the namespace but none declared it. Path X G6.D refinement pulled
// `Windows.Kernel` apart but did not consolidate the L2 spec form anchors.

extension Windows.`32`.Kernel {
    /// Root namespace for Win32 thread APIs (L2 spec form).
    public enum Thread: Sendable {}
}

// MARK: - Windows Thread Creation

extension Windows.`32`.Kernel.Thread {
    /// Creates a new OS thread.
    ///
    /// This is the low-level thread creation syscall wrapper. The closure
    /// is invoked exactly once on the spawned OS thread.
    ///
    /// - Parameter body: The work to run on the new thread.
    /// - Returns: A handle to the created thread.
    /// - Throws: `Windows.`32`.Kernel.Thread.Error` if thread creation fails.
    @inlinable
    public static func create(
        _ body: @escaping @Sendable () -> Void
    ) throws(Windows.`32`.Kernel.Thread.Error) -> Windows.`32`.Kernel.Thread.Handle {
        let context = UnsafeMutablePointer<(@Sendable () -> Void)>.allocate(capacity: 1)
        context.initialize(to: body)

        let threadProc: LPTHREAD_START_ROUTINE = { ctx in
            guard let ctx else { return 0 }
            let bodyPtr = ctx.assumingMemoryBound(to: (@Sendable () -> Void).self)
            let work = bodyPtr.move()
            bodyPtr.deallocate()
            work()
            return 0
        }

        let handle = CreateThread(
            nil,  // default security attributes
            0,    // default stack size
            threadProc,
            context,
            0,    // run immediately
            nil   // don't need thread ID
        )

        guard let handle else {
            context.deinitialize(count: 1)
            context.deallocate()
            throw .create(Error_Primitives.Error(code: Error_Primitives.Error.captureLastError()))
        }

        return Windows.`32`.Kernel.Thread.Handle(_handle: handle)
    }

    /// Waits for a thread to terminate.
    ///
    /// - Parameters:
    ///   - handle: The thread handle to wait on.
    ///   - timeout: Maximum time to wait in milliseconds, or `INFINITE` for no timeout.
    /// - Returns: `true` if the thread terminated, `false` if timed out.
    @inlinable
    public static func join(
        _ handle: Windows.`32`.Kernel.Thread.Handle,
        timeout: DWORD = INFINITE
    ) -> Bool {
        let result = WaitForSingleObject(handle._handle, timeout)
        return result == WAIT_OBJECT_0
    }

    /// Closes a thread handle.
    ///
    /// - Parameter handle: The thread handle to close.
    @inlinable
    public static func close(_ handle: Windows.`32`.Kernel.Thread.Handle) {
        _ = CloseHandle(handle._handle)
    }
}

// MARK: - Thread Yield

extension Windows.`32`.Kernel.Thread {
    /// Yields execution to the OS scheduler as a hint.
    ///
    /// This is a policy-free wrapper around `SwitchToThread`.
    @inlinable
    public static func yield() {
        _ = SwitchToThread()
    }
}

// MARK: - Current Thread

extension Windows.`32`.Kernel.Thread {
    /// Returns the handle of the current thread.
    ///
    /// Note: This returns a pseudo-handle that doesn't need to be closed.
    @inlinable
    public static func current() -> Windows.`32`.Kernel.Thread.Handle {
        Windows.`32`.Kernel.Thread.Handle(_handle: GetCurrentThread())
    }

    /// Returns the ID of the current thread.
    ///
    /// - Note: Prefer `Windows.`32`.Kernel.Thread.ID.current` — the portable, typed
    ///   equivalent that works across platforms. This Windows-specific
    ///   overload remains for parity with the Windows API surface but
    ///   new code should use the cross-platform form.
    @available(*, deprecated, message: "Use Windows.`32`.Kernel.Thread.ID.current for portable, typed thread identity.")
    @inlinable
    public static func currentID() -> DWORD {
        GetCurrentThreadId()
    }
}

// MARK: - Thread Handle Extension

extension Windows.`32`.Kernel.Thread.Handle {
    /// Creates a handle from a Windows HANDLE.
    @inlinable
    package init(_handle: HANDLE) {
        self = Self(rawValue: UInt(bitPattern: _handle))
    }

    /// The underlying Windows HANDLE.
    @inlinable
    package var _handle: HANDLE {
        HANDLE(bitPattern: Int(rawValue))!
    }
}

// MARK: - Instance join / identity (ISO parity)

extension Windows.`32`.Kernel.Thread.Handle {
    /// Whether this handle refers to the calling thread.
    ///
    /// Mirrors `ISO_9945.Kernel.Thread.Handle.isCurrent`. `GetThreadId`
    /// resolves pseudo-handles to the calling thread, so this is correct
    /// for handles from both `create()` and `current()`.
    public var isCurrent: Bool {
        GetThreadId(_handle) == GetCurrentThreadId()
    }

    /// Waits for the thread to finish and releases the handle.
    ///
    /// Mirrors `ISO_9945.Kernel.Thread.Handle.join()` (consuming: the
    /// handle is closed and must not be reused).
    public consuming func join() {
        _ = WaitForSingleObject(_handle, INFINITE)
        _ = CloseHandle(_handle)
    }

    /// Releases the handle without waiting for the thread.
    ///
    /// Mirrors `ISO_9945.Kernel.Thread.Handle.detach()` (consuming: the
    /// handle must not be reused). Windows has no detached-thread state —
    /// closing the last handle is the analog: the thread keeps running
    /// and the OS reclaims its resources when it exits.
    public consuming func detach() {
        _ = CloseHandle(_handle)
    }
}

#endif
