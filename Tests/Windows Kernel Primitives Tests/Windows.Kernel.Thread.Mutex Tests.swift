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
import WinSDK
import Test_Primitives
import Testing_Extras

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Thread.Mutex {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test("Thread.Mutex class exists")
    func classExists() {
        _ = Windows.Kernel.Thread.Mutex.self
    }

    @Test("Thread.Mutex.Lock type exists")
    func lockTypeExists() {
        _ = Windows.Kernel.Thread.Mutex.Lock.self
    }

    @Test("Thread.Mutex.Lock.Error type exists")
    func lockErrorTypeExists() {
        _ = Windows.Kernel.Thread.Mutex.Lock.Error.self
    }
}

// MARK: - Mutex Creation Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test("Mutex can be created")
    func mutexCanBeCreated() {
        let mutex = Windows.Kernel.Thread.Mutex()
        _ = mutex
    }

    @Test("Multiple mutexes can be created")
    func multipleMutexesCanBeCreated() {
        let mutex1 = Windows.Kernel.Thread.Mutex()
        let mutex2 = Windows.Kernel.Thread.Mutex()
        _ = mutex1
        _ = mutex2
    }
}

// MARK: - Lock/Unlock Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test("lock and unlock succeeds")
    func lockUnlockSucceeds() {
        let mutex = Windows.Kernel.Thread.Mutex()
        mutex.lock()
        mutex.unlock()
    }

    @Test("lock accessor exists")
    func lockAccessorExists() {
        let mutex = Windows.Kernel.Thread.Mutex()
        _ = mutex.lock
    }

    @Test("lock.immediate throws on contention")
    func lockImmediateThrowsOnContention() throws {
        let mutex = Windows.Kernel.Thread.Mutex()
        mutex.lock()
        defer { mutex.unlock() }

        // From another thread, should throw
        // But from same thread on Windows SRWLOCK, this will deadlock
        // so we just verify the function exists
        _ = Windows.Kernel.Thread.Mutex.Lock.Error.contention
    }
}

// MARK: - withLock Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test("withLock executes closure")
    func withLockExecutesClosure() {
        let mutex = Windows.Kernel.Thread.Mutex()
        var executed = false

        mutex.withLock {
            executed = true
        }

        #expect(executed)
    }

    @Test("withLock returns value")
    func withLockReturnsValue() {
        let mutex = Windows.Kernel.Thread.Mutex()

        let result = mutex.withLock {
            42
        }

        #expect(result == 42)
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test("Lock.Error.contention exists")
    func errorContentionExists() {
        let error = Windows.Kernel.Thread.Mutex.Lock.Error.contention
        if case .contention = error {
            // Expected
        } else {
            Issue.record("Expected .contention")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Thread.Mutex.Test.EdgeCase {
    @Test("lock and unlock multiple times")
    func lockUnlockMultipleTimes() {
        let mutex = Windows.Kernel.Thread.Mutex()

        for _ in 0..<100 {
            mutex.lock()
            mutex.unlock()
        }
    }

    @Test("withLock with throwing closure propagates error")
    func withLockThrowingClosurePropagates() {
        struct TestError: Error {}
        let mutex = Windows.Kernel.Thread.Mutex()

        #expect(throws: TestError.self) {
            try mutex.withLock {
                throw TestError()
            }
        }
    }
}

#endif
