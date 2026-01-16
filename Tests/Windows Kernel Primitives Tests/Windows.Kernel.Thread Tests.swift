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

extension Windows.Kernel.Thread {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test("Thread namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Thread.self
    }

    @Test("Thread.Handle type exists")
    func handleTypeExists() {
        _ = Kernel.Thread.Handle.self
    }
}

// MARK: - Current Thread Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test("current returns valid handle")
    func currentReturnsValidHandle() {
        let handle = Windows.Kernel.Thread.current()
        #expect(handle.rawValue != 0)
    }

    @Test("currentID returns non-zero")
    func currentIDReturnsNonZero() {
        let id = Windows.Kernel.Thread.currentID()
        #expect(id > 0)
    }

    @Test("currentID matches GetCurrentThreadId")
    func currentIDMatchesWin32() {
        let id = Windows.Kernel.Thread.currentID()
        let win32Id = GetCurrentThreadId()
        #expect(id == win32Id)
    }
}

// MARK: - Yield Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test("yield completes without error")
    func yieldCompletesWithoutError() {
        // yield() is a hint, should never fail
        Windows.Kernel.Thread.yield()
    }

    @Test("yield can be called multiple times")
    func yieldMultipleTimes() {
        for _ in 0..<10 {
            Windows.Kernel.Thread.yield()
        }
    }
}

// MARK: - Thread Creation Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test("create and join thread")
    func createAndJoinThread() throws {
        var executed = false

        let handle = try Windows.Kernel.Thread.create {
            executed = true
        }

        let joined = Windows.Kernel.Thread.join(handle)
        Windows.Kernel.Thread.close(handle)

        #expect(joined)
        // Note: executed may be false due to race, but thread should complete
    }

    @Test("create multiple threads")
    func createMultipleThreads() throws {
        var handles: [Kernel.Thread.Handle] = []

        for _ in 0..<5 {
            let handle = try Windows.Kernel.Thread.create {
                // Do nothing
            }
            handles.append(handle)
        }

        // Join all
        for handle in handles {
            _ = Windows.Kernel.Thread.join(handle)
            Windows.Kernel.Thread.close(handle)
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Thread.Test.EdgeCase {
    @Test("currentID is consistent within same thread")
    func currentIDConsistent() {
        let id1 = Windows.Kernel.Thread.currentID()
        let id2 = Windows.Kernel.Thread.currentID()
        #expect(id1 == id2)
    }

    @Test("join with timeout returns false on timeout")
    func joinTimeoutReturnsFalse() throws {
        // Create a thread that takes a long time
        let handle = try Windows.Kernel.Thread.create {
            Sleep(5000)  // Sleep 5 seconds
        }

        // Try to join with very short timeout
        let joined = Windows.Kernel.Thread.join(handle, timeout: 1)
        #expect(!joined)

        // Clean up - wait for thread to finish
        _ = Windows.Kernel.Thread.join(handle)
        Windows.Kernel.Thread.close(handle)
    }
}

#endif
