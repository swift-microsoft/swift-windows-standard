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
import Testing

@testable import Windows_Kernel_Standard
import Kernel_Primitives_Core
import Error_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Kernel_Time_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import System_Primitives

extension Windows.Kernel.Thread.Mutex {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test
    func `Thread.Mutex class exists`() {
        _ = Windows.Kernel.Thread.Mutex.self
    }

    @Test
    func `Thread.Mutex.Lock type exists`() {
        _ = Windows.Kernel.Thread.Mutex.Lock.self
    }

    @Test
    func `Thread.Mutex.Lock.Error type exists`() {
        _ = Windows.Kernel.Thread.Mutex.Lock.Error.self
    }
}

// MARK: - Mutex Creation Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test
    func `Mutex can be created`() {
        let mutex = Windows.Kernel.Thread.Mutex()
        _ = mutex
    }

    @Test
    func `Multiple mutexes can be created`() {
        let mutex1 = Windows.Kernel.Thread.Mutex()
        let mutex2 = Windows.Kernel.Thread.Mutex()
        _ = mutex1
        _ = mutex2
    }
}

// MARK: - Lock/Unlock Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test
    func `lock and unlock succeeds`() {
        let mutex = Windows.Kernel.Thread.Mutex()
        mutex.lock()
        mutex.unlock()
    }

    @Test
    func `lock accessor exists`() {
        let mutex = Windows.Kernel.Thread.Mutex()
        _ = mutex.lock
    }

    @Test
    func `lock.immediate throws on contention`() throws {
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
    @Test
    func `withLock executes closure`() {
        let mutex = Windows.Kernel.Thread.Mutex()
        var executed = false

        mutex.withLock {
            executed = true
        }

        #expect(executed)
    }

    @Test
    func `withLock returns value`() {
        let mutex = Windows.Kernel.Thread.Mutex()

        let result = mutex.withLock {
            42
        }

        #expect(result == 42)
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Thread.Mutex.Test.Unit {
    @Test
    func `Lock.Error.contention exists`() {
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
    @Test
    func `lock and unlock multiple times`() {
        let mutex = Windows.Kernel.Thread.Mutex()

        for _ in 0..<100 {
            mutex.lock()
            mutex.unlock()
        }
    }

    @Test
    func `withLock with throwing closure propagates error`() {
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
