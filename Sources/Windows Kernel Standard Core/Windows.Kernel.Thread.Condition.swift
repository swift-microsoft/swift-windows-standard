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
@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import WinSDK

// MARK: - Windows Thread Condition Variable

extension Windows.Kernel.Thread {
    /// A low-level condition variable for thread synchronization.
    ///
    /// This is a policy-free wrapper around Windows `CONDITION_VARIABLE`.
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because it provides internal synchronization.
    ///
    /// ## Usage
    /// Condition variables are always used with a mutex:
    /// ```swift
    /// let mutex = Windows.Kernel.Thread.Mutex()
    /// let condition = Windows.Kernel.Thread.Condition()
    ///
    /// // Waiting thread:
    /// mutex.lock()
    /// while !ready {
    ///     condition.wait(mutex: mutex)
    /// }
    /// // ... process ...
    /// mutex.unlock()
    ///
    /// // Signaling thread:
    /// mutex.lock()
    /// ready = true
    /// condition.signal()
    /// mutex.unlock()
    /// ```
    public final class Condition: @unchecked Sendable {
        private var cond: CONDITION_VARIABLE

        /// Creates a new condition variable.
        public init() {
            self.cond = CONDITION_VARIABLE()
            InitializeConditionVariable(&self.cond)
        }

        // CONDITION_VARIABLE doesn't need destruction
    }
}

// MARK: - Wait Operations

extension Windows.Kernel.Thread.Condition {
    /// Waits on the condition variable.
    ///
    /// The mutex is atomically released while waiting and reacquired before returning.
    ///
    /// - Parameter mutex: The mutex to release while waiting.
    /// - Precondition: The mutex must be held by the current thread.
    public func wait(mutex: Windows.Kernel.Thread.Mutex) {
        _ = mutex.withUnsafeMutablePointer { mutexPtr in
            SleepConditionVariableSRW(&cond, mutexPtr, INFINITE, 0)
        }
    }

    /// Waits on the condition variable with a timeout.
    ///
    /// The mutex is atomically released while waiting and reacquired before returning.
    ///
    /// - Parameters:
    ///   - mutex: The mutex to release while waiting.
    ///   - timeout: Maximum time to wait.
    /// - Returns: `true` if signaled, `false` if timed out.
    /// - Precondition: The mutex must be held by the current thread.
    public func wait(mutex: Windows.Kernel.Thread.Mutex, timeout: Duration) -> Bool {
        mutex.withUnsafeMutablePointer { mutexPtr in
            let (seconds, attoseconds) = timeout.components
            let totalMs = seconds * 1000 + attoseconds / 1_000_000_000_000_000
            let ms = DWORD(min(totalMs, Int64(DWORD.max - 1)))

            return SleepConditionVariableSRW(&cond, mutexPtr, ms, 0)
        }
    }

    /// Waits on the condition variable with a timeout in milliseconds.
    ///
    /// - Parameters:
    ///   - mutex: The mutex to release while waiting.
    ///   - milliseconds: Maximum time to wait in milliseconds.
    /// - Returns: `true` if signaled, `false` if timed out.
    public func wait(mutex: Windows.Kernel.Thread.Mutex, milliseconds: DWORD) -> Bool {
        mutex.withUnsafeMutablePointer { mutexPtr in
            SleepConditionVariableSRW(&cond, mutexPtr, milliseconds, 0)
        }
    }
}

// MARK: - Signal Operations

extension Windows.Kernel.Thread.Condition {
    /// Signals one waiting thread.
    ///
    /// If multiple threads are waiting, one is unblocked (which one is unspecified).
    public func signal() {
        WakeConditionVariable(&cond)
    }

    /// Signals all waiting threads.
    ///
    /// All threads waiting on this condition variable are unblocked.
    public func broadcast() {
        WakeAllConditionVariable(&cond)
    }
}

#endif
