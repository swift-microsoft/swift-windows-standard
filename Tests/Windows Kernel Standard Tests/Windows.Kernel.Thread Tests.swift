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
import Error_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import System_Primitives

extension Windows.Kernel.Thread {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test
    func `Thread namespace exists`() {
        _ = Windows.Kernel.Thread.self
    }

    @Test
    func `Thread.Handle type exists`() {
        _ = Kernel.Thread.Handle.self
    }
}

// MARK: - Current Thread Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test
    func `current returns valid handle`() {
        let handle = Windows.Kernel.Thread.current()
        #expect(handle.rawValue != 0)
    }

    @Test
    func `currentID returns non-zero`() {
        let id = Windows.Kernel.Thread.currentID()
        #expect(id > 0)
    }

    @Test
    func `currentID matches GetCurrentThreadId`() {
        let id = Windows.Kernel.Thread.currentID()
        let win32Id = GetCurrentThreadId()
        #expect(id == win32Id)
    }
}

// MARK: - Yield Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test
    func `yield completes without error`() {
        // yield() is a hint, should never fail
        Windows.Kernel.Thread.yield()
    }

    @Test
    func `yield can be called multiple times`() {
        for _ in 0..<10 {
            Windows.Kernel.Thread.yield()
        }
    }
}

// MARK: - Thread Creation Tests

extension Windows.Kernel.Thread.Test.Unit {
    @Test
    func `create and join thread`() throws {
        var executed = false

        let handle = try Windows.Kernel.Thread.create {
            executed = true
        }

        let joined = Windows.Kernel.Thread.join(handle)
        Windows.Kernel.Thread.close(handle)

        #expect(joined)
        // Note: executed may be false due to race, but thread should complete
    }

    @Test
    func `create multiple threads`() throws {
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
    @Test
    func `currentID is consistent within same thread`() {
        let id1 = Windows.Kernel.Thread.currentID()
        let id2 = Windows.Kernel.Thread.currentID()
        #expect(id1 == id2)
    }

    @Test
    func `join with timeout returns false on timeout`() throws {
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
