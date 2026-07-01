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

// MARK: - Windows Thread Mutex

extension Windows.`32`.Kernel.Thread {
    /// A low-level mutex for thread synchronization.
    ///
    /// This is a policy-free wrapper around Windows `SRWLOCK` (Slim Reader/Writer Lock)
    /// used in exclusive mode.
    ///
    /// ## Threading
    /// - **lock()**: Blocks the calling thread until the mutex is available
    /// - **lock.immediate()**: Returns immediately, throws on contention
    /// - **unlock()**: Must be called from the thread that acquired the lock
    ///
    /// ## Safety
    /// This type is `@unchecked Sendable` because it provides internal synchronization.
    /// The mutex itself is what makes cross-thread access safe.
    ///
    /// ## Usage
    /// ```swift
    /// let mutex = Windows.`32`.Kernel.Thread.Mutex()
    /// mutex.lock()
    /// defer { mutex.unlock() }
    /// // ... critical section ...
    /// ```
    public final class Mutex: @unchecked Sendable {
        private var srwlock: SRWLOCK

        /// Creates a new mutex.
        public init() {
            self.srwlock = SRWLOCK()
            InitializeSRWLock(&self.srwlock)
        }

        // SRWLOCK doesn't need destruction
    }
}

// MARK: - Lock Operations

extension Windows.`32`.Kernel.Thread.Mutex {
    /// Releases the mutex, allowing other threads to acquire it.
    ///
    /// ## Precondition
    /// The mutex **must** be held by the current thread.
    public func unlock() {
        ReleaseSRWLockExclusive(&srwlock)
    }

    /// Accessor for lock operation variants.
    ///
    /// - `mutex.lock()` - blocking, waits until available
    /// - `try mutex.lock.immediate()` - non-blocking, throws on contention
    public var lock: Lock { Lock(mutex: self) }
}

// MARK: - Lock Accessor

extension Windows.`32`.Kernel.Thread.Mutex {
    /// Lock operation accessor with variants.
    public struct Lock: Sendable {
        let mutex: Windows.`32`.Kernel.Thread.Mutex

        init(mutex: Windows.`32`.Kernel.Thread.Mutex) {
            self.mutex = mutex
        }

        /// Error thrown when a non-blocking lock cannot be acquired.
        public enum Error: Swift.Error, Sendable {
            /// The mutex is held by another thread.
            case contention
        }

        /// Acquires the mutex, blocking until available.
        ///
        /// ## Threading
        /// Blocks the calling thread until the mutex becomes available.
        public func callAsFunction() {
            mutex.acquireBlocking()
        }

        /// Attempts to acquire the mutex without blocking.
        ///
        /// ## Threading
        /// Never blocks. Returns immediately regardless of mutex state.
        ///
        /// - Throws: `Error.contention` if the mutex is held by another thread.
        public func immediate() throws(Error) {
            guard TryAcquireSRWLockExclusive(&mutex.srwlock) != 0 else {
                throw .contention
            }
        }
    }

    /// Internal blocking lock implementation.
    fileprivate func acquireBlocking() {
        AcquireSRWLockExclusive(&srwlock)
    }

    /// Executes a closure while holding the mutex.
    ///
    /// The mutex is automatically acquired before and released after the closure.
    ///
    /// - Parameter body: The closure to execute while holding the mutex.
    /// - Returns: The value returned by the closure.
    /// - Throws: Any error thrown by `body`.
    public func withLock<T, E: Swift.Error>(_ body: () throws(E) -> T) throws(E) -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}

// MARK: - Internal Access for Condition

extension Windows.`32`.Kernel.Thread.Mutex {
    /// Provides access to the underlying platform mutex pointer.
    ///
    /// This is internal API for `Condition` to use when waiting.
    func withUnsafeMutablePointer<T>(_ body: (UnsafeMutablePointer<SRWLOCK>) -> T) -> T {
        Swift.withUnsafeMutablePointer(to: &srwlock, body)
    }
}

#endif
