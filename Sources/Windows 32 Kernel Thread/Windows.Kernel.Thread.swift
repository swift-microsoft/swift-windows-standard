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

// MARK: - Windows Thread Creation

extension Windows.Kernel.Thread {
    /// Creates a new OS thread.
    ///
    /// This is the low-level thread creation syscall wrapper. The closure
    /// is invoked exactly once on the spawned OS thread.
    ///
    /// - Parameter body: The work to run on the new thread.
    /// - Returns: A handle to the created thread.
    /// - Throws: `Windows.Kernel.Thread.Error` if thread creation fails.
    @inlinable
    public static func create(
        _ body: @escaping @Sendable () -> Void
    ) throws(Windows.Kernel.Thread.Error) -> Windows.Kernel.Thread.Handle {
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
            throw .create(Error_Primitives.Error.captureLastError())
        }

        return Windows.Kernel.Thread.Handle(_handle: handle)
    }

    /// Waits for a thread to terminate.
    ///
    /// - Parameters:
    ///   - handle: The thread handle to wait on.
    ///   - timeout: Maximum time to wait in milliseconds, or `INFINITE` for no timeout.
    /// - Returns: `true` if the thread terminated, `false` if timed out.
    @inlinable
    public static func join(
        _ handle: Windows.Kernel.Thread.Handle,
        timeout: DWORD = INFINITE
    ) -> Bool {
        let result = WaitForSingleObject(handle._handle, timeout)
        return result == WAIT_OBJECT_0
    }

    /// Closes a thread handle.
    ///
    /// - Parameter handle: The thread handle to close.
    @inlinable
    public static func close(_ handle: Windows.Kernel.Thread.Handle) {
        _ = CloseHandle(handle._handle)
    }
}

// MARK: - Thread Yield

extension Windows.Kernel.Thread {
    /// Yields execution to the OS scheduler as a hint.
    ///
    /// This is a policy-free wrapper around `SwitchToThread`.
    @inlinable
    public static func yield() {
        _ = SwitchToThread()
    }
}

// MARK: - Current Thread

extension Windows.Kernel.Thread {
    /// Returns the handle of the current thread.
    ///
    /// Note: This returns a pseudo-handle that doesn't need to be closed.
    @inlinable
    public static func current() -> Windows.Kernel.Thread.Handle {
        Windows.Kernel.Thread.Handle(_handle: GetCurrentThread())
    }

    /// Returns the ID of the current thread.
    ///
    /// - Note: Prefer `Windows.Kernel.Thread.ID.current` — the portable, typed
    ///   equivalent that works across platforms. This Windows-specific
    ///   overload remains for parity with the Windows API surface but
    ///   new code should use the cross-platform form.
    @available(*, deprecated, message: "Use Windows.Kernel.Thread.ID.current for portable, typed thread identity.")
    @inlinable
    public static func currentID() -> DWORD {
        GetCurrentThreadId()
    }
}

// MARK: - Thread Handle Extension

extension Windows.Kernel.Thread.Handle {
    /// Creates a handle from a Windows HANDLE.
    @_spi(Syscall)
    @inlinable
    public init(_handle: HANDLE) {
        self = Self(rawValue: UInt(bitPattern: _handle))
    }

    /// The underlying Windows HANDLE.
    @_spi(Syscall)
    @inlinable
    public var _handle: HANDLE {
        HANDLE(bitPattern: Int(rawValue))!
    }
}

#endif
